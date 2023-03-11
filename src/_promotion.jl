"""
convert
"""

# function Base.convert(::Type{<:AbstractSymbolic{T}}, x::AbstractSymbolicVariable{S}) where {T,S}
#     symbolic(x.var, T)
# end

# function Base.convert(::Type{<:AbstractSymbolic{T}}, x::AbstractSymbolicValue{S}) where {T,S}
#     symbolic(T(x.val), T)
# end

# function Base.convert(::Type{<:AbstractNumberSymbolic{T}}, x::S) where {T<:Number,S<:Number}
#     symbolic(T(x), T)
# end

# function Base.convert(::Type{<:AbstractNumberSymbolic{T}}, x::SymbolicExpression{S}) where {T<:Number,S<:Number}
#     if T != S
#         SymbolicExpression{T}(x.params, x.op, [convert(AbstractNumberSymbolic{T}, u) for u = x.args], [])
#     else
#         x
#     end
# end

"""
promotion
"""

function Base.promote_rule(::Type{<:AbstractSymbolic{T}}, ::Type{S}) where {T,S}
    AbstractSymbolic{promote_type(T,S)}
end

function Base.promote_rule(::Type{<:AbstractSymbolic{T}}, ::Type{<:AbstractSymbolic{S}}) where {T,S}
    AbstractSymbolic{promote_type(T,S)}
end
