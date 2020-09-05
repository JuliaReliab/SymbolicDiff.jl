"""
SymbolicVector
"""

"""
symboliceval(f, env, cache)
Return the value for expr f
"""

function symboliceval(f::Vector{<:AbstractSymbolic}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, env, cache) for x = f]
end

"""
symboliceval(f, dvar, env, cache)
Return the first derivative of expr f with respect to dvar
"""

function symboliceval(f::Vector{<:AbstractSymbolic}, dvar::Symbol, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, dvar, env, cache) for x = f]
end

"""
symboliceval(f, dvar, env, cache)
Return the second derivative of expr f with respect to dvar1 and dvar2
"""

function symboliceval(f::Vector{<:AbstractSymbolic}, dvar::Tuple{Symbol,Symbol}, env::SymbolicEnv{Tv}, cache::SymbolicCache) where Tv
    [symboliceval(x, dvar, env, cache) for x = f]
end

