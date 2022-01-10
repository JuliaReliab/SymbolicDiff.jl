@testset "SymbolicCSR1" begin
    @bind x = 10
    v = [x^i + i for i = 1:9]
    m = SparseCSR(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    println(typeof(m))
    println(m)
    @test seval(m) == SparseCSR(3, 3, [seval(x)^i + i for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSR2" begin
    @bind x = 10
    v = [x^i + i for i = 1:9]
    m = convert(AbstractMatrixSymbolic{Float64}, SparseCSR(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3]))
    println(typeof(m))
    println(m)
    @test seval(m) == SparseCSR(3, 3, [seval(x)^i + i for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSC1" begin
    @bind x = 10
    v = [x^i + i for i = 1:9]
    m = SparseCSC(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    @test seval(m) == SparseCSC(3, 3, [seval(x)^i + i for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCOO1" begin
    @bind x = 10
    v = [x^i + i for i = 1:9]
    m = SparseCOO(3, 3, v, [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    @test seval(m) == SparseCOO(3, 3, [seval(x)^i + i for i = 1:10], [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSR2" begin
    @bind x = 10
    v = [x^i + i for i = 1:9]
    m = SparseCSR(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    @test seval(m, :x) == SparseCSR(3, 3, [i * seval(x)^(i-1) for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCSC2" begin
    @bind x = 10
    v = [x^i + i for i = 1:9]
    m = SparseCSC(3, 3, v, [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    @test seval(m, :x) == SparseCSC(3, 3, [i * seval(x)^(i-1) for i = 1:10], [1, 4, 7, 10], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicCOO2" begin
    @bind x = 10
    v = [x^i + i for i = 1:9]
    m = SparseCOO(3, 3, v, [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
    @test seval(m, :x) == SparseCOO(3, 3, [i * seval(x)^(i-1) for i = 1:10], [1, 1, 1, 2, 2, 2, 3, 3, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3])
end

@testset "SymbolicMat1" begin
    @bind x = 10
    m = [x^i + i for i = 1:3, j = 1:3]
    result = seval(m)
    @test result == [seval(x)^i + i for i = 1:3, j = 1:3]
end

@testset "SymbolicMat2" begin
    @bind x = 10
    m = [x^i + i for i = 1:3, j = 1:3]
    @test seval(m, :x) == [i*seval(x)^(i-1) for i = 1:3, j = 1:3]
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

@testset "SymbolicMat4" begin
    m = SparseCSR(@expr [0 x 0; 0 z y])
    println(m)
    x0 = 10.0
    y0 = 0.8
    z0 = 4
    test = SymbolicEnv()
    @bind test begin
        x = x0
        y = y0
        z = z0
    end
    test2 = SymbolicEnv()
    @bind test2 begin
        x = 1.0
        y = 0.0
        z = 0.0
    end
    result = seval(m, :x, test)
    expected = seval(m, test2)
    println(typeof(result))
    println(typeof(expected))
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat5" begin
    m = SparseCSC(@expr [0 x 0; 0 z y])
    println(m)
    x0 = 10.0
    y0 = 0.8
    z0 = 4
    test = SymbolicEnv()
    @bind test begin
        x = x0
        y = y0
        z = z0
    end
    test2 = SymbolicEnv()
    @bind test2 begin
        x = 1.0
        y = 0.0
        z = 0.0
    end
    result = seval(m, :x, test)
    expected = seval(m, test2)
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat6" begin
    m = SparseCOO(@expr [0 x 0; 0 z y])
    println(m)
    x0 = 10.0
    y0 = 0.8
    z0 = 4
    test = SymbolicEnv()
    @bind test begin
        x = x0
        y = y0
        z = z0
    end
    test2 = SymbolicEnv()
    @bind test2 begin
        x = 1.0
        y = 0.0
        z = 0.0
    end
    result = seval(m, :x, test)
    expected = seval(m, test2)
    @test isapprox(expected.val, result.val)
end

@testset "SymbolicMat7" begin
    m = sparse(@expr [0 x 0; 0 z y])
    println(m)
    x0 = 10.0
    y0 = 0.8
    z0 = 4
    test = SymbolicEnv()
    @bind test begin
        x = x0
        y = y0
        z = z0
    end
    test2 = SymbolicEnv()
    @bind test2 begin
        x = 1.0
        y = 0.0
        z = 0.0
    end
    result = seval(m, :x, test)
    expected = seval(m, test2)
    @test isapprox(expected, result)
end
