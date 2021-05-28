"""
SymbolicVector
"""

# abstract type AbstractSymbolicVectorMatrix{Tv} <: AbstractSymbolic{Tv} end
# abstract type AbstractSymbolicVector{Tv} <: AbstractSymbolicVectorMatrix{Tv} end

# struct SymbolicVector{Tv} <: AbstractSymbolicVector{Tv}
#     params::Set{Symbol}
#     elem::Vector{<:AbstractSymbolic{Tv}}
# end

# function symbolic(vec::Vector{<:AbstractSymbolic{T}}, ::Type{S} = Float64) where {T<:Number,S<:Number}
#     params = union([x.params for x = vec]...)
#     SymbolicVector{S}(params, [convert(AbstractSymbolic{S}, x) for x = vec])
# end

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
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(vec::Vector{<:AbstractSymbolic{Tv}}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, env, cache) for x = vec]
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(vec::Vector{<:AbstractSymbolic{Tv}}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, dvar, env, cache) for x = vec]
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(vec::Vector{<:AbstractSymbolic{Tv}}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, dvar, env, cache) for x = vec]
end
