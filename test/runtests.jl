using SymbolicDiff
using SparseMatrix
using SparseArrays
using LinearAlgebra
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
    y = symboliceval(expr, env, cache)
    @test y == x + 1.6
end

@testset "SymbolicExpression2" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(x - 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x - 1.6
end

@testset "SymbolicExpression3" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(x * 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x * 1.6
end

@testset "SymbolicExpression4" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(x / 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x / 1.6
end

@testset "SymbolicExpression5" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(x ^ 1.6))
    y = symboliceval(expr, env, cache)
    @test y == x ^ 1.6
end

@testset "SymbolicExpression6" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = exp(symbolic(:(-x ^ 1.6)))
    y = symboliceval(expr, env, cache)
    @test y == exp(-x ^ 1.6)
end

@testset "SymbolicExpression7" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = @expr log(x ^ 1.6)
    y = symboliceval(expr, env, cache)
    @test y == log(x ^ 1.6)
end

@testset "SymbolicExpression8" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = log(symbolic(:(x ^ 1.6)))
    y = symboliceval(expr, env, cache)
    @test y == log(x ^ 1.6)
end

@testset "SymbolicExpression9" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = @expr sqrt(x^ 1.6)
    y = symboliceval(expr, env, cache)
    @test y == sqrt(x ^ 1.6)
end

@testset "SymbolicExpressionDeriv1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(4.0 * x + 1.6))
    y = symboliceval(expr, :x, env, cache)
    @test y == 4.0
end

@testset "SymbolicExpressionDeriv2" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(-4.0 * x - 1.6 * x))
    y = symboliceval(expr, :x, env, cache)
    @test y == -4-1.6
end

@testset "SymbolicExpressionDeriv3" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = 5.6
    expr = symbolic(:(-4.0 * x * x))
    println(expr)
    y = symboliceval(expr, :x, env, cache)
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
    res = symboliceval(expr, :x, env, cache)
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
    res = symboliceval(expr, :y, env, cache)
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
    res = symboliceval(expr, :x, env, cache)
    @test res == -4 * y
end

@testset "SymbolicExpressionDeriv7" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 5.6
    env[:x] = x
    expr = symbolic(:(-4 * x ^ 3))
    res = symboliceval(expr, :x, env, cache)
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
    res = symboliceval(expr, :x, env, cache)
    @test res == - y / (x * y) * y
    res = symboliceval(expr, :y, env, cache)
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
    res = symboliceval(expr, (:x,:y), env, cache)
    @test res == 10.0
end

@testset "Macro1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
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

@testset "ops1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 0.56
    y = 0.101
    @env env begin
        x = x
        y = y
    end
    expr = @expr exp(x^2 + 10*x*y + 4*y^2)
    res = symboliceval(expr, (:x,:y), env, cache)
    @test res == exp(x^2 + 10*x*y + 4*y^2) * (10*x + 8*y) * (2*x + 10*y) + exp(x^2 + 10*x*y + 4*y^2) * 10
end

@testset "lam1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    t = rand()
    lam1 = rand()
    lam2 = rand()
    @env env begin
        t = t
        lam1 = lam1
        lam2 = lam2
    end
    expr = @expr exp(-lam1*t) - (lam1/lam2) * exp(-lam1*t) * (exp(-lam2*t) - 1)
    res1 = symboliceval(expr, :lam1, env, cache)
    @test res1 ≈ -t*exp(-lam1*t) - (1/lam2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(lam1/lam2)*exp(-lam1*t)*(exp(-lam2*t)-1)
    res2 = symboliceval(expr, :lam2, env, cache)
    @test res2 ≈ (lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t)
    res3 = symboliceval(expr, (:lam2,:lam1), env, cache)
    res4 = symboliceval(expr, (:lam1,:lam2), env, cache)
    @test isapprox(res3, res4)
    @test isapprox((1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t),
                    (1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t))
    @test res3 ≈ (1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t)
    @test res4 ≈ (1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t)
end

@testset "vector1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = [@expr(x), 1, 1.0]
    println(x)
end

@testset "SymbolicVector1" begin
    v = [@expr x + $i for i = 1:10]
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(v, test, SymbolicCache()) == [x+i for i = 1:10]
end

@testset "SymbolicVector1" begin
    v = [@expr x^$i + $i for i = 1:10]
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(v, :x, test, SymbolicCache()) == [i * x^(i-1) for i = 1:10]
end

@testset "SymbolicCSR1" begin
    v = [@expr x^$i + $i for i = 1:9]
    m = SparseCSR(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(m, test, SymbolicCache()) == SparseCSR(3, 3, [x^i + i for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSR2" begin
    v = [@expr x^$i + $i for i = 1:9]
    m = SparseCSR(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(m, :x, test, SymbolicCache()) == SparseCSR(3, 3, [i * x^(i-1) for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSC1" begin
    v = [@expr x^$i + $i for i = 1:9]
    m = SparseCSC(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(m, test, SymbolicCache()) == SparseCSC(3, 3, [x^i + i for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSC2" begin
    v = [@expr x^$i + $i for i = 1:9]
    m = SparseCSC(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(m, :x, test, SymbolicCache()) == SparseCSC(3, 3, [i * x^(i-1) for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCOO1" begin
    v = [@expr x^$i + $i for i = 1:9]
    m = SparseCOO(3, 3, v, [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(m, test, SymbolicCache()) == SparseCOO(3, 3, [x^i + i for i = 1:10], [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCOO2" begin
    v = [@expr x^$i + $i for i = 1:9]
    m = SparseCOO(3, 3, v, [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(m, :x, test, SymbolicCache()) == SparseCOO(3, 3, [i * x^(i-1) for i = 1:10], [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicMat1" begin
    m = [@expr x^$i + $i for i = 1:3, j = 1:3]
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(m, test, SymbolicCache()) == [x^i + i for i = 1:3, j = 1:3]
end

@testset "SymbolicMat2" begin
    m = [@expr x^$i + $i for i = 1:3, j = 1:3]
    x = 10
    @env test begin
        x = x
    end
    @test symboliceval(m, :x, test, SymbolicCache()) == [i*x^(i-1) for i = 1:3, j = 1:3]
end

@testset "SymbolicVec3" begin
    m = @expr [1, x, 3]
    @test m[1].val == 1
    @test m[2].var == :x
    @test m[3].val == 3
end

@testset "SymbolicMat3" begin
    m = @expr [1 x 3; 3 4 y]
    @test m[1,1].val == 1
    @test m[1,2].var == :x
    @test m[1,3].val == 3
    @test m[2,1].val == 3
    @test m[2,2].val == 4
    @test m[2,3].var == :y
end

@testset "SymbolicDot1" begin
    e1 = @expr [x^2, y, 10]
    e2 = @expr [x^2, y, 10]
    expr = dot(e1, e2)
    x = 0.5
    y = 0.8
    @env test begin
        x = x
        y = y
    end
    @test symboliceval(expr, test, SymbolicCache()) == dot([x^2, y, 10], [x^2, y, 10])
end

@testset "SymbolicDot2" begin
    e1 = @expr [x^2, y, 10]
    e2 = @expr [x^2, y, 10]
    expr = dot(e1, e2)
    x = 0.5
    y = 0.8
    @env test begin
        x = x
        y = y
    end
    h = 0.0001
    @env test1 begin
        x = x + h
        y = y
    end
    @env test2 begin
        x = x - h
        y = y
    end
    ex = (symboliceval(expr, test1, SymbolicCache()) - symboliceval(expr, test2, SymbolicCache())) / (2*h)
    @test isapprox(symboliceval(expr, :x, test, SymbolicCache()), ex, atol=1.0e-5)
end

@testset "SymbolicDot3" begin
    e1 = @expr [x^2, y, 10]
    e2 = @expr [x^2, y, 10]
    expr = dot(e1, e2)
    x = 10.0
    y = 0.8
    @env test begin
        x = x
        y = y
    end
    # h = 0.00001
    # @env test1 begin
    #     x = x+h
    #     y = y
    # end
    # @env test2 begin
    #     x = x-h
    #     y = y
    # end
    # ex = (symboliceval(expr, test1, SymbolicCache()) - 2*symboliceval(expr, test, SymbolicCache()) + symboliceval(expr, test2, SymbolicCache())) / (h^2)
    # @test isapprox(ex, 4*3*x^2)
    @test isapprox(symboliceval(expr, (:x,:x), test, SymbolicCache()), 4*3*x^2)
end

@testset "SymbolicMat4" begin
    m = SparseCSR(@expr [0 x 0; 0 z y])
    println(m)
    x = 10.0
    y = 0.8
    z = 4
    @env test begin
        x = x
        y = y
        z = z
    end
    @env test2 begin
        x = 1.0
        y = 0.0
        z = 0.0
    end
    result = symboliceval(m, :x, test, SymbolicCache())
    expected = symboliceval(m, test2, SymbolicCache())
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat5" begin
    m = SparseCSC(@expr [0 x 0; 0 z y])
    println(m)
    x = 10.0
    y = 0.8
    z = 4
    @env test begin
        x = x
        y = y
        z = z
    end
    @env test2 begin
        x = 1.0
        y = 0.0
        z = 0.0
    end
    result = symboliceval(m, :x, test, SymbolicCache())
    expected = symboliceval(m, test2, SymbolicCache())
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat6" begin
    m = SparseCOO(@expr [0 x 0; 0 z y])
    println(m)
    x = 10.0
    y = 0.8
    z = 4
    @env test begin
        x = x
        y = y
        z = z
    end
    @env test2 begin
        x = 1.0
        y = 0.0
        z = 0.0
    end
    result = symboliceval(m, :x, test, SymbolicCache())
    expected = symboliceval(m, test2, SymbolicCache())
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat7" begin
    m = sparse(@expr [0 x 0; 0 z y])
    println(m)
    x = 10.0
    y = 0.8
    z = 4
    @env test begin
        x = x
        y = y
        z = z
    end
    @env test2 begin
        x = 1.0
        y = 0.0
        z = 0.0
    end
    result = symboliceval(m, :x, test, SymbolicCache())
    expected = symboliceval(m, test2, SymbolicCache())
    @test isapprox(expected, result)
end

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
