using Statistics
using Printf

export MonteCarloAgent, QLearningAgent, SarsaAgent, OnlineAgent, train!, evaluate_on_episode!, choose_action

"""
Table based Monte Carlo agent.

# Examples
```julia-repl
julia> MonteCarloAgent(1:2,["noop","go"])
MonteCarloAgent(Real[0.0 0.0; 0.0 0.0], Integer[0 0; 0 0])
```
"""
struct MonteCarloAgent 
    Q::Matrix
    C::Matrix
    function MonteCarloAgent(state_space, action_space)
        s = length(state_space)
        a = length(action_space)
        new(zeros(s, a), zeros(s, a))
    end
end
"""Table based agent capable of online 1-step learning."""
abstract type OnlineAgent end
"""Q-Learning (1-step off-policy Expected SARSA) based agent.""" 
struct QLearningAgent <: OnlineAgent 
    Q::Matrix
    function QLearningAgent(state_space, action_space)
        s = length(state_space)
        a = length(action_space)
        new(zeros(s, a))
    end
end
"""SARSA (1-step on-policy) based agent.""" 
struct SarsaAgent <: OnlineAgent 
    Q::Matrix
    function SarsaAgent(state_space, action_space)
        s = length(state_space)
        a = length(action_space)
        new(zeros(s, a))
    end
end

function choose_action(agent, state)::Integer
    return argmax(agent.Q[state, :])
end

function train_step!(agent::QLearningAgent, state, action, reward, next_state, next_action, done, alpha)
    agent.Q[state, action] += alpha * (reward + Integer(!done) * max(agent.Q[next_state]) - agent.Q[state, action])
end

function train_step!(agent::SarsaAgent, state, action, reward, next_state, next_action, done, alpha)
    agent.Q[state, action] += alpha * (reward + Integer(!done) * agent.Q[next_state, next_action] - agent.Q[state, action])
end

function train_on_episode!(env, agent::MonteCarloAgent; max_steps, epsilon, alpha)
    history = Tuple{Integer, Integer, Real, Bool}[]    

    state = reset!(env)

    for _ in 1:max_steps
        if rand() >= epsilon
            action = choose_action(agent, state)
        else
            action = rand(1:length(env.ACTION_SPACE))
        end
        next_state, reward, done = step!(env, action)
        push!(history, (state, action, reward, done))
        if done
            break
        end
        state = next_state
    end
    "Episode return (total reward)"
    G = 0
    for (state, action, reward, _) in reverse(history)
        G += reward
        agent.C[state, action] += 1
        agent.Q[state, action] += 1/agent.C[state,action] * (G - agent.Q[state, action])
    end
    return G
end

function train_on_episode!(env, agent::OnlineAgent; max_steps, epsilon, alpha)
    "Episode return (total reward)"
    G = 0
    next_state = reset!(env)
    if rand() >= epsilon
        next_action = choose_action(agent, next_state)
    else
        next_action = rand(1:length(env.ACTION_SPACE))
    end
    for _ in 1:max_steps
        state, action = next_state, next_action
        next_state, reward, done = step!(env, action)
        if rand() >= epsilon
            next_action = choose_action(agent, next_state)
        else
            next_action = rand(1:length(env.ACTION_SPACE))
        end
        G += reward
        train_step!(agent, state, action, reward, next_state, next_action, done, alpha)
        if done
            break
        end
        state = next_state
    end
    return G
end

function evaluate_on_episode!(env, agent; max_steps)::Real
    "Episode return (total reward)"
    G = 0
    state = reset!(env)
    for _ in 1:max_steps
        action = choose_action(agent, state)
        next_state, reward, done = step!(env, action)
        G += reward
        if done
            break
        end
        state = next_state
    end
    return G
end

function train!(env, agent; episodes, max_steps, epsilon, epsilon_final=nothing, print_each=0, alpha=0.1, evaluate_each=0)
    eps = epsilon
    history = Real[]
    for i in 1:episodes
        G = train_on_episode!(env, agent, max_steps=max_steps, epsilon=eps, alpha=alpha)
        push!(history, G)
        if epsilon_final !== nothing
            # linear interpolation
            eps = (epsilon * (episodes - i) + epsilon_final * i) / episodes
        end
        if print_each > 0 && i % print_each == 0
            _mean = @sprintf("%.2f", mean(history[end-print_each+1:end]))
            _std = @sprintf("%.2f", std(history[end-print_each+1:end]))
            println("Average $(print_each)-episode return is $(_mean)+-$(_std)")
        end
        if evaluate_each > 0 && i % evaluate_each == 0
            G_eval = @sprintf("%.2f", evaluate_on_episode!(env, agent, max_steps=max_steps))
            println("Evaluation after $(i) episodes: $(G_eval)")
        end
    end
end
