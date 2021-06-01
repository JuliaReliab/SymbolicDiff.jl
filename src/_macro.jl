"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

macro vars(params...)
    body = [Expr(:(=), esc(x), esc(Expr(:call, :symbolic, Expr(:quote, x)))) for x = params]
    push!(body, Expr(:tuple, [esc(x) for x = params]...))
    Expr(:block, body...)
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
