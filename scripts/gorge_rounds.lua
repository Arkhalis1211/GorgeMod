local FIXED_ROUNDS = 8

local function PickFromList(list, previouscraving)	
	return (type(list) ~= "table" and list) or (previouscraving and list[previouscraving]) or list[math.random(1, #list)]
end

Rounds = {
	cache = {},
}

Rounds.fixed_rounds = {
	[1] = "SNACK",
	[2] = {"VEGGIE", "BREAD"},
	[3] = {"MEAT", "FISH"},
    [4] = "SWEET",
	[5] = {"SNACK", "SOUP", "VEGGIE"},
	[6] = {SOUP = "BREAD", SNACK = "FISH", VEGGIE = "MEAT"},
	[7] = "PASTA",
    [8] = "SWEET",
}

Rounds.rng_rounds = {
	[1] = {"CHEESE", "SOUP", "SNACK", "BREAD"},
	[2] = {"CHEESE", "FISH", "SNACK", "BREAD"},
	[3] = {FISH = "MEAT", "PASTA"},
    [4] = "SWEET"
}

Rounds.cached_rounds = deepcopy(Rounds.rng_rounds)

local function GetRandomCravingForRoundIdx(round, roundidx)
    local craving = PickFromList(Rounds.cached_rounds[roundidx], Rounds.cache[round-1])
    if roundidx == 1 then
        RemoveByValue(Rounds.cached_rounds[2], craving)
    elseif roundidx == 3 then
        Rounds.cached_rounds[2] = shallowcopy(Rounds.rng_rounds[2])
    end
	return craving
end

function Rounds:GetCraving(round)
    local craving
    if round <= FIXED_ROUNDS then
        craving = PickFromList(Rounds.fixed_rounds[round], Rounds.cache[round-1])
    else
        craving = GetRandomCravingForRoundIdx(round, ((round - 1) % 4) + 1)
	end
    Rounds.cache[round] = craving
    Rounds.cache[round-4] = nil
    return craving
end

function Rounds:Debug(rounds)
	for i = 1, 15 do
		print("\n")
	end
	print("Debugging round data:")
	for i = 1, rounds do
		print(string.format("[%i]: %s", i, self:GetCraving(i)))
	end
end

--[[
function Rounds:DedbugRemove(craving)
	for i = 1, FIXED_ROUNDS do
		if self.fixed_rounds[i] and type(self.fixed_rounds[i]) == "table" then
			print("["..i.."]:")
			for k = 1, #self.fixed_rounds[i] do
				print("\t"..k..": "..self.fixed_rounds[i][k])
			end
			RemoveByValue(self.fixed_rounds[i], craving)
		end
	end
	
	print("\nAfter:")
	for i = 1, FIXED_ROUNDS do
		if self.fixed_rounds[i] and type(self.fixed_rounds[i]) == "table" then
			print("["..i.."]:")
			for k = 1, #self.fixed_rounds[i] do
				print("\t"..k..": "..self.fixed_rounds[i][k])
			end
		end
	end
end]] 

return Rounds