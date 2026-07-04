-- @ScriptType: ModuleScript
local Conveyor = {} -- conveyor component table
Conveyor.__index = Conveyor -- set the metatable index so it can access its own functions

function Conveyor.new(tycoon, instance) -- creates a new conveyor component
	local self = setmetatable({}, Conveyor) -- new table with the Conveyor metatable
	self.Instance = instance -- the conveyor instance in the game
	self.Speed = instance:GetAttribute("Speed") -- how fast the conveyor moves

	return self
end

function Conveyor:Init() -- runs when the component is set up
	local belt = self.Instance.Belt -- get the belt part inside the conveyor
	belt.AssemblyLinearVelocity = belt.CFrame.LookVector * self.Speed -- make the belt move in the direction its facing at the set speed
end

return Conveyor