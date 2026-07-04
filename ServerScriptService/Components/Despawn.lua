-- @ScriptType: ModuleScript
local Despawn = {} -- despawn component table
Despawn.__index = Despawn -- set the metatable index so it can access its own functions


function Despawn.new(tycoon, instance) -- creates a new despawn component
	local self = setmetatable({}, Despawn) -- new table with the Despawn metatable
	self.Tycoon = tycoon -- reference to the tycoon that owns this component
	self.Instance = instance -- the instance that will be removed
	return self
end


function Despawn:Init() -- runs when the component is set up
	self.Tycoon:SubscribeTopic("Button", function(id) -- listen for when any button is pressed
		if id == self.Instance:GetAttribute("Id") then -- check if the button id matches this instances id
			self.Instance:Destroy() -- remove the instance from the game (like a wall blocking something)
		end
	end)
end

return Despawn
