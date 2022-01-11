
"""
SymbolicMatrix
"""

# Matrix{<:AbstractSymbolic{Tv}}
# SparseCSR{<:AbstractSymbolic{Tv},Ti}
# SparseCSC{<:AbstractSymbolic{Tv},Ti}
# SparseCOO{<:AbstractSymbolic{Tv},Ti}
# SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}

mutable struct SymbolicMatrix{Tv,MatrixT,Ti} <: AbstractMatrixSymbolic{Tv}
    params::Set{Symbol}
    mat #::MaT{<:AbstractNumberSymbolic{Tv},Ti}
    dim
end

# mutable struct SymbolicMatrixExpression{Tv} <: AbstractVectorSymbolic{Tv}
#     params::Set{Symbol}
#     op::Symbol
#     args::Vector{<:AbstractSymbolic{Tv}}
#     dim::Int
#     others
# end

"""
convert
"""

function Base.convert(::Type{<:AbstractSymbolic{Tv}}, v::Matrix{<:AbstractNumberSymbolic{Tv}}) where {Tv<:Number}
    s = union([u.params for u = v]...)
    SymbolicMatrix{Tv,Matrix,Int}(s, v, size(v))
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, s::SymbolicMatrix{S,Matrix,Int}) where {T<:Number,S<:Number}
    v = [convert(AbstractNumberSymbolic{T}, x) for x = s.mat]
    SymbolicMatrix{T,Matrix,Int}(s.params, v, length(v))
end

##

function Base.convert(::Type{<:AbstractSymbolic{Tv}}, v::SparseMatrixCSC{<:AbstractNumberSymbolic{Tv},Ti}) where {Tv<:Number,Ti}
    s = union([u.params for u = v.nzval]...)
    SymbolicMatrix{Tv,SparseMatrixCSC,Ti}(s, v, size(v))
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, s::SymbolicMatrix{S,SparseMatrixCSC,Ti}) where {T<:Number,S<:Number,Ti}
    f = s.mat
    v = SparseMatrixCSC{T,Ti}(f.m, f.n, f.colptr, f.rowval, [convert(AbstractNumberSymbolic{T}, x) for x = f.nzval])
    SymbolicMatrix{T,SparseMatrixCSC,Ti}(s.params, v, size(v))
end

##

for m in [:SparseCSR, :SparseCSC, :SparseCOO]
    @eval function Base.convert(::Type{<:AbstractSymbolic{Tv}}, v::$m{<:AbstractNumberSymbolic{Tv},Ti}) where {Tv<:Number,Ti}
        s = union([u.params for u = v.val]...)
        SymbolicMatrix{Tv,$m,Ti}(s, v, size(v))
    end
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, s::SymbolicMatrix{S,SparseCSR,Ti}) where {T<:Number,S<:Number,Ti}
    f = s.mat
    v = SparseCSR{T,Ti}(f.m, f.n, [convert(AbstractNumberSymbolic{T}, x) for x = f.val], f.rowptr, f.colind)
    SymbolicMatrix{T,SparseCSR,Ti}(s.params, v, size(v))
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, s::SymbolicMatrix{S,SparseCSC,Ti}) where {T<:Number,S<:Number,Ti}
    f = s.mat
    v = SparseCSC{T,Ti}(f.m, f.n, [convert(AbstractNumberSymbolic{T}, x) for x = f.val], f.colptr, f.rowind)
    SymbolicMatrix{T,SparseCSC,Ti}(s.params, v, size(v))
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, s::SymbolicMatrix{S,SparseCOO,Ti}) where {T<:Number,S<:Number,Ti}
    f = s.mat
    v = SparseCOO{T,Ti}(f.m, f.n, [convert(AbstractNumberSymbolic{T}, x) for x = f.val], f.rowind, f.colind)
    SymbolicMatrix{T,SparseCOO,Ti}(s.params, v, size(v))
end

"""
promotion
"""

function Base.promote_rule(::Type{<:AbstractMatrixSymbolic{T}}, ::Type{S}) where {T<:Number,S<:Number}
    AbstractMatrixSymbolic{promote_type(T,S)}
end

function Base.promote_rule(::Type{<:AbstractMatrixSymbolic{T}}, ::Type{<:AbstractMatrixSymbolic{S}}) where {T<:Number,S<:Number}
    AbstractMatrixSymbolic{promote_type(T,S)}
end

