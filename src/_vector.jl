"""
SymbolicVector
"""

export symbolicvector

import Base

abstract type AbstractSymbolicVectorMatrix <: AbstractSymbolic end

struct SymbolicVector <: AbstractSymbolicVectorMatrix
    params::Set{Symbol}
    elem::Vector{<:AbstractSymbolic}
end

function symbolicvector(vec::Vector{<:AbstractSymbolic})
    params = union([x.params for x = vec]...)
    SymbolicVector(params, vec)
end

function _toexpr(x::SymbolicVector)
    args = [_toexpr(e) for e = x.elem]
    Expr(:vect, args...)
end


"""
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(f::SymbolicVector, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, env, cache) for x = f.elem]
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(f::SymbolicVector, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, dvar, env, cache) for x = f.elem]
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(f::SymbolicVector, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, dvar, env, cache) for x = f.elem]
end
