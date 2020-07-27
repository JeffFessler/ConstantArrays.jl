module ConstantArrays

export ConstantArray, getindex!

"""
    ConstantArray{T,D} <: AbstractArray{T,D}
- `value::T`
- `dim::Dims{D}`
"""
struct ConstantArray{T,D} <: AbstractArray{T,D}
    value::T
    dim::Dims{D}
    ConstantArray(value::T, dim::Dims{D}) where {T,D} =
        new{T, D}(value, dim)
end


"""
    ConstantArray(value, dim::Dims)
    ConstantArray(dim::Dims) (default value=1)

Return a read-only `AbstractArray` of dimension `dim`
as if it is filled with the constant `value`,
i.e., equivalent to `fill(value, dim)`
except it uses much less memory.

The `setindex!` operation is not allowed for `ConstantArray`

# Examples
```jldoctest
julia> x = ConstantArray(7, (2,3))
2×3 ConstantArray{Int64,2}:
 7  7  7
 7  7  7

julia> x[1]
7

julia> x[1] = 10
ERROR: setindex! not defined for ConstantArray{Int64,2}
[...]
```
"""
ConstantArray(dim::Dims{D}) where {D} = ConstantArray(one(Bool), dim)

Base.IteratorSize(::Type{<:ConstantArray{T,N}}) where {T,N} = Base.HasLength()
Base.IteratorEltype(::Type{<:ConstantArray{T,N}}) where {T,N} = T
Base.eltype(::Type{<:ConstantArray{T,N}}) where {T,N} = T
Base.size(x::ConstantArray) = x.dim
Base.size(x::ConstantArray, args...) = x.dim[args...]

# this seems ok because dim tuple is immutable:
Base.copy(x::ConstantArray) = ConstantArray(x.value, x.dim)

Base.@propagate_inbounds function Base.getindex(x::ConstantArray, i::Int)
    @boundscheck 1 <= i <= prod(x.dim) || throw(BoundsError("$i"))
    return x.value
end

# harder to handle ':' etc. so let Base do it
#Base.@propagate_inbounds Base.getindex(x::ConstantArray, I...) = fill(x.value, ?)

Base.firstindex(::ConstantArray) = 1
Base.lastindex(x::ConstantArray) = prod(x.dim)
Base.IndexStyle(::Type{<:ConstantArray{T,N}}) where {T,N} = IndexLinear()
#Base.iterate(x::ConstantArray, args...) = iterate(x.value, args...)
Base.length(x::ConstantArray) = prod(x.dim)

Base.axes(x::ConstantArray) = ntuple(i -> Base.OneTo(x.dim[i]), length(x.dim))

"""
    getindex(x::AbstractArray{T,D}, mask::ConstantArray{Bool,D})

Ensure that `x[mask]` is efficient.
"""
Base.getindex(x::AbstractArray{T,D}, mask::ConstantArray{Bool,D}) where {T,D} = vec(x)


"""
    getindex!(y::AbstractVector, x::AbstractArray{T,D}, mask::ConstantArray{Bool,D})
Equivalent to the in-place `y .= x[mask]` but is non-allocating.

For non-Boolean indexing, just use `@views y .= A[index]`, per
https://discourse.julialang.org/t/efficient-non-allocating-in-place-getindex-for-bitarray/42268
"""
@inline function getindex!(
    y::AbstractVector,
    x::AbstractArray{T,D},
    mask::ConstantArray{Bool,D},
) where {T,D}
    axes(y) == (Base.OneTo(length(mask)),) || throw("y axes $(axes(y))")
    axes(mask) == axes(x) || throw(DimensionMismatch("x vs mask"))
    mask[1] == true || fail("only valid for mask with trues")
    y .= vec(x)
    return y
end

end # module
