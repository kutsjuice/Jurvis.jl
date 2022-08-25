# Jurvis

[![Build Status](https://github.com/kutsjuice/Jurvis.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kutsjuice/Jurvis.jl/actions/workflows/CI.yml?query=branch%3Amain)

Package for analysis of nonlinear dynamics

Currently support Hilbert analysis of MDoF system using Singular-Spectrum Analysis for mode decomposition (SSA-HT)

To add package run in REPL
    julia> using Pkg; 
    julia> Pkg.add("https://github.com/kutsjuice/Jurvis.jl");
    julia> Pkg.activate((DEPOT_PATH[1])*"\\dev\\Jurvis")
    