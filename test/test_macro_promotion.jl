@testset "Macro1" begin
    x = 5.6
    y = 10.1
    @bind :x => x
    @bind :y => y
    expr = @expr x^2 + 10*x*y + 4*y^2
    res = seval(expr, (:x,:y))
    @test res == 10.0
end

@testset "ops1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    x = 0.56
    y = 0.101
    @bind env begin
        :x => x
        :y => y
    end
    expr = @expr exp(x^2 + 10*x*y + 4*y^2)
    res = seval(expr, (:x,:y), env, cache)
    @test res == exp(x^2 + 10*x*y + 4*y^2) * (10*x + 8*y) * (2*x + 10*y) + exp(x^2 + 10*x*y + 4*y^2) * 10
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
