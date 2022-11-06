module ReinforcedSnake

export SnakeGame, 
    reset!, 
    step!, 
    Action, 
    UP, DOWN, RIGHT, LEFT, 
    STATE_SPACE, ACTION_SPACE, 
    train!,
    MonteCarloAgent, 
    OnlineAgent,
    QLearningAgent,
    SarsaAgent,
    display_game!,
    BanditsEnv,
    choose_action

include("snake.jl")
include("bandits.jl")
include("agents.jl")
include("visualize.jl")

end
