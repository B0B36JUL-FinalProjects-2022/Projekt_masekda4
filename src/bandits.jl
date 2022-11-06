"""
Environment with a single state and N actions.
"""
struct BanditsEnv
    STATE_SPACE::Vector{<:Integer}
    ACTION_SPACE::Vector{<:Integer}
    "mean, std for each lever"
    levers::Matrix{<:Real}
    function BanditsEnv(levers::Matrix{<:Real})
        rows, cols = size(levers)
        new([1], collect(1:rows), levers)
    end
end

ReinforcedSnake.reset!(env::BanditsEnv) = rand(env.STATE_SPACE)

function ReinforcedSnake.step!(env::BanditsEnv, action::Integer)
    mean, std = env.levers[action, :]
    reward = mean + randn() * std
    return (rand(env.STATE_SPACE), reward, true)
end
