using Documenter, Weave, ONet

for file ∈ readdir(joinpath(dirname(pathof(ONet)), "..", "docs", "jmd"))
      weave(joinpath(dirname(pathof(ONet)), "..", "docs", "jmd", file),
            out_path = joinpath(dirname(pathof(ONet)), "..", "docs", "src"),
            doctype = "github")
end

makedocs(format = Documenter.HTML(),
         modules = [ONet],
         sitename = "ONet.jl",
         pages = ["Introduction" => "index.md",
                  "Manual" => "manual.md",
                  "API" => "api.md"]
    )

deploydocs(repo = "github.com/uva-bi-sdad/ONet.jl.git")
