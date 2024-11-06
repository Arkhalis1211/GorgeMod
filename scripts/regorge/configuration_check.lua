local menv = env
GLOBAL.setfenv(1, GLOBAL)

local error_codes = {
	[1] = {
		error = true,
		str = "Your server is using \"pause_when_empty\". It must be set to false. Please modify your cluster.ini file."
	},
	
	[2] = {
		error = false,
		str = "Your server is using \"shard_enabled\". It is recomended to set it to false. Please modify your cluster.ini file."
	},
	
	[3] = {
		error = true,
		str = "Your cluster.ini file seems to use the wrong encoding. Please change it to UTF-8."
	},
}

function GorgeError(game_error)
	local sep = "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	
	print("\n")
	
	for i = 1, 3 do
		print(sep)
	end
	
	print(error_codes[game_error].str)
	
	for i = 1, 3 do
		print(sep)
	end
	
	print("\n")
	
	if error_codes[game_error].error then
		error("")
	end
end

menv.AddPrefabPostInit("world", function(w)
	if TheNet:GetServerGameMode() ~= "quagmire" then
		GorgeError(3)
	end
end)