using SymbolicDiff
using Test

@testset "SymbolicDiff1" begin
    x = variable(3.0)
    y = exp(x)
    println(y)
end