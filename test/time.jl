# time.jl
# some timing tests

using ConstantArrays
using FillArrays: Ones
using BenchmarkTools

dim = (2^8,2^8,2^4)
x = randn(dim)
y = similar(x)

mask0 = trues(dim)
maskc = ConstantArray(dim)
maskf = Ones{Bool}(dim)

@assert mask0 == maskc == maskf


# function wrappers for timing tests

function dotter!(y, mask, x) # .*
	return y .= mask .* x
end

function setter!(y, mask, x) # setindex!
	y[mask] = x
end

function getter(mask, x) # getindex
	return x[mask]
end

function masker!(y, mask, x) # copyto! and getindex, ala getindex!
	copyto!(y, x[mask])
end


# time y[mask] = x when mask is trues()
# default setindex! operations are much slower than copyto!
if true
	@info "setter"
	@btime copyto!($y, $x) # 0.65 ms (baseline)
	@btime setter!($y, $mask0, $x) # 1.1 ms (2 allocations: 48)
	@btime setter!($y, $maskc, $x) # 2.3 ms :(
	@btime setter!($y, $maskf, $x) # 2.3 ms :(
end


# here is the solution for a ConstantArray:
# y[mask] = x
function Base.setindex!(y::AbstractArray{T,D}, x, mask::ConstantArray{Bool,D}) where {T,D}
	if mask.value == true
		copyto!(y, x)
	else
		y[mask] = x
	end
end

# here is the solution for Ones in FillArrays:
const Trues = Ones{Bool, N, Axes} where {N, Axes} # lazy trues()
maskt = Trues(dim)
@assert mask0 == maskt

# y[mask] = x when mask isa Trues
function Base.setindex!(y::AbstractArray{T,D}, x, mask::Trues{D}) where {T,D}
	copyto!(y, x)
end


if true
	@info "updated setter!"
	@btime setter!($y, $maskc, $x) # 0.65 ms :)
	@btime setter!($y, $maskt, $x) # 0.65 ms :)
end


# x[mask]
# FillArrays is even slower than base here; it needs an appropriate getindex
if true
	@info "getter"
	@assert getter(maskc, x) == getter(maskf, x) == getter(mask0, x) == vec(x)
	@btime getter($mask0, $x) # 1 ms 4 alloc 8MiB
	@btime getter($maskc, $x) # 28 ns 2 alloc 80
	@btime getter($maskf, $x) # 1.6 ms 2 alloc 8MiB
end

if true
	@info "masker!"
	@assert masker!(y, maskc, x) == x
	@btime masker!($y, $mask0, $x) # 2 ms 4 alloc 8MiB
	@btime masker!($y, $maskc, $x) # 3 ms 4 alloc 8MiB => was 1.5× slower :(
								# before i overloaded getindex; then it became:
								# 0.66 ms 2 alloc 80 byte => 3× faster!
	@btime masker!($y, $maskf, $x) # 2.6 ms (2 allocations: 8MiB)
end

# here is the key fix:
Base.getindex(x::AbstractArray{T,D}, ::Trues{D}) where {T,D} = vec(x)
@assert getter(maskc, x) == getter(maskf, x) == getter(mask0, x) == vec(x)

# much faster after providing that "getindex" method:
if true
	@info "updated"
	@btime getter($maskf, $x) # 28 ns 2 alloc 80 :)
	@btime masker!($y, $maskf, $x) # 66 ms 2 alloc 80 :)
end


if true # .*
	@info "dotter"
	@btime dotter!($y, $mask0, $x) # 1.3 ms
	@btime dotter!($y, $maskc, $x) # 0.6 ms :)
	@btime dotter!($y, $maskf, $x) # 0.6 ms :)
end

nothing
