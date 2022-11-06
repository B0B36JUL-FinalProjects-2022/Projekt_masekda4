export print_game!, export_game!

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
    print_game!(io::IO, env, agent; max_steps=nothing)

Play a single episode and print (string) visualizations.
"""
function print_game!(io::IO, env, agent; max_steps=nothing)
    "Episode return (total reward)"
    G = 0
    println(io, "H, W = $(env.H), $(env.W)")
    println(io, "typeof(agent) = $(typeof(agent))")
    state = reset!(env)
    println(io, "Score: $G")
    print_board(io, env)
    i = 1
    while true
        action = choose_action(agent, state)
        println(io, "Action: $(sprint_action(env, action))")
        next_state, reward, done = step!(env, action)
        G += reward

        println(io, "Score: $(@sprintf("%.1f", G))")
        print_board(io, env)

        i += 1
        if done || (max_steps !== nothing && i >= max_steps)
            break
        end
        state = next_state
    end
end

print_game!(env, agent; max_steps=nothing) = print_game!(stdout, env, agent, max_steps=max_steps)

"""
    export_game!(io::IO, env, agent; max_steps=nothing)

Play a single episode and export concise (string) visualizations.
"""
function export_game!(io::IO, env, agent; max_steps=nothing)
    "Episode return (total reward)"
    G = 0
    state = reset!(env)
    print_board(io, env, separator="|")
    println(io, "$(@sprintf("%.1f", G))")
    # println(io)
    i = 1
    while true
        action = choose_action(agent, state)
        next_state, reward, done = step!(env, action)
        G += reward
        
        print_board(io, env, separator="|")
        println(io, "$(@sprintf("%.1f", G))")
        # println(io)

        if done || (max_steps !== nothing && i > max_steps)
            break
        end
        state = next_state
        i += 1
    end
end
