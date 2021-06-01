"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

"""
symboliceval(f, dvar, cache)
Return the first derivative of expr f with respect to dvar
"""

function symeval(f::SymbolicValue{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    Tv(0)
end

function symeval(f::SymbolicVariable{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    f.var == dvar ? 1 : 0
end

function symeval(f::AbstractSymbolic{Tv}, dvar::Symbol, cache::SymbolicCache) where Tv
    (dvar in f.params) || return 0
    get(cache, (f,dvar)) do
        retval = _eval(Val(f.op), f, dvar, cache)
        cache[(f,dvar)] = retval
    end
end

"""
_eval(::Val{xx}, dvar, f, cache)

Dispached function to evaluate the first derivative of f
"""

function _eval(::Val{:+}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    args = [symeval(x, dvar, cache) for x = f.args]
    +(args...)
end

function _eval(::Val{:-}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    args = [symeval(x, dvar, cache) for x = f.args]
    -(args...)
end

function _eval(::Val{:*}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    args = [symeval(x, cache) for x = f.args]
    dargs = [symeval(x, dvar, cache) for x = f.args]
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

function _eval(::Val{:/}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    x,y = [symeval(x, cache) for x = f.args]
    dx,dy = [symeval(x, dvar, cache) for x = f.args]
    (dx * y - x * dy) / y^2
end

function _eval(::Val{:^}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    x,y = [symeval(x, cache) for x = f.args]
    dx,dy = [symeval(x, dvar, cache) for x = f.args]
    x^(y-1) * (x * log(x) * dy + y * dx)
end

function _eval(::Val{:exp}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    x, = [symeval(x, cache) for x = f.args]
    dx, = [symeval(x, dvar, cache) for x = f.args]
    exp(x) * dx
end

function _eval(::Val{:log}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    x, = [symeval(x, cache) for x = f.args]
    dx, = [symeval(x, dvar, cache) for x = f.args]
    dx / x
end

function _eval(::Val{:sqrt}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    x, = [symeval(x, cache) for x = f.args]
    dx, = [symeval(x, dvar, cache) for x = f.args]
    dx /(2 * sqrt(x))
end

function _eval(::Val{:dot}, f::SymbolicExpression{Tv}, dvar::Symbol, cache::SymbolicCache)::Tv where Tv
    x,y = [symeval(x, cache) for x = f.args]
    dx,dy = [symeval(x, dvar, cache) for x = f.args]
    dot(x,dy) + dot(dx,y)
end
