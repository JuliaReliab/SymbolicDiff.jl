"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

export SymbolicEnv, SymbolicCache

const SymbolicEnv{Tv} = Dict{Symbol,Tv}
const SymbolicCache = Dict{Union{AbstractSymbolic,Tuple{AbstractSymbolic,Symbol},Tuple{AbstractSymbolic,Tuple{Symbol,Symbol}}},Any}
