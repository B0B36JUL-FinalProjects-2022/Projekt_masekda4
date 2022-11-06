using ReinforcedSnake
using Test

@testset "bandits.jl" begin
    env = BanditsEnv([
        1 0 ;
        0 5 ;
        4 1 ;
        -2 3 ;
        5 3 ;
    ])

    @testset "Initialization" begin
        reset!(env)

        @test length(env.ACTION_SPACE) == 5
    end

    @testset "Step" begin
        reset!(env)

        next_state, reward, done = step!(env, 1)
        @test done === true
        @test reward == 1
    end
end