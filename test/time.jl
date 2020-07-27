# time.jl
# some timing tests

using ConstantArrays
using BenchmarkTools

dim = (2^8,2^8,2^4)

mask0 = trues(dim)
x = randn(dim)
y = similar(x)

mask1 = ConstantArray(dim)

@assert mask0 == mask1 

function dottimes(y, mask, x)
	return y .= mask .* x
end

function indexer(y, mask, x)
	y[mask] .= vec(x)
end

function masker(y, mask, x)
	vec(y) .= x[mask]
end

if true
	@btime dottimes($y, $mask0, $x)
	@btime dottimes($y, $mask1, $x) # about 2× faster!
end

if true
#	indexer(y, mask0, x)
	@btime indexer($y, $mask0, $x)
	@btime indexer($y, $mask1, $x) # 3× more memory and slower :(
end

if true
	@assert masker(y, mask1, x) == vec(x)
#	masker(y, mask1, x)
	@btime masker($y, $mask0, $x) # 2 ms 6 alloc 8MiB
	@btime masker($y, $mask1, $x) # 3 ms 4 alloc 8MiB => was 1.5× slower :(
								# before overloaded getindex
								# then became:
								# 0.66 ms 4 alloc 160 byte => 3× faster!
end

nothing
