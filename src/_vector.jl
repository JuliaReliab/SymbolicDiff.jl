"""
SymbolicVector
"""

export symbolic, AbstractSymbolicVectorMatrix, AbstractSymbolicVector

import Base

abstract type AbstractSymbolicVectorMatrix <: AbstractSymbolic end
abstract type AbstractSymbolicVector <: AbstractSymbolicVectorMatrix end

struct SymbolicVector <: AbstractSymbolicVector
    params::Set{Symbol}
    elem::Vector{<:AbstractSymbolic}
end

function symbolic(vec::Vector{<:AbstractSymbolic})
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

function symboliceval(f::SymbolicVector, env::SymbolicEnv, cache::SymbolicCache)
    [symboliceval(x, env, cache) for x = f.elem]
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(f::SymbolicVector, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)
    [symboliceval(x, dvar, env, cache) for x = f.elem]
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(f::SymbolicVector, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    [symboliceval(x, dvar, env, cache) for x = f.elem]
end
