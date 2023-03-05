
export variable
export value

abstract type AbstractVariable end

abstract type AbstractFunction end

struct NothingFunction <: AbstractFunction end

struct Variable{T} <: AbstractVariable
    data::T
    grad::T
    creator::AbstractFunction
end

function variable(x::T) where T
    Variable{T}(x, zero(T), NothingFunction())
end

function variable(x::T, creator::AbstractFunction) where T
    Variable{T}(x, zero(T), creator)
end

function value(x::Variable{T})::T where T
    x.data
end

function eval(f::AbstractFunction, input::AbstractVariable)::AbstractVariable
    x = value(input)
    y = forward(f, x)
    variable(y, f)
end

function gettinputvalue(f::AbstractFunction)
    value(f.input)
end

function getoutput(f::AbstractFunction)
    value(f.input)
end

function setinput(f::AbstractFunction, input::AbstractVariable)
    f.input = input
end

function setoutput(f::AbstractFunction, output::AbstractVariable)
    f.output = output
end

struct ExpFunction <: AbstractFunction
    input::AbstractVariable
    output::AbstractVariable

    function ExpFunction(input::AbstractVariable)
        f = new()
        output = eval(f, input)
        f.input = input
        f.output = output
        f
    end
end

forward(f::ExpFunction, x::Real)::Real = exp(x)

function backward(f::ExpFunction, gy)
    x = getinputvalue(f)
    exp(x) * gy
end

function Base.exp(x::AbstractVariable)::AbstractVariable
    f = ExpFunction(x)
    getoutput(f)
end

