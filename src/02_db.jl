# Database
"""
    dbconnect()::Connection
Returns a connection to the burning_glass database in postgis_2.
"""
dbconnect() =
    Connection("""
               host = $db_host
               port = $db_port
               dbname = $dbname
               user = $db_user
               password = $db_pwd
               """)

"""
    varschema(variable)::String
Returns a suitable schema for the database declaration from the table information.
"""
function varschema(variable)
    varname = variable.column_id
    format = variable.format
    optional = variable.optional ? "" : "not null"
    if occursin("Character Varying", format)
        datatype = "varchar($(match(r"\d+", format).match))"
    elseif occursin("Character", format)
        datatype = "char($(match(r"\d+", format).match))"
    elseif occursin("Date", format)
        datatype = "date"
    elseif occursin("Float", format)
        precision, scale = getproperty.(eachmatch(r"\d+", format), :match)
        datatype = "numeric($precision, $scale)"
    elseif occursin("Integer", format)
        datatype = "numeric($(match(r"\d+", format).match))"
    end
    "$varname $datatype $optional"
end

"""
    drop_duplicates!(name::AbstractString)
Drop duplicate records from the table.
"""
function drop_duplicates!(name::AbstractString)
    conn = dbconnect()
    execute(conn, "create table onet.$(name)_clean (like onet.$name including all);")
    execute(conn, "insert into onet.$(name)_clean select distinct * from onet.$name;")
    execute(conn, "drop table onet.$(name)")
    execute(conn, "alter table onet.$(name)_clean rename to onet.$name")
    close(conn)
end

"""
    isdone(name::AbstractString)::Bool
Are all available records for that table in the database?
"""
function isdone(name::AbstractString)
    conn = dbconnect()
    output = execute(conn, "select count(*) from (select * from onet.$name) as tmp;") |>
        (tbl -> getproperty.(tbl, :count) |> first) |>
        (n -> n == tbls.count[findfirst(isequal(name), tbls.name)])
    close(conn)
    output
end
