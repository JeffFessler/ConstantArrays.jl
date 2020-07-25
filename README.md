ConstantArrays.jl
=============

[![Travis Build Status](https://travis-ci.org/JeffFessler/ConstantArrays.jl.svg?branch=master)](https://travis-ci.org/JeffFessler/ConstantArrays.jl)
[![codecov.io](http://codecov.io/github/JeffFessler/ConstantArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/JeffFessler/ConstantArrays.jl?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/JeffFessler/ConstantArrays.jl/badge.svg?branch=master)](https://coveralls.io/github/JeffFessler/ConstantArrays.jl?branch=master)

https://github.com/JeffFessler/ConstantArrays.jl

A Julia data type that is a subtype of `AbstractArray`
where every element is the same constant.

### Installation

At the Julia REPL run:
`using Pkg; Pkg.add("ConstantArrays")`.

### Documentation

At the Julia REPL execute:
`using ConstantArrays`,
then type `?ConstantArray` and press enter to get help.

`x = ConstantArray(7, (4,6))` makes a "lazy" constant array
equivalent to `fill(7, (4,6))` but essentially requires only
the memory need to store the value `7` and the dimensions `(4,6)`.

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
That `I` is non-essential
because one could accomplish something similar
using `Diagonal(ones(N))`
but `I` requires much less memory.

Developed by Jeff Fessler at the University of Michigan.
