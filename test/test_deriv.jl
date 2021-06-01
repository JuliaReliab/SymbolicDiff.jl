@testset "SymbolicExpressionDeriv1" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(4.0 * x + 1.6))
    assign(expr, Dict(:x=>x))
    y = symeval(expr, :x, cache)
    @test y == 4.0
end

@testset "SymbolicExpressionDeriv2" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(-4.0 * x - 1.6 * x))
    assign(expr, Dict(:x=>x))
    y = symeval(expr, :x, cache)
    @test y == -4-1.6
end

@testset "SymbolicExpressionDeriv3" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(-4.0 * x * x))
    assign(expr, Dict(:x=>x))
    println(expr)
    y = symeval(expr, :x, cache)
    @test y == -8 * x
end

@testset "SymbolicExpressionDeriv4" begin
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    expr = symbolic(:(-4.0 * x / y))
    assign(expr, Dict(:x=>x, :y=>y))
    res = symeval(expr, :x, cache)
    @test res == -4 / y
end

@testset "SymbolicExpressionDeriv5" begin
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    expr = symbolic(:(-4.0 * x / y))
    assign(expr, Dict(:x=>x, :y=>y))
    res = symeval(expr, :y, cache)
    @test res == 4 * x / y^2
end

@testset "SymbolicExpressionDeriv6" begin
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    expr = symbolic(:(-4 * x * y))
    assign(expr, Dict(:x=>x, :y=>y))
    res = symeval(expr, :x, cache)
    @test res == -4 * y
end

@testset "SymbolicExpressionDeriv7" begin
    cache = SymbolicCache()
    x = 5.6
    expr = symbolic(:(-4 * x ^ 3))
    assign(expr, Dict(:x=>x))
    res = symeval(expr, :x, cache)
    @test res == -12 * x^2
end

@testset "SymbolicExpressionDeriv8" begin
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    expr = -log(symbolic(:(x*y))) * symbolic(:y)
    assign(expr, Dict(:x=>x, :y=>y))
    res = symeval(expr, :x, cache)
    @test res == - y / (x * y) * y
    res = symeval(expr, :y, cache)
    @test res == - y / (x * y) * x - log(x * y)
    println(cache)
end

@testset "SymbolicExpressionDeriv2_1" begin
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    expr = symbolic(:(x^2 + 10*x*y + 4*y^2))
    assign(expr, Dict(:x=>x, :y=>y))
    res = symeval(expr, (:x,:y), cache)
    @test res == 10.0
end

