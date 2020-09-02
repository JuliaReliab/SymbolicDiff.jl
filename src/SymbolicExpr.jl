module SymbolicExpr

include("_symbolic.jl")
include("_env.jl")
include("_eval.jl")
include("_deriv.jl")
include("_deriv2.jl")

include("_macro.jl")

const defaultenv = SymbolicEnv{Float64}()
const defaultcache = SymbolicCache{Float64}()

end
