using SymbolicDiff
using Test

import SymbolicDiff: var, val

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = val(0.5)
    println(expr(x))
    println(expr(y))
    println(expr(z))
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = exp(x)
    a = val(0.5)
    println(x)
    println(y)
    println(expr(a * z))
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = exp(x)
    a = val(0.5)
    println(x)
    println(y)
    env = Dict()
    env[x] = 1.2
    env[y] = 2.2
    getvalue(a * z, env)
    println(env)
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = exp(x)
    a = val(0.5)
    b = a * z
    links = reverselinks(b * exp(a))
    println(links)
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = exp(x)
    a = val(0.5)
    b = a * z
    f = b * exp(a)
    println(reverselinks(f))
    list = getsort(f)
    println(list)
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = exp(x)
    a = val(0.5)
    b = a * z
    f = b * exp(a)
    println(params(f))
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    env = Dict()
    env[x] = 1.2
    env[y] = 2.2
    println(getvalue(y, y, env))
    println(getvalue(x, y, env))
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = exp(x)
    a = val(0.5)
    b = a * z * a
    f = b * exp(a)
    env = Dict()
    env[x] = 1.2
    env[y] = 2.2
    println(getvalue(b, z, env))
    println(getvalue(val(2) * z * a, env))
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = exp(x)
    a = val(0.5)
    b = a * z * y
    f = b * exp(a)
    env = Dict()
    env[x] = 1.2
    env[y] = 2.2
    gradcache = Dict()
    gradcache[f] = 1.0
    bpropagate(f, env, gradcache)
    println(gradcache)
    println(getvalue(f, x, env))
    println(getvalue(f, y, env))
end

@testset "SymbolicDiff1" begin
    x = var(:x)
    y = var(:y)
    z = y + log(x)
    env = Dict()
    env[x] = 1.2
    env[y] = 2.2
    gradcache = Dict()
    gradcache[z] = 1.0
    bpropagate(z, env, gradcache)
    println(gradcache)
    println(getvalue(z, x, env))
    println(getvalue(z, y, env))
end

@testset "SymbolicDiff1" begin
    x = val(1)
    y = val(1.5)
    println(promote(1, y))
    z = x * y
    println(typeof(x))
    println(typeof(y))
    println(typeof(z))
end
