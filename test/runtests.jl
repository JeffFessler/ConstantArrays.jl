using ConstantArrays
using Test: @test, @testset, @test_throws, @inferred

@testset "ConstantArrays" begin
    dim = (3,4)
    val = 7
    x = @inferred ConstantArray(val, dim)

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
    @test length(x) == prod(dim)
    @test axes(x) == axes(ones(dim))
    @test x .* ones(dim) == fill(val, dim)
    @test vec(x) == fill(val, prod(dim))
    @test [v for v in x] == fill(val, prod(dim)) # iterator

    z = @inferred copy(x)
    @test z === x # !

    @test_throws BoundsError x[0]
    @test_throws BoundsError x[end+1]

    y = @inferred ConstantArray(dim)
    @test eltype(y) == Bool
end
