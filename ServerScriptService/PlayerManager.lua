-- @ScriptType: ModuleScript
local Players = game:GetService("Players") -- get the Players service
local DataStoreService = game:GetService("DataStoreService") -- get the DataStore service for saving data
local PlayerData = DataStoreService:GetDataStore("PlayerData") -- get the data store called PlayerData


local function LeaderboardSetup(value) -- creates the leaderstats folder with a Money value for the leaderboard
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats" -- name has to be leaderstats for Roblox to show it on the leaderboard
	
	
	local money = Instance.new("IntValue")
	money.Name = "Money" -- this is what shows up on the leaderboard
	money.Value = value -- set the starting money amount
	money.Parent = leaderstats
	return leaderstats
	
end

local function LoadData(player) -- loads the players saved data from the data store
	local success, result = pcall(function() -- use pcall so it doesnt break if the data store is down
		return PlayerData:GetAsync(player.UserId)
	end)
	if not success then
		warn(result) -- warn if loading failed
	end
	return success, result
end

local function SaveData(player, data) -- saves the players data to the data store with retry logic
	local maxRetries = 3
	for attempt = 1, maxRetries do
		local success, result = pcall(function() -- use pcall so it doesnt break if the data store is down
			PlayerData:UpdateAsync(player.UserId, function(oldData)
				return data -- UpdateAsync saves atomically, safer than SetAsync
			end)
		end)
		if success then
			return true
		end
		warn("Save attempt " .. attempt .. " failed for " .. player.Name .. ": " .. tostring(result))
		if attempt < maxRetries then
			task.wait(1) -- wait before retrying
		end
	end
	warn("All save attempts failed for " .. player.Name)
	return false
end


local sessionData = {} -- stores all player data in memory while they are in the game



local playerAdded = Instance.new("BindableEvent") -- event that fires when a player joins
local playerRemoving = Instance.new("BindableEvent") -- event that fires when a player leaves

local PlayerManager = {}

PlayerManager.PlayerAdded = playerAdded.Event -- expose the event so other scripts can listen
PlayerManager.PlayerRemoving = playerRemoving.Event -- expose the event so other scripts can listen


function PlayerManager.Start() -- starts the player manager, handles players already in the game and new ones
	for _, player in ipairs(Players:GetPlayers()) do -- loop through players already in the game when the script starts
		coroutine.wrap(PlayerManager.OnPlayerAdded)(player)	
	end
	
	Players.PlayerAdded:Connect(PlayerManager.OnPlayerAdded) -- listen for new players joining
	Players.PlayerRemoving:Connect(PlayerManager.OnPlayerRemoving) -- listen for players leaving
	
	game:BindToClose(PlayerManager.OnClose) -- save all data when the server shuts down
end


function PlayerManager.OnPlayerAdded(player) -- runs when a player joins the game
	player.CharacterAdded:Connect(function(character) -- listen for when the players character loads
		PlayerManager.OnCharacterAdded(player, character)
	end)
	
	local success, data = LoadData(player) -- try to load their saved data
	if success and type(data) == "table" then
		-- validate the loaded data has the expected fields, fill in any missing ones
		sessionData[player.UserId] = {
			Money = type(data.Money) == "number" and data.Money or 0,
			UnlockIds = type(data.UnlockIds) == "table" and data.UnlockIds or {},
		}
	else
		-- loading failed or data was nil/corrupted, give them default data
		sessionData[player.UserId] = {
			Money = 0,
			UnlockIds = {} -- list of ids for things they have unlocked
		}
	end
	
	local leaderstats = LeaderboardSetup(PlayerManager.GetMoney(player)) -- create the leaderboard stats
	leaderstats.Parent = player -- parent it to the player so it shows on the leaderboard
	
	playerAdded:Fire(player) -- fire the event so other scripts know a player joined
end


function PlayerManager.OnCharacterAdded(player, character) -- runs when a players character spawns
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function() -- when the player dies
			task.wait(3) -- wait 3 seconds before respawning
			player:LoadCharacter() -- respawn the player
		end)
	end
end


function PlayerManager.GetMoney(player) -- returns how much money the player has
	return sessionData[player.UserId].Money
end


function PlayerManager.SetMoney(player, value) -- sets the players money to a new value
	if value then
		sessionData[player.UserId].Money = value -- update the session data
		
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local money = leaderstats:FindFirstChild("Money")
			if money then
				
				money.Value = value -- update the leaderboard value too
			end
		end		
	end
	return 0
end



function PlayerManager.AddUnlockId(player, id) -- adds an unlock id to the players data so it persists
	local data = sessionData[player.UserId]
	
	if not table.find(data.UnlockIds, id) then -- check if they already have it
		table.insert(data.UnlockIds, id) -- add it if they dont
	end
end


function PlayerManager.GetUnlockIds(player) -- returns the list of unlock ids the player has
	return sessionData[player.UserId].UnlockIds
end



function PlayerManager.OnPlayerRemoving(player) -- runs when a player leaves the game
	SaveData(player, sessionData[player.UserId]) -- save their data before they go
	sessionData[player.UserId] = nil -- clean up session data to prevent memory leak
	playerRemoving:Fire(player) -- fire the event so other scripts know a player left
end


function PlayerManager.OnClose() -- runs when the server is shutting down
	for _, player in ipairs(Players:GetPlayers()) do -- save every players data before the server closes
		SaveData(player, sessionData[player.UserId]) -- save sequentially so all saves complete before shutdown
	end
end

return PlayerManager
