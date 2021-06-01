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
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(x + 1.6))
    println(expr)
    y = seval(expr, env, cache)
    @test y == x + 1.6
end

@testset "SymbolicExpression2" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(x - 1.6))
    y = seval(expr, env, cache)
    @test y == x - 1.6
end

@testset "SymbolicExpression3" begin
    x = 5.6
    globalenv[:x] = 5.6
    expr = symbolic(:(x * 1.6))
    y = seval(expr, globalenv)
    @test y == x * 1.6
end

@testset "SymbolicExpression4" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(x / 1.6))
    y = seval(expr, env, cache)
    @test y == x / 1.6
end

@testset "SymbolicExpression5" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(x ^ 1.6))
    y = seval(expr, env, cache)
    @test y == x ^ 1.6
end

@testset "SymbolicExpression6" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = exp(symbolic(:(-x ^ 1.6)))
    y = seval(expr, env, cache)
    @test y == exp(-x ^ 1.6)
end

@testset "SymbolicExpression7" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = @expr log(x ^ 1.6)
    y = seval(expr, env, cache)
    @test y == log(x ^ 1.6)
end

@testset "SymbolicExpression8" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = log(symbolic(:(x ^ 1.6)))
    y = seval(expr, env, cache)
    @test y == log(x ^ 1.6)
end

@testset "SymbolicExpression9" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = @expr sqrt(x^ 1.6)
    y = seval(expr, env, cache)
    @test y == sqrt(x ^ 1.6)
end
