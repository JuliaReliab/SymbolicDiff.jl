"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

export symboliceval

"""
symboliceval(f, (dvar1, dver2), env, cache)
Return the second derivative of expr f with respect to dvar1 and dver2
"""

function symboliceval(f::SymbolicValue{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    Tv(0)
end

function symboliceval(f::SymbolicVariable, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    0
end

function symboliceval(f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    (dvar[1] in f.params) || (dvar[2] in f.params) || return 0
    get(cache, (f,dvar)) do
        retval = _eval(Val(f.op), f, dvar, env, cache)
        cache[(f,dvar)] = retval
    end
end

"""
_eval(::Val{xx}, dvar, f, env, cache)

Dispached function to evaluate the second derivative of f
"""

function _eval(::Val{:+}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    args = [symboliceval(x, dvar, env, cache) for x = f.args]
    +(args...)
end

function _eval(::Val{:-}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    args = [symboliceval(x, dvar, env, cache) for x = f.args]
    -(args...)
end

function _eval(::Val{:*}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    args = [symboliceval(x, env, cache) for x = f.args]
    dargs_a = [symboliceval(x, dvar[1], env, cache) for x = f.args]
    dargs_b = [symboliceval(x, dvar[2], env, cache) for x = f.args]
    dargs_ab = [symboliceval(x, dvar, env, cache) for x = f.args]

    ret = dargs_ab[1]
    s = args[1]
    s_a = dargs_a[1]
    s_b = dargs_b[1]
    for i = 2:length(args)
        ret *= args[i]
        ret += s * dargs_ab[i]
        ret += s_a * dargs_b[i]
        ret += s_b * dargs_a[i]
        (i == length(args)) && break
        s_a *= args[i]
        s_b *= args[i]
        s_a += s * dargs_a[i]
        s_b += s * dargs_b[i]
        s *= args[i]
    end
    ret
end

function _eval(::Val{:/}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    x,y = [symboliceval(x, env, cache) for x = f.args]
    dx_a,dy_a = [symboliceval(x, dvar[1], env, cache) for x = f.args]
    dx_b,dy_b = [symboliceval(x, dvar[2], env, cache) for x = f.args]
    dx_ab,dy_ab = [symboliceval(x, dvar, env, cache) for x = f.args]
    ((dx_ab * y + dx_a * dy_b - dx_b * dy_a - x * dy_ab) * y + (dx_a * y - x * dy_a) * 2 * dy_b) / y^3
end

function _eval(::Val{:^}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    x,y = [symboliceval(x, env, cache) for x = f.args]
    dx_a,dy_a = [symboliceval(x, dvar[1], env, cache) for x = f.args]
    dx_b,dy_b = [symboliceval(x, dvar[2], env, cache) for x = f.args]
    dx_ab,dy_ab = [symboliceval(x, dvar, env, cache) for x = f.args]
    f = x^y
    f_a = f * (dy_a * x * log(x) + y * dx_a) / x
    f_b = f * (dy_b * x * log(x) + y * dx_b) / x
    f_ab = (f_b * (dy_a * x * log(x) + y * dx_a) - f_a * dx_b + f * (dy_ab * x * log(x) + dy_a * dx_b * (1 + log(x)) + dx_a * dy_b + y * dx_ab)) / x
    f_ab
end

function _eval(::Val{:exp}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    x, = [symboliceval(x, env, cache) for x = f.args]
    dx_a, = [symboliceval(x, dvar[1], env, cache) for x = f.args]
    dx_b, = [symboliceval(x, dvar[2], env, cache) for x = f.args]
    dx_ab, = [symboliceval(x, dvar, env, cache) for x = f.args]
    exp(x) * (dx_b * dx_a + dx_ab)
end

function _eval(::Val{:log}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    x, = [symboliceval(x, env, cache) for x = f.args]
    dx_a, = [symboliceval(x, dvar[1], env, cache) for x = f.args]
    dx_b, = [symboliceval(x, dvar[2], env, cache) for x = f.args]
    dx_ab, = [symboliceval(x, dvar, env, cache) for x = f.args]
    (dx_ab * x - dx_a * dx_b) / x^2
end

function _eval(::Val{:sqrt}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    x, = [symboliceval(x, env, cache) for x = f.args]
    dx_a, = [symboliceval(x, dvar[1], env, cache) for x = f.args]
    dx_b, = [symboliceval(x, dvar[2], env, cache) for x = f.args]
    dx_ab, = [symboliceval(x, dvar, env, cache) for x = f.args]
    sqrt(x) * (dx_ab * 2 - dx_a * dx_b) / (4*x)
end

function _eval(::Val{:dot}, f::SymbolicExpression, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv, cache::SymbolicCache)
    x,y = [symboliceval(x, env, cache) for x = f.args]
    dx_a,dy_a = [symboliceval(x, dvar[1], env, cache) for x = f.args]
    dx_b,dy_b = [symboliceval(x, dvar[2], env, cache) for x = f.args]
    dx_ab,dy_ab = [symboliceval(x, dvar, env, cache) for x = f.args]
    dot(x,dy_ab) + dot(dx_b,dy_a) + dot(dx_a,dy_b) + dot(dx_ab,y)
end
