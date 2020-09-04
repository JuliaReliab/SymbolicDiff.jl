using SymbolicDiff
using Test

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
    x = SymbolicVariable(:a)
    @test x.var == :a
end

@testset "SymbolicExpression1" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(x + 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x + 1.6
end

@testset "SymbolicExpression2" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(x - 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x - 1.6
end

@testset "SymbolicExpression3" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(x * 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x * 1.6
end

@testset "SymbolicExpression4" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(x / 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x / 1.6
end

@testset "SymbolicExpression5" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(x ^ 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x ^ 1.6
end

@testset "SymbolicExpression6" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(exp(-x ^ 1.6)))
    y = symboliceval(expr, env, cache)
    @test y == exp(-x ^ 1.6)
end

@testset "SymbolicExpression7" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(log(x ^ 1.6)))
    y = symboliceval(expr, env, cache)
    @test y == log(x ^ 1.6)
end

@testset "SymbolicExpression8" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(log(x ^ 1.6)))
    y = symboliceval(expr, env, cache)
    @test y == log(x ^ 1.6)
end

@testset "SymbolicExpression9" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(sqrt(x ^ 1.6)))
    y = symboliceval(expr, env, cache)
    @test y == sqrt(x ^ 1.6)
end

@testset "SymbolicExpressionDeriv1" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(4 * x + 1.6))
    y = symboliceval(expr, :x, env, cache)
    @test y == 4.0
end

@testset "SymbolicExpressionDeriv2" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(-4 * x - 1.6 * x))
    y = symboliceval(expr, :x, env, cache)
    @test y == -4-1.6
end

@testset "SymbolicExpressionDeriv3" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = 5.6
    expr = symbolicexpr(:(-4 * x * x))
    y = symboliceval(expr, :x, env, cache)
    @test y == -8 * x
end

@testset "SymbolicExpressionDeriv4" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolicexpr(:(-4 * x / y))
    res = symboliceval(expr, :x, env, cache)
    @test res == -4 / y
end

@testset "SymbolicExpressionDeriv5" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolicexpr(:(-4 * x / y))
    res = symboliceval(expr, :y, env, cache)
    @test res == 4 * x / y^2
end

@testset "SymbolicExpressionDeriv6" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolicexpr(:(-4 * x * y))
    res = symboliceval(expr, :x, env, cache)
    @test res == -4 * y
end

@testset "SymbolicExpressionDeriv7" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    env[:x] = x
    expr = symbolicexpr(:(-4 * x ^ 3))
    res = symboliceval(expr, :x, env, cache)
    @test res == -12 * x^2
end

@testset "SymbolicExpressionDeriv8" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolicexpr(:(- log(x * y) * y))
    res = symboliceval(expr, :x, env, cache)
    @test res == - y / (x * y) * y
    res = symboliceval(expr, :y, env, cache)
    @test res == - y / (x * y) * x - log(x * y)
    println(cache)
end

@testset "SymbolicExpressionDeriv2_1" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolicexpr(:(x^2 + 10*x*y + 4*y^2))
    res = symboliceval(expr, (:x,:y), env, cache)
    @test res == 10.0
end

@testset "Macro1" begin
    env = SymbolicEnv{Float64}()
    cache = SymbolicCache{Float64}()
    x = 5.6
    y = 10.1
    @env env begin
        x = x
        y = y
    end
    expr = @expr x^2 + 10*x*y + 4*y^2
    res = symboliceval(expr, (:x,:y), env, cache)
    @test res == 10.0
end

