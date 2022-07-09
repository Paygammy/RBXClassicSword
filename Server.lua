--!strict

local tool = script:FindFirstAncestorWhichIsA("Tool")
assert(tool, 'Could not find tool')
local handle = tool:WaitForChild("Handle")
assert(handle:IsA("BasePart"), 'Handle is not a BasePart')

local players = game:GetService("Players")
local debris = game:GetService("Debris")
local runservice = game:GetService("RunService")

local damage_values = { base = 5, slash = 10, lunge = 30 }
local damage = damage_values.base
local grips = { up = CFrame.new(0, 0, -1.70000005, 0, 0, 1, 1, 0, 0, 0, 1, 0), out = CFrame.new(0, 0, -1.70000005, 0, 1, 0, 1, -0, 0, 0, 0, -1) }
local sounds = { slash = handle:WaitForChild("SwordSlash", 5), lunge = handle:WaitForChild("SwordLunge", 5), unsheath = handle:WaitForChild("Unsheath") }

local equipped = false
local player, character, humanoid

tool.Grip = grips.up
tool.Enabled = true

local function isteammate(player, opponent)
	if player.Team == opponent.Team then
		return true
	end
	return false
end

local function taghumanoid(humanoid, player)
	local objectvalue = Instance.new("ObjectValue")
	objectvalue.Name = 'creator'
	objectvalue.Value = player
	objectvalue.Parent = humanoid
	debris:AddItem(objectvalue, 2)
	return objectvalue
end

local function untaghumanoid(humanoid)
	for _, objectvalue in pairs(humanoid:GetChildren()) do
		if objectvalue:IsA("ObjectValue") and objectvalue.Name == 'creator' then
			objectvalue:Destroy()
		end
	end
end

local function blow(hit)
	if typeof(player) == 'Instance' and player:IsA("Player") and typeof(character) == 'Instance' and character:IsA("Model") then
		local rightarm = select(2, pcall(function()
			return character:FindFirstChild("Right Arm") or character:FindFirstChild("Right Hand")
		end))
		local rightgrip = select(2, pcall(function()
			return rightarm:FindFirstChild("RightGrip")
		end))
		if typeof(rightgrip) == 'Instance' and typeof(hit) == 'Instance' then
			local character = hit.Parent
			if typeof(character) == 'Instance' and character:IsA("Model") then
				local victim = players:GetPlayerFromCharacter(character)
				if typeof(victim) == 'Instance' and victim:IsA("Player") then
					if isteammate(player, victim) then
						return
					end
				end
				local humanoid = character:FindFirstChildWhichIsA("Humanoid")
				if typeof(humanoid) == 'Instance' and humanoid:IsA("Humanoid") and humanoid.Health > 0 then
					untaghumanoid(humanoid)
					taghumanoid(humanoid, player)
					return humanoid:TakeDamage(damage)
				end
			end
		end
	end
end

local function attack()
	damage = damage_values.slash
	sounds.slash:Play()
	if typeof(humanoid) == 'Instance' and humanoid:IsA("Humanoid") then
		local toolanim = Instance.new("StringValue")
		toolanim.Name = 'toolanim'
		toolanim.Value = 'Slash'
		toolanim.Parent = tool
	end
end

local function lunge()
	damage = damage_values.lunge
	sounds.lunge:Play()
	if typeof(humanoid) == 'Instance' and humanoid:IsA("Humanoid") then
		local toolanim = Instance.new("StringValue")
		toolanim.Name = 'toolanim'
		toolanim.Value = 'Lunge'
		toolanim.Parent = tool
	end
	task.wait(.2)
	tool.Grip = grips.out
	task.wait(.6)
	tool.Grip = grips.up
	damage = damage_values.slash
end

tool.Enabled = true
local last_attack = 0

local function activated()
	if tool.Enabled and equipped and typeof(humanoid) == 'Instance' and humanoid:IsA("Humanoid") and humanoid.Health > 0 then
		tool.Enabled = false
		local time = runservice.Stepped:Wait()
		if time - last_attack < 0.2 then
			lunge()
		else
			attack()
		end
		last_attack = time
		damage = damage_values.base
		tool.Enabled = true
	end
end

local function onequipped()
	character = tool.Parent
	if typeof(character) == 'Instance' then
		player = players:GetPlayerFromCharacter(character)
		humanoid = character:FindFirstChildWhichIsA("Humanoid")
		if typeof(humanoid) == 'Instance' and humanoid:IsA("Humanoid") and humanoid.Health > 0 then
			equipped = true
			sounds.unsheath:Play()
		end
	end
end

local function unequipped()
	tool.Grip = grips.up
	equipped = false
end

tool.Activated:Connect(activated)
tool.Equipped:Connect(onequipped)
tool.Unequipped:Connect(unequipped)
handle.Touched:Connect(blow)
