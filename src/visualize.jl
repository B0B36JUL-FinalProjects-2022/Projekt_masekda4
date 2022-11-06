export display_game!

sprint_action(env, action)::String = String(action)

function sprint_action(env::SnakeGame, action::Integer)::String
    action = env.ACTION_SPACE[action]
    if action == UP
        return "↑"
    elseif action == DOWN
        return "↓"
    elseif action == LEFT
        return "←"
    elseif action == RIGHT
        return "→"
    else
        return "<unexpected>"
    end
end

"""
    display_game!(env, agent; max_steps=nothing)

Play a single episode and print (string) visualizations.
"""
function display_game!(env, agent; max_steps=nothing)
    "Episode return (total reward)"
    G = 0
    state = reset!(env)
    println("Score: $G")
    show(env)
    i = 1
    while true
        action = choose_action(agent, state)
        println("Action: $(sprint_action(env, action))")
        next_state, reward, done = step!(env, action)
        G += reward

        println("Score: $G")
        show(env)

        if done || (max_steps !== nothing && i > max_steps)
            break
        end
        state = next_state
        i += 1
    end
end
