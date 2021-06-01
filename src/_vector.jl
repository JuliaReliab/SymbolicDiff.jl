"""
SymbolicVector
"""

"""
convert
"""

function Base.convert(::Type{<:AbstractSymbolic{T}}, vec::Vector{<:AbstractSymbolic{S}}) where {T<:Number,S<:Number}
    [convert(AbstractSymbolic{T}, x) for x = vec]
end

"""
for macro
"""

function _toexpr(x::Vector{<:AbstractSymbolic{Tv}}) where Tv
    args = [_toexpr(e) for e = x]
    Expr(:vect, args...)
end


"""
seval(f, env, cache)
Return the value for expr f
"""

function seval(vec::Vector{<:AbstractSymbolic{Tv}}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[seval(x, env, cache) for x = vec]
end

"""
seval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function seval(vec::Vector{<:AbstractSymbolic{Tv}}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[seval(x, dvar, env, cache) for x = vec]
end

"""
seval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function seval(vec::Vector{<:AbstractSymbolic{Tv}}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[seval(x, dvar, env, cache) for x = vec]
end
