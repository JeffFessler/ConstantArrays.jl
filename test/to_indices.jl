# to_indices.jl
# timing test with to_indices version

# times reported below are all with julia 1.5
# on 2017 iMac (4.2GHz Intel Core i7) with Mojave 10.14.6

using ConstantArrays
using FillArrays: Ones # (for 0.8.14)
#using FillArrays: Trues
using BenchmarkTools

dim = (2^8,2^8,2^4)
x = randn(dim)
y = similar(x)

mask0 = trues(dim)
maskc = ConstantArray(dim)
maskf = Ones{Bool}(dim)
#maskf = Trues(dim)

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
if false
	@info "setter"
	@btime copyto!($y, $x) # 0.65 ms (baseline)
	@btime setter!($y, $mask0, $x) # 1.6 ms
	@btime setter!($y, $maskc, $x) # 2.5 ms :(
	@btime setter!($y, $maskf, $x) # 2.0 ms :(
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

#=
# y[mask] = x when mask isa Trues
function Base.setindex!(y::AbstractArray{T,D}, x, mask::Trues{D}) where {T,D}
	copyto!(y, x)
end
=#

if false
	@info "updated setter!"
	@btime setter!($y, $maskc, $x) # 0.65 ms :)
	@btime setter!($y, $maskt, $x) # 2.0 ms :(
end

function masker_check()
	@assert masker!(y, maskc, x) == masker!(y, maskf, x) ==
		masker!(y, mask0, x) == x
end


# x[mask]
# FillArrays is even slower than base here; it needs an appropriate getindex
if false
	@info "getter"
	@assert getter(maskc, x) == getter(maskf, x) == getter(mask0, x) == vec(x)
	@btime getter($mask0, $x) # 1.4 ms 2 alloc 8MiB
	@btime getter($maskc, $x) # 28 ns 2 alloc 80 -> 2.2 ms in 1.5 !?
	@btime getter($maskf, $x) # 1.8 ms 2 alloc 8MiB
end

if true
	@info "masker!"
	masker_check()
#	@btime masker!($y, $mask0, $x) # 2.1 ms 2 alloc 8MiB
#	@btime masker!($y, $maskc, $x) # 3 ms 4 alloc 8MiB => was 1.5× slower :(
								# before i overloaded getindex; then it became:
								# 0.66 ms 2 alloc 80 byte => 3× faster!
	@btime masker!($y, $maskf, $x) # 2.8 ms (2 allocations: 8MiB)
end

# as suggested here:
# https://github.com/JuliaArrays/FillArrays.jl/pull/110
Base.to_indices(A::AbstractArray{N}, inds, I::Tuple{Trues{N}}) where N =
	Base.to_indices(A, inds, (:,))

# no benefit to the suggested use of `to_indices`
if true
	@info "updated1"
	masker_check()
	@btime masker!($y, $maskf, $x) # 2.8 ms (2 alloc 8MiB) - no benefit
end


# here is the essence of the key fix:
# Base.getindex(x::AbstractArray{T,D}, ::Trues{D}) where {T,D} = vec(x)

# here is a more specialized version with axes and size checking:
function Base.getindex(x::AbstractArray{T,N}, 
    mask::Trues{N, NTuple{N,Base.OneTo{Int}}},
) where {T,N} 
    if axes(x) isa NTuple{N,Base.OneTo{Int}} where N
       @boundscheck size(x) == size(mask) || throw(BoundsError(x, mask))
       return vec(x)
    end
    return x[trues(size(x))] # else revert to usual getindex method
end

# much faster after providing my specialized "getindex" method:
if true
	@info "updated2"
	masker_check()
	@btime getter($maskf, $x) # 28 ns 2 alloc 80 :) -> 1.5 ms in 1.5 !?
	@btime masker!($y, $maskf, $x) # 66 ms 2 alloc 80 :)
end


if false # .*
	@info "dotter"
	@btime dotter!($y, $mask0, $x) # 1.0 ms
	@btime dotter!($y, $maskc, $x) # 0.6 ms :)
	@btime dotter!($y, $maskf, $x) # 0.6 ms :)
end

nothing

#=
using FFTViews
v = FFTView(collect(1:8))
v[:] # works fine
v[trues(8)]
# ERROR: BoundsError: attempt to access 8-element FFTView{Int64,1,Array{Int64,1}} with indices FFTViews.URange(0,7) at index [Bool[1, 1, 1, 1, 1, 1, 1, 1]]
v[trues(8)] = zeros(8) # also fails
=#
