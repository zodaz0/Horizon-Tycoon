-- @ScriptType: ModuleScript
local Test = {} -- test component table
Test.__index = Test -- set the metatable index so it can access its own functions

function Test.new(tycoon, instance) -- creates a new test component
	local self = setmetatable({}, Test) -- new table with the Test metatable
	self.Tycoon = tycoon -- reference to the tycoon that owns this component
	self.Instance = instance -- the instance in the game this component is attached to
	return self
end

function Test:Init() -- runs when the component is set up
	print("Test component initialized!") -- just prints to confirm it works
end

return Test
