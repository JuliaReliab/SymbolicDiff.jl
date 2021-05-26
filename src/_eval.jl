"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

"""
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(f::SymbolicValue{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    f.val
end

function symboliceval(f::SymbolicVariable{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    get(env, f.var) do
        0
    end
end

function symboliceval(f::AbstractSymbolic{Tv}, env::SymbolicEnv, cache::SymbolicCache) where Tv
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
    args = [symboliceval(x, env, cache) for x = f.args]
    +(args...)
end

function _eval(::Val{:-}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    args = [symboliceval(x, env, cache) for x = f.args]
    -(args...)
end

function _eval(::Val{:*}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    args = [symboliceval(x, env, cache) for x = f.args]
    *(args...)
end

function _eval(::Val{:/}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x,y = [symboliceval(x, env, cache) for x = f.args]
    x/y
end

function _eval(::Val{:^}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x,y = [symboliceval(x, env, cache) for x = f.args]
    x^y
end

function _eval(::Val{:exp}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x, = [symboliceval(x, env, cache) for x = f.args]
    exp(x)
end

function _eval(::Val{:log}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    @assert length(f.args) == 1
    x, = [symboliceval(x, env, cache) for x = f.args]
    log(x)
end

function _eval(::Val{:sqrt}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x, = [symboliceval(x, env, cache) for x = f.args]
    sqrt(x)
end

function _eval(::Val{:dot}, f::SymbolicExpression{Tv}, env::SymbolicEnv, cache::SymbolicCache)::Tv where Tv
    x,y = [symboliceval(x, env, cache) for x = f.args]
    dot(x,y)
end
