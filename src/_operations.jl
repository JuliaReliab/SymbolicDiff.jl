"""
operations
"""

import Base
import LinearAlgebra: dot

function Base.:+(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :+, [x])
end

function Base.:-(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :-, [x])
end

types(::Union{Val{:+},Val{:-},Val{:*},Val{:^}}, ::Type{Int}, ::Type{Int}) = Int
types(::Val{:/}, ::Type{Int}, ::Type{Int}) = Float64
types(::Union{Val{:+},Val{:-},Val{:*},Val{:/},Val{:^}}, ::Type{Tx}, ::Type{Ty}) where {Tx<:AbstractFloat,Ty<:Integer} = Tx
types(::Union{Val{:+},Val{:-},Val{:*},Val{:/},Val{:^}}, ::Type{Tx}, ::Type{Ty}) where {Tx<:Integer,Ty<:AbstractFloat} = Ty
types(::Union{Val{:+},Val{:-},Val{:*},Val{:/},Val{:^}}, ::Type{Float64}, ::Type{Float64}) = Float64

for op in [:+, :-, :*, :/, :^]
    @eval function Base.$op(x::AbstractSymbolic{Tx}, y::AbstractSymbolic{Ty}) where {Tx, Ty}
        s = union(x.params, y.params)
        SymbolicExpression{types(Val($(Expr(:quote, op))), Tx, Ty)}(s, $(Expr(:quote, op)), [x, y])
    end
end

# function Base.:+(x::AbstractSymbolic{Tv}, xs::Vararg{<:AbstractSymbolic{Tv}}) where Tv
#     args = [e for e = (x, xs...)]
#     s = union([x.params for x = args]...)
#     SymbolicExpression{Tv}(s, :+, args)
# end

# function Base.:*(x::AbstractSymbolic{Tv}, xs::Vararg{<:AbstractSymbolic{Tv}}) where Tv
#     args = [e for e = (x, xs...)]
#     s = union([x.params for x = args]...)
#     SymbolicExpression{Tv}(s, :*, args)
# end

# function Base.:+(x::AbstractSymbolic{Tv}, y::AbstractSymbolic{Tv}) where Tv
#     s = union(x.params, y.params)
#     SymbolicExpression{Tv}(s, :+, [x, y])
# end

# function Base.:-(x::AbstractSymbolic{Tv}, y::AbstractSymbolic{Tv}) where Tv
#     s = union(x.params, y.params)
#     SymbolicExpression{Tv}(s, :-, [x, y])
# end

# function Base.:*(x::AbstractSymbolic{Tv}, y::AbstractSymbolic{Tv}) where Tv
#     s = union(x.params, y.params)
#     SymbolicExpression{Tv}(s, :*, [x, y])
# end

# function Base.:/(x::AbstractSymbolic{Tv}, y::AbstractSymbolic{Tv}) where Tv
#     s = union(x.params, y.params)
#     SymbolicExpression{Tv}(s, :/, [x, y])
# end

# function Base.:^(x::AbstractSymbolic{Tv}, y::AbstractSymbolic{Tv}) where Tv
#     s = union(x.params, y.params)
#     SymbolicExpression{Tv}(s, :^, [x, y])
# end

function Base.exp(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :exp, [x])
end

function Base.log(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :log, [x])
end

function Base.sqrt(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :sqrt, [x])
end

function dot(x::AbstractSymbolic{Tv}, y::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(union(x.params, y.params), :dot, [x, y])
end
