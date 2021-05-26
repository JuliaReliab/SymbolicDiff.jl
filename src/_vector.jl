"""
SymbolicVector
"""

abstract type AbstractSymbolicVectorMatrix{Tv} <: AbstractSymbolic{Tv} end
abstract type AbstractSymbolicVector{Tv} <: AbstractSymbolicVectorMatrix{Tv} end

struct SymbolicVector{Tv} <: AbstractSymbolicVector{Tv}
    params::Set{Symbol}
    elem::Vector{<:AbstractSymbolic}
end

function symbolic(vec::Vector{<:AbstractSymbolic}, ::Type{Tv} = Float64) where Tv
    params = union([x.params for x = vec]...)
    SymbolicVector{Tv}(params, vec)
end

function _toexpr(x::SymbolicVector)
    args = [_toexpr(e) for e = x.elem]
    Expr(:vect, args...)
end


"""
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(f::SymbolicVector{Tv}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, env, cache) for x = f.elem]
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(f::SymbolicVector{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, dvar, env, cache) for x = f.elem]
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(f::SymbolicVector{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, dvar, env, cache) for x = f.elem]
end
