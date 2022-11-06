using Revise
using ReinforcedSnake

env = SnakeGame(6, 12)
agent = QLearningAgent(env.STATE_SPACE, env.ACTION_SPACE)

train!(env, agent, episodes=500_000, max_steps=100, epsilon=0.9, epsilon_final=0.05, print_each=5_000, alpha=0.05)
evaluate_on_episode!(env, agent, max_steps=1000)

print_game!(env, agent, max_steps=5)

open("q_6_12_500000.txt", "w") do io
    export_game!(io, env, agent, max_steps=1000)
end

env_big = SnakeGame(12, 24)

evaluate_on_episode!(env_big, agent, max_steps=1000)

open("q_12_24_500000.txt", "w") do io
    export_game!(io, env_big, agent, max_steps=1000)
end
