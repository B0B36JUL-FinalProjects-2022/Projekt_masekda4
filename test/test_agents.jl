using ReinforcedSnake
using Test
using Random

@testset "bandits.jl" begin
    levers = [
        1 0 ;
        0 5 ;
        3 2 ;
        -2 3 ;
        5 3 ;
    ]
    env = BanditsEnv(levers)

    @testset "Monte Carlo" begin
        Random.seed!(42)
        state = reset!(env)
        agent = MonteCarloAgent(env.STATE_SPACE, env.ACTION_SPACE)
        train!(env, agent, episodes=300, max_steps=10, epsilon=0.5, epsilon_final=0.1)
        action = choose_action(agent, state)
        @test action == argmax(levers[:, 1])
    end

    @testset "SARSA" begin
        Random.seed!(42)
        state = reset!(env)
        agent = SarsaAgent(env.STATE_SPACE, env.ACTION_SPACE)
        train!(env, agent, episodes=300, max_steps=10, epsilon=0.5, epsilon_final=0.1, alpha=0.1)
        action = choose_action(agent, state)
        @test action == argmax(levers[:, 1])
    end

    @testset "Q-Learning" begin
        Random.seed!(42)
        state = reset!(env)
        agent = QLearningAgent(env.STATE_SPACE, env.ACTION_SPACE)
        train!(env, agent, episodes=300, max_steps=10, epsilon=0.5, epsilon_final=0.1, alpha=0.1)
        action = choose_action(agent, state)
        @test action == argmax(levers[:, 1])
    end
end