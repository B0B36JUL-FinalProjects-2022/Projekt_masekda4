
export SnakeGame, reset!, step!, Action, UP, DOWN, RIGHT, LEFT, STATE_SPACE, ACTION_SPACE

Point = CartesianIndex{2}
Direction = CartesianIndex{2}
Action = Direction

# dy, dx
const UP = Direction(-1, 0)
const DOWN = Direction(1, 0)
const LEFT = Direction(0, -1)
const RIGHT = Direction(0, 1)

"""Returns index of random `false` value or `nothing` if none found.""" 
function find_empty(arr::BitMatrix)::Union{CartesianIndex{2}, Nothing}
    valid_indices = CartesianIndex{2}[]
    for idx in CartesianIndices(arr)
        if !arr[idx]
            push!(valid_indices, idx)
        end
    end
    if length(valid_indices) == 0
        return nothing
    end
    return rand(valid_indices)
end

"""
    SnakeGame(H::Integer, W::Integer)

SnakeGame environment. Must be initialized by `reset!(env)` before first usage.
"""
mutable struct SnakeGame
    "height"
    const H::Integer
    "width"
    const W::Integer
    "Observable states, see `get_state`"
    const STATE_SPACE
    "The possible actions are UP, DOWN, LEFT and RIGHT"
    const ACTION_SPACE
    "is set to `true` after first reset"
    initialized::Bool
    "tiles blocked with obstacles"
    blocks::BitMatrix
    "tiles occupied by snake body (including head)"
    body::BitMatrix
    "direction of last movement trough a given tile; used for computing movement"
    directions::Matrix{Direction}
    "head location"
    head::Point
    "tail (last body-part) location"
    tail::Point
    "apple (food) location"
    apple::Point
    function SnakeGame(H::Integer, W::Integer)
        if H < 3
            throw(DomainError(H, "Minimum height is 3."))
        end
        if W < 5
            throw(DomainError(W, "Minimum width is 5."))
        end
        "The observable state is described by 8 bits, but shifted to positive numbers"
        STATE_SPACE = 1:2^8
        "The possible actions are UP, DOWN, LEFT and RIGHT"
        ACTION_SPACE = [UP, DOWN, LEFT, RIGHT]
        return new(H, W, STATE_SPACE, ACTION_SPACE, false)
    end
end

"""
    reset(env::SnakeGame)

Reset environment to random valid starting state. Returns current (observed) state.
"""
function reset!(env::SnakeGame)::Integer
    env.initialized = true

    env.blocks = falses(env.H, env.W)
    env.blocks[1, :] .= true
    env.blocks[end, :] .= true
    env.blocks[:, 1] .= true
    env.blocks[:, end] .= true

    env.directions = fill(RIGHT, env.H, env.W)
    
    env.body = falses(env.H, env.W)
    start_y = env.H ÷ 2 + 1
    start_x = env.W ÷ 2 + 1
    env.head = Point(start_y, start_x)
    env.body[env.head] = true
    env.tail = env.head + LEFT
    env.body[env.tail] = true

    env.apple = find_empty(env.blocks .| env.body)

    return get_state(env)
end

function print_board(io::IO, game::SnakeGame)
    if !game.initialized
        print(io, "SnakeGame($(game.H), $(game.W), false)")
        return
    end
    for y in 1:game.H
        for x in 1:game.W
            if game.blocks[y, x]
                print(io, '#')
            elseif game.head == Point(y, x)
                print(io, 'H')
            elseif game.body[y, x]
                print(io, '@')
            elseif game.apple == Point(y, x)
                print(io, 'F')
            else
                print(io, ' ')
            end
        end
        print(io, '\n')
    end
end

print_board(game::SnakeGame) = print_board(stdout, game)

function Base.show(io::IO, game::SnakeGame)
    print_board(io, game)
end

"""
    get_state(game::SnakeGame)::Integer

Return observable game state encoded as `Integer`. Note that this may not fully describe the environment.

Returned value will be positive so it can be used as an index.
"""
function get_state(game::SnakeGame)::Integer
    blocks = []
    for d in [UP, DOWN, LEFT, RIGHT]
        pos = game.head + d
        blocked = game.blocks[pos] | game.body[pos]
        push!(blocks, blocked)
    end
    dy, dx = Tuple(game.apple - game.head)
    food_up = dy < 0
    food_down = dy > 0
    food_left = dx < 0
    food_right = dx > 0

    state_parts = [blocks..., food_up, food_down, food_left, food_right]
    # although the 0 state is not reachable in standard game adding the one makes
    # this more bulletproof
    return evalpoly(2, state_parts) + 1
end 

"""
    step!(game::SnakeGame, action::Action)::Tuple{Integer, Real, Bool}

Move one step in the environment with the given action. Returns (next_state, reward, done).
"""
function step!(game::SnakeGame, action::Action)::Tuple{Integer, Real, Bool}
    next = game.head + action
    crashed = game.blocks[next] | game.body[next]
    if crashed
        return get_state(game), -100, true
    end

    game.directions[game.head] = action
    game.head = game.head + action
    game.body[game.head] = true
    if next == game.apple
        next_apple = find_empty(game.blocks .| game.body)
        if next_apple === nothing
            return get_state(game), 100, true
        else
            game.apple = next_apple
            return get_state(game), 100, false
        end
    else
        game.body[game.tail] = false
        game.tail = game.tail + game.directions[game.tail]
        return get_state(game), -0.1, false
    end
end


"""
    step!(game::SnakeGame, action::Integer)::Tuple{Integer, Real, Bool}

Move one step in the environment with the action given by index `action`. Returns (next_state, reward, done).

Equivalent to `step!(game, ACTION_SPACE[action])`.
"""
function step!(game::SnakeGame, action::Integer)::Tuple{Integer, Real, Bool}
    return step!(game, game.ACTION_SPACE[action])
end
