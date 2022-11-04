using ReinforcedSnake
using Test

@testset "ReinforcedSnake.jl" begin
    # Write your tests here.
    @test add(1, 2) == 3
    @test add(π, π) == 2π
end
