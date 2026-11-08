local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local requestEvent = ReplicatedStorage:WaitForChild("AdminMoneyRequest")
local resultEvent = ReplicatedStorage:WaitForChild("AdminMoneyResult")

local COLORS = {
	background = Color3.fromRGB(22, 27, 32),
	panel = Color3.fromRGB(31, 38, 44),
	input = Color3.fromRGB(43, 51, 58),
	text = Color3.fromRGB(241, 245, 247),
	muted = Color3.fromRGB(165, 177, 184),
	accent = Color3.fromRGB(55, 190, 125),
	close = Color3.fromRGB(190, 72, 72),
}

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function createLabel(parent, name, text, size, position, fontSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or COLORS.text
	label.TextSize = fontSize
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local gui = Instance.new("ScreenGui")
gui.Name = "AdminMoneyMenu"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = playerGui

local toggle = Instance.new("TextButton")
toggle.Name = "ToggleButton"
toggle.Size = UDim2.fromOffset(42, 42)
toggle.Position = UDim2.new(0, 18, 0.5, -21)
toggle.BackgroundColor3 = COLORS.panel
toggle.Text = "$"
toggle.TextColor3 = COLORS.accent
toggle.TextSize = 24
toggle.Font = Enum.Font.GothamBold
toggle.Visible = false
toggle.Parent = playerGui
addCorner(toggle, 8)

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(320, 285)
panel.Position = UDim2.new(0, 70, 0.5, -142)
panel.BackgroundColor3 = COLORS.background
panel.BorderSizePixel = 0
panel.Parent = gui
addCorner(panel, 8)

createLabel(panel, "Title", "Admin money", UDim2.new(1, -68, 0, 30), UDim2.fromOffset(18, 16), 19, COLORS.text).Font = Enum.Font.GothamBold

local close = Instance.new("TextButton")
close.Name = "CloseButton"
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -46, 0, 14)
close.BackgroundColor3 = COLORS.close
close.Text = "X"
close.TextColor3 = COLORS.text
close.TextSize = 14
close.Font = Enum.Font.GothamBold
close.Parent = panel
addCorner(close, 6)

createLabel(panel, "AmountLabel", "Amount", UDim2.new(1, -36, 0, 20), UDim2.fromOffset(18, 61), 13, COLORS.muted)
local amountBox = Instance.new("TextBox")
amountBox.Name = "AmountInput"
amountBox.Size = UDim2.new(1, -36, 0, 38)
amountBox.Position = UDim2.fromOffset(18, 84)
amountBox.BackgroundColor3 = COLORS.input
amountBox.TextColor3 = COLORS.text
amountBox.PlaceholderColor3 = COLORS.muted
amountBox.PlaceholderText = "Whole amount"
amountBox.Text = "100"
amountBox.TextSize = 15
amountBox.Font = Enum.Font.Gotham
amountBox.ClearTextOnFocus = false
amountBox.Parent = panel
addCorner(amountBox, 6)

createLabel(panel, "TargetLabel", "Player (blank for yourself)", UDim2.new(1, -36, 0, 20), UDim2.fromOffset(18, 132), 13, COLORS.muted)
local targetBox = Instance.new("TextBox")
targetBox.Name = "TargetInput"
targetBox.Size = UDim2.new(1, -36, 0, 38)
targetBox.Position = UDim2.fromOffset(18, 155)
targetBox.BackgroundColor3 = COLORS.input
targetBox.TextColor3 = COLORS.text
targetBox.PlaceholderColor3 = COLORS.muted
targetBox.PlaceholderText = "Player name"
targetBox.Text = ""
targetBox.TextSize = 15
targetBox.Font = Enum.Font.Gotham
targetBox.ClearTextOnFocus = false
targetBox.Parent = panel
addCorner(targetBox, 6)

local grant = Instance.new("TextButton")
grant.Name = "GrantButton"
grant.Size = UDim2.new(1, -36, 0, 38)
grant.Position = UDim2.fromOffset(18, 207)
grant.BackgroundColor3 = COLORS.accent
grant.Text = "Grant money"
grant.TextColor3 = Color3.fromRGB(16, 30, 23)
grant.TextSize = 15
grant.Font = Enum.Font.GothamBold
grant.Parent = panel
addCorner(grant, 6)

local status = createLabel(panel, "Status", "", UDim2.new(1, -36, 0, 25), UDim2.fromOffset(18, 250), 12, COLORS.muted)
status.TextWrapped = true

local function setOpen(open)
	gui.Enabled = open
	toggle.Visible = not open
end

toggle.Activated:Connect(function()
	setOpen(true)
end)

close.Activated:Connect(function()
	setOpen(false)
end)

grant.Activated:Connect(function()
	status.TextColor3 = COLORS.muted
	status.Text = "Sending..."
	requestEvent:FireServer("grant", amountBox.Text, targetBox.Text)
end)

resultEvent.OnClientEvent:Connect(function(result)
	if typeof(result) ~= "table" then
		return
	end

	if result.action == "access" then
		if result.authorized then
			toggle.Visible = true
		else
			gui:Destroy()
			toggle:Destroy()
		end
		return
	end

	status.Text = tostring(result.message or "Request failed.")
	status.TextColor3 = result.success and COLORS.accent or COLORS.close
end)

requestEvent:FireServer("access")
