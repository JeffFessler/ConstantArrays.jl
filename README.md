ConstantArrays.jl
=============

[![Travis Build Status](https://travis-ci.org/JeffFessler/ConstantArrays.jl.svg?branch=master)](https://travis-ci.org/JeffFessler/ConstantArrays.jl)
[![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/phgcro59kntb2xtf/branch/master?svg=true)](https://ci.appveyor.com/project/JeffFessler/readonlyarrays-jl/branch/master)
[![Coverage Status](https://coveralls.io/repos/github/JeffFessler/ConstantArrays.jl/badge.svg?branch=master)](https://coveralls.io/github/JeffFessler/ConstantArrays.jl?branch=master)
[![codecov.io](http://codecov.io/github/JeffFessler/ConstantArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/JeffFessler/ConstantArrays.jl?branch=master)

A Julia data type that is a subtype of `AbstractArray` where every element is the same constant.

### Installation

At the Julia REPL run:
`using Pkg; Pkg.add("ConstantArrays")`.

### Documentation

At the Julia REPL execute:
`using ConstantArrays`,
then type `?ConstantArray` and press enter to get help.

Developed by Jeff Fessler at the University of Michigan.

The motivating use of this type
is for the "masks" used in tomographic image reconstruction
that are often uniform
but also often patient conforming.
