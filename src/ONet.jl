"""
    ONet
Application to upload the ONet data to the database.
"""
module ONet
    using HTTP: HTTP
    using JSON3: JSON3
    using CSV: CSV
    using Tables: columntable, rowtable, schema, transform, rows
    using LibPQ: Connection, execute, load!, CopyIn
    using ConfParser
    # Compat
    if !@isdefined(isnothing)
        isnothing(::Any) = false
        isnothing(::Nothing) = true
    end
    if !@isdefined(ismissing)
        isnothing(::Any) = false
        isnothing(::Missing) = true
    end
    foreach(include,
            file for file ∈ readdir(@__DIR__) if !isequal("ONet.jl", file))
    export sdad_setup!, onet!
    include_dependency(joinpath(dirname(@__FILE__), "..", "confs", "config.simple"))
end
