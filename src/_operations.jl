"""
operations
"""

function Base.:+(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :+, [x])
end

function Base.:-(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :-, [x])
end

for op in [:+, :-, :*, :/, :^]
    @eval function Base.$op(x::AbstractSymbolic{Tx}, y::AbstractSymbolic{Ty}) where {Tx<:Number,Ty<:Number}
        s = union(x.params, y.params)
        Tv = promote_type(Tx,Ty)
        SymbolicExpression{promote_type(Tx,Ty)}(s, $(Expr(:quote, op)), [x, y])
    end

    @eval function Base.$op(x::Tx, y::AbstractSymbolic{Ty}) where {Tx<:Number,Ty<:Number}
        Tv = promote_type(Tx,Ty)
        SymbolicExpression{promote_type(Tx,Ty)}(y.params, $(Expr(:quote, op)), [x, y])
    end

    @eval function Base.$op(x::AbstractSymbolic{Tx}, y::Ty) where {Tx<:Number,Ty<:Number}
        Tv = promote_type(Tx,Ty)
        SymbolicExpression{promote_type(Tx,Ty)}(x.params, $(Expr(:quote, op)), [x, y])
    end
end

function Base.exp(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :exp, [x])
end

function Base.log(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :log, [x])
end

function Base.sqrt(x::AbstractSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :sqrt, [x])
end

function dot(x::Vector{<:AbstractSymbolic{Tx}}, y::Vector{<:AbstractSymbolic{Ty}}) where {Tx<:Number,Ty<:Number}
    Tv = promote_type(Tx,Ty)
    s = union([u.params for u = x]..., [u.params for u = y]...)
    SymbolicExpression{Tv}(s, :dot, [x, y])
end
