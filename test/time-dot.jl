# time-dot.jl
# some timing tests

# times reported below are all with julia 1.5
# on 2017 iMac (4.2GHz Intel Core i7) with Mojave 10.14.6

using ConstantArrays
#using FillArrays: Ones
using FillArrays: Ones, Trues # for 0.9
using BenchmarkTools

dim = (2^8,2^8,2^4)
x = randn(dim)
y = similar(x)

mask0 = trues(dim)
maskc = ConstantArray(dim)
maskf = Ones{Bool}(dim)
#const Trues = Ones{Bool, N, Axes} where {N, Axes} # lazy trues()
maskt = Trues(dim)
@assert mask0 == maskt

@assert mask0 == maskc == maskf == maskt


# function wrappers for timing tests

function dotter!(y, mask, x) # .*
	return y .= mask .* x
end

if true # .*
	@info "dotter"
	@assert dotter!(y, mask0, x) ==
		dotter!(y, maskc, x) ==
		dotter!(y, maskf, x) ==
		dotter!(y, maskt, x) == x
	@btime dotter!($y, $mask0, $x) # 1.0 ms
	@btime dotter!($y, $maskc, $x) # 0.6 ms :)
	@btime dotter!($y, $maskf, $x) # 0.6 ms :)
	@btime dotter!($y, $maskt, $x) # 0.6 ms :)
end

nothing
