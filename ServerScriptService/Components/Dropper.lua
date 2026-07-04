-- @ScriptType: ModuleScript
local dropsFolder = game:GetService("ServerStorage").Drops -- folder where all the drop templates are stored
local Debris = game:GetService("Debris") -- used to remove drops after a set time

local Dropper = {} -- dropper component table
Dropper.__index = Dropper -- set the metatable index so it can access its own functions


function Dropper.new(tycoon, instance) -- creates a new dropper component
	local self = setmetatable({}, Dropper) -- new table with the Dropper metatable
	self.Tycoon = tycoon -- reference to the tycoon that owns this dropper
	self.Instance = instance -- the dropper instance in the game
	self.Rate = instance:GetAttribute("Rate") -- how often it drops in seconds
	self.DropTemplate = dropsFolder[instance:GetAttribute("Drop")] -- the drop model to clone from ServerStorage
	self.DropSpawn = instance.Spout.Spawn -- the spawn point where drops come out
	return self
end


function Dropper:Init() -- runs when the component is set up
	coroutine.wrap(function() -- wrap in a coroutine so the loop doesnt block other code
		while self.Instance.Parent do -- keep dropping as long as the dropper exists
			self:Drop()
			wait(self.Rate) -- wait for the drop rate before dropping again
		end
	end)()
	
end


function Dropper:Drop() -- spawns a single drop from the dropper
	local drop = self.DropTemplate:Clone() -- clone the drop template
	drop.Position = self.DropSpawn.WorldPosition -- put it at the spawn point
	drop.Parent = self.Instance -- parent it to the dropper so its in the workspace
	
	Debris:AddItem(drop, 10) -- remove the drop after 10 seconds so they dont pile up forever
	
end


return Dropper
