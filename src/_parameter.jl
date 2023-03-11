
export variable
export value
export expr
export getvalue
export getsort
export getall
export params

export getvalue

export bpropagate

export reverselinks
# export reverselinks!

export grad

import Base

abstract type AbstractSymbolic{T} end
abstract type AbstractSymbolicVariable{T} <: AbstractSymbolic{T} end
abstract type AbstractSymbolicValue{T} <: AbstractSymbolic{T} end
abstract type AbstractSymbolicExpression{T} <: AbstractSymbolic{T} end

# abstract type AbstractFunction end

function expr(x::AbstractSymbolic)
    throw("error")
end

function next(x::AbstractSymbolic)
    throw("error")
end

function Base.show(io::IO, x::AbstractSymbolic)
    # Base.show(io, objectid(x))
    Base.show(io, expr(x))
end

function Base.show(io::IO, x::AbstractSymbolicVariable)
    Base.show(io, name(x))
end

function Base.show(io::IO, x::AbstractSymbolicValue)
    Base.show(io, "val($(value(x)))")
end

# struct NothingExpression <: AbstractSymbolicExpression end

mutable struct SymbolicVariable{T} <: AbstractSymbolicVariable{T}
    params::Set{AbstractSymbolic}
    name::Symbol

    function SymbolicVariable(name::Symbol, ::Type{T}) where T
        x = new{T}()
        x.name = name
        x.params = Set{AbstractSymbolic}([x])
        x
    end
end

function var(x::Symbol, ::Type{T} = Float64) where T
    SymbolicVariable(x, T)
end

function name(x::AbstractSymbolicVariable)
    x.name
end

function params(x::AbstractSymbolic)
    x.params
end

# function creator!(x::AbstractSymbolicVariable, f::AbstractSymbolic)
#     x.creator = f
# end

mutable struct SymbolicValue{T} <: AbstractSymbolicValue{T}
    params::Set{AbstractSymbolic}
    data::T

    function SymbolicValue{T}(data::T) where T
        x = new{T}()
        x.data = data
        x.params = Set{AbstractSymbolic}([x])
        x
    end
end

function val(x::T) where T
    SymbolicValue{T}(x)
end

# function creator!(x::AbstractSymbolicValue, f::AbstractSymbolic)
#     x.creator = f
# end

function expr(x::AbstractSymbolicVariable)
    name(x)
end

function expr(x::AbstractSymbolicValue)
    value(x)
end

mutable struct SymbolicExpression{T} <: AbstractSymbolicExpression{T}
    params::Set{AbstractSymbolic}
    op::Symbol
    args::Vector{AbstractSymbolic}

    function SymbolicExpression{T}(params, op, args) where T
        f = new{T}(params, op, args)
        push!(f.params, f)
        f
    end
end

function symbolicexpression(op::Symbol, x1::AbstractSymbolic{T}, xs...) where T
    s = union(x1.params, [u.params for u = xs]...)
    SymbolicExpression{T}(s, op, AbstractSymbolic[x1, xs...])
end

function Base.:+(x::AbstractSymbolic{T}, y::AbstractSymbolic{T}) where T
    symbolicexpression(:+, x, y)
end

function Base.:-(x::AbstractSymbolic{T}, y::AbstractSymbolic{T}) where T
    symbolicexpression(:-, x, y)
end

function Base.:*(x::AbstractSymbolic{T}, y::AbstractSymbolic{T}) where T
    symbolicexpression(:*, x, y)
end

function Base.:/(x::AbstractSymbolic{T}, y::AbstractSymbolic{T}) where T
    symbolicexpression(:/, x, y)
end

function Base.:+(x::AbstractSymbolic{T}, y::AbstractSymbolic{S}) where {T,S}
    symbolicexpression(:+, promote(x, y)...)
end

function Base.:-(x::AbstractSymbolic{T}, y::AbstractSymbolic{S}) where {T,S}
    symbolicexpression(:-, promote(x, y)...)
end

function Base.:*(x::AbstractSymbolic{T}, y::AbstractSymbolic{S}) where {T,S}
    symbolicexpression(:*, promote(x, y)...)
end

function Base.:/(x::AbstractSymbolic{T}, y::AbstractSymbolic{S}) where {T,S}
    symbolicexpression(:/, promote(x, y)...)
end

function Base.exp(x::AbstractSymbolic{T}) where T
    symbolicexpression(:exp, x)
end

function Base.log(x::AbstractSymbolic{T}) where T
    symbolicexpression(:log, x)
end

function Base.sqrt(x::AbstractSymbolic{T}) where T
    symbolicexpression(:sqrt, x)
end

function expr(x::AbstractSymbolicExpression)
    Expr(:call, x.op, [expr(u) for u = x.args]...)
end

function getvalue(x::AbstractSymbolicVariable, env)
    get(env, x) do
        throw("$(name(x)) is not defined yet.")
    end
end

function value(x::AbstractSymbolicValue)
    x.data
end

function getvalue(x::AbstractSymbolicValue{T}, env)::T where T
    value(x)
end

function getvalue(x::AbstractSymbolicExpression{T}, env)::T where T
    get!(env, x) do
        xs = [getvalue(u, env) for u = x.args]
        eval(Expr(:call, x.op, xs...))
    end
end

function reverselinks(x::AbstractSymbolicExpression)
    links = Dict{AbstractSymbolic,Vector{AbstractSymbolic}}()
    reverselinks!(links, x)
    links
end

function reverselinks!(links::Dict{AbstractSymbolic,Vector{AbstractSymbolic}}, x::AbstractSymbolicExpression)
    for u = x.args
        h = get(links, u, AbstractSymbolic[])
        push!(h, x)
        links[u] = h
        reverselinks!(links, u)
    end
end

