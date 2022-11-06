using ReinforcedSnake
using Test

@testset "ReinforcedSnake.jl" begin
    include("test_snake.jl")
    include("test_bandits.jl")
    include("test_agents.jl")
end
