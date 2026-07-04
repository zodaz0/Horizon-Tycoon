-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local template = game:GetService("ServerStorage").Baseplate -- actually get the tycoon base
local componentFolder = script.Parent.Components -- getting the components
local tycoonStorage = game:GetService("ServerStorage").TycoonStorage
local playerManager = require(script.Parent.PlayerManager)


local function NewModel(model, cframe) -- model we want to clone and a frame to clone it to
	local newModel = model:Clone() -- putting the part wherever 
	newModel:SetPrimaryPartCFrame(cframe)
	newModel.Parent = workspace
	return newModel -- return part
end


local Tycoon = {}
Tycoon.__index = Tycoon -- creates a new metatable for the tycoon that can access the functions and properties, its a metamethod
local player = game.Players



function Tycoon.new(player, spawnPoint) -- creates the tycoon , is used for naming and defining
	local self = setmetatable({}, Tycoon)  --new table with metatable Tycoon
	self.Owner = player
	
	self._topicEvent = Instance.new("BindableEvent")
	self._spawn = spawnPoint
	return self

end



function Tycoon:init() -- the function will have all the code for the tycoon
	self.Model = NewModel(template, self._spawn.CFrame)
	self._spawn:SetAttribute("Occupied", true)
	self.Owner.RespawnLocation = self.Model.Restore
	self.Owner:LoadCharacter()
	
	
	self:LockAll()
	self:LoadUnlocks()
	self:WaitForExit()
	
end


function Tycoon:LoadUnlocks()
	for _, id in ipairs(playerManager.GetUnlockIds(self.Owner)) do
		self:PublishTopic("Button", id)
	end
end


function Tycoon:Lock(instance)
	instance.Parent = tycoonStorage
	self:CreateComponent(instance, componentFolder.Unlockable)
	
end

function Tycoon:Unlock(instance, id)
	
	playerManager.AddUnlockId(self.Owner, id)
	
	
	CollectionService:RemoveTag(instance, "Unlockable")
	self:AddComponents(instance)
	instance.Parent = self.Model
end

function Tycoon:LockAll ()
	for _, instance in ipairs(self.Model:GetDescendants()) do
		if CollectionService:HasTag(instance, "Unlockable") then
			self:Lock(instance)
		else
			self:AddComponents(instance)
		end
	end
end


function Tycoon:AddComponents(instance)
	for _, tag in ipairs(CollectionService:GetTags(instance)) do -- returns an array
		-- get all the tags of our instance because multiple components can be on a same instance
		local component = componentFolder:FindFirstChild(tag) -- find the component based on the tag if it exists
		if  component then -- if the component exists
			self:CreateComponent(instance, component) -- create the component
		end
		
	end
end



function Tycoon:CreateComponent(instance, componentScript) -- creating the components
	local compMoudle = require(componentScript) 
	local newComp = compMoudle.new(self, instance) -- we need to reference the tycoon calling it, the function is in tycoon itself
	newComp:Init() -- init the component
end


function Tycoon:PublishTopic(topicName, ...)
	self._topicEvent:Fire(topicName, ...) -- fire the event (touch)

end



function Tycoon:SubscribeTopic(topicName, callback)
	local connection = self._topicEvent.Event:Connect(function(name, ...)
		if name == topicName then
			callback(...) -- call the callback
		end
		
	end)
	return connection
end


function Tycoon:WaitForExit()
	playerManager.PlayerRemoving:Connect(function(player)
		if self.Owner == player then
			self:destroy()
		end
	end)
end


function Tycoon:destroy()
	self.Model:Destroy()
	self._spawn:SetAttribute("Occupied", false)
	self._topicEvent:Destroy()
end



return Tycoon
