@testset "vector1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = [@expr(x), 1, 1.0]
    println(x)
end

@testset "vector2" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = [@expr(x), 1, 1.0]
    println(convert(AbstractSymbolic{Float64}, x))
end

@testset "SymbolicVector1" begin
    @bind x = 10
    v = [x + i for i = 1:10]
    @test seval(v) == [seval(x)+i for i = 1:10]
end

@testset "SymbolicVector1" begin
    @bind x = 10
    v = [x^i + i for i = 1:10]
    @test seval(v, :x) == [i * seval(x)^(i-1) for i = 1:10]
end

@testset "SymbolicVec3" begin
    m = @expr [1, x, 3]
    @test m[1].val == 1
    @test m[2].var == :x
    @test m[3].val == 3
end

@testset "SymbolicVec4" begin
    test = SymbolicEnv()
    m = @expr [1, x, y]
    @bind test x = 10
    @bind test y = 20
    result = seval(m[1:2], test)
    @test result == [1, 10]
end

@testset "SymbolicVec5" begin
    test = SymbolicEnv()
    m = @expr [1, x, y]
    expr = sum(m)
    println(expr)
    @bind test x = 10
    @bind test y = 20
    result = seval(expr, test)
    @test result == 31.0
    result = seval(expr, :x, test)
    @test result == 1.0
end

@testset "SymbolicDot1" begin
    test = SymbolicEnv()
    e1 = @expr [x^2, y, 10]
    e2 = @expr [x^2, y, 10]
    expr = dot(e1, e2)
    println(expr)
    x = 0.5
    y = 0.8
    @bind test x = x
    @bind test y = y
    @test seval(expr, test, SymbolicCache()) == dot([seval(x,test)^2, seval(y,test), 10], [seval(x,test)^2, seval(y,test), 10])
end

@testset "SymbolicDot2" begin
    test = SymbolicEnv()
    e1 = @expr [x^2, y, 10]
    e2 = @expr [x^2, y, 10]
    expr = dot(e1, e2)
    x0 = 0.5
    y0 = 0.8
    @bind test x = x0
    @bind test y = y0
    h = 0.0001
    test1 = SymbolicEnv()
    @bind test1 begin
        x = x0 + h
        y = y0
    end
    test2 = SymbolicEnv()
    @bind test2 begin
        x = x0 - h
        y = y0
    end
    ex = (seval(expr, test1, SymbolicCache()) - seval(expr, test2, SymbolicCache())) / (2*h)
    @test isapprox(seval(expr, :x, test, SymbolicCache()), ex, atol=1.0e-5)
end

@testset "SymbolicDot3" begin
    test = SymbolicEnv()
    e1 = @expr [x^2, y, 10]
    e2 = @expr [x^2, y, 10]
    expr = dot(e1, e2)
    x0 = 10.0
    y0 = 0.8
    @bind test begin
        x = x0
        y = y0
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
    # ex = (seval(expr, test1, SymbolicCache()) - 2*seval(expr, test, SymbolicCache()) + seval(expr, test2, SymbolicCache())) / (h^2)
    # @test isapprox(ex, 4*3*x^2)
    @test isapprox(seval(expr, (:x,:x), test), 4*3*x0^2)
end

@testset "SymbolicPlus1" begin
    test = SymbolicEnv()
    e1 = convert(AbstractVectorSymbolic{Float64}, @expr [x^2, y, 10])
    e2 = convert(AbstractVectorSymbolic{Float64}, @expr [x, y^2, 10])
    expr = e1 + e2
    println(expr)
    x0 = 10.0
    y0 = 0.8
    @bind test begin
        x = x0
        y = y0
    end
    println(seval(expr, test))
    println(seval(expr[1], test))
    println(seval(expr[1:2], test))
    println(seval(expr, :x, test))
    println(seval(expr[1], :x, test))
    println(seval(expr[1:2], :x, test))
    println(seval(expr, (:x,:y), test))
    println(seval(expr[1], (:x,:y), test))
    println(seval(expr[1:2], (:x,:y), test))
    # @test isapprox(seval(expr, (:x,:x), test), 4*3*x0^2)
end

@testset "SymbolicDot5" begin
    @bind begin
        x = 4
        y = 3
    end
    v1 = [x, y]
    v2 = [x, 8]
    println(seval(dot(v1, v2)))
    println(seval(dot(v1, v2), :x))
    println(seval(dot(v1, v2), :y))
    println(seval(dot(v1, v2), (:x,:y)))
end
