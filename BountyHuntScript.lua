-- Bounty Hunt Script
-- Main script for handling bounty hunting gameplay

local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/aliveboy540-rgb/Bounty-Hunt-script/main/Config.lua"))()


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Bounty System Variables
local bountyEarned = 0
local currentTarget = nil
local isHunting = false
local safeZones = {
	Vector3.new(0, 50, 0); -- Example safe zone location
}

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BountyUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Bounty Display Frame
local bountyFrame = Instance.new("Frame")
bountyFrame.Name = "BountyFrame"
bountyFrame.Size = UDim2.new(0, 300, 0, 120)
bountyFrame.Position = UDim2.new(0, 20, 0, 20)
bountyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bountyFrame.BackgroundTransparency = 0.3
bountyFrame.BorderSizePixel = 2
bountyFrame.BorderColor3 = Color3.fromRGB(255, 165, 0)
bountyFrame.Parent = screenGui

-- Bounty Label
local bountyLabel = Instance.new("TextLabel")
bountyLabel.Name = "BountyLabel"
bountyLabel.Size = UDim2.new(1, 0, 0.5, 0)
bountyLabel.Position = UDim2.new(0, 0, 0, 0)
bountyLabel.BackgroundTransparency = 1
bountyLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
bountyLabel.TextSize = 24
bountyLabel.Font = Enum.Font.GothamBold
bountyLabel.Text = "Bounty: $" .. bountyEarned
bountyLabel.Parent = bountyFrame

-- Skip Player Button
local skipButton = Instance.new("TextButton")
skipButton.Name = "SkipButton"
skipButton.Size = UDim2.new(1, -10, 0.4, 0)
skipButton.Position = UDim2.new(0, 5, 0.55, 0)
skipButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
skipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
skipButton.TextSize = 16
skipButton.Font = Enum.Font.Gotham
skipButton.Text = "Skip Player"
skipButton.Parent = bountyFrame

-- Target Info Label
local targetLabel = Instance.new("TextLabel")
targetLabel.Name = "TargetLabel"
targetLabel.Size = UDim2.new(0, 300, 0, 50)
targetLabel.Position = UDim2.new(0, 20, 0, 150)
targetLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
targetLabel.BackgroundTransparency = 0.3
targetLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
targetLabel.TextSize = 14
targetLabel.Font = Enum.Font.Gotham
targetLabel.Text = "Status: Searching for target..."
targetLabel.TextWrapped = true
targetLabel.BorderColor3 = Color3.fromRGB(0, 255, 0)
targetLabel.BorderSizePixel = 2
targetLabel.Parent = screenGui

-- Update Bounty Display
local function updateBountyDisplay()
	bountyLabel.Text = "Bounty: $" .. bountyEarned
end

-- Check if player is in safe zone
local function isInSafeZone(position)
	for _, safeZone in ipairs(safeZones) do
		if (position - safeZone).Magnitude < 50 then
			return true
		end
	end
	return false
end

