module SymbolicDiff

export AbstractSymbolic, SymbolicVariable, SymbolicValue, SymbolicExpression
export SymbolicEnv, SymbolicCache
export symbolic, seval
export @vars, @bind, @expr
export globalenv

import Base
import LinearAlgebra: dot
import SparseMatrix: SparseCSR, SparseCSC, SparseCOO
import SparseArrays: SparseMatrixCSC

include("_symbolic.jl")
include("_operations.jl")

include("_env.jl")
include("_eval.jl")
include("_deriv.jl")
include("_deriv2.jl")

include("_vector.jl")
include("_matrix.jl")

include("_macro.jl")

end
