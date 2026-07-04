-- @ScriptType: ModuleScript
local Unlockable = {} -- unlockable component table
Unlockable.__index = Unlockable -- set the metatable index so it can access its own functions

function Unlockable.new(tycoon, instance) -- creates a new unlockable component
	local self = setmetatable({}, Unlockable) -- new table with the Unlockable metatable
	self.Tycoon = tycoon -- reference to the tycoon that owns this component
	self.Instance = instance -- the instance that can be unlocked
	return self
end

function Unlockable:Init() -- runs when the component is set up
	self.Subscription = self.Tycoon:SubscribeTopic("Button", function(...) -- listen for when any button is pressed
		self:OnButtonPressed(...)
	end)
end


function Unlockable:OnButtonPressed(id) -- runs when a button is pressed somewhere in the tycoon
	if id == self.Instance:GetAttribute("UnlockId") then -- check if the button id matches this unlockables id
		self.Tycoon:Unlock(self.Instance, id) -- unlock this instance in the tycoon
		self.Subscription:Disconnect() -- stop listening since its unlocked now
	end
end

return Unlockable
