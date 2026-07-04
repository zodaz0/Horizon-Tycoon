-- @ScriptType: ModuleScript
local PlayerManager = require(script.Parent.Parent.PlayerManager) -- require the PlayerManager so we can give the player money

local Bank = {} -- bank component table
Bank.__index = Bank -- set the metatable index so it can access its own functions

function Bank.new(tycoon, instance) -- creates a new bank component
	local self = setmetatable({}, Bank) -- new table with the Bank metatable
	self.Tycoon = tycoon -- reference to the tycoon that owns this bank
	self.Instance = instance -- the bank instance in the game
	self.Balance = 0 -- how much money is stored in the bank

	return self
end

function Bank:Init() -- runs when the component is set up
	self.Tycoon:SubscribeTopic("WorthChange", function(...) -- listen for when drops are collected so we can add to the balance
		self:OnWorthChange(...)
	end)
	self.Instance.Pad.Touched:Connect(function(...) -- listen for when a player steps on the bank pad
		self:OnTouched(...)
	end)
end

function Bank:OnWorthChange(worth) -- runs when a drop is collected by the collector
	self.Balance += worth -- add the drops worth to the bank balance
	self:SetDisplay("$".. math.floor(self.Balance)) -- update the display to show the new balance, floor it to remove decimals
end

function Bank:SetDisplay(str) -- updates the text on the bank display
	self.Instance.Display.Money.Text = str
end

function Bank:OnTouched(hitPart) -- runs when something touches the bank pad
	local character = hitPart:FindFirstAncestorWhichIsA("Model") -- find the character model from the part that touched
	if character then
		local player = game:GetService("Players"):GetPlayerFromCharacter(character) -- get the player from the character
		if player and player == self.Tycoon.Owner and self.Balance > 0 then -- only the tycoon owner can collect and only if theres money
			local playerMoney = PlayerManager.GetMoney(player) + self.Balance -- add the bank balance to the players money
			PlayerManager.SetMoney(player, playerMoney) -- update the players money
			self.Balance = 0 -- reset the bank balance
			self:SetDisplay("$0") -- update the display to show $0

			local collectSound = self.Instance.Pad:FindFirstChild("CollectSound") -- check if there is a collect sound
			if collectSound and collectSound:IsA("Sound") then
				collectSound:Play() -- play the collect sound
			end
		end
	end
end

return Bank