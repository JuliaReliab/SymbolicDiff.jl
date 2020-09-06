
"""
SymbolicMatrix
"""

export symbolic, AbstractSymbolicMatrix

import SparseMatrix: SparseCSR, SparseCSC, SparseCOO

abstract type AbstractSymbolicMatrix <: AbstractSymbolicVectorMatrix end

struct SymbolicMatrix <: AbstractSymbolicMatrix
    params::Set{Symbol}
    elem::Matrix{<:AbstractSymbolic}
end

struct SymbolicCSRMatrix <: AbstractSymbolicMatrix
    params::Set{Symbol}
    elem::SparseCSR{<:AbstractSymbolic,Int}
end

struct SymbolicCSCMatrix <: AbstractSymbolicMatrix
    params::Set{Symbol}
    elem::SparseCSC{<:AbstractSymbolic,Int}
end

struct SymbolicCOOMatrix <: AbstractSymbolicMatrix
    params::Set{Symbol}
    elem::SparseCOO{<:AbstractSymbolic,Int}
end

"""
symbolicmatrix
"""

function symbolic(mat::Matrix{<:AbstractSymbolic})
    params = union([x.params for x = mat]...)
    SymbolicMatrix(params, mat)
end

function symbolic(mat::SparseCSR{<:AbstractSymbolic,Int})
    params = union([x.params for x = mat.val]...)
    SymbolicCSRMatrix(params, mat)
end

function symbolic(mat::SparseCSC{<:AbstractSymbolic,Int})
    params = union([x.params for x = mat.val]...)
    SymbolicCSCMatrix(params, mat)
end

function symbolic(mat::SparseCOO{<:AbstractSymbolic,Int})
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

function symboliceval(m::SymbolicMatrix, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    [symboliceval(x, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCSR(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCSC(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCOO(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(m::SymbolicMatrix, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    [symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCSR(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCSC(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCOO(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(m::SymbolicMatrix, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    [symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(m::SymbolicCSRMatrix, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCSR(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(m::SymbolicCSCMatrix, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCSC(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(m::SymbolicCOOMatrix, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    f = m.elem
    SparseCOO(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

