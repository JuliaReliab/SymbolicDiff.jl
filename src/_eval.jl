"""
Module: SymbolicDiff (Symbolic Operation for Arithmetic)
"""

const SymbolicCache = Dict{Union{AbstractSymbolic,Tuple{AbstractSymbolic,Symbol},Tuple{AbstractSymbolic,Tuple{Symbol,Symbol}}},Any}


function symeval(f::Any)
    symeval(f, SymbolicCache())
end

"""
symeval(f, cache)
Return the value for expr f
"""

function symeval(f::SymbolicValue{Tv}, cache::SymbolicCache)::Tv where Tv
    f.val
end

function symeval(f::SymbolicVariable{Tv}, cache::SymbolicCache)::Tv where Tv
    Tv(f.val[1])
end

function symeval(f::AbstractSymbolic{Tv}, cache::SymbolicCache) where Tv
    get(cache, f) do
        retval = _eval(Val(f.op), f, cache)
        cache[f] = retval
    end
end

"""
_eval(::Val{xx}, f, cache)

Dispached function to evaluate the expr f
"""

function _eval(::Val{:+}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    args = [symeval(x, cache) for x = f.args]
    +(args...)
end

function _eval(::Val{:-}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    args = [symeval(x, cache) for x = f.args]
    -(args...)
end

function _eval(::Val{:*}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    args = [symeval(x, cache) for x = f.args]
    *(args...)
end

function _eval(::Val{:/}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    x,y = [symeval(x, cache) for x = f.args]
    x/y
end

function _eval(::Val{:^}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    x,y = [symeval(x, cache) for x = f.args]
    x^y
end

function _eval(::Val{:exp}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    x, = [symeval(x, cache) for x = f.args]
    exp(x)
end

function _eval(::Val{:log}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    @assert length(f.args) == 1
    x, = [symeval(x, cache) for x = f.args]
    log(x)
end

function _eval(::Val{:sqrt}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    x, = [symeval(x, cache) for x = f.args]
    sqrt(x)
end

function _eval(::Val{:dot}, f::SymbolicExpression{Tv}, cache::SymbolicCache)::Tv where Tv
    x,y = [symeval(x, cache) for x = f.args]
    dot(x,y)
end
