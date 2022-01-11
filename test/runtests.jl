using SymbolicDiff
using SparseMatrix
using SparseArrays
using LinearAlgebra
using Test

#include("test_eval.jl")
#include("test_deriv.jl")
#include("test_vec.jl")
include("test_mat.jl")

#include("test_macro_promotion.jl")