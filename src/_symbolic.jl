"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

export AbstractSymbolic, SymbolicVariable, SymbolicValue, SymbolicExpression
export symbolicexpr

import Base

"""
AbstractSymbolic

An abstract structure for symbolic expr.

AbstractSymbolic has the filed
- params::Set{Symbol} A set of Symbol included in expr
"""

abstract type AbstractSymbolic end

"""
SymbolicValue

A constant value
"""

struct SymbolicValue{Tv <: Number} <: AbstractSymbolic
    params::Set{Symbol}
    val::Tv
end

SymbolicValue(value::Tv) where Tv = SymbolicValue(Set{Symbol}([]), value)

"""
convert
"""

function Base.convert(::Type{<:AbstractSymbolic}, x::Number)
    SymbolicValue(x)
end

"""
iszero
"""

function Base.iszero(x::AbstractSymbolic) where Tv
    return false
end

function Base.iszero(x::SymbolicValue{Tv}) where Tv
    return Base.iszero(x.val)
end

"""
SymbolicVariable

A variable to be derivatived
"""

struct SymbolicVariable <: AbstractSymbolic
    params::Set{Symbol}
    var::Symbol
end

SymbolicVariable(param::Symbol) = SymbolicVariable(Set([param]), param)

"""
SymbolicExpr

An expr
"""

struct SymbolicExpression <: AbstractSymbolic
    params::Set{Symbol}
    op::Symbol
    args::Vector{<:AbstractSymbolic}
end

"""
IO for structures
"""

function Base.show(io::IO, x::AbstractSymbolic)
    expr = _toexpr(x)
    Base.show(io, expr)
end

# function Base.show(io::IO, x::SymbolicVariable)
#     Base.show(io, x.var)
# end

# function Base.show(io::IO, x::SymbolicExpression)
#     expr = _toexpr(x)
#     Base.show(io, expr)
# end

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

const operations = [:+, :-, :*, :/, :^]


function symbolicexpr(expr::Expr)
    if Meta.isexpr(expr, :call) && expr.args[1] in operations
        args = [symbolicexpr(x) for x = expr.args[2:end]]
        params = [x.params for x = args]
        SymbolicExpression(union(params...), expr.args[1], args)
    elseif Meta.isexpr(expr, :vect)
        [symbolicexpr(x) for x = expr.args]
    elseif Meta.isexpr(expr, :vcat)
        elem = [Expr(:row, [symbolicexpr(y) for y = x.args]...) for x = expr.args]
        eval(Expr(:vcat, elem...))
    else
        nothing
    end
end

function symbolicexpr(expr::Symbol)
    SymbolicVariable(expr)
end

function symbolicexpr(expr::Nothing)
    nothing
end

function symbolicexpr(expr::Tv) where {Tv <: Number}
    SymbolicValue(expr)
end
