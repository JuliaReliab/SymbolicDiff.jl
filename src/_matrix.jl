
"""
SymbolicMatrix
"""

using SparseMatrix: SparseCSR, SparseCSC, SparseCOO

"""
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(f::Matrix{<:AbstractSymbolic}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, env, cache) for x = f]
end

function symboliceval(f::SparseCSR{<:AbstractSymbolic,Ti}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCSR(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(f::SparseCSC{<:AbstractSymbolic,Ti}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCSC(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(f::SparseCOO{<:AbstractSymbolic,Ti}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCOO(f.m, f.n, [symboliceval(x, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(f::Matrix{<:AbstractSymbolic}, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(f::SparseCSR{<:AbstractSymbolic,Ti}, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCSR(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(f::SparseCSC{<:AbstractSymbolic,Ti}, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCSC(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(f::SparseCOO{<:AbstractSymbolic,Ti}, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCOO(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(f::Matrix{<:AbstractSymbolic}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, dvar, env, cache) for x = f]
end

function symboliceval(f::SparseCSR{<:AbstractSymbolic,Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCSR(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function symboliceval(f::SparseCSC{<:AbstractSymbolic,Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCSC(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function symboliceval(f::SparseCOO{<:AbstractSymbolic,Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where {Ti,Tv}
    SparseCOO(f.m, f.n, [symboliceval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

