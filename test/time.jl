# time.jl
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

function getter(mask, x) # getindex
	return x[mask]
end

function masker!(y, mask, x) # copyto! and getindex, ala getindex!
	copyto!(y, x[mask])
end

function get_check()
	@assert vec(x) ==
		 getter(mask0, x) ==
		 getter(maskc, x) ==
		 getter(maskf, x) ==
		 getter(maskt, x)
end

# x[mask]
# FillArrays is even slower than base here; it needs an appropriate getindex
if false
	@info "getter"
	get_check()
	@btime getter($mask0, $x) # 1 ms 4 alloc 8MiB
	@btime getter($maskc, $x) # 28 ns 2 alloc 80
	@btime getter($maskf, $x) # 1.6 ms 2 alloc 8MiB -> 28 ns 2 alloc 80
	@btime getter($maskt, $x) # 1.6 ms 2 alloc 8MiB -> 28 ns 2 alloc 80
end


function masker_check()
	@assert masker!(y, maskc, x) == masker!(y, maskf, x) ==
		masker!(y, mask0, x) == x
end

if true
	@info "masker!"
	masker_check()
	@btime masker!($y, $mask0, $x) # 2 ms 4 alloc 8MiB
	@btime masker!($y, $maskc, $x) # 3 ms 4 alloc 8MiB => was 1.5× slower :(
								# before i overloaded getindex; then it became:
								# 0.6 ms 2 alloc 80 byte => 3× faster!
	@btime masker!($y, $maskf, $x) # 2.6 ms (2 allocations: 8MiB) -> 0.6 ms 2 alloc 80
	@btime masker!($y, $maskt, $x) # 2.6 ms (2 allocations: 8MiB) -> 0.6 ms 2 alloc 80
end

#=
# here is the key fix (now in module):
Base.getindex(x::AbstractArray{T,D}, ::Trues{D}) where {T,D} = vec(x)
=#

# much faster after providing that "getindex" method:
if false
	get_check()
	@info "updated"
	@btime getter($maskf, $x) # 28 ns 2 alloc 80 :)
	@btime masker!($y, $maskf, $x) # 66 ms 2 alloc 80 :)
end


#include("time-set.jl") # setindex!
#include("time-dot.jl") # .*

nothing
