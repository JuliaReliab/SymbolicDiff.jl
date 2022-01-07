"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

"""
@vars(parms...)

generate symbolic variables

Example:
@vars x y
"""

macro vars(params...)
    if length(params) == 1 && Meta.isexpr(params[1], :block)
        args = params[1].args
    else
        args = params
    end
    body = []
    xargs = []
    for x = args
        if typeof(x) == Symbol
            push!(body, Expr(:(=), esc(x), esc(Expr(:call, :symbolic, Expr(:quote, x)))))
            push!(xargs, esc(x))
        else
            push!(body, x)
        end
    end
    push!(body, Expr(:tuple, [x for x = xargs]...))
    Expr(:block, body...)
end

"""
@bind(envname, block)

Set parameter values in the block to the environment

Example:
@bind env1 x = 1.0

@bind env1 begin
    x = 1.0
    y = 2.0
end
"""

macro bind(x...)
    if length(x) == 1
        envname = :globalenv
        arg = x[1]
    elseif length(x) == 2
        envname = x[1]
        arg = x[2]
    else
        throw(ErrorException("@bind should take 1 or 2 arguments"))
    end

    vars = []
    if Meta.isexpr(arg, :block)
        body = [_parameter(x, envname, vars) for x = arg.args]
        expr = Expr(:block, body...)
    else
        expr = _parameter(arg, envname, vars)
    end

    unique!(vars)
    esc(Expr(:block,
        expr,
        [Expr(:(=), x, Expr(:call, :symbolic, Expr(:quote, x))) for x = vars]...,
        Expr(:tuple, vars...)
        ))
end

function _parameter(x::Any, envname, vars)
    x
end

function _parameter(x::Symbol, envname, vars)
    push!(vars, x)
    nothing
end

function _parameter(x::Expr, envname, vars)
    if Meta.isexpr(x, :(=))
        var = x.args[1]
        push!(vars, var)
        val = x.args[2]
        :($(envname)[$(Expr(:quote, var))] = $(val))
    else
        throw(ErrorException("invalid expression for @bind."))
    end
end

"""
@expr x

Make SymbolicExpression

Example:
f = @expr x^2 + y
"""

macro expr(x)
    esc(_genexpr(x))
end

function _genexpr(x)
    if Meta.isexpr(x, :vect)
        Expr(:vect, [_genexpr(u) for u = x.args]...)
    elseif Meta.isexpr(x, :vcat)
        Expr(:vcat, [_genexpr(u) for u = x.args]...)
    elseif Meta.isexpr(x, :row)
        Expr(:row, [_genexpr(u) for u = x.args]...)
    else
        Expr(:call, :symbolic, Expr(:quote, x))
    end
end
