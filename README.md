# Telperion

### What does **Telperion** do?

##### 1. Replace items in an expression via `getproperty`

```julia
using Telperion

struct A 
    thing
end

a = A("hello")

@withprops a collect(thing)
```

```
5-element Array{Char,1}:
 'h': ASCII/Unicode U+0068 (category Ll: Letter, lowercase)
 'e': ASCII/Unicode U+0065 (category Ll: Letter, lowercase)
 'l': ASCII/Unicode U+006C (category Ll: Letter, lowercase)
 'l': ASCII/Unicode U+006C (category Ll: Letter, lowercase)
 'o': ASCII/Unicode U+006F (category Ll: Letter, lowercase)
```

##### 2. Parse statistical formulas into feature columns.

```julia
using DataFrames, StatsBase, Telperion

df = DataFrame(y=rand(100), a=1:100, b=randn(100), c=randn(100), d=rand(1:5, 100))

x, y = @xy df log.(y) ~ 1 + a + zscore(b) + abs.(sin.(c)) + dummy(d)

x
```

```
OrderedDict{String,Any} with 8 entries:
  "1"            => [1, 1, 1, 1, 1, 1, 1, 1, 1, 1  …  1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  "log.(a)"      => [0.0, 0.693147, 1.09861, 1.38629, 1.60944, 1.79176, 1.94591, 2.07944, 2.19722, 2.30259  …  4.51086, 4.52179, 4.5326, 4.54329, 4.55388, 4.56435, 4.5…
  "zscore(b)"    => [0.331412, 1.13535, 1.32111, -0.942869, -0.962877, 0.150559, 0.228082, -0.252694, 0.66791, 0.643581  …  0.669354, 0.727924, 1.35388, 1.87328, 0.694…
  "mean(b)"      => [-0.0240543, -0.0240543, -0.0240543, -0.0240543, -0.0240543, -0.0240543, -0.0240543, -0.0240543, -0.0240543, -0.0240543  …  -0.0240543, -0.0240543,…
  "dummy(d) [2]" => Bool[0, 0, 0, 0, 0, 0, 0, 0, 0, 0  …  0, 0, 0, 0, 1, 0, 0, 0, 0, 0]
  "dummy(d) [3]" => Bool[0, 0, 0, 0, 0, 0, 1, 1, 0, 0  …  0, 0, 0, 1, 0, 1, 0, 0, 0, 1]
  "dummy(d) [4]" => Bool[0, 0, 0, 1, 1, 0, 0, 0, 1, 0  …  0, 0, 0, 0, 0, 0, 1, 1, 0, 0]
  "dummy(d) [5]" => Bool[1, 1, 0, 0, 0, 0, 0, 0, 0, 0  …  0, 0, 1, 0, 0, 0, 0, 0, 1, 0]
```