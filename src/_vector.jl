"""
SymbolicVector
"""

mutable struct SymbolicVector{Tv} <: AbstractVectorSymbolic{Tv}
    params::Set{Symbol}
    vec::Vector{<:AbstractNumberSymbolic{Tv}}
    dim::Int
end

mutable struct SymbolicVectorExpression{Tv} <: AbstractVectorSymbolic{Tv}
    params::Set{Symbol}
    op::Symbol
    args::Vector{<:AbstractSymbolic{Tv}}
    dim::Int
    others
end

"""
convert
"""

function Base.convert(::Type{<:AbstractSymbolic{T}}, vec::Vector{<:AbstractNumberSymbolic{T}}) where {T<:Number}
    s = union([u.params for u = vec]...)
    SymbolicVector{T}(s, vec, length(vec))
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, s::SymbolicVector{S}) where {T<:Number,S<:Number}
    v = [convert(AbstractNumberSymbolic{T}, x) for x = s.vec]
    SymbolicVector{T}(s.params, v, length(v))
end

"""
promotion
"""

function Base.promote_rule(::Type{<:AbstractVectorSymbolic{T}}, ::Type{S}) where {T<:Number,S<:Number}
    AbstractVectorSymbolic{promote_type(T,S)}
end

function Base.promote_rule(::Type{<:AbstractVectorSymbolic{T}}, ::Type{<:AbstractVectorSymbolic{S}}) where {T<:Number,S<:Number}
    AbstractVectorSymbolic{promote_type(T,S)}
end

"""
IO for structures
"""

function Base.show(io::IO, x::AbstractVectorSymbolic)
    expr = _toexpr(x)
    Base.show(io, expr)
end

function _toexpr(x::SymbolicVector)
    args = [_toexpr(e) for e = x.vec]
    Expr(:vect, args...)
end

function _toexpr(x::SymbolicVectorExpression)
    args = [_toexpr(e) for e = x.args]
    Expr(:call, x.op, args...)
end

"""
operators
"""

function Base.getindex(x::SymbolicVector{T}, i::Number) where {T<:Number}
    x.vec[i]
end

function Base.getindex(x::SymbolicVector{T}, i::Any) where {T<:Number}
    v = getindex(x.vec, i)
    s = union([u.params for u = v]...)
    SymbolicVector{T}(s, v, length(v))
end

function Base.getindex(x::AbstractVectorSymbolic{T}, i::Number) where {T<:Number}
    SymbolicExpression{T}(x.params, :getindex, [x], [i])
end

function Base.getindex(x::AbstractVectorSymbolic{T}, i::Any) where {T<:Number}
    SymbolicVectorExpression{T}(x.params, :getindex, [x], length(i), [i])
end

# function Base.setindex!(x::SymbolicVector{T}, v::AbstractNumberSymbolic{T}, i::Number) where {T<:Number}
#     x.vec[i] = v
# end

# """
# for macro
# """

# function _toexpr(x::Vector{<:AbstractSymbolic{Tv}}) where Tv
#     args = [_toexpr(e) for e = x]
#     Expr(:vect, args...)
# end


"""
seval(f, env, cache)
Return the value for expr f
"""

function seval(s::SymbolicVector{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where {Tv <: Number}
    Tv[seval(x, env, cache) for x = s.vec]
end

function seval(f::AbstractVectorSymbolic{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    get(cache, f) do
        retval = _eval(Val(f.op), f, env, cache)
        cache[f] = retval
    end
end

"""
seval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function seval(s::SymbolicVector{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where {Tv <: Number}
    Tv[seval(x, dvar, env, cache) for x = s.vec]
end

function seval(f::AbstractVectorSymbolic{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    (dvar in f.params) || return zeros(Tv, f.dim)
    get(cache, (f,dvar)) do
        retval = _eval(Val(f.op), f, dvar, env, cache)
        cache[(f,dvar)] = retval
    end
end

"""
seval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function seval(s::SymbolicVector{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where {Tv <: Number}
    Tv[seval(x, dvar, env, cache) for x = s.vec]
end

function seval(f::AbstractVectorSymbolic{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    (dvar[1] in f.params) || (dvar[2] in f.params) || return zeros(Tv, f.dim)
    get(cache, (f,dvar)) do
        retval = _eval(Val(f.op), f, dvar, env, cache)
        cache[(f,dvar)] = retval
    end
end

"""
seval for vec
"""

function seval(vec::Vector{<:AbstractNumberSymbolic{Tv}}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where {Tv <: Number}
    seval(convert(SymbolicVector{Tv}, vec), env, cache)
end

function seval(vec::Vector{<:AbstractNumberSymbolic{Tv}}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where {Tv <: Number}
    seval(convert(SymbolicVector{Tv}, vec), dvar, env, cache)
end

function seval(vec::Vector{<:AbstractNumberSymbolic{Tv}}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where {Tv <: Number}
    seval(convert(SymbolicVector{Tv}, vec), dvar, env, cache)
end

"""
getindex1
"""

function _eval(::Val{:getindex}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x = seval(f.args[1], env, cache)
    getindex(x, f.others[1])
end

function _eval(::Val{:getindex}, f::SymbolicExpression{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x = seval(f.args[1], dvar, env, cache)
    getindex(x, f.others[1])
end

function _eval(::Val{:getindex}, f::SymbolicExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x = seval(f.args[1], dvar, env, cache)
    getindex(x, f.others[1])
end

"""
getindex
"""

function _eval(::Val{:getindex}, f::SymbolicVectorExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    x = seval(f.args[1], env, cache)
    getindex(x, f.others[1])
end

function _eval(::Val{:getindex}, f::SymbolicVectorExpression{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    x = seval(f.args[1], dvar, env, cache)
    getindex(x, f.others[1])
end

function _eval(::Val{:getindex}, f::SymbolicVectorExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    x = seval(f.args[1], dvar, env, cache)
    getindex(x, f.others[1])
end

"""
plus
"""

function _eval(::Val{:+}, f::SymbolicVectorExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    args = [seval(x, env, cache) for x = f.args]
    +(args...)
end

function _eval(::Val{:+}, f::SymbolicVectorExpression{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    args = [seval(x, dvar, env, cache) for x = f.args]
    +(args...)
end

function _eval(::Val{:+}, f::SymbolicVectorExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    args = [seval(x, dvar, env, cache) for x = f.args]
    +(args...)
end

"""
minus
"""

function _eval(::Val{:-}, f::SymbolicVectorExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    args = [seval(x, env, cache) for x = f.args]
    -(args...)
end

function _eval(::Val{:-}, f::SymbolicVectorExpression{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    args = [seval(x, dvar, env, cache) for x = f.args]
    -(args...)
end

function _eval(::Val{:-}, f::SymbolicVectorExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
    args = [seval(x, dvar, env, cache) for x = f.args]
    -(args...)
end