"""
IO for structures
"""

function Base.show(io::IO, x::AbstractMatrixSymbolic)
    expr = _toexpr(x)
    Base.show(io, expr)
end

function _toexpr(x::SymbolicMatrix{Tv,MatrixT,Ti}) where {Tv<:Number,MatrixT,Ti}
    Expr(:call, Symbol(MatrixT), size(x.mat)[1], size(x.mat)[2])
end

# function _toexpr(x::SymbolicVectorExpression)
#     args = [_toexpr(e) for e = x.args]
#     Expr(:call, x.op, args...)
# end

"""
seval(f, env, cache)
Return the value for expr f
"""

function seval(s::SymbolicMatrix{Tv,Matrix,Int}, env::SymbolicEnv, cache::SymbolicCache)::Matrix{Tv} where {Tv <: Number}
    [seval(x, env, cache) for x = s.mat]
end

function seval(s::SymbolicMatrix{Tv,SparseMatrixCSC,Ti}, env::SymbolicEnv, cache::SymbolicCache)::SparseMatrixCSC{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, env, cache) for x = f.nzval])
end

function seval(s::SymbolicMatrix{Tv,SparseCSR,Ti}, env::SymbolicEnv, cache::SymbolicCache)::SparseCSR{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCSR{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.rowptr, f.colind)
end

function seval(s::SymbolicMatrix{Tv,SparseCSC,Ti}, env::SymbolicEnv, cache::SymbolicCache)::SparseCSC{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCSC{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.colptr, f.rowind)
end

function seval(s::SymbolicMatrix{Tv,SparseCOO,Ti}, env::SymbolicEnv, cache::SymbolicCache)::SparseCOO{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCOO{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
seval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function seval(s::SymbolicMatrix{Tv,Matrix,Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Matrix{Tv} where {Tv <: Number}
    [seval(x, dvar, env, cache) for x = s.mat]
end

function seval(s::SymbolicMatrix{Tv,SparseMatrixCSC,Ti}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::SparseMatrixCSC{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, dvar, env, cache) for x = f.nzval])
end

function seval(s::SymbolicMatrix{Tv,SparseCSR,Ti}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::SparseCSR{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCSR{Tv,Ti}(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function seval(s::SymbolicMatrix{Tv,SparseCSC,Ti}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::SparseCSC{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCSC{Tv,Ti}(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function seval(s::SymbolicMatrix{Tv,SparseCOO,Ti}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::SparseCOO{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCOO{Tv,Ti}(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
seval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function seval(s::SymbolicMatrix{Tv,Matrix,Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Matrix{Tv} where {Tv <: Number}
    [seval(x, dvar, env, cache) for x = s.mat]
end

function seval(s::SymbolicMatrix{Tv,SparseMatrixCSC,Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::SparseMatrixCSC{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, dvar, env, cache) for x = f.nzval])
end

function seval(s::SymbolicMatrix{Tv,SparseCSR,Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::SparseCSR{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCSR{Tv,Ti}(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function seval(s::SymbolicMatrix{Tv,SparseCSC,Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::SparseCSC{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCSC{Tv,Ti}(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function seval(s::SymbolicMatrix{Tv,SparseCOO,Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::SparseCOO{Tv,Ti} where {Tv <: Number, Ti}
    f = s.mat
    SparseCOO{Tv,Ti}(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
seval for vec
"""

function seval(v::Matrix{<:AbstractNumberSymbolic{Tv}}, env::SymbolicEnv, cache::SymbolicCache)::Matrix{Tv} where {Tv <: Number}
    seval(convert(SymbolicMatrix{Tv}, v), env, cache)
end

for m in [:SparseCSR, :SparseCSC, :SparseCOO, :SparseMatrixCSC]
    @eval function seval(v::$m{<:AbstractNumberSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache)::$m{Tv,Ti} where {Tv <: Number,Ti}
        seval(convert(SymbolicMatrix{Tv}, v), env, cache)
    end
end

##

function seval(v::Matrix{<:AbstractNumberSymbolic{Tv}}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Matrix{Tv} where {Tv <: Number}
    seval(convert(SymbolicMatrix{Tv}, v), dvar, env, cache)
end

for m in [:SparseCSR, :SparseCSC, :SparseCOO, :SparseMatrixCSC]
    @eval function seval(v::$m{<:AbstractNumberSymbolic{Tv},Ti}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::$m{Tv,Ti} where {Tv <: Number,Ti}
        seval(convert(SymbolicMatrix{Tv}, v), dvar, env, cache)
    end
end

##

function seval(v::Matrix{<:AbstractNumberSymbolic{Tv}}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::Matrix{Tv} where {Tv <: Number}
    seval(convert(SymbolicMatrix{Tv}, v), dvar, env, cache)
end

for m in [:SparseCSR, :SparseCSC, :SparseCOO, :SparseMatrixCSC]
    @eval function seval(v::$m{<:AbstractNumberSymbolic{Tv},Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)::$m{Tv,Ti} where {Tv <: Number,Ti}
        seval(convert(SymbolicMatrix{Tv}, v), dvar, env, cache)
    end
end


# function seval(f::AbstractVectorSymbolic{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Vector{Tv} where Tv
#     get(cache, f) do
#         retval = _eval(Val(f.op), f, env, cache)
#         cache[f] = retval
#     end
# end




# """
# convert
# """

# function Base.convert(::Type{<:AbstractSymbolic{T}}, m::Matrix{<:AbstractSymbolic{S}}) where {T<:Number,S<:Number}
#     [convert(AbstractSymbolic{T}, x) for x = m]
# end

# function Base.convert(::Type{<:AbstractSymbolic{T}}, m::SparseCSR{<:AbstractSymbolic{S},Ti}) where {T<:Number,S<:Number,Ti}
#     SparseCSR{T,Ti}(f.m, f.n, [convert(AbstractSymbolic{T}, x) for x = m.val], f.rowptr, f.colind)
# end

# function Base.convert(::Type{<:AbstractSymbolic{T}}, m::SparseCSC{<:AbstractSymbolic{S},Ti}) where {T<:Number,S<:Number,Ti}
#     SparseCSC{T,Ti}(f.m, f.n, [convert(AbstractSymbolic{T}, x) for x = m.val], f.rowptr, f.colind)
# end

# function Base.convert(::Type{<:AbstractSymbolic{T}}, m::SparseCOO{<:AbstractSymbolic{S},Ti}) where {T<:Number,S<:Number,Ti}
#     SparseCOO{T,Ti}(f.m, f.n, [convert(AbstractSymbolic{T}, x) for x = m.val], f.rowptr, f.colind)
# end

# function Base.convert(::Type{<:AbstractSymbolic{T}}, m::SparseMatrixCSC{<:AbstractSymbolic{S},Ti}) where {T<:Number,S<:Number,Ti}
#     SparseMatrixCSC{T,Ti}(f.m, f.n, f.colptr, f.rowval, [convert(AbstractSymbolic{T}, x) for x = m.nzval])
# end

# """
# seval(f, env, cache)
# Return the value for expr f
# """

# function seval(f::Matrix{<:AbstractSymbolic{Tv}}, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     Tv[seval(x, env, cache) for x = f]
# end

# function seval(f::SparseCSR{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
#     SparseCSR{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.rowptr, f.colind)
# end

# function seval(f::SparseCSC{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
#     SparseCSC{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.colptr, f.rowind)
# end

# function seval(f::SparseCOO{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
#     SparseCOO{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.rowind, f.colind)
# end

# function seval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
#     SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, env, cache) for x = f.nzval])
# end

# """
# seval(f, dvar, env, cache)
# Return the first derivative of expr f with respect to dvar
# """

# function seval(f::Matrix{<:AbstractSymbolic{Tv}}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     Tv[seval(x, dvar, env, cache) for x = f]
# end

# function seval(f::SparseCSR{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     SparseCSR(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
# end

# function seval(f::SparseCSC{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     SparseCSC(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
# end

# function seval(f::SparseCOO{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     SparseCOO(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
# end

# function seval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
#     SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, dvar, env, cache) for x = f.nzval])
# end

# """
# seval(f, dvar, env, cache)
# Return the second derivative of expr f with respect to dvar1 and dvar2
# """

# function seval(f::Matrix{<:AbstractSymbolic{Tv}}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     Tv[seval(x, dvar, env, cache) for x = f]
# end

# function seval(f::SparseCSR{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     SparseCSR(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
# end

# function seval(f::SparseCSC{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     SparseCSC(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
# end

# function seval(f::SparseCOO{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
#     SparseCOO(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
# end

# function seval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
#     SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, dvar, env, cache) for x = f.nzval])
# end
