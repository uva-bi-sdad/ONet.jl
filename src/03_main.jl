# Working with the API
"""
    createtable!(name)
Creates a table in the database based on the O*NET API specification.
"""
function createtable!(name::AbstractString)
    url = "https://services.onetcenter.org/ws/database/info/$name"
    request = HTTP.get(url, headers)
    @assert request.status == 200
    schema = request.body |> String |> JSON3.read
    tblname = schema.table_id
    datatypes = mapreduce(varschema,
                          (x, y) -> "$x, $y",
                          schema.column)
    vals = mapreduce(x -> "\$$x",
                     (x, y) -> "$x, $y",
                     eachindex(schema.column))
    conn = dbconnect()
    execute(conn, "create table if not exists onet.$tblname($datatypes)")
    close(conn)
    "insert into onet.$tblname values ($vals);"
end

"""
    onettable(table)
Given a table node, it returns a row with the table information.
"""
function onettable(table)
    name = table.table_id
    request = HTTP.get(table.info, headers)
    @assert request.status == 200
    json = request.body |>
        String |>
        JSON3.read
    request = HTTP.get(table.rows, headers)
    @assert request.status == 200
    total = request.body |>
        String |>
        JSON3.read |>
        (obj -> getproperty(obj, :total))
    [ (table_name = name,
       table_description = table.description,
       variable_id = elem.column_id,
       variable_name = elem.title,
       variable_description = elem.description,
       n = total)
       for elem ∈ json.column ]
end

"""
    onettables!()
Uploads a `_metadata` table to the database.
"""
function onettables!()
    request = HTTP.get("https://services.onetcenter.org/ws/database/",
                       headers)
    @assert request.status == 200
    tables = request.body |> String |> JSON3.read |>
        (obj -> getproperty(obj, :table))
    data = onettable(tables[1])
    for table ∈ tables[2:end]
        append!(data, onettable(table))
    end
    vals = mapreduce(x -> "\$$x",
                     (x, y) -> "$x, $y",
                     eachindex(propertynames(output[1])))
    conn = dbconnect()
    execute(conn, """create table if not exists onet.onet_tables (
                     table_name text not null,
                     table_description text not null,
                     variable_id text not null,
                     variable_name text not null,
                     variable_description text not null,
                     n int not null
                     )
                  """)
    statement = "insert into onet.onet_tables values ($vals)"
    execute(conn, "begin;")
    load!(data, conn, statement)
    execute(conn, "commit;")
    close(conn)
end

"""
    processtable!(name::AbstractString)
Adds the table data to the database.
"""
function processtable!(name::AbstractString)
    url = "https://services.onetcenter.org/ws/database/rows/$name"
    request = HTTP.get(url, headers)
    @assert request.status == 200
    json = request.body |>
        String |>
        JSON3.read
    url = replace(json.link[1].href,
                  r"(?<=start=)\d+&end=\d+$" => "1&end=$(json.total)")
    request = HTTP.get(url, headers)
    @assert request.status == 200
    json = request.body |>
        String |>
        JSON3.read
    statement = createtable!(name)
    data = rowtable(json.row) |>
        (tbl -> transform(tbl,
                          Dict(cn => x -> something(x, missing)
                               for cn ∈ eachindex(tbl[1])))) |>
        rowtable
    isdir("/mnt/volume_nyc1_02/onet") || mkdir("/mnt/volume_nyc1_02/onet")
    CSV.write("data.csv", data)
    conn = dbconnect()
    execute(conn, "COPY $name from '/mnt/volume_nyc1_02/onet/data.csv' with (format csv, header)")
    close(conn)
    isfile("/mnt/volume_nyc1_02/onet/data.csv") &&
        rm("/mnt/volume_nyc1_02/onet/data.csv")
    true
end

"""
    onet!()
Runs the application to refresh all the data in the database.
"""
function onet!()
    conn = dbconnect()
    tbls = execute(conn, "select distinct table_name, n from onet.onet_tables") |>
        (tbl -> [(name = elem.table_name, count = elem.n) for elem ∈ tbl]) |>
        columntable
    close(conn)
    foreach(drop_duplicates!, tbls.name)
    to_add = filter(!isdone, tbls.name) |> sort!
    x = rowtable(tbls) |>
        (tbl -> filter(row -> row.name ∈ to_add, tbl)) |>
        (tbl -> sort!(tbl, by = last))
    foreach(processtable!, to_add)
    true
end
