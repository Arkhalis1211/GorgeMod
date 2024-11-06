local symbols_transform_merm =
{
	"fx_hit",
	"fx_spit",
	"fx_splat",
	"fx_wisp",
	"headbase_transform",
	"merm_hand",
	"pig_arm",
	"pig_ear",
	"pig_head",
	"pig_leg",
	"pig_torso",
	"scale",
	"scale_loop",
	"scale_wrist",
	"torso_transform",
}

local symbols_transform_pig =
{
	"pig_arm",
	"pig_ear",
	"pig_head",
	"pig_leg",
	"pig_torso",
	"fx_wisp",
	"fx_legwisp",
	"fx_armwisp",
	"fx_dizziness_back",
	"fx_dizziness_front",
	"veggie",
}

local sounds_pig =
{
	[1] = "dontstarve/pig/oink",
	[3] = "dontstarve/pig/eat",
	[10] = "dontstarve/pig/pig_king_laugh",
	[13] = "dontstarve/pig/scream",
	[14] = "dontstarve/pig/attack",
	[15] = "dontstarve/pig/eat",
	[16] = "dontstarve/pig/attack",
	[17] = "dontstarve/pig/death",
}

--[[
local function PlayMermificationMusic(inst)
	if GORGE_SETTINGS.MERMIFICATION_MUSIC then
		inst.sg.statemem.transform_sound = (inst.sg.statemem.transform_sound or 0) + 1
		if inst.player_classified then
			inst.player_classified.mermification_sounds:set(inst.sg.statemem.transform_sound)
		end
	else
	end
end]]

--[[
local function SwapHatSymbols(inst, enable)
	if not GetGorgeGameModeProperty("darkness") then
		return
	end
	
	if enable then
		inst.AnimState:Show("HAT")
		inst.AnimState:Show("HAIR_HAT")
		inst.AnimState:Hide("HAIR_NOHAT")
		inst.AnimState:Hide("HAIR")
	else
		inst.AnimState:Hide("HAT")
		inst.AnimState:Hide("HAIR_HAT")
		inst.AnimState:Show("HAIR_NOHAT")
		inst.AnimState:Show("HAIR")
	end
	inst:EnableFire(enable)
end]]

local function TreeThrust(inst, nosound)
	if inst.sg.statemem.tree then
		local tree = inst.sg.statemem.tree
		
		if tree.components.workable then
			tree.components.workable:WorkedBy(inst, 1.4)
		end
		
		if not nosound then
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
		end
	end
end

local function EnableLantern(inst, val)
	if not inst.components.inventory then
		return
	end

	local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if item and item.prefab == "quagmire_lantern" and item._lit_fx_inst then
		item:PushEvent("lantern_"..(val and "on" or "off"))
	end
end

local function MermSound(inst, id)
	inst.SoundEmitter:PlaySound((inst:HasTag("merm") and sounds_pig[id]) and sounds_pig[id] or "dontstarve/quagmire/transform/fx/"..id)
end

