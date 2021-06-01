
"""
SymbolicMatrix
"""

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
seval(f, env, cache)
Return the value for expr f
"""

function seval(f::Matrix{<:AbstractSymbolic{Tv}}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[seval(x, env, cache) for x = f]
end

function seval(f::SparseCSR{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseCSR{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.rowptr, f.colind)
end

function seval(f::SparseCSC{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseCSC{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.colptr, f.rowind)
end

function seval(f::SparseCOO{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseCOO{Tv,Ti}(f.m, f.n, Tv[seval(x, env, cache) for x = f.val], f.rowind, f.colind)
end

function seval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, env, cache) for x = f.nzval])
end

"""
seval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function seval(f::Matrix{<:AbstractSymbolic{Tv}}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[seval(x, dvar, env, cache) for x = f]
end

function seval(f::SparseCSR{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCSR(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function seval(f::SparseCSC{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCSC(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function seval(f::SparseCOO{<:AbstractSymbolic{Tv},Int}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCOO(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

function seval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, dvar, env, cache) for x = f.nzval])
end

"""
seval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function seval(f::Matrix{<:AbstractSymbolic{Tv}}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv[seval(x, dvar, env, cache) for x = f]
end

function seval(f::SparseCSR{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCSR(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowptr, f.colind)
end

function seval(f::SparseCSC{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCSC(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.colptr, f.rowind)
end

function seval(f::SparseCOO{<:AbstractSymbolic{Tv},Int}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    SparseCOO(f.m, f.n, Tv[seval(x, dvar, env, cache) for x = f.val], f.rowind, f.colind)
end

function seval(f::SparseMatrixCSC{<:AbstractSymbolic{Tv},Ti}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where {Tv,Ti}
    SparseMatrixCSC{Tv,Ti}(f.m, f.n, f.colptr, f.rowval, Tv[seval(x, dvar, env, cache) for x = f.nzval])
end
