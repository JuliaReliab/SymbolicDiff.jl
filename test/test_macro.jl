@testset "Macro1" begin
    cache = SymbolicCache()
    @vars x y
    x => 5.6
    y => 10.1
    expr = x^2 + 10*x*y + 4*y^2
    res = symeval(expr, (:x,:y), cache)
    @test res == 10.0
end

@testset "ops1" begin
    cache = SymbolicCache()
    @vars x y
    x => 0.56
    y => 0.101
    expr = exp(x^2 + 10*x*y + 4*y^2)
    res = symeval(expr, (:x,:y), cache)
    @test res == symeval(exp(x^2 + 10*x*y + 4*y^2) * (10*x + 8*y) * (2*x + 10*y) + exp(x^2 + 10*x*y + 4*y^2) * 10)
end

@testset "lam1" begin
    cache = SymbolicCache()
    @vars t lam1 lam2
    t => rand()
    lam1 => rand()
    lam2 => rand()
    expr = exp(-lam1*t) - (lam1/lam2) * exp(-lam1*t) * (exp(-lam2*t) - 1)
    res1 = symeval(expr, :lam1, cache)
    @test res1 ≈ symeval(-t*exp(-lam1*t) - (1/lam2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(lam1/lam2)*exp(-lam1*t)*(exp(-lam2*t)-1))
    res2 = symeval(expr, :lam2, cache)
    @test res2 ≈ symeval((lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t))
    res3 = symeval(expr, (:lam2,:lam1), cache)
    res4 = symeval(expr, (:lam1,:lam2), cache)
    @test isapprox(res3, res4)
    @test res3 ≈ symeval((1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t))
    @test res4 ≈ symeval((1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) + t*(1/lam2)*exp(-lam1*t)*exp(-lam2*t) - t*(lam1/lam2^2)*exp(-lam1*t)*(exp(-lam2*t)-1) - t^2*(lam1/lam2)*exp(-lam1*t)*exp(-lam2*t))
end
