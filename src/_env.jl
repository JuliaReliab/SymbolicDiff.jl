"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

const SymbolicEnv = Dict{Symbol,Any}
const SymbolicCache = Dict{Union{AbstractSymbolic,Tuple{AbstractSymbolic,Symbol},Tuple{AbstractSymbolic,Tuple{Symbol,Symbol}}},Any}
const globalenv = SymbolicEnv()

function Base.setindex!(h::SymbolicEnv, x::Any, k::SymbolicVariable{Tv}) where Tv
    h[h.var] = x
end