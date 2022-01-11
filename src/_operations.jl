"""
operations
"""

function Base.:+(x::AbstractNumberSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :+, [x], [])
end

function Base.:-(x::AbstractNumberSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :-, [x], [])
end

for op in [:+, :-, :*, :/, :^]
    @eval function Base.$op(x::AbstractNumberSymbolic{Tx}, y::AbstractNumberSymbolic{Ty}) where {Tx<:Number,Ty<:Number}
        s = union(x.params, y.params)
        Tv = promote_type(Tx,Ty)
        SymbolicExpression{promote_type(Tx,Ty)}(s, $(Expr(:quote, op)), [x, y], [])
    end

    @eval function Base.$op(x::Tx, y::AbstractNumberSymbolic{Ty}) where {Tx<:Number,Ty<:Number}
        Tv = promote_type(Tx,Ty)
        SymbolicExpression{promote_type(Tx,Ty)}(y.params, $(Expr(:quote, op)), [x, y], [])
    end

    @eval function Base.$op(x::AbstractNumberSymbolic{Tx}, y::Ty) where {Tx<:Number,Ty<:Number}
        Tv = promote_type(Tx,Ty)
        SymbolicExpression{promote_type(Tx,Ty)}(x.params, $(Expr(:quote, op)), [x, y], [])
    end
end

function Base.exp(x::AbstractNumberSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :exp, [x], [])
end

function Base.log(x::AbstractNumberSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :log, [x], [])
end

function Base.sqrt(x::AbstractNumberSymbolic{Tv}) where Tv
    SymbolicExpression{Tv}(x.params, :sqrt, [x], [])
end

###

function Base.sum(x::Vector{<:AbstractNumberSymbolic{T}}) where {T<:Number}
    sum(convert(AbstractVectorSymbolic{T}, x))
end

function Base.sum(x::AbstractVectorSymbolic{T}) where {T<:Number}
    SymbolicExpression{T}(x.params, :sum, [x], [])
end

function dot(x::Vector{<:AbstractNumberSymbolic{Tx}}, y::Vector{<:AbstractNumberSymbolic{Ty}}) where {Tx<:Number,Ty<:Number}
    dot(convert(AbstractVectorSymbolic{Tx}, x), convert(AbstractVectorSymbolic{Ty}, y))
end

function dot(x::AbstractVectorSymbolic{Tx}, y::Vector{<:AbstractNumberSymbolic{Ty}}) where {Tx<:Number,Ty<:Number}
    dot(x, convert(AbstractVectorSymbolic{Ty}, y))
end

function dot(x::Vector{<:AbstractNumberSymbolic{Tx}}, y::AbstractVectorSymbolic{Ty}) where {Tx<:Number,Ty<:Number}
    dot(convert(AbstractVectorSymbolic{Tx}, x), y)
end

function dot(x::AbstractVectorSymbolic{Tx}, y::AbstractVectorSymbolic{Ty}) where {Tx<:Number,Ty<:Number}
    Tv = promote_type(Tx,Ty)
    s = union(x.params, y.params)
    SymbolicExpression{Tv}(s, :dot, AbstractVectorSymbolic{Tv}[x, y], [])
end

for op in [:+, :-]
    @eval function Base.$op(x::AbstractVectorSymbolic{Tx}, y::AbstractVectorSymbolic{Ty}) where {Tx<:Number,Ty<:Number}
        s = union(x.params, y.params)
        Tv = promote_type(Tx,Ty)
        SymbolicVectorExpression{promote_type(Tx,Ty)}(s, $(Expr(:quote, op)), [x, y], x.dim, [])
    end

    @eval function Base.$op(x::Tx, y::AbstractVectorSymbolic{Ty}) where {Tx<:Number,Ty<:Number}
        Tv = promote_type(Tx,Ty)
        SymbolicVectorExpression{promote_type(Tx,Ty)}(y.params, $(Expr(:quote, op)), [x, y], x.dim, [])
    end

    @eval function Base.$op(x::AbstractVectorSymbolic{Tx}, y::Ty) where {Tx<:Number,Ty<:Number}
        Tv = promote_type(Tx,Ty)
        SymbolicVectorExpression{promote_type(Tx,Ty)}(x.params, $(Expr(:quote, op)), [x, y], x.dim, [])
    end
end