return {
	OverrideRunSounds = function(fn)
		return function(inst, ...)
			UpdateStat(inst.userid, "stepcounter", 1)
			fn(inst, ...)
		end
	end,

	AddQuagmireStates = function(states, DoTalkSound, StopTalkSound, ToggleOnPhysics, ToggleOffPhysics)
		local quagmire_states = {
			State{
				name = "idle_wait_before_jump",
				tags = { "busy", "pausepredict"},

				onenter = function(inst)
					inst.components.locomotor:Stop()
					inst.components.locomotor:Clear()
				
					if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST and (GetGorgeGameModeProperty("murder_mystery") and inst ~= TheWorld.net.components.quagmire_murdermysterymanager:GetMurder()) then
						inst:DoTaskInTime(math.random()*2, function()
							inst.AnimState:PlayAnimation("emote_pre_toast")
							inst.AnimState:PushAnimation("emote_loop_toast", true)
						end)
					else
						inst.AnimState:PlayAnimation("idle_loop", true)
						inst.sg:SetTimeout(math.random() * 4 + 2)
					end
					if GetGorgeGameModeProperty("murder_mystery") and inst == TheWorld.net.components.quagmire_murdermysterymanager:GetMurder() then
						inst.AnimState:PlayAnimation("emote_sad", true)
						inst.sg:SetTimeout(math.random() * 4 + 1)
					end
				end,
			
				ontimeout = function(inst)
					inst.sg:GoToState("funnyidle_wait_before_jump")
				end,
			},

			State{
				name = "funnyidle_wait_before_jump",
				tags = { "busy", "pausepredict" },

				onenter = function(inst)
					if inst.customidleanim == nil then
						inst.AnimState:PlayAnimation("idle_inaction")
					else
						local anim = type(inst.customidleanim) == "string" and inst.customidleanim or inst:customidleanim()
						if anim ~= nil then
							if inst.sg.mem.idlerepeats == nil then
								inst.sg.mem.usecustomidle = math.random() < .5
								inst.sg.mem.idlerepeats = 0
							end
							if inst.sg.mem.idlerepeats > 1 then
								inst.sg.mem.idlerepeats = inst.sg.mem.idlerepeats - 1
							else
								inst.sg.mem.usecustomidle = not inst.sg.mem.usecustomidle
								inst.sg.mem.idlerepeats = inst.sg.mem.usecustomidle and math.random(2) or math.ceil(math.random(5) * .5)
							end
							inst.AnimState:PlayAnimation(inst.sg.mem.usecustomidle and anim or "idle_inaction")
						else
							inst.AnimState:PlayAnimation("idle_inaction")
						end
					end
					if GetGorgeGameModeProperty("murder_mystery") and inst == TheWorld.net.components.quagmire_murdermysterymanager:GetMurder() then
						inst.AnimState:PlayAnimation("emoteXL_sad")
						inst:DoTaskInTime(17 * FRAMES, function()
							local fx = SpawnPrefab("tears")
							if fx ~= nil then
								fx.entity:SetParent(inst.entity)
								fx.entity:AddFollower()
								fx.Follower:FollowSymbol(inst.GUID, "emotefx", 0, 0, 0)
							end
						end)
					end
				end,

				events =
				{
					EventHandler("animqueueover", function(inst)
						if inst.AnimState:AnimDone() then
							inst.sg:GoToState("idle_wait_before_jump")
						end
					end),
				},
			},

			State {
				name = "quagmire_hide",
				tags = { "busy", "nopredict", "nointerrupt" },

				onenter = function(inst)
					ToggleOffPhysics(inst)
					-- SwapHatSymbols(inst, false)
					EnableLantern(inst, false)
					
					inst:Hide()
					
					if inst.DynamicShadow then
						inst.DynamicShadow:Enable(false)
					end
					
					if inst.components.playercontroller then
						inst.components.playercontroller:RemotePausePrediction()
						inst.DynamicShadow:Enable(false)
					end
				end,

				onexit = function(inst)
					-- SwapHatSymbols(inst, true)
					EnableLantern(inst, true)
					
					inst:Show()
				
					ToggleOnPhysics(inst)
				
					if inst.DynamicShadow then
						inst.DynamicShadow:Enable(true)
					end
					
					if inst.components.playercontroller ~= nil then
						inst.components.playercontroller:Enable(true)
					end
				end,
			},

			State{
				name = "transform_merm",
				tags = { "busy", "pausepredict", "transform", "nomorph", "nointerrupt" },

				onenter = function(inst)

					if inst.components.playercontroller ~= nil then
						inst.components.playercontroller:Enable(false)
					end

					inst.AnimState:Hide("swap_arm_carry")
					inst.AnimState:Show("ARM_normal")
					inst.AnimState:PlayAnimation("transform_merm")

					for i, symbol in ipairs(symbols_transform_merm) do
						inst.AnimState:OverrideSymbol(symbol, "player_transform_merm", symbol)
					end

					inst.components.health:SetInvincible(true)
					inst:SetCameraDistance(35)
				end,

				timeline =
				{
					TimeEvent(3*FRAMES, function(inst)
						inst.sg.statemem.camzoom = 16
						inst:SetCameraDistance(inst.sg.statemem.camzoom)
					end),
					TimeEvent(16*FRAMES, function(inst)
						MermSound(inst, 1)
					end),
					TimeEvent(32*FRAMES, function(inst)
						MermSound(inst, 3)
						MermSound(inst, 5)
					end),
					TimeEvent(36*FRAMES, function(inst)
						inst.sg.statemem.camzoom = inst.sg.statemem.camzoom - 1
						inst:SetCameraDistance(inst.sg.statemem.camzoom)
					end),
					TimeEvent(52*FRAMES, function(inst)
						MermSound(inst, 10)
					end),
					TimeEvent(79*FRAMES, function(inst)
						MermSound(inst, 11)
					end),
					TimeEvent(95*FRAMES, function(inst)
						MermSound(inst, 9)
					end),
					TimeEvent(100*FRAMES, function(inst)
						MermSound(inst, 12)
					end),
					TimeEvent(126*FRAMES, function(inst)
						MermSound(inst, 7)
					end),
					TimeEvent(146*FRAMES, function(inst)
						inst.sg.statemem.camzoom = inst.sg.statemem.camzoom - 1
						inst:SetCameraDistance(inst.sg.statemem.camzoom)
					end),
					TimeEvent(167*FRAMES, function(inst)
						MermSound(inst, 9)
					end),
					TimeEvent(190*FRAMES, function(inst)
						MermSound(inst, 9)
					end),
					TimeEvent(210*FRAMES, function(inst)
						MermSound(inst, 9)
					end),
					TimeEvent(223*FRAMES, function(inst)
						MermSound(inst, 10)
					end),
					TimeEvent(243*FRAMES, function(inst)
						MermSound(inst, 9)
					end),
					TimeEvent(253*FRAMES, function(inst)
						MermSound(inst, 11)
					end),
					TimeEvent(253*FRAMES, function(inst)
						MermSound(inst, 12)
					end),
					TimeEvent(255*FRAMES, function(inst)
						inst.sg.statemem.camzoom = inst.sg.statemem.camzoom - 1
						inst:SetCameraDistance(inst.sg.statemem.camzoom)
					end),
					TimeEvent(263*FRAMES, function(inst)
						MermSound(inst, 13)
					end),
					TimeEvent(287*FRAMES, function(inst)
						MermSound(inst, 14)
					end),
					TimeEvent(300*FRAMES, function(inst)
						MermSound(inst, 15)
					end),
					TimeEvent(320*FRAMES, function(inst)
						MermSound(inst, 16)
					end),
					TimeEvent(340*FRAMES, function(inst)
						MermSound(inst, 17)
					end),
				},

				events =
				{
					EventHandler("animover", function(inst)
						if inst.AnimState:AnimDone() then
							inst.sg:GoToState("idle_merm")
						end
					end),
				},
			},

			State{
				name = "transform_pig",
				tags = { "busy", "pausepredict", "transform", "nomorph", "nointerrupt" },

				onenter = function(inst)
					inst.AnimState:SetBank("player_transform_pig")

					if inst.components.playercontroller ~= nil then
						inst.components.playercontroller:Enable(false)
					end

					inst.AnimState:Hide("swap_arm_carry")
					inst.AnimState:Show("ARM_normal")
					inst.AnimState:PlayAnimation("transform_pig")

					for i, symbol in ipairs(symbols_transform_pig) do
						inst.AnimState:OverrideSymbol(symbol, "player_transform_pig", symbol)
					end

					inst.components.health:SetInvincible(true)
					inst:SetCameraDistance(35)
				end,

				timeline =
				{
					TimeEvent(3*FRAMES, function(inst)
						inst.sg.statemem.camzoom = 16
						inst:SetCameraDistance(inst.sg.statemem.camzoom)
					end),					
					TimeEvent(36*FRAMES, function(inst)
						inst.sg.statemem.camzoom = inst.sg.statemem.camzoom - 1
						inst:SetCameraDistance(inst.sg.statemem.camzoom)
					end),
					TimeEvent(87*FRAMES, function(inst)
						MermSound(inst, 11)
					end),
					TimeEvent(90*FRAMES, function(inst)
						MermSound(inst, 3)
					end),
					TimeEvent(129*FRAMES, function(inst)
						MermSound(inst, 11)
					end),
					TimeEvent(135*FRAMES, function(inst)
						MermSound(inst, 3)
					end),
					TimeEvent(146*FRAMES, function(inst)
						inst.sg.statemem.camzoom = inst.sg.statemem.camzoom - 1
						inst:SetCameraDistance(inst.sg.statemem.camzoom)
					end),
					TimeEvent(183*FRAMES, function(inst)
						MermSound(inst, 11)
					end),
					TimeEvent(189*FRAMES, function(inst)
						MermSound(inst, 3)
					end),
					TimeEvent(243*FRAMES, function(inst)
						MermSound(inst, 11)
					end),
					TimeEvent(255*FRAMES, function(inst)
						inst.sg.statemem.camzoom = inst.sg.statemem.camzoom - 1
						inst:SetCameraDistance(inst.sg.statemem.camzoom)
						MermSound(inst, 3)
					end),
					TimeEvent(288*FRAMES, function(inst)
						MermSound(inst, 12)
					end),
					TimeEvent(315*FRAMES, function(inst)
						MermSound(inst, 1)
					end),
					TimeEvent(341*FRAMES, function(inst)
						MermSound(inst, 1)
					end),
				},

				events =
				{
					EventHandler("animover", function(inst)
						if inst.AnimState:AnimDone() then
							inst.sg:GoToState("idle_pig")
						end
					end),
				},
			},

			State{
				name = "idle_merm",
				tags = { "busy", "pausepredict", "transform", "nomorph", "nointerrupt" },

				onenter = function(inst)
					inst.AnimState:PlayAnimation("idle_merm", true)
					inst:SetCameraDistance()
					inst:ScreenFade(false, 2)
					TheWorld:PushEvent("player_mermified")
				end,
			},
            
            State{
				name = "idle_pig",
				tags = { "busy", "pausepredict", "transform", "nomorph", "nointerrupt" },

				onenter = function(inst)
					inst.AnimState:PlayAnimation("idle_pig", true)
					inst:SetCameraDistance()
					inst:ScreenFade(false, 2)
					TheWorld:PushEvent("player_mermified")
				end,
			},
			
			State{
				name = "idle_scared",
				tags = { "busy", "pausepredict"},

				onenter = function(inst, nofade)
					DoTalkSound(inst)
					if (GetGorgeGameModeProperty("murder_mystery") and inst == TheWorld.net.components.quagmire_murdermysterymanager:GetMurder()) then
						inst.AnimState:PlayAnimation("emoteXL_happycheer", true) 
					else
						inst.AnimState:PlayAnimation("idle_inaction_sanity", true)
					end
					if inst.components.playercontroller ~= nil then
						inst.components.playercontroller:EnableMapControls(false)
						inst.components.playercontroller:Enable(false)
					end
					inst.nofade = nofade
					inst.sg:SetTimeout(2)
				end,
				
				ontimeout = function(inst)
					if not inst.nofade then
						inst:ScreenFade(false, 1)
						inst:DoTaskInTime(1, function(inst)
							inst:ShowHUD(false)
							inst.sg:GoToState("quagmire_hide")
						end)
					end
				end,
				
				timeline = {
					TimeEvent(75 * FRAMES, function(inst)
						StopTalkSound(inst)
					end),
				},
				
				onexit = function(inst)
					StopTalkSound(inst)
				end,
			},
			
			State{
				name = "portal_jump",
				tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },

				onenter = function(inst)
					ToggleOffPhysics(inst)
					
					inst.components.locomotor:Stop()

					inst.AnimState:PlayAnimation("jump")
					
					inst.Physics:SetMotorVel(4, 0, 0)
					inst:SetCameraDistance(8)
				end,

				timeline =
				{
					TimeEvent(10 * FRAMES, function(inst)
						inst.Physics:SetMotorVel(3, 0, 0)
					end),
					
					TimeEvent(15 * FRAMES, function(inst)
						inst.Physics:SetMotorVel(2, 0, 0)
					end),
					
					TimeEvent(15.2 * FRAMES, function(inst)
						inst.DynamicShadow:Enable(false)
						SpawnAt("quagmire_portal_player_splash_fx", inst)
						inst:SetCameraDistance(3)
					end),

					TimeEvent(17 * FRAMES, function(inst)
						inst.Physics:SetMotorVel(1, 0, 0)
					end),
					
					TimeEvent(18 * FRAMES, function(inst)
						inst.Physics:Stop()
					end),
					TimeEvent(20 * FRAMES, function(inst)
						ToggleOffPhysics(inst)
						inst:ScreenFade(false, 1)
						TheWorld:PushEvent("player_teleported")
					end),
				},
			},
			
			State{
				name = "quagmireportalkey",
				tags = { "doing", "busy", "opening", "pausepredict" },

				onenter = function(inst)
					inst.AnimState:PlayAnimation("build_pre")
					inst.AnimState:PushAnimation("build_loop")
				end,

				events = {
					EventHandler("animover", function(inst)
						if inst.AnimState:AnimDone() then
							DoTalkSound(inst)
							inst:PerformBufferedAction()
							inst.AnimState:PushAnimation("build_loop", true)
						end
					end)
				},
				
				timeline = {
					TimeEvent(25 * FRAMES, function(inst)
						StopTalkSound(inst)
					end),
				},
				
				onexit = function(inst)
					StopTalkSound(inst)
					ToggleOffPhysics(inst)
				end,
			},
			
			State{
				name = "win",
				tags = { "busy", "pausepredict"},

				onenter = function(inst)
					DoTalkSound(inst)
					
					inst.AnimState:PlayAnimation("dial_loop", true)
					
					if inst.components.playercontroller ~= nil then
						inst.components.playercontroller:EnableMapControls(false)
						inst.components.playercontroller:Enable(false)
					end
				end,
				
				timeline = {
					TimeEvent(25 * FRAMES, function(inst)
						StopTalkSound(inst)
					end),
				},
				
				onexit = function(inst)
					StopTalkSound(inst)
					ToggleOffPhysics(inst)
				end,
			},
			
			State
			{
				name = "tree_thrust_pre",
				tags = { "thrusting", "doing", "busy", "nointerrupt", "nomorph", "pausepredict" },

				onenter = function(inst, tree)
					inst.components.locomotor:Stop()
					inst.AnimState:PlayAnimation("multithrust_yell")

					if tree and tree:IsValid() then
						inst:ForceFacePoint(tree.Transform:GetWorldPosition())
					end

					if inst.components.playercontroller ~= nil then
						inst.components.playercontroller:RemotePausePrediction()
					end
					
					inst.sg.statemem.tree = tree
				end,

				events =
				{
					EventHandler("animover", function(inst)
						if inst.AnimState:AnimDone() then
							inst.sg:GoToState("tree_thrust", inst.sg.statemem.tree)
						end
					end),
				},
			},

			State
			{
				name = "tree_thrust",
				tags = { "thrusting", "doing", "busy", "nointerrupt", "nomorph", "pausepredict" },

				onenter = function(inst, tree)
					inst.components.locomotor:Stop()
					inst.AnimState:PlayAnimation("multithrust")
					inst.Transform:SetEightFaced()

					if tree then
						inst:ForceFacePoint(tree.Transform:GetWorldPosition())
					end
					
					inst.sg.statemem.tree = tree

					inst.sg:SetTimeout(30 * FRAMES)
				end,
				
				timeline =
				{
					TimeEvent(7 * FRAMES, function(inst)
						inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
					end),
					TimeEvent(9 * FRAMES, function(inst)
						inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
					end),
					TimeEvent(11 * FRAMES, TreeThrust),
					TimeEvent(13 * FRAMES, TreeThrust),
					TimeEvent(15 * FRAMES, TreeThrust),
					TimeEvent(17 * FRAMES, function(inst)
						TreeThrust(inst, true)
					end),
					TimeEvent(19 * FRAMES, function(inst)
						TreeThrust(inst, true)
					end),
				},

				ontimeout = function(inst)
					inst.sg:GoToState("idle", true)
				end,

				events =
				{
					EventHandler("animover", function(inst)
						if inst.AnimState:AnimDone() then
							inst.sg:GoToState("idle")
						end
					end),
				},

				onexit = function(inst)
					inst.Transform:SetFourFaced()
				end,
    },
		}
		
		for i, state in ipairs(quagmire_states) do
			table.insert(states, state)
		end
	end,
}