"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

"""
seval(f, env, cache)
Return the value for expr f
"""

function seval(f)
    seval(f, globalenv, SymbolicCache())
end

function seval(f, env::SymbolicEnv)
    seval(f, env, SymbolicCache())
end

function seval(f, cache::SymbolicCache)
    seval(f, globalenv, cache)
end

function seval(f::SymbolicValue{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    f.val
end

function seval(f::SymbolicVariable{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    env[f.var]
end

function seval(f::AbstractSymbolic{Tv}, env::SymbolicEnv, cache::SymbolicCache) where Tv
    get(cache, f) do
        retval = _eval(Val(f.op), f, env, cache)
        cache[f] = retval
    end
end

"""
_eval(::Val{xx}, f, env, cache)

Dispached function to evaluate the expr f
"""

function _eval(::Val{:+}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    args = [seval(x, env, cache) for x = f.args]
    +(args...)
end

function _eval(::Val{:-}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    args = [seval(x, env, cache) for x = f.args]
    -(args...)
end

function _eval(::Val{:*}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    args = [seval(x, env, cache) for x = f.args]
    *(args...)
end

function _eval(::Val{:/}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x,y = [seval(x, env, cache) for x = f.args]
    x/y
end

function _eval(::Val{:^}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x,y = [seval(x, env, cache) for x = f.args]
    x^y
end

function _eval(::Val{:exp}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x, = [seval(x, env, cache) for x = f.args]
    exp(x)
end

function _eval(::Val{:log}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    @assert length(f.args) == 1
    x, = [seval(x, env, cache) for x = f.args]
    log(x)
end

function _eval(::Val{:sqrt}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x, = [seval(x, env, cache) for x = f.args]
    sqrt(x)
end

function _eval(::Val{:sum}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x, = [seval(x, env, cache) for x = f.args]
    sum(x)
end

function _eval(::Val{:dot}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x,y = [seval(x, env, cache) for x = f.args]
    dot(x,y)
end
