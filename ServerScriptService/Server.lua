-- @ScriptType: Script
local Tycoon = require(script.Parent.Tycoon) -- require the Tycoon moudle script 

local PlayerManager = require(script.Parent.PlayerManager) -- require the PlayerManager moudle script 


local function FindSpawn()
	for _, spawnPoint in ipairs(workspace.Spawns:GetChildren()) do -- there is no fail safe so only one per player
		if not spawnPoint:GetAttribute("Occupied") then
			return spawnPoint
		end
	end
end

PlayerManager.Start() -- start the player manager

PlayerManager.PlayerAdded:Connect(function(player)
	local tycoon = Tycoon.new(player, FindSpawn()) 
	tycoon:init() -- init the tycoon
end)