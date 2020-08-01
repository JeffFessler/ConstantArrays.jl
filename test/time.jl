# time.jl
# some timing tests

using ConstantArrays
using FillArrays: Ones
using BenchmarkTools

dim = (2^8,2^8,2^4)

mask0 = trues(dim)
x = randn(dim)
y = similar(x)

maskc = ConstantArray(dim)
maskf = Ones{Bool}(dim)

@assert mask0 == maskc == maskf

function dottimes(y, mask, x) # for timing .*
	return y .= mask .* x
end

function indexer(y, mask, x) # getindex!
	y[mask] .= vec(x)
end

function masker(y, mask, x) # getindex
	vec(y) .= x[mask]
end

# FillArrays is even slower than base here - it needs an appropriate getindex
if true
	@assert masker(y, maskc, x) == vec(x)
#	masker(y, maskc, x)
	@btime masker($y, $mask0, $x) # 2 ms 6 alloc 8MiB
	@btime masker($y, $maskc, $x) # 3 ms 4 alloc 8MiB => was 1.5× slower :(
								# before overloaded getindex
								# then became:
								# 0.66 ms 4 alloc 160 byte => 3× faster!
	@btime masker($y, $maskf, $x) # 2.6 ms (4 allocations: 8.00 MiB)
end

# todo: work on a getindex for Fill
# Base.getindex(x::AbstractArray{T,D}, mask::Fill{Bool,D,todo}) where {T,D} =mask.value ? vec(x) : ones(T, 0)


# todo: anyway to speed up this one?
if true
#	indexer(y, mask0, x)
	@btime indexer($y, $mask0, $x) # 2 ms (11 allocations: 8.00 MiB)
	@btime indexer($y, $maskc, $x) # 5 ms (6 allocations: 24.00 MiB) :(
	@btime indexer($y, $maskf, $x) # 5 ms (6 allocations: 24.00 MiB) :(
end

if true
	@btime dottimes($y, $mask0, $x) # 960 μs
	@btime dottimes($y, $maskc, $x) # 630 μs
	@btime dottimes($y, $maskf, $x) # 630 μs
end

nothing
