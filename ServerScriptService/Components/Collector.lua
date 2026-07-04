-- @ScriptType: ModuleScript
local Collector = {} -- collector component table
Collector.__index = Collector -- set the metatable index so it can access its own functions

function Collector.new(tycoon, instance) -- creates a new collector component
	local self = setmetatable({}, Collector) -- new table with the Collector metatable
	self.Instance = instance -- the collector instance in the game
	self.Tycoon = tycoon -- reference to the tycoon that owns this collector
	
	return self

end


function Collector:Init() -- runs when the component is set up
	self.Instance.Collider.Touched:Connect(function(...) -- listen for when something touches the collector
		self:OnTouched(...)
	end)
end


function Collector:OnTouched(hitPart) -- runs when something touches the collector
	local worth = hitPart:GetAttribute("Worth") -- check if the part has a Worth attribute (means its a drop)
	if worth then
		self.Tycoon:PublishTopic("WorthChange", worth) -- tell the bank that money was collected
		hitPart:Destroy() -- remove the drop from the game
	end
end


return Collector