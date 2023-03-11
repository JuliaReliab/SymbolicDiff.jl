abstract type TSortState end
struct Unmarked <: TSortState end
struct Temporary <: TSortState end
struct Permanent <: TSortState end

"""
    tsort

Tomprogical sort to determine the sequence of T. The type T has the function
`next` to obtain next elements
"""
function tsort(elems::Vector{T}) where T
    list = T[]
    check = Dict{T,TSortState}([n => Unmarked() for n = elems]...)
    for n = elems
        if check[n] != Permanent()
            _visit!(n, check, list)
        end
    end
    list
end

function _visit!(n, check, list)
    if check[n] == Temporary()
        throw(ErrorException("DAG has a closed path"))
    elseif check[n] == Unmarked()
        check[n] = Temporary()
        for m = next(n)
            _visit!(m, check, list)
        end
        check[n] = Permanent()
        pushfirst!(list, n)
    end
end