-- Join another server
local function joinAnotherServer()
	local servers = {}
	local success, result = pcall(function()
		return game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
	end)
	
	if success then
		local decoded = game:GetService("HttpService"):JSONDecode(result)
		servers = decoded.data or {}
		
		if #servers > 0 then
			local randomServer = servers[math.random(1, #servers)]
			TeleportService:Teleport(game.PlaceId, player, nil, randomServer.id)
		end
	end
end

-- Find nearest player (target)
local function findNearestPlayer()
	local nearestPlayer = nil
	local nearestDistance = math.huge
	
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			local otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
			
			if otherRoot and otherHumanoid and otherHumanoid.Health > 0 then
				local distance = (otherRoot.Position - rootPart.Position).Magnitude
				if distance < nearestDistance and distance < Config.CombatSettings.NearestPlayer then
					nearestDistance = distance
					nearestPlayer = otherPlayer
				end
			end
		end
	end
	
	return nearestPlayer
end

-- Attach to enemy and follow
local function attachToEnemy(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	
	local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
	
	if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
		currentTarget = nil
		isHunting = false
		return
	end
	
	-- Move towards target
	local direction = (targetRoot.Position - rootPart.Position).Unit
	rootPart.CFrame = rootPart.CFrame + direction * 0.5
	
	-- Update target label
	targetLabel.Text = "Target: " .. targetPlayer.Name .. " (" .. math.round(targetHumanoid.Health) .. " HP)"
end

-- Get weapon from inventory
local function equip(weaponName)
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		local weapon = backpack:FindFirstChild(weaponName)
		if weapon then
			weapon.Parent = character
			return weapon
		end
	end
	
	-- Try to find weapon in character
	local weapon = character:FindFirstChild(weaponName)
	return weapon
end

-- Attack enemy with melee
local function meleeAttack(targetPlayer)
	if not Config.CombatSettings.Melee then return end
	local weapon = equip("Melee") or equip("Sword")
	if weapon then
		-- Simulate melee attack
		local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			targetRoot.Position = targetRoot.Position + Vector3.new(0, 0.1, 0)
			weapon:FindFirstChild("Handle").CFrame = targetRoot.CFrame
		end
	end
end

-- Attack enemy with fruit sword
local function fruitSwordAttack(targetPlayer)
	if not Config.CombatSettings.Sword then return end
	local weapon = equip("FruitSword") or equip("Sword")
	if weapon then
		local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			weapon.Parent = character
			-- Trigger attack (depends on game mechanics)
		end
	end
end

-- Attack enemy with gun
local function gunAttack(targetPlayer)
	if not Config.CombatSettings.Gun then return end
	local weapon = equip("Gun")
	if weapon then
		local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot and weapon:FindFirstChild("RemoteEvent") then
			weapon.RemoteEvent:FireServer(targetRoot.CFrame.Position)
		end
	end
end

-- Combat loop
local function fightEnemy(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	
	local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then
		return
	end
	
	-- Kill with all weapons in rotation
	meleeAttack(targetPlayer)
	wait(0.5)
	fruitSwordAttack(targetPlayer)
	wait(0.5)
	gunAttack(targetPlayer)
	wait(0.5)
end

-- Skip button clicked
skipButton.MouseButton1Click:Connect(function()
	if isInSafeZone(rootPart.Position) then
		targetLabel.Text = "Safe zone detected! Joining another server..."
		joinAnotherServer()
	else
		currentTarget = nil
		isHunting = false
		targetLabel.Text = "Player skipped. Searching for new target..."
	end
end)

-- Handle player elimination
local function onTargetDied()
	if currentTarget and currentTarget.Character then
		local humanoid = currentTarget.Character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health <= 0 then
			bountyEarned = bountyEarned + 500 -- Reward for killing
			updateBountyDisplay()
			targetLabel.Text = "Enemy defeated! +$500 bounty earned!"
			currentTarget = nil
			isHunting = false
			wait(2)
			targetLabel.Text = "Searching for new target..."
		end
	end
end

-- Main hunting loop
RunService.Heartbeat:Connect(function()
	if not character or humanoid.Health <= 0 then return end
	
	-- Search for target if none exists
	if not currentTarget or not currentTarget.Character or currentTarget.Character:FindFirstChild("Humanoid").Health <= 0 then
		currentTarget = findNearestPlayer()
		if currentTarget then
			isHunting = true
			targetLabel.Text = "Target found: " .. currentTarget.Name
		end
	end
	
	-- Hunt and fight if target exists
	if currentTarget and isHunting then
		attachToEnemy(currentTarget)
		fightEnemy(currentTarget)
		onTargetDied()
	end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	currentTarget = nil
	isHunting = false
	targetLabel.Text = "Respawned! Searching for target..."
end)

print("Bounty Hunt Script loaded successfully!")
