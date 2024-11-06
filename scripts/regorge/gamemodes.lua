GorgeGameModes = {
	modes = {
		{
			id = "default",
			icon = "default.tex",
		},
		{
			id = "darkness",
			icon = "darkness.tex",
		},
		{-- Endless mode
			id = "endless",
			icon = "endless.tex",
		},
		{-- No sweat mode
			id = "no_sweat",
			icon = "no_sweat.tex",
		},
		{-- Sandbox
			id = "sandbox",
			icon = "sandbox.tex",
		},
		{
			id = "hungry",
			icon = "hungry.tex",
		},
		{-- The sick Gnaw
			id = "sick",
			icon = "sick.tex",
		},
		{-- Scaling difficulty
			id = "scaling",
			icon = "scaling.tex",
		},
		{-- Thieves mode
			id = "thieves",
			icon = "thieves.tex",
		},
		{-- Rush mode
			id = "rush",
			icon = "rush.tex",
		},
		{-- Hard mode
			id = "hard",
			icon = "hard.tex",
		},
		{-- Confusion mode
			id = "confusion",
			icon = "confusion.tex",
		},
		{-- Murder Mystery mode
			id = "murder_mystery",
			icon = "murder_mystery.tex",
		},
		{-- Moonlight Curse mode
			id = "moon_curse",
			icon = "moon_curse.tex",
		},
	},
}

function GorgeGameModes:AddNewMode(id, atlas, icon)
	table.insert(self.modes, {
		id = id,
		atlas = atlas,
		icon = icon or "missing.tex",
	})
end

function GorgeGameModes:GetGameModes()
	return self.modes
end

return GorgeGameModes