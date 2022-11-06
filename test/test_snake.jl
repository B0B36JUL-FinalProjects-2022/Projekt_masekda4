using ReinforcedSnake
using Test

@testset "snake.jl" begin
    H, W = 6, 12
    env = SnakeGame(H, W)
    @testset "Initialization" begin
        @test env.H == H
        @test env.W == W
    
        state = reset!(env)
        @test isa(state, Integer)
    end

    @testset "Step" begin
        reset!(env)
        # hide the apple
        env.apple = ReinforcedSnake.Point(1,1)
        head = env.head
        tail = env.tail
        next_state, reward, done = step!(env, UP)
        @test isa(next_state, Integer)
        @test reward < 0
        @test done === false
        @test head + UP == env.head
        @test tail + RIGHT == env.tail
    end

    @testset "Eating Apple" begin
        reset!(env)
        head = env.head
        tail = env.tail
        env.apple = head + RIGHT
        next_state, reward, done = step!(env, RIGHT)
        @test isa(next_state, Integer)
        @test reward > 0
        @test done === false
        @test head + RIGHT == env.head
        @test tail == env.tail
    end

    @testset "Crashing - Self" begin
        reset!(env)
        head = env.head
        @test env.body[head + LEFT]
        next_state, reward, done = step!(env, LEFT)
        @test isa(next_state, Integer)
        @test reward < 0
        @test done === true
    end

    @testset "Crashing - Block" begin
        reset!(env)
        env.blocks[env.head + DOWN] = true
        next_state, reward, done = step!(env, DOWN)
        @test isa(next_state, Integer)
        @test reward < 0
        @test done === true
    end
end