module Telperion

using OrderedCollections: OrderedDict

export OrderedDict, @withprops, @xy, dummy

#-----------------------------------------------------------------------------# @withprops
macro withprops(df, ex)
    esc(quote
        eval(Telperion.replace_props!($df, $(Meta.quot(ex))))
    end)
end

replace_props!(df, x) = x

replace_props!(df, x::Symbol) = hasproperty(df, x) ? getproperty(df, x) : x

function replace_props!(df, ex::Expr) 
    if ex.head === :call || ex.head === :.
        Expr(ex.head, vcat(ex.args[1], replace_props!.(Ref(df), ex.args[2:end]))...)
    else
        Expr(ex.head, replace_props!.(Ref(df), ex.args)...)
    end
end

#-----------------------------------------------------------------------------# @xy 
macro xy(df, ex)
    ex.args[1] === :~ && length(ex.args) == 3 || error("Formula must have the form `lhs ~ rhs`")
    lhs = [ex.args[2]]  # TODO: allow multivariate responses
    rhs = split_terms(ex.args[3])

    yblock = Expr(:call, :OrderedDict)
    for term in lhs 
        push!(yblock.args, :($(string(term)) => Telperion.@withprops($df, $term)))
    end
    xblock = Expr(:call, :OrderedDict)
    for term in rhs 
        push!(xblock.args, :($(string(term)) => Telperion.@withprops($df, $term)))
    end
    esc(quote
        Telperion.process!($df, $xblock), Telperion.process!($df, $yblock)
    end)
end

split_terms(x) = [x]
function split_terms(x::Expr) 
    x.head === :call && x.args[1] === :+ || error("Formula must have the form `y ~ 1 + x`")
    x.args[2:end]
end

#-----------------------------------------------------------------------------# process!
# Deal with special things : Numbers and OrderedDicts
function process!(df, dict)
    for (k,v) in dict 
        if v isa OrderedDict 
            for (k2, v2) in v 
                dict["$k [$k2]"] = v2
            end
            delete!(dict, k)
        elseif length(v) == 1 
            dict[k] = fill(v, size(df, 1))
        end
    end
    dict
end

#-----------------------------------------------------------------------------# functions 
dummy(x) = OrderedDict("$level" => x .== level for level in sort(unique(x))[2:end])

end
