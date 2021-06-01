@testset "vector1" begin
    cache = SymbolicCache()
    @vars x
    v = [x, x, 1.0]
    println(v)
    @test v[1].val === v[2].val
end

@testset "SymbolicVector1" begin
    @vars x
    v = [x + i for i = 1:10]
    x => 10
    println(v)
    println(symeval(x))
    println(symeval(v[1]))
    @test symeval(v, SymbolicCache()) == [10 + i for i = 1:10]
end

@testset "SymbolicVector2" begin
    @vars x
    v = [x^i + i for i = 1:10]
    x => 10
    @test symeval(v, :x, SymbolicCache()) == [symeval(i * x^(i-1)) for i = 1:10]
end

@testset "SymbolicCSR1" begin
    @vars x
    v = [x^i + i for i = 1:9]
    m = SparseCSR(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x => 10
    @test symeval(m, SymbolicCache()) == SparseCSR(3, 3, [symeval(x^i + i) for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSR2" begin
    @vars x
    v = [x^i + i for i = 1:9]
    m = SparseCSR(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x => 10
    @test symeval(m, :x, SymbolicCache()) == SparseCSR(3, 3, [symeval(i * x^(i-1)) for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSC1" begin
    @vars x
    v = [x^i + i for i = 1:9]
    m = SparseCSC(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x => 10
    @test symeval(m, SymbolicCache()) == SparseCSC(3, 3, [symeval(x^i + i) for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSC2" begin
    @vars x
    v = [x^i + i for i = 1:9]
    m = SparseCSC(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x => 10
    @test symeval(m, :x, SymbolicCache()) == SparseCSC(3, 3, [symeval(i * x^(i-1)) for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCOO1" begin
    @vars x
    v = [x^i + i for i = 1:9]
    m = SparseCOO(3, 3, v, [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x => 10
    @test symeval(m, SymbolicCache()) == SparseCOO(3, 3, [symeval(x^i + i) for i = 1:10], [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCOO2" begin
    @vars x
    v = [x^i + i for i = 1:9]
    m = SparseCOO(3, 3, v, [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    x => 10
    @test symeval(m, :x, SymbolicCache()) == SparseCOO(3, 3, [symeval(i * x^(i-1)) for i = 1:10], [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicMat1" begin
    @vars x
    m = [x^i + j for i = 1:3, j = 1:3]
    x => 10
    @test symeval(m, SymbolicCache()) == [symeval(x^i + j) for i = 1:3, j = 1:3]
end

@testset "SymbolicMat2" begin
    @vars x
    m = [x^i + j for i = 1:3, j = 1:3]
    x => 10
    @test symeval(m, :x, SymbolicCache()) == [symeval(i*x^(i-1)) for i = 1:3, j = 1:3]
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
    @vars x y
    e1 = [x^2, y, 10]
    e2 = [x^2, y, 10]
    expr = dot(e1, e2)
    x => 0.5
    y => 0.8
    @test symeval(expr, SymbolicCache()) == dot(symeval([x^2, y, 10]), symeval([x^2, y, 10]))
end

@testset "SymbolicDot2" begin
    @vars x y
    e1 = [x^2, y, 10]
    e2 = [x^2, y, 10]
    expr = dot(e1, e2)

    h = 0.0001
    x => 0.5 + h
    y => 0.8
    test1 = symeval(expr, SymbolicCache())

    x => 0.5 - h
    y => 0.8
    test2 = symeval(expr, SymbolicCache())

    ex = (test1 - test2) / (2*h)

    x => 0.5
    y => 0.8
    test = symeval(expr, SymbolicCache())
    @test isapprox(symeval(expr, :x, SymbolicCache()), ex, atol=1.0e-5)
end

@testset "SymbolicDot3" begin
    @vars x y
    e1 = [x^2, y, 10]
    e2 = [x^2, y, 10]
    expr = dot(e1, e2)

    x => 10.0
    y => 0.8

    @test isapprox(symeval(expr, (:x,:x), SymbolicCache()), symeval(4*3*x^2))
end

@testset "SymbolicMat4" begin
    @vars x y z
    m = SparseCSR([0 x 0; 0 z y])
    println(m)
    x => 10.0
    y => 0.8
    z => 4
    result = symeval(m, :x, SymbolicCache())
    x => 1.0
    y => 0.0
    z => 0.0
    expected = symeval(m, SymbolicCache())
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat5" begin
    @vars x y z
    m = SparseCSC([0 x 0; 0 z y])
    println(m)
    x => 10.0
    y => 0.8
    z => 4
    result = symeval(m, :x, SymbolicCache())
    
    x => 1.0
    y => 0.0
    z => 0.0
    expected = symeval(m, SymbolicCache())
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat6" begin
    @vars x y z
    m = SparseCOO([0 x 0; 0 z y])
    println(m)
    x => 10.0
    y => 0.8
    z => 4
    result = symeval(m, :x, SymbolicCache())

    x => 1.0
    y => 0.0
    z => 0.0
    expected = symeval(m, SymbolicCache())
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat7" begin
    @vars x y z
    m = sparse([0 x 0; 0 z y])
    println(m)
    x => 10.0
    y => 0.8
    z => 4
    result = symeval(m, :x, SymbolicCache())
    x => 1.0
    y => 0.0
    z => 0.0
    expected = symeval(m, SymbolicCache())
    @test isapprox(expected, result)
end
