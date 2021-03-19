# HumanReadableIDs

Human-readable but randomly generated identifiers.

```
using HumanReadableIDs

julia> using HumanReadableIDs, Random

julia> [randstring(HumanReadableIDs.name_model, 8) for _=1:10]
10-element Vector{String}:
 "Gantandd"
 "Serfrwal"
 "Kilarage"
 "Miemadeu"
 "Sishengi"
 "Phalotil"
 "Mmannody"
 "Caceanan"
 "Htharore"
 "Lietanan"
```

See the [notebook file](notebooks/random_patient_ids.ipynb) for further musings.

[![Build Status](https://github.com/c42f/HumanReadableIDs.jl/workflows/CI/badge.svg)](https://github.com/c42f/HumanReadableIDs.jl/actions)
