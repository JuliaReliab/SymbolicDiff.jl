@testset "SymbolicExpressionDeriv1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(4.0 * x + 1.6))
    y = seval(expr, :x, env, cache)
    @test y == 4.0
end

@testset "SymbolicExpressionDeriv2" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(-4.0 * x - 1.6 * x))
    y = seval(expr, :x, env, cache)
    @test y == -4-1.6
end

@testset "SymbolicExpressionDeriv3" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(-4.0 * x * x))
    println(expr)
    y = seval(expr, :x, env, cache)
    @test y == -8 * x
end

@testset "SymbolicExpressionDeriv4" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolic(:(-4.0 * x / y))
    res = seval(expr, :x, env, cache)
    @test res == -4 / y
end

@testset "SymbolicExpressionDeriv5" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolic(:(-4.0 * x / y))
    res = seval(expr, :y, env, cache)
    @test res == 4 * x / y^2
end

@testset "SymbolicExpressionDeriv6" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolic(:(-4 * x * y))
    res = seval(expr, :x, env, cache)
    @test res == -4 * y
end

@testset "SymbolicExpressionDeriv7" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = x
    expr = symbolic(:(-4 * x ^ 3))
    res = seval(expr, :x, env, cache)
    @test res == -12 * x^2
end

@testset "SymbolicExpressionDeriv8" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = -log(symbolic(:(x*y))) * symbolic(:y)
    res = seval(expr, :x, env, cache)
    @test res == - y / (x * y) * y
    res = seval(expr, :y, env, cache)
    @test res == - y / (x * y) * x - log(x * y)
    println(cache)
end

@testset "SymbolicExpressionDeriv2_1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    y = 10.1
    env[:x] = x
    env[:y] = y
    expr = symbolic(:(x^2 + 10*x*y + 4*y^2))
    res = seval(expr, (:x,:y), env, cache)
    @test res == 10.0
end

@testset "lam1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    t = rand()
    lam1 = rand()
    lam2 = rand()
    @bind env begin
        :t => t
        :lam1 => lam1
        :lam2 => lam2
    end
    expr = @expr exp(-lam1*t) - (lam1/lam2) * exp(-lam1*t) * (exp(-lam2*t) - 1)
    res1 = seval(expr, :lam1, env, cache)
    @test res1 ≈ -t*exp(-lam1*t) - (1/lam2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(lam1/lam2)*exp(-lam1*t)*(exp(-lam2*t)-1)
    res2 = seval(expr, :lam2, env, cache)
    @test res2 ≈ (lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t)
    res3 = seval(expr, (:lam2,:lam1), env, cache)
    res4 = seval(expr, (:lam1,:lam2), env, cache)
    @test isapprox(res3, res4)
    @test isapprox((1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t),
                    (1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t))
    @test res3 ≈ (1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t)
    @test res4 ≈ (1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t)
end