function reverselinks!(links::Dict{AbstractSymbolic,Vector{AbstractSymbolic}}, x::AbstractSymbolicValue)
end

function reverselinks!(links::Dict{AbstractSymbolic,Vector{AbstractSymbolic}}, x::AbstractSymbolicVariable)
end

function getvalue(f::AbstractSymbolicExpression{T}, dvar::AbstractSymbolic, env)::T where T
    if f === dvar
        return T(1)
    end
    if !in(dvar, params(f))
        return T(0)
    end
    key = (f, dvar)
    get!(env, key) do
        _grad(Val(f.op), f, dvar, env)
    end
end

function getvalue(f::AbstractSymbolicVariable{T}, dvar::AbstractSymbolicVariable, env)::T where T
    if f === dvar
        T(1)
    else
        T(0)
    end
end

function getvalue(f::AbstractSymbolicValue{T}, dvar::AbstractSymbolicValue, env)::T where T
    if f === dvar
        T(1)
    else
        T(0)
    end
end

function getvalue(f::AbstractSymbolic{T}, dvar::AbstractSymbolic, env)::T where T
    T(0)
end

function _grad(::Val{:+}, f::AbstractSymbolicExpression, dvar::AbstractSymbolic, env)
    args = [getvalue(x, dvar, env) for x = f.args]
    +(args...)
end

function _grad(::Val{:-}, f::AbstractSymbolicExpression, dvar::AbstractSymbolic, env)
    args = [getvalue(x, dvar, env) for x = f.args]
    -(args...)
end

function _grad(::Val{:*}, f::AbstractSymbolicExpression, dvar::AbstractSymbolic, env)
    args = [getvalue(x, env) for x = f.args]
    dargs = [getvalue(x, dvar, env) for x = f.args]
    ret = dargs[1]
    s = args[1]
    for i = 2:length(args)
        ret *= args[i]
        ret += s * dargs[i]
        (i == length(args)) && break
        s *= args[i]
    end
    ret
end

function _grad(::Val{:/}, f::AbstractSymbolicExpression, dvar::AbstractSymbolic, env)
    x,y = [getvalue(x, env) for x = f.args]
    dx,dy = [getvalue(x, dvar, env) for x = f.args]
    (dx * y - x * dy) / y^2
end

function _grad(::Val{:^}, f::AbstractSymbolicExpression, dvar::AbstractSymbolic, env)
    x,y = [getvalue(x, env) for x = f.args]
    dx,dy = [getvalue(x, dvar, env) for x = f.args]
    x^(y-1) * (x * log(x) * dy + y * dx)
end

function _grad(::Val{:exp}, f::AbstractSymbolicExpression, dvar::AbstractSymbolic, env)
    x, = [getvalue(x, env) for x = f.args]
    dx, = [getvalue(x, dvar, env) for x = f.args]
    exp(x) * dx
end

function _grad(::Val{:log}, f::AbstractSymbolicExpression, dvar::AbstractSymbolic, env)
    x, = [getvalue(x, env) for x = f.args]
    dx, = [getvalue(x, dvar, env) for x = f.args]
    dx / x
end

function _grad(::Val{:sqrt}, f::AbstractSymbolicExpression, dvar::AbstractSymbolic, env)
    x, = [getvalue(x, env) for x = f.args]
    dx, = [getvalue(x, dvar, env) for x = f.args]
    dx /(2 * sqrt(x))
end

# function _eval(::Val{:sum}, f::SymbolicExpression{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
#     dx, = [seval(x, dvar, env, cache) for x = f.args]
#     sum(dx)
# end

# function _eval(::Val{:dot}, f::SymbolicExpression{Tv}, dvar::Symbol, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
#     x,y = [seval(x, env, cache) for x = f.args]
#     dx,dy = [seval(x, dvar, env, cache) for x = f.args]
#     dot(x,dy) + dot(dx,y)
# end

function bpropagate(f::AbstractSymbolic, env, gradcache)
    cs = getsort(f)
    for f = cs
        dy = gradcache[f]
        if typeof(f) <: AbstractSymbolicExpression
            for x = f.args
                tmp = get(gradcache, x, 0.0)
                tmp += dy * getvalue(f, x, env)
                gradcache[x] = tmp
            end
        end
    end
end

next(x::AbstractSymbolicExpression) = x.args
next(x::AbstractSymbolicValue) = []
next(x::AbstractSymbolicVariable) = []

function getsort(x::AbstractSymbolic{T}) where T
    getsort(getall(x))
end

function getsort(v::Vector{AbstractSymbolic{T}}) where T
    tsort(v)
end

function getall(root::AbstractSymbolic)
    [u for u = params(root)]
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, x::AbstractSymbolicVariable{T}) where T
    x
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, x::AbstractSymbolicValue{T}) where T
    x
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, x::AbstractSymbolicExpression{T}) where T
    x
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, x::AbstractSymbolicVariable{S}) where {T,S}
    SymbolicVariable{T}(x.params, x.name)
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, x::AbstractSymbolicValue{S}) where {T,S}
    SymbolicValue{T}(T(x.data))
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, x::AbstractSymbolicExpression{S}) where {T,S}
    SymbolicExpression{T}(x.params, x.op, x.args)
end

function Base.convert(::Type{<:AbstractSymbolic{T}}, x::S) where {T<:Number,S<:Number}
    SymbolicValue{T}(T(x))
end

"""
promotion
"""

function Base.promote_rule(::Type{<:AbstractSymbolic{T}}, ::Type{S}) where {T,S}
    AbstractSymbolic{promote_type(T,S)}
end

function Base.promote_rule(::Type{<:AbstractSymbolic{T}}, ::Type{<:AbstractSymbolic{S}}) where {T,S}
    AbstractSymbolic{promote_type(T,S)}
end
