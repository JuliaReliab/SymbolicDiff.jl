
"""
SymbolicMatrix
"""

# abstract type AbstractSymbolicMatrix{Tv} <: AbstractSymbolicVectorMatrix{Tv} end

# struct SymbolicMatrix{Tv} <: AbstractSymbolicMatrix{Tv}
#     params::Set{Symbol}
#     elem::Matrix{<:AbstractSymbolic}
# end

# struct SymbolicCSRMatrix{Tv} <: AbstractSymbolicMatrix{Tv}
#     params::Set{Symbol}
#     elem::SparseCSR{<:AbstractSymbolic,Int}
# end

# struct SymbolicCSCMatrix{Tv} <: AbstractSymbolicMatrix{Tv}
#     params::Set{Symbol}
#     elem::SparseCSC{<:AbstractSymbolic,Int}
# end

# struct SymbolicCOOMatrix{Tv} <: AbstractSymbolicMatrix{Tv}
#     params::Set{Symbol}
#     elem::SparseCOO{<:AbstractSymbolic,Int}
# end

# SymbolicCSRMatrix(m::SymbolicMatrix{Tv}) where Tv = symbolic(SparseCSR(m.elem), Tv)
# SymbolicCSCMatrix(m::SymbolicMatrix{Tv}) where Tv = symbolic(SparseCSC(m.elem), Tv)
# SymbolicCOOMatrix(m::SymbolicMatrix{Tv}) where Tv = symbolic(SparseCOO(m.elem), Tv)

"""
symbolicmatrix
"""

# function symbolic(mat::Matrix{<:AbstractSymbolic}, ::Type{Tv} = Float64) where Tv
#     params = union([x.params for x = mat]...)
#     SymbolicMatrix{Tv}(params, mat)
# end

# function symbolic(mat::SparseCSR{<:AbstractSymbolic,Int}, ::Type{Tv} = Float64) where Tv
#     params = union([x.params for x = mat.val]...)
#     SymbolicCSRMatrix{Tv}(params, mat)
# end

# function symbolic(mat::SparseCSC{<:AbstractSymbolic,Int}, ::Type{Tv} = Float64) where Tv
#     params = union([x.params for x = mat.val]...)
#     SymbolicCSCMatrix{Tv}(params, mat)
# end

# function symbolic(mat::SparseCOO{<:AbstractSymbolic,Int}, ::Type{Tv} = Float64) where Tv
#     params = union([x.params for x = mat.val]...)
#     SymbolicCOOMatrix{Tv}(params, mat)
# end

"""
IO
"""

# function _toexpr(x::Matrix{<:AbstractSymbolic{Tv}}) where {Tv<:Number}
#     m, n = size(x.elem)
#     Expr(:vcat, [Expr(:row, [_toexpr(e) for e = x[i,:]]...) for i = 1:m]...)
# end

# function _toexpr(x::SparseCSR{<:AbstractSymbolic{Tv},Int}) where {Tv<:Number}
#     rowptr = Expr(:vect, x.elem.rowptr...)
#     colind = Expr(:vect, x.elem.colind...)
#     val = Expr(:vect, [_toexpr(u) for u = x.elem.val]...)
#     Expr(:call, :SparseCSR, [x.elem.m, x.elem.n, val, rowptr, colind]...)
# end

# function _toexpr(x::SparseCSC{<:AbstractSymbolic{Tv},Int}) where {Tv<:Number}
#     colptr = Expr(:vect, x.elem.colptr...)
#     rowind = Expr(:vect, x.elem.rowind...)
#     val = Expr(:vect, [_toexpr(u) for u = x.elem.val]...)
#     Expr(:call, :SparseCSR, [x.elem.m, x.elem.n, val, colptr, rowind]...)
# end

# function _toexpr(x::SparseCOO{<:AbstractSymbolic{Tv},Int}) where {Tv<:Number}
#     rowind = Expr(:vect, x.elem.rowind...)
#     colind = Expr(:vect, x.elem.colind...)
#     val = Expr(:vect, [_toexpr(u) for u = x.elem.val]...)
#     Expr(:call, :SparseCOO, [x.elem.m, x.elem.n, val, rowind, colind]...)
# end

"""
"""

# function Base.length(x::AbstractSymbolicVectorMatrix)
#     Base.length(x.elem)
# end

# function Base.size(x::AbstractSymbolicVectorMatrix)
#     Base.size(x.elem)
# end

# function Base.getindex(x::AbstractSymbolicVectorMatrix, inds...)
#     Base.getindex(x.elem, inds...)
# end

"""
convert
"""

function Base.convert(::Type{<:AbstractSymbolic{T}}, m::Matrix{<:AbstractSymbolic{S}}) where {T<:Number,S<:Number}
    [convert(AbstractSymbolic{T}, x) for x = m]
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, m::SparseCSR{<:AbstractSymbolic{S},Ti}) where {T<:Number,S<:Number,Ti}
    SparseCSR{T,Ti}(f.m, f.n, [convert(AbstractSymbolic{T}, x) for x = m.val], f.rowptr, f.colind)
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, m::SparseCSC{<:AbstractSymbolic{S},Ti}) where {T<:Number,S<:Number,Ti}
    SparseCSC{T,Ti}(f.m, f.n, [convert(AbstractSymbolic{T}, x) for x = m.val], f.rowptr, f.colind)
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, m::SparseCOO{<:AbstractSymbolic{S},Ti}) where {T<:Number,S<:Number,Ti}
    SparseCOO{T,Ti}(f.m, f.n, [convert(AbstractSymbolic{T}, x) for x = m.val], f.rowptr, f.colind)
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, m::SparseMatrixCSC{<:AbstractSymbolic{S},Ti}) where {T<:Number,S<:Number,Ti}
    SparseMatrixCSC{T,Ti}(f.m, f.n, f.colptr, f.rowval, [convert(AbstractSymbolic{T}, x) for x = m.nzval])
end

"""
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(f::Matrix{<:AbstractSymbolic{Tv}}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, env, cache) for x = f]
end

function symboliceval(f::SparseCSR{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseCSR{Tv,Ti}(f.m, f.n, Tv[symboliceval(x, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(f::SparseCSC{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseCSC{Tv,Ti}(f.m, f.n, Tv[symboliceval(x, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(f::SparseCOO{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseCOO{Tv,Ti}(f.m, f.n, Tv[symboliceval(x, env, cache) for x = f.val], f.rowind, f.colind)
end

function symboliceval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[symboliceval(x, env, cache) for x = f.nzval])
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(f::Matrix{<:AbstractSymbolic{Tv}}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(f::SparseCSR{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCSR(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(f::SparseCSC{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCSC(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(f::SparseCOO{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCOO(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

function symboliceval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[symboliceval(x, dvar, env, cache) for x = f.nzval])
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(f::Matrix{<:AbstractSymbolic{Tv}}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(f::SparseCSR{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCSR(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(f::SparseCSC{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCSC(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(f::SparseCOO{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCOO(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

function symboliceval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[symboliceval(x, dvar, env, cache) for x = f.nzval])
end
