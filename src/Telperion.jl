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
    Expr(ex.head, replace_props!.(Ref(df), ex.args)...)
end

#-----------------------------------------------------------------------------# @xy 
macro xy(df, ex)
    ex.args[1] === :~ && length(ex.args) == 3 || error("Formula must have the form `lhs ~ rhs`")
    lhs = split_terms(ex.args[2])
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
dummy(x; base=first) = OrderedDict("$l" => x .== l for l in sort(unique(x))[2:end])

end
