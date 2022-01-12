"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

"""
AbstractSymbolic

An abstract structure for symbolic expr.

AbstractSymbolic has the filed
- params::Set{Symbol} A set of Symbol included in expr
"""

abstract type AbstractSymbolic{Tv} end

"""
AbstractNumberSymbolic
AbstractVectorSymbolic
AbstractMatrixSymbolic
AbstractGeneralSymbolic

They represent the types of zero values when the derivative becomes zero
"""

abstract type AbstractNumberSymbolic{Tv} <: AbstractSymbolic{Tv} end
abstract type AbstractVectorSymbolic{Tv} <: AbstractSymbolic{Tv} end
abstract type AbstractMatrixSymbolic{Tv} <: AbstractSymbolic{Tv} end
abstract type AbstractGeneralSymbolic{Tv} <: AbstractSymbolic{Tv} end

"""
SymbolicValue

A constant value
"""

mutable struct SymbolicValue{Tv} <: AbstractNumberSymbolic{Tv}
    params::Set{Symbol}
    val::Tv
end

SymbolicValue(value::Tv) where Tv = SymbolicValue(Set{Symbol}([]), value)

"""
SymbolicVariable

A variable to be derivatived
"""

mutable struct SymbolicVariable{Tv} <: AbstractNumberSymbolic{Tv}
    params::Set{Symbol}
    var::Symbol
end

"""
SymbolicExpr

An expr
"""

mutable struct SymbolicExpression{Tv} <: AbstractNumberSymbolic{Tv}
    params::Set{Symbol}
    op::Symbol
    args::Vector{<:AbstractSymbolic{Tv}}
    others
end

"""
convert
"""

function Base.convert(::Type{<:AbstractNumberSymbolic{T}}, x::SymbolicVariable{S}) where {T<:Number,S<:Number}
    symbolic(x.var, T)
end

function Base.convert(::Type{<:AbstractNumberSymbolic{T}}, x::SymbolicValue{S}) where {T<:Number,S<:Number}
    symbolic(T(x.val), T)
end

function Base.convert(::Type{<:AbstractNumberSymbolic{T}}, x::S) where {T<:Number,S<:Number}
    symbolic(T(x), T)
end

function Base.convert(::Type{<:AbstractNumberSymbolic{T}}, x::SymbolicExpression{S}) where {T<:Number,S<:Number}
    if T != S
        SymbolicExpression{T}(x.params, x.op, [convert(AbstractNumberSymbolic{T}, u) for u = x.args], [])
    else
        x
    end
end

"""
promotion
"""

function Base.promote_rule(::Type{<:AbstractNumberSymbolic{T}}, ::Type{S}) where {T<:Number,S<:Number}
    AbstractNumberSymbolic{promote_type(T,S)}
end

function Base.promote_rule(::Type{<:AbstractNumberSymbolic{T}}, ::Type{<:AbstractNumberSymbolic{S}}) where {T<:Number,S<:Number}
    AbstractNumberSymbolic{promote_type(T,S)}
end

"""
iszero
"""

function Base.iszero(x::AbstractNumberSymbolic{Tv}) where Tv
    false
end

function Base.iszero(x::SymbolicValue{Tv}) where Tv
    Base.iszero(x.val)
end

function Base.zero(::Type{AbstractNumberSymbolic{Tv}}) where Tv
    SymbolicValue(Tv(0))
end

"""
IO for structures
"""

function Base.show(io::IO, x::AbstractNumberSymbolic)
    expr = _toexpr(x)
    Base.show(io, expr)
end

function _toexpr(x::SymbolicExpression)
    args = [_toexpr(e) for e = x.args]
    Expr(:call, x.op, args...)
end

function _toexpr(x::SymbolicVariable)
    x.var
end

function _toexpr(x::SymbolicValue)
    x.val
end


"""
symbolicexpr(expr)

Build a SymbolicExpression
"""

const operations = [:+, :-, :*, :/, :^, :exp, :sqrt, :log]


function symbolic(expr::Expr, ::Type{Tv} = Float64) where Tv
    if Meta.isexpr(expr, :call) && expr.args[1] in operations
        args = [symbolic(x, Tv) for x = expr.args[2:end]]
        eval(Expr(:call, expr.args[1], args...))
    elseif Meta.isexpr(expr, :vect)
        vec = [symbolic(x, Tv) for x = expr.args]
        symbolic(vec, Tv)
    elseif Meta.isexpr(expr, :vcat)
        elem = [Expr(:row, [symbolic(y, Tv) for y = x.args]...) for x = expr.args]
        mat = eval(Expr(:vcat, elem...))
        symbolic(mat, Tv)
    else
        nothing
    end
end

function symbolic(expr::Symbol, ::Type{Tv} = Float64) where Tv
    SymbolicVariable{Tv}(Set([expr]), expr)
end

function symbolic(expr::Tv, ::Type{Tx}) where {Tv,Tx}
    SymbolicValue(expr)
end

function symbolic(expr::Tv) where Tv
    SymbolicValue(expr)
end

function symbolic(expr::Nothing, ::Type{Tv}) where Tv
    nothing
end

function symbolic(expr::Nothing) where Tv
    nothing
end

