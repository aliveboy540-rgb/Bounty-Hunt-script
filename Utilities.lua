-- Bounty Hunt Utilities
-- Helper functions for the bounty hunt script

local Utilities = {}

-- Get player from character
function Utilities:GetPlayerFromCharacter(character)
	local Players = game:GetService("Players")
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character == character then
			return player
		end
	end
	return nil
end

-- Check if a player is alive
function Utilities:IsPlayerAlive(player)
	if not player or not player.Character then
		return false
	end
	
	local humanoid = player.Character:FindFirstChild("Humanoid")
	return humanoid and humanoid.Health > 0
end

-- Get distance between two positions
function Utilities:GetDistance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

-- Get direction between two positions
function Utilities:GetDirection(fromPos, toPos)
	return (toPos - fromPos).Unit
end

-- Find weapon by name
function Utilities:FindWeapon(character, weaponName)
	if character:FindFirstChild(weaponName) then
		return character:FindFirstChild(weaponName)
	end
	
	local backpack = character.Parent:FindFirstChild("Backpack")
	if backpack and backpack:FindFirstChild(weaponName) then
		return backpack:FindFirstChild(weaponName)
	end
	
	return nil
end

-- Move character towards target
function Utilities:MoveTowards(character, targetPosition, speed)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if humanoid and rootPart then
		local direction = (targetPosition - rootPart.Position).Unit
		rootPart.CFrame = rootPart.CFrame + direction * speed
	end
end

-- Create a notification
function Utilities:Notify(title, message, duration)
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	duration = duration or 3
	
	local notifGui = Instance.new("ScreenGui")
	notifGui.ResetOnSpawn = false
	notifGui.Parent = playerGui
	
	local notifFrame = Instance.new("TextLabel")
	notifFrame.Size = UDim2.new(0, 300, 0, 80)
	notifFrame.Position = UDim2.new(0.5, -150, 0, 20)
	notifFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	notifFrame.BackgroundTransparency = 0.3
	notifFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
	notifFrame.BorderSizePixel = 2
	notifFrame.Parent = notifGui
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.Parent = notifFrame
	
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, 0, 0.6, 0)
	messageLabel.Position = UDim2.new(0, 0, 0.4, 0)
	messageLabel.BackgroundTransparency = 1
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.TextSize = 14
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.Text = message
	messageLabel.TextWrapped = true
	messageLabel.Parent = notifFrame
	
	wait(duration)
	notifGui:Destroy()
end

-- Format numbers with commas
function Utilities:FormatNumber(num)
	local formatted = tostring(num)
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k == 0) then
			break
		end
	end
	return formatted
end

-- Get all players in server
function Utilities:GetAllPlayers(excludePlayer)
	local Players = game:GetService("Players")
	local playerList = {}
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= excludePlayer then
			table.insert(playerList, player)
		end
	end
	
	return playerList
end

-- Sort players by distance
function Utilities:GetPlayersByDistance(fromPosition, excludePlayer)
	local Players = game:GetService("Players")
	local playerDistances = {}
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= excludePlayer and player.Character then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local distance = (root.Position - fromPosition).Magnitude
				table.insert(playerDistances, {player = player, distance = distance})
			end
		end
	end
	
	table.sort(playerDistances, function(a, b)
		return a.distance < b.distance
	end)
	
	return playerDistances
end

-- Check if player is in region
function Utilities:IsInRegion(position, regionCenter, regionRadius)
	return (position - regionCenter).Magnitude <= regionRadius
end

-- Teleport player safely
function Utilities:TeleportPlayer(player, position)
	if player and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = CFrame.new(position)
		end
	end
end

-- Get player's current team
function Utilities:GetPlayerTeam(player)
	return player.Team
end

-- Wait for player to spawn
function Utilities:WaitForPlayerSpawn(player)
	if player.Character then
		return player.Character
	end
	
	return player.CharacterAdded:Wait()
end

-- Damage enemy with weapon
function Utilities:DamageEnemy(targetPlayer, damage)
	if targetPlayer and targetPlayer.Character then
		local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:TakeDamage(damage)
		end
	end
end

-- Create progress bar
function Utilities:CreateProgressBar(maxValue, currentValue, parent)
	local barSize = UDim2.new(0.8, 0, 0.3, 0)
	local barPosition = UDim2.new(0.1, 0, 0.35, 0)
	
	local barBackground = Instance.new("Frame")
	barBackground.Size = barSize
	barBackground.Position = barPosition
	barBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	barBackground.BorderSizePixel = 1
	barBackground.Parent = parent
	
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.new(math.min(currentValue / maxValue, 1), 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBackground
	
	return barBackground, barFill
end

-- Cooldown manager
function Utilities:CreateCooldown(cooldownTime)
	local cd = {
		LastUsed = 0,
		CooldownTime = cooldownTime,
	}
	
	function cd:IsReady()
		return tick() - self.LastUsed >= self.CooldownTime
	end
	
	function cd:Use()
		self.LastUsed = tick()
	end
	
	function cd:GetTimeLeft()
		local timeLeft = self.CooldownTime - (tick() - self.LastUsed)
		return math.max(timeLeft, 0)
	end
	
-- Get the closest player's character
function Utilities:GetClosestPlayer(fromPosition, excludePlayer, maxDistance)
	local Players = game:GetService("Players")
	local closestCharacter = nil
	local closestDistance = maxDistance or math.huge
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= excludePlayer and player.Character then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local distance = (root.Position - fromPosition).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestCharacter = player.Character
				end
			end
		end
	end
	
	return closestCharacter
end

return Utilities
