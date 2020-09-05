"""
operations
"""

import Base
import LinearAlgebra: dot

function Base.:+(x::AbstractSymbolic)
    SymbolicExpression(x.params, :+, [x])
end

function Base.:+(x::AbstractSymbolic, xs::Vararg{<:AbstractSymbolic})
    args = [e for e = (x, xs...)]
    s = union([x.params for x = args]...)
    SymbolicExpression(s, :+, args)
end

function Base.:-(x::AbstractSymbolic)
    SymbolicExpression(x.params, :-, [x])
end

function Base.:-(x::AbstractSymbolic, y::AbstractSymbolic)
    s = union(x.params, y.params)
    SymbolicExpression(s, :-, [x, y])
end

function Base.:*(x::AbstractSymbolic, xs::Vararg{<:AbstractSymbolic})
    args = [e for e = (x, xs...)]
    s = union([x.params for x = args]...)
    SymbolicExpression(s, :*, args)
end

function Base.:/(x::AbstractSymbolic, y::AbstractSymbolic)
    s = union(x.params, y.params)
    SymbolicExpression(s, :/, [x, y])
end

function Base.:^(x::AbstractSymbolic, y::AbstractSymbolic)
    s = union(x.params, y.params)
    SymbolicExpression(s, :^, [x, y])
end

function Base.exp(x::AbstractSymbolic)
    SymbolicExpression(x.params, :exp, [x])
end

function Base.log(x::AbstractSymbolic)
    SymbolicExpression(x.params, :log, [x])
end

function Base.sqrt(x::AbstractSymbolic)
    SymbolicExpression(x.params, :sqrt, [x])
end

function dot(x::AbstractSymbolic, y::AbstractSymbolic)
    SymbolicExpression(union(x.params, y.params), :dot, [x, y])
end
