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
symeval(f, cache)
Return the value for expr f
"""

function symeval(vec::Vector{<:AbstractSymbolic{Tv}}, cache::SymbolicCache) where Tv
    Tv[symeval(x, cache) for x = vec]
end

"""
symeval(f, dvar, cache)
Return the first derivative of expr f with respect to dvar
"""

function symeval(vec::Vector{<:AbstractSymbolic{Tv}}, dvar::Symbol, cache::SymbolicCache) where Tv
    Tv[symeval(x, dvar, cache) for x = vec]
end

"""
symeval(f, dvar, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symeval(vec::Vector{<:AbstractSymbolic{Tv}}, dvar::Tuple{Symbol,Symbol}, cache::SymbolicCache) where Tv
    Tv[symeval(x, dvar, cache) for x = vec]
end
