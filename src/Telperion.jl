module Telperion

using OrderedCollections: OrderedDict

#-----------------------------------------------------------------------------# xy 
function xy(df, ex::Expr)
    (ex.args[1] === :~) && length(ex.args) == 3 || error("Formula must have the form `lhs ~ rhs`")
    y = coldict(df, ex.args[2])
    x = if ex.args[3] isa Expr
        if ex.args[3].args[1] === :+
            reduce(merge, coldict(df, a) for a in ex.args[3].args[2:end])
        else
            @warn "What are you even doing?" ex.args[3]
        end
    else
        coldict(df, ex.args[3])
    end
    return x, y
end

coldict(df, term) = OrderedDict(string(term) => calcterm(df, term))

#-----------------------------------------------------------------------------# calcterm core
calcterm(df, term::Number) = fill(term, size(df, 1))
calcterm(df, term::Symbol) = getproperty(df, term)

function calcterm(df, term::Expr) 
    if term.head === :call 
        f, args = term.args[1], term.args[2:end]
        calcterm(df, Val(term.args[1]), term.args[2:end])
    end
end
    

#-----------------------------------------------------------------------------# Expr terms
function calcterm(df, f::Val{T}, args) where {T} 
    s = string(T)
    @info s
    @info args
    # TODO: figure this out for broadcasted functions
    if first(s) === '.' || last(s) === '.'
        broadcast(eval(Meta.parse(replace(s, '.' => ""))), map(x -> calcterm(df, x), args)...)
    else
        eval(T)(map(x -> calc(df, x), args)...)
    end
end




# # arbitrary function is applied elementwise
# 

# # special functions
# calc(df, ::Val{:.+}, args) = sum(reduce(hcat, calc(df, a) for a in args), dims=2)

# zscore(x) = (x - mean(x)) ./ std(x)
# calc(df, ::Val{:zscore}, args) = zscore(map(x -> calc(df, x), args)...)

end
