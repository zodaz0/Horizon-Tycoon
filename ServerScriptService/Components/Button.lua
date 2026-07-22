-- @ScriptType: ModuleScript
local PlayerManager = require(script.Parent.Parent.PlayerManager) -- require the PlayerManager so we can check and change money

local Button = {} -- button component table
Button.__index = Button -- set the metatable index so it can access its own functions

function Button.new(tycoon, part) -- creates a new button component
	local self = setmetatable({}, Button) -- new table with the Button metatable
	self.Tycoon = tycoon -- reference to the tycoon that owns this button
	self.Instance = part -- the part in the game this button is on
	
	return self
end



function Button:Init() -- runs when the component is set up
	self.Prompt = self:CreatePrompt() -- create the proximity prompt on the button
	self.Prompt.Triggered:Connect(function(...) -- listen for when a player triggers the prompt
		self:Press(...)
	end)

	-- Check if this button requires a previous button to be purchased first
	local requires = self.Instance:GetAttribute("Requires")
	if requires then
		self:Hide() -- hide the button until its requirement is met
		self.RequireSubscription = self.Tycoon:SubscribeTopic("Button", function(id)
			if id == requires then
				self:Reveal() -- show the button now that the requirement is unlocked
				self.RequireSubscription:Disconnect() -- stop listening since we're revealed
				self.RequireSubscription = nil
			end
		end)
	end
end

function Button:CreatePrompt() -- creates the proximity prompt that shows up when you walk near the button
	local prompt = Instance.new("ProximityPrompt")
	prompt.HoldDuration = 0.5 -- how long you have to hold E to trigger it
	prompt.ActionText = self.Instance:GetAttribute("Display") -- what the prompt says (like "Buy Dropper")
	prompt.ObjectText = "$".. self.Instance:GetAttribute("Cost") -- shows the price next to the prompt
	prompt.Parent = self.Instance -- put the prompt on the button part
	return prompt
end


function Button:Hide() -- hides the button until its requirement is met
	self.Instance.Transparency = 1
	self.Instance.CanCollide = false
	self.Prompt.Enabled = false
end

function Button:Reveal() -- reveals the button after its requirement is met
	self.Instance.Transparency = 0
	self.Instance.CanCollide = true
	self.Prompt.Enabled = true
end

function Button:Press(player) -- runs when a player triggers the prompt
	local id = self.Instance:GetAttribute("Id") -- get the button id so other components know which button was pressed
	local cost = self.Instance:GetAttribute("Cost") -- how much this button costs
	local money = PlayerManager.GetMoney(player) -- get the players current money

	if player == self.Tycoon.Owner and money >= cost then -- check if the player owns this tycoon and can afford it
		PlayerManager.SetMoney(player, money - cost) -- take the money from the player
		self.Tycoon:PublishTopic("Button", id) -- tell all other components that this button was pressed
	end
end


return Button
