
"""
SymbolicMatrix
"""

abstract type AbstractSymbolicMatrix{Tv} <: AbstractSymbolicVectorMatrix{Tv} end

struct SymbolicMatrix{Tv} <: AbstractSymbolicMatrix{Tv}
    params::Set{Symbol}
    elem::Matrix{<:AbstractSymbolic}
end

struct SymbolicCSRMatrix{Tv} <: AbstractSymbolicMatrix{Tv}
    params::Set{Symbol}
    elem::SparseCSR{<:AbstractSymbolic,Int}
end

struct SymbolicCSCMatrix{Tv} <: AbstractSymbolicMatrix{Tv}
    params::Set{Symbol}
    elem::SparseCSC{<:AbstractSymbolic,Int}
end

struct SymbolicCOOMatrix{Tv} <: AbstractSymbolicMatrix{Tv}
    params::Set{Symbol}
    elem::SparseCOO{<:AbstractSymbolic,Int}
end

SymbolicCSRMatrix(m::SymbolicMatrix{Tv}) where Tv = symbolic(SparseCSR(m.elem), Tv)
SymbolicCSCMatrix(m::SymbolicMatrix{Tv}) where Tv = symbolic(SparseCSC(m.elem), Tv)
SymbolicCOOMatrix(m::SymbolicMatrix{Tv}) where Tv = symbolic(SparseCOO(m.elem), Tv)

"""
symbolicmatrix
"""

function symbolic(mat::Matrix{<:AbstractSymbolic}, ::Type{Tv} = Float64) where Tv
    params = union([x.params for x = mat]...)
    SymbolicMatrix{Tv}(params, mat)
end

function symbolic(mat::SparseCSR{<:AbstractSymbolic,Int}, ::Type{Tv} = Float64) where Tv
    params = union([x.params for x = mat.val]...)
    SymbolicCSRMatrix{Tv}(params, mat)
end

function symbolic(mat::SparseCSC{<:AbstractSymbolic,Int}, ::Type{Tv} = Float64) where Tv
    params = union([x.params for x = mat.val]...)
    SymbolicCSCMatrix{Tv}(params, mat)
end

function symbolic(mat::SparseCOO{<:AbstractSymbolic,Int}, ::Type{Tv} = Float64) where Tv
    params = union([x.params for x = mat.val]...)
    SymbolicCOOMatrix{Tv}(params, mat)
end

"""
IO
"""

function _toexpr(x::SymbolicMatrix)
    m, n = size(x.elem)
    Expr(:vcat, [Expr(:row, [_toexpr(e) for e = x[i,:]]...) for i = 1:m]...)
end

function _toexpr(x::SymbolicCSRMatrix)
    rowptr = Expr(:vect, x.elem.rowptr...)
    colind = Expr(:vect, x.elem.colind...)
    val = Expr(:vect, [_toexpr(u) for u = x.elem.val]...)
    Expr(:call, :SparseCSR, [x.elem.m, x.elem.n, val, rowptr, colind]...)
end

function _toexpr(x::SymbolicCSCMatrix)
    colptr = Expr(:vect, x.elem.colptr...)
    rowind = Expr(:vect, x.elem.rowind...)
    val = Expr(:vect, [_toexpr(u) for u = x.elem.val]...)
    Expr(:call, :SparseCSR, [x.elem.m, x.elem.n, val, colptr, rowind]...)
end

function _toexpr(x::SymbolicCOOMatrix)
    rowind = Expr(:vect, x.elem.rowind...)
    colind = Expr(:vect, x.elem.colind...)
    val = Expr(:vect, [_toexpr(u) for u = x.elem.val]...)
    Expr(:call, :SparseCOO, [x.elem.m, x.elem.n, val, rowind, colind]...)
end

"""
"""

function Base.length(x::AbstractSymbolicVectorMatrix)
    Base.length(x.elem)
end

function Base.size(x::AbstractSymbolicVectorMatrix)
    Base.size(x.elem)
end

function Base.getindex(x::AbstractSymbolicVectorMatrix, inds...)
    Base.getindex(x.elem, inds...)
end

"""
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(m::SymbolicMatrix{Tv}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    Tv[symboliceval(x, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix{Tv}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCSR(f.m, f.n, Tv[symboliceval(x, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix{Tv}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCSC(f.m, f.n, Tv[symboliceval(x, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix{Tv}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCOO(f.m, f.n, Tv[symboliceval(x, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(m::SymbolicMatrix{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    Tv[symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCSR(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCSC(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCOO(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(m::SymbolicMatrix{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    Tv[symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCSR(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCSC(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    f = m.elem
    SparseCOO(f.m, f.n, Tv[symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

