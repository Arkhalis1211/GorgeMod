local CoinLogic = {}

function CoinLogic:CalculateReward(coins_data, stale, spoiled, current_craving, cravings, plated)
    print(coins_data, stale, spoiled, current_craving, cravings, plated)
    local appraisal_data = {}
    local base_value = coins_data[1]

    local multiplier = 1
    if stale then
        multiplier = multiplier * 0.75
    elseif spoiled then
        multiplier = multiplier * 0.5
    end

    appraisal_data.matchedcraving = current_craving
    if not table.contains(cravings, current_craving) then
        multiplier = multiplier * 0.5
        appraisal_data.matchedcraving = ""
    end

    local fullfills_sweet_craving = table.contains(cravings, "sweet")
    local fullfills_snack_craving = table.contains(cravings, "snack")

    if fullfills_sweet_craving or current_craving == "sweet" then
        if (fullfills_sweet_craving and current_craving ~= "sweet") or (not fullfills_sweet_craving and current_craving == "sweet") then
            multiplier = multiplier * 0.5
        end
    elseif fullfills_snack_craving and current_craving ~= "snack" and current_craving ~= "soup" and current_craving ~= "pasta" then
        multiplier = multiplier * 0.75
        appraisal_data.snackpenalty = true
    end

    appraisal_data.maxvalue = multiplier == 1

    if plated then
        multiplier = multiplier * 1.25
    end

    local adjusted_value = math.ceil(base_value * multiplier)

    local recipeLvL = coins_data[2]
    local buffer_value = 4

    if plated or (fullfills_sweet_craving and current_craving == "sweet") then
        recipeLvL = recipeLvL < 4 and (recipeLvL + 1) or recipeLvL
        buffer_value = buffer_value - 2
    end

    --the very first coin upgrade requires 0 leftover old coins
    --if its not plated: all subsequent coin upgrades require having atleast 4 leftover old coins after the upgrade.
    --if its plated: all subsequent coin upgrades require having atleast 2 leftover old coins after the upgrade.

    local coin_data = {{1, is_leftovers = true}, {6}, {12}, {18, max = 1, first_value = 18 + buffer_value}}
    local first_upgrade = true
    local coins = {0, 0, 0, 0}

    for i = recipeLvL, 1, -1 do
        --not not is a cast to boolean.
        local value, is_leftovers, max, first_value = coin_data[i][1], coin_data[i].is_leftovers, coin_data[i].max, coin_data[i].first_value
        if first_upgrade and adjusted_value >= (first_value or value) then
            coins[i] = 1
            adjusted_value = adjusted_value - value
            first_upgrade = false
        end
        while (is_leftovers and adjusted_value >= value) or ((max == nil or coins[i] < max) and adjusted_value >= value + buffer_value) do
            coins[i] = coins[i] + 1
            adjusted_value = adjusted_value - value
        end
    end

    return coins, appraisal_data
end

return CoinLogic