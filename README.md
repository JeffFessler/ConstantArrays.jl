ConstantArrays.jl
=============

[![Build Status][travis-img]][travis-url]
[![Codecov.io][codecov-img]][codecov-url]
<!-- [![Coveralls][coveralls-img]][coveralls-url] -->

https://github.com/JeffFessler/ConstantArrays.jl

A Julia data type that is a subtype of `AbstractArray`
where every element is the same constant.

The "constant" in the name has two meaning:
every element of the array has the same constant value,
and the array is immutable
(`setindex!` is unsupported).

### Caution

This package may be a subset of the existing
https://github.com/JuliaArrays/FillArrays.jl
(that I did not know about when I wrote it).
So I may end up deleting it
after I do a bit more testing and benchmarking to confirm.

### Installation

At the Julia REPL run:
`using Pkg; Pkg.add("ConstantArrays")`.

### Documentation

At the Julia REPL execute:
`using ConstantArrays`,
then type `?ConstantArray` and press enter to get help.

Primary usage example:
```
x = ConstantArray(42, (5,7))
```
makes a "lazy" constant "array"
functionally equivalent to `fill(42, (5,7))`
but essentially requires only
the memory need to store a struct
with the value `42` and the dimensions `(5,7)`.

The motivating use of this type
is for the "masks" used in tomographic image reconstruction
that are often uniform
but also often patient conforming.
The default one-argument usage
`mask = ConstantArray((4,6))` uses `true` (i.e., `one(Bool)`)
as the constant value
for this purpose.

The idea here is somewhat analogous
to the `UniformScaling` type (`I`)
in the `LinearAlgebra` package.
Arguably that `I` is non-essential
because one could accomplish something similar
using `Diagonal(ones(N))`
but `I` requires much less memory.
Likewise,
arguably `ConstantArray` is non-essential, but
`ConstantArray(true, (100,100,100))` uses about a million times
less memory than `trues(100,100,100)`.

A better analogy might be a sparse array,
where only the nonzero values are stored
to save memory.
A `ConstantArray` needs only to store only a single value.

The most useful operations are probably
`x .* y`
and `y[x]`,
both of which are faster
with a `ConstantArray`
than with `trues(dim)`.

Developed by Jeff Fessler at the University of Michigan,
with some inspiration from
[ReadOnlyArrays.jl](https://github.com/bkamins/ReadOnlyArrays.jl).


<!-- URLs -->
[travis-img]: https://travis-ci.org/JeffFessler/ConstantArrays.jl.svg?branch=master
[travis-url]: https://travis-ci.org/JeffFessler/ConstantArrays.jl
[codecov-img]: https://codecov.io/github/JeffFessler/ConstantArrays.jl/coverage.svg?branch=master
[codecov-url]: https://codecov.io/github/JeffFessler/ConstantArrays.jl?branch=master
[coveralls-img]: https://coveralls.io/repos/JeffFessler/ConstantArrays.jl/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/JeffFessler/ConstantArrays.jl?branch=master
