using SymbolicDiff
using SparseMatrix
using SparseArrays
using LinearAlgebra
using Test

# include("test_eval.jl")
# include("test_deriv.jl")
# include("test_macro.jl")
include("test_vec.jl")

@testset "Promotion1" begin
    a = symbolic(:a)
    b = symbolic(:b, Int)
    x = [a, b]
    @test typeof(b) <: SymbolicVariable{Int}
    @test typeof(x[1]) == SymbolicVariable{Float64}
    @test typeof(x[2]) == SymbolicVariable{Float64}
end

@testset "Promotion2" begin
    a = symbolic(:a)
    x = [a, 1.0]
    @test typeof(x[1]) == SymbolicVariable{Float64}
    @test typeof(x[2]) == SymbolicValue{Float64}
end

@testset "Promotion3" begin
    a = symbolic(:a)
    x = [a, 1]
    @test typeof(x[1]) == SymbolicVariable{Float64}
    @test typeof(x[2]) == SymbolicValue{Float64}
end

@testset "Promotion4" begin
    a = symbolic(:a)
    x = a + 1
    println(x)
    @test typeof(x) == SymbolicExpression{Float64}
end
