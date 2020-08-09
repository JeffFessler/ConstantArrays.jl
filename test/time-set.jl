# time-set.jl
# timing tests for setindex!

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

function setter!(y, mask, x) # setindex!
	y[mask] = x
end

function set_checker()
	@assert copyto!(y, x) ==
		setter!(y, mask0, x) ==
		setter!(y, maskc, x) ==
		setter!(y, maskf, x) ==
		setter!(y, maskt, x) == x
end

# time y[mask] = x when mask is trues()
# default setindex! operations are much slower than copyto!
if true
	@info "setter"
	set_checker()
	@btime copyto!($y, $x) # 0.65 ms (baseline)
	@btime setter!($y, $mask0, $x) # 1.6 ms
	@btime setter!($y, $maskc, $x) # 2.5 ms :(
	@btime setter!($y, $maskf, $x) # 2.3 ms :( before code update, # 0.6 after
	@btime setter!($y, $maskt, $x) # 2.3 ms :( before code update, # 0.6 after
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

#=
# here is the essence of the solution for Ones in FillArrays:
# y[mask] = x when mask isa Trues
function Base.setindex!(y::AbstractArray{T,D}, x, mask::Trues{D}) where {T,D}
	copyto!(y, x)
end
=#

if true
	@info "updated setter!"
	set_checker()
	@btime setter!($y, $maskc, $x) # 0.65 ms :)
	@btime setter!($y, $maskf, $x) # 0.65 ms :)
	@btime setter!($y, $maskt, $x) # 0.65 ms :)
end

nothing
