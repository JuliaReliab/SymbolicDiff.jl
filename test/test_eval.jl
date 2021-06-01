@testset "SymbolicValue" begin
    x = SymbolicValue(1.0)
    @test typeof(x) == SymbolicValue{Float64}
    x = SymbolicValue(1)
    @test typeof(x) == SymbolicValue{Int}
    x = SymbolicValue(true)
    @test typeof(x) == SymbolicValue{Bool}
end

@testset "SymbolicValue2" begin
    x = SymbolicValue(0.0)
    @test iszero(x)
end

@testset "SymbolicVariable" begin
    x = symbolic(:a)
    @test x.var == :a
end

@testset "SymbolicExpression1" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(x + 1.6))
    println(expr)
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == x + 1.6
end

@testset "SymbolicExpression2" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(x - 1.6))
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == x - 1.6
end

@testset "SymbolicExpression3" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(x * 1.6))
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == x * 1.6
end

@testset "SymbolicExpression4" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(x / 1.6))
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == x / 1.6
end

@testset "SymbolicExpression5" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(x ^ 1.6))
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == x ^ 1.6
end

@testset "SymbolicExpression6" begin
    cache = SymbolicCache()
    x = 5.6
    expr = exp(symbolic(:(-x ^ 1.6)))
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == exp(-x ^ 1.6)
end

@testset "SymbolicExpression7" begin
    cache = SymbolicCache()
    x = 5.6
    expr = @expr log(x ^ 1.6)
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == log(x ^ 1.6)
end

@testset "SymbolicExpression8" begin
    cache = SymbolicCache()
    x = 5.6
    expr = log(symbolic(:(x ^ 1.6)))
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == log(x ^ 1.6)
end

@testset "SymbolicExpression9" begin
    cache = SymbolicCache()
    x = 5.6
    expr = @expr sqrt(x^ 1.6)
    assign(expr, Dict(:x => 5.6, :y => 1))
    y = symeval(expr, cache)
    @test y == sqrt(x ^ 1.6)
end
