-- Example Custom Bounty Hunt Script
-- Shows how to extend the main script with custom features

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Import utilities
-- local Utilities = require(game.ServerScriptService.Utilities)

-- EXAMPLE 1: Custom Bounty Multiplier System
local function createMultiplierSystem()
	local multipliers = {
		streak = 1.0,      -- Killing streak multiplier
		difficulty = 1.0,  -- Target difficulty multiplier
		timeBonus = 1.0,   -- Time-based bonus multiplier
	}
	
	local killStreak = 0
	
	local function calculateBounty(baseBounty, targetLevel)
		multipliers.difficulty = 1 + (targetLevel * 0.1)
		multipliers.streak = 1 + (killStreak * 0.05)
		
		return baseBounty * multipliers.difficulty * multipliers.streak
	end
	
	local function addKill()
		killStreak = killStreak + 1
	end
	
	local function resetStreak()
		killStreak = 0
	end
	
	return {
		calculateBounty = calculateBounty,
		addKill = addKill,
		resetStreak = resetStreak,
		getMultipliers = function() return multipliers end
		getStreak = function() return killStreak end
	}
end

-- EXAMPLE 2: Leaderboard System
local function createLeaderboard()
	local playerStats = {}
	
	local function updateStats(player, kills, bounty)
		if not playerStats[player.Name] then
			playerStats[player.Name] = {
				player = player,
				kills = 0,
				bounty = 0,
				deaths = 0,
			}
		end
		
		playerStats[player.Name].kills = playerStats[player.Name].kills + kills
		playerStats[player.Name].bounty = playerStats[player.Name].bounty + bounty
	end
	
	local function getTop10()
		local sorted = {}
		for name, stats in pairs(playerStats) do
			table.insert(sorted, stats)
		end
		
		table.sort(sorted, function(a, b)
			return a.bounty > b.bounty
		end)
		
		local top = {}
		for i = 1, math.min(10, #sorted) do
			table.insert(top, sorted[i])
		end
		
		return top
	end
	
	local function displayLeaderboard()
		local top = getTop10()
		print("\n=== TOP BOUNTY HUNTERS ===")
		for i, stats in ipairs(top) do
			print(i .. ". " .. stats.player.Name .. " - $" .. stats.bounty .. " (" .. stats.kills .. " kills)")
		end
		print("========================\n")
	end
	
	return {
		updateStats = updateStats,
		getTop10 = getTop10,
		displayLeaderboard = displayLeaderboard,
		getAllStats = function() return playerStats end
	}
end

-- EXAMPLE 3: Advanced Combat AI
local function createCombatAI()
	local function selectWeapon(targetDistance)
		if targetDistance < 10 then
			return "Melee"  -- Very close: use melee
		elseif targetDistance < 30 then
			return "Sword"  -- Medium: use sword
		else
			return "Gun"    -- Far: use gun
		end
	end
	
	local function calculateAttackPriority(targetsList)
		-- Attack player with most bounty first
		table.sort(targetsList, function(a, b)
			local aLevel = 1
			local bLevel = 1
			-- You'd extract actual level from game
			return aLevel > bLevel
		end)
		
		return targetsList[1]
	end
	
	local function predictMovement(targetRoot, targetSpeed)
		-- Predict where target will be in 0.5 seconds
		local direction = targetRoot.CFrame.LookVector
		return targetRoot.Position + direction * targetSpeed * 0.5
	end
	
	return {
		selectWeapon = selectWeapon,
		calculateAttackPriority = calculateAttackPriority,
		predictMovement = predictMovement,
	}
end

-- EXAMPLE 4: Safe Zone Management
local function createSafeZoneManager(safeZones)
	local function findNearestSafeZone(position)
		local nearest = nil
		local nearestDistance = math.huge
		
		for _, zone in ipairs(safeZones) do
			local distance = (position - zone.Position).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearest = zone
			end
		end
		
		return nearest
	end
	
	local function isInAnySafeZone(position)
		for _, zone in ipairs(safeZones) do
			if (position - zone.Position).Magnitude <= zone.Radius then
				return true, zone
			end
		end
		return false
	end
	
	local function createSafeZoneWarning(position)
		-- Warn player when approaching safe zone
		for _, zone in ipairs(safeZones) do
			local distance = (position - zone.Position).Magnitude
			if distance < zone.Radius + 20 then
				print("WARNING: Approaching safe zone!")
				return true
			end
		end
		return false
	end
	
	return {
		findNearestSafeZone = findNearestSafeZone,
		isInAnySafeZone = isInAnySafeZone,
		createSafeZoneWarning = createSafeZoneWarning,
	}
end

-- EXAMPLE 5: Bounty History/Log
local function createBountyLogger()
	local log = {}
	
	local function logKill(killer, victim, bountyEarned, weaponUsed)
		local entry = {
			timestamp = tick(),
			killer = killer,
			victim = victim,
			bounty = bountyEarned,
			weapon = weaponUsed,
		}
		table.insert(log, entry)
	end
	
	local function getRecentKills(minutes)
		local cutoffTime = tick() - (minutes * 60)
		local recentKills = {}
		
		for _, entry in ipairs(log) do
			if entry.timestamp > cutoffTime then
				table.insert(recentKills, entry)
			end
		end
		
		return recentKills
	end
	
	local function printLog()
		print("\n=== BOUNTY HUNT LOG ===")
		for i = math.max(1, #log - 10), #log do
			local entry = log[i]
			print(entry.killer.Name .. " killed " .. entry.victim.Name .. 
				  " for $" .. entry.bounty .. " with " .. entry.weapon)
		end
		print("======================\n")
	end
	
	return {
		logKill = logKill,
		getRecentKills = getRecentKills,
		printLog = printLog,
		getFullLog = function() return log end
	}
end

-- EXAMPLE 6: Achievements System
local function createAchievements()
	local achievements = {
		FirstBlood = {
			name = "First Blood",
			description = "Get your first kill",
			unlocked = false,
		},
		SerialKiller = {
			name = "Serial Killer",
			description = "Get 10 kills in one session",
			unlocked = false,
		},
		GunSlinger = {
			name = "Gun Slinger",
			description = "Kill 5 enemies with gun",
			unlocked = false,
		},
		BladeRunner = {
			name = "Blade Runner",
			description = "Kill 5 enemies with sword",
			unlocked = false,
		},
		BountyMaster = {
			name = "Bounty Master",
			description = "Earn $50,000 in bounty",
			unlocked = false,
		},
	}
	
	local function unlockAchievement(achievementName)
		if achievements[achievementName] then
			achievements[achievementName].unlocked = true
			print("Achievement Unlocked: " .. achievements[achievementName].name)
		end
	end
	
	local function listAchievements()
		print("\n=== ACHIEVEMENTS ===")
		for name, achievement in pairs(achievements) do
			local status = achievement.unlocked and "[✓]" or "[ ]"
			print(status .. " " .. achievement.name .. ": " .. achievement.description)
		end
		print("====================\n")
	end
	
	return {
		unlockAchievement = unlockAchievement,
		listAchievements = listAchievements,
		getAll = function() return achievements end
	}
end

-- Export all systems
return {
	createMultiplierSystem = createMultiplierSystem,
	createLeaderboard = createLeaderboard,
	createCombatAI = createCombatAI,
	createSafeZoneManager = createSafeZoneManager,
	createBountyLogger = createBountyLogger,
	createAchievements = createAchievements,
}
