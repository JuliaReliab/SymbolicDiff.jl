@testset "Macro1" begin
    @bind begin
        x = 5.6
        y = 10.1
    end
    expr = x^2 + 10*x*y + 4*y^2
    res = seval(expr, (x,y))
    @test res == 10.0
end

@testset "ops1" begin
    env = SymbolicEnv()
    cache = SymbolicCache()
    @bind env begin
        x = 0.56
        y = 0.101
    end
    expr = exp(x^2 + 10*x*y + 4*y^2)
    res = seval(expr, (x,y), env, cache)
    @test res == seval(exp(x^2 + 10*x*y + 4*y^2) * (10*x + 8*y) * (2*x + 10*y) + exp(x^2 + 10*x*y + 4*y^2) * 10, env)
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

@testset "Var1" begin
    @bind begin
        x = 0.8
        y = 0.9
    end
    z = x + y
    result = seval(z)
    @test result == 0.8 + 0.9
end

@testset "Var3" begin
    @bind begin
        x = 0.8
        y = 0.9
    end
    z = x + y
    result = seval(z, x)
    @test result == 1.0
end