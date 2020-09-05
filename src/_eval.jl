"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

export symboliceval

"""
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(f::Nothing, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    nothing
end

function symboliceval(f::SymbolicValue{Tx}, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where {Tx,Tv}
    Tv(f.val)
end

function symboliceval(f::SymbolicVariable, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where {Tx,Tv}
    get(env, f.var) do
        Tv(0)
    end
end

function symboliceval(f::AbstractSymbolic, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    get(cache, f) do
        retval = _eval(Val(f.op), f, env, cache)
        cache[f] = retval
    end
end

"""
_eval(::Val{xx}, f, env, cache)

Dispached function to evaluate the expr f
"""

function _eval(::Val{:+}, f::SymbolicExpression, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    args = [symboliceval(x, env, cache) for x = f.args]
    +(args...)
end

function _eval(::Val{:-}, f::SymbolicExpression, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    args = [symboliceval(x, env, cache) for x = f.args]
    -(args...)
end

function _eval(::Val{:*}, f::SymbolicExpression, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    args = [symboliceval(x, env, cache) for x = f.args]
    *(args...)
end

function _eval(::Val{:/}, f::SymbolicExpression, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    x,y = [symboliceval(x, env, cache) for x = f.args]
    x/y
end

function _eval(::Val{:^}, f::SymbolicExpression, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    x,y = [symboliceval(x, env, cache) for x = f.args]
    x^y
end

function _eval(::Val{:exp}, f::SymbolicExpression, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    x, = [symboliceval(x, env, cache) for x = f.args]
    exp(x)
end

function _eval(::Val{:log}, f::SymbolicExpression, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    x, = [symboliceval(x, env, cache) for x = f.args]
    log(x)
end

function _eval(::Val{:sqrt}, f::SymbolicExpression, env::SymbolicEnv{Tv}, cache::SymbolicCache{Tv}) where Tv
    x, = [symboliceval(x, env, cache) for x = f.args]
    sqrt(x)
end
