# Configuration Parameters
"""
    sdad_setup!(;db_user::AbstractString = "",
                 db_pwd::AbstractString = "",
                 token::AbstractString = "")
This function writes the configurations to `confs/config.simple`
# Arguments
- `db_user`: Your username for the `postgis_2` [database](http://sdad.policy-analytics.net:8080/?pgsql=postgis_2&db=sdad_data&ns=onet) (i.e., your UVA computing ID).
- `db_pwd`: The password for the `postgis_2` [database](http://sdad.policy-analytics.net:8080/?pgsql=postgis_2&db=sdad_data&ns=onet).
- `onet_auth`: Basic authentication [token](https://services.onetcenter.org/developer/) for the O*Net REST API.
# Examples
## Good!
```
julia> sdad_setup!(db_user = "jbs3hp",
                   db_pwd = "MyVerySafePwd",
                   onet_auth = "ASZ1QqATfYXdOLFnr6EVfxyHymx4kTGMLQgXCs==")
😃
```
## Incomplete!
```
julia> sdad_setup!(db_user = "jbs3hp",
                   db_pwd = "MyVerySafePwd")
Warning: github_login has not been defined.
😞
```
# Updating the configuration file.
```
julia> using ONet
julia> sdad_setup!(db_user = "jbs3hp",
                   db_pwd = "MyVerySafePwd",
                   onet_auth = "ASZ1QqATfYXdOLFnr6EVfxyHymx4kTGMLQgXCs==")
julia> exit()
> julia
julia> using ONet # config up-to-date
```
!!! note
    Updating the configuration file requires a restart of the session.
"""
function sdad_setup!(;db_user::AbstractString = "",
                      db_pwd::AbstractString = "",
                      onet_auth::AbstractString = "")
    args = ["db_user", "db_pwd", "onet_auth"]
    isdir(joinpath(dirname(@__FILE__), "..", "confs")) || mkdir(joinpath(dirname(@__FILE__), "..", "confs"))
    isfile(joinpath(dirname(@__FILE__), "..", "confs", "config.simple")) ||
        touch(joinpath(dirname(@__FILE__), "..", "confs", "config.simple"))
    conf = ConfParse(joinpath(dirname(@__FILE__), "..", "confs", "config.simple"),
                     "simple")
    parse_conf!(conf)
    for (key, val) ∈ zip(args, [db_user, db_pwd, onet_auth])
        isempty(val) || commit!(conf, key, val)
    end
    save!(conf)
    notdefined = filter(key -> !haskey(conf, key),
                        args)
    foreach(key -> @warn("$key has not been defined."),
            notdefined)
    if isinteractive()
        if isempty(notdefined)
            println("😃")
        else
            println("😞")
        end
    end
end
isfile(joinpath(dirname(@__FILE__), "..", "confs", "config.simple")) ||
    sdad_setup!(db_user = get(ENV, "db_user", ""),
                db_pwd = get(ENV, "db_pwd", ""),
                onet_auth = get(ENV, "onet_auth", ""))
const conf = ConfParse(joinpath(dirname(@__FILE__), "..", "confs", "config.simple"),
                       "simple");
parse_conf!(conf);
"""
    db_user::String
The username for the [database](http://sdad.policy-analytics.net:8080/?pgsql=postgis_2&db=sdad_data&ns=onet) (i.e., your UVA computing ID).
"""
const db_user = haskey(conf, "db_user") ? retrieve(conf, "db_user") : "";
"""
    db_pwd::String
The password for the [database](http://sdad.policy-analytics.net:8080/?pgsql=postgis_2&db=sdad_data&ns=onet).
"""
const db_pwd = haskey(conf, "db_pwd") ? retrieve(conf, "db_pwd") : "";
"""
    onet_auth::String
The application O*Net basic authentication token.
"""
const onet_auth = haskey(conf, "onet_auth") ? retrieve(conf, "onet_auth") : "";
"""
    headers = ["Authorization" => "Basic \$onet_auth",
               "Accept" => "application/json"]
Headers to be passed to the ONet REST API.
"""
const headers = ["Authorization" => "Basic $onet_auth",
                 "Accept" => "application/json"]
"""
    db_host = "postgis_2"
Host for the [database](http://sdad.policy-analytics.net:8080/?pgsql=postgis_2&db=sdad_data&schema=onet).
"""
const db_host = "postgis_2";
"""
    db_port = 5432
Port for the `postgis_2` in the [database](http://sdad.policy-analytics.net:8080/?pgsql=postgis_2&db=sdad_data&schema=onet).
"""
const db_port = 5432
"""
    dbname = "sdad_data"
Database for the SDAD data.
"""
const dbname = "sdad_data";
