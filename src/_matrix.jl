
"""
SymbolicMatrix
"""

export symbolicmatrix, AbstractSymbolicMatrix

import SparseMatrix: SparseCSR, SparseCSC, SparseCOO

abstract type AbstractSymbolicMatrix <: AbstractSymbolicVectorMatrix end

struct SymbolicMatrix <: AbstractSymbolicMatrix
    params::Set{Symbol}
    elem::Matrix{<:AbstractSymbolic}
end

struct SymbolicCSRMatrix{Ti} <: AbstractSymbolicMatrix
    params::Set{Symbol}
    elem::SparseCSR{<:AbstractSymbolic,Ti}
end

struct SymbolicCSCMatrix{Ti} <: AbstractSymbolicMatrix
    params::Set{Symbol}
    elem::SparseCSC{<:AbstractSymbolic,Ti}
end

struct SymbolicCOOMatrix{Ti} <: AbstractSymbolicMatrix
    params::Set{Symbol}
    elem::SparseCOO{<:AbstractSymbolic,Ti}
end

"""
symbolicmatrix
"""

function symbolicmatrix(mat::Matrix{<:AbstractSymbolic})
    params = union([x.params for x = mat]...)
    SymbolicMatrix(params, mat)
end

function symbolicmatrix(mat::SparseCSR{<:AbstractSymbolic,Ti}) where Ti
    params = union([x.params for x = mat.val]...)
    SymbolicCSRMatrix(params, mat)
end

function symbolicmatrix(mat::SparseCSC{<:AbstractSymbolic,Ti}) where Ti
    params = union([x.params for x = mat.val]...)
    SymbolicCSCMatrix(params, mat)
end

function symbolicmatrix(mat::SparseCOO{<:AbstractSymbolic,Ti}) where Ti
    params = union([x.params for x = mat.val]...)
    SymbolicCOOMatrix(params, mat)
end

function _toexpr(x::SymbolicMatrix)
    m, n = size(x.elem)
    Expr(:vcat, [Expr(:row, [_toexpr(e) for e = x[i,:]]...) for i = 1:m]...)
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

function symboliceval(m::SymbolicMatrix, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    f = m.elem
    [symboliceval(x, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix{Ti}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCSR(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix{Ti}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCSC(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix{Ti}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCOO(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(m::SymbolicMatrix, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    f = m.elem
    [symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix{Ti}, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCSR(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix{Ti}, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCSC(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix{Ti}, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCOO(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(m::SymbolicMatrix, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    f = m.elem
    [symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix{Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCSR(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix{Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCSC(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix{Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    f = m.elem
    SparseCOO(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

