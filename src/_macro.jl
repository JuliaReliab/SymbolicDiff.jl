"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""


"""
@env(envname, block)

Set parameter values in the block to the environment

Example:
@env env1 begin
    x = 1.0
    y = 2.0
end
"""

macro env(envname, block)
    body = []
    push!(body, :($(envname) = SymbolicEnv()))
    for x = block.args
        _parameter(x, envname, body)
    end
    esc(Expr(:block, body...))
end

function _parameter(x::Any, envname, body)
    x
end

function _parameter(x::Expr, envname, body)
    if Meta.isexpr(x, :(=))
        var = x.args[1]
        val = x.args[2]
        push!(body, :($(envname)[$(Expr(:quote, var))] = $(val)))
    end
end

function _parameter(x::Symbol, envname, body)
    push!(body, _defparam(x))
    var = x
    push!(body, :(get($(envname), $(var), 0.0)))
end

"""
@expr x

Make SymbolicExpression

Example:
f = @expr x^2 + y
"""

macro expr(x)
    esc(Expr(:call, :symbolic, Expr(:quote, x)))
end

