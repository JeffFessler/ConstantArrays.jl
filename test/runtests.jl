using ConstantArrays
using Test: @test, @testset, @test_throws, @inferred

@testset "ConstantArrays" begin
    dim = (3,4)
    val = 7
    x = @inferred ConstantArray(val, dim)

    show(isinteractive() ? stdout : devnull, MIME("text/plain"), x)

    # getindex:
    @test x[1] == val
    @test x[end] == val
    @test x[[2,3]] == [val,val]
    @test x[:,1] == fill(val, dim[1])
    @test x[:] == fill(val, prod(dim))

    @test all(x .== val)
    @test size(x) == dim
    @test size(x,1) == dim[1]
    @test size(x,2) == dim[2]
    @test eltype(x) == eltype(val)
    @test eltype(typeof(x)) == eltype(val)
    @test length(x) == prod(dim)
    @test axes(x) == axes(ones(dim))
    @test x .* ones(dim) == fill(val, dim)
    @test vec(x) == fill(val, prod(dim))
    @test [v for v in x] == fill(val, prod(dim)) # iterator

    @test Base.IteratorSize(typeof(x)) == Base.HasLength()
    @test Base.IteratorEltype(typeof(x)) == typeof(val)
    @test Base.IndexStyle(typeof(x)) == IndexLinear()
    @test Base.firstindex(x) == 1
    @test Base.lastindex(x) == prod(dim)

    z = @inferred copy(x)
    @test z === x # !

    @test_throws BoundsError x[0]
    @test_throws BoundsError x[end+1]

    mask = @inferred ConstantArray(dim)
    @test eltype(mask) == Bool

    z = rand(dim...)
    @test z[mask] == vec(z)

    dim = (2^9,2^8)
    mask = @inferred ConstantArray(dim)
    x = rand(dim...)
    y = similar(vec(x))
    @test getindex!(y, x, mask) == vec(x)
    @test 100 > @allocated getindex!(y, x, mask)
end
