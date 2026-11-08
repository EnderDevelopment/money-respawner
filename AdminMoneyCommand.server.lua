local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Replace these example IDs with the UserIds of trusted developers.
local ADMIN_USER_IDS = {
	[123456789] = true,
}

local COMMAND_PREFIX = "/givemoney"
local MAX_GRANT = 1000000
local REQUEST_EVENT_NAME = "AdminMoneyRequest"
local RESULT_EVENT_NAME = "AdminMoneyResult"

local requestEvent = ReplicatedStorage:FindFirstChild(REQUEST_EVENT_NAME)
if not requestEvent then
	requestEvent = Instance.new("RemoteEvent")
	requestEvent.Name = REQUEST_EVENT_NAME
	requestEvent.Parent = ReplicatedStorage
end

local resultEvent = ReplicatedStorage:FindFirstChild(RESULT_EVENT_NAME)
if not resultEvent then
	resultEvent = Instance.new("RemoteEvent")
	resultEvent.Name = RESULT_EVENT_NAME
	resultEvent.Parent = ReplicatedStorage
end

local function isAdmin(player)
	return ADMIN_USER_IDS[player.UserId] == true
end

local function getCash(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	local cash = leaderstats:FindFirstChild("Cash")
	if cash and (cash:IsA("IntValue") or cash:IsA("NumberValue")) then
		return cash
	end

	return nil
end

local function findPlayer(name)
	local normalizedName = string.lower(name)
	local exactMatch
	local partialMatch

	for _, player in Players:GetPlayers() do
		local playerName = string.lower(player.Name)
		local displayName = string.lower(player.DisplayName)

		if playerName == normalizedName then
			exactMatch = player
			break
		end

		if string.sub(playerName, 1, #normalizedName) == normalizedName
			or string.sub(displayName, 1, #normalizedName) == normalizedName then
			partialMatch = partialMatch or player
		end
	end

	return exactMatch or partialMatch
end

local function parseAmount(value)
	local amount = tonumber(value)
	if not amount or amount <= 0 or amount ~= math.floor(amount) then
		return nil
	end

	return math.min(amount, MAX_GRANT)
end

local function sendResult(player, message, success)
	resultEvent:FireClient(player, {
		message = message,
		success = success,
	})
end

local function grantMoney(sender, amountText, targetText)
	if not isAdmin(sender) then
		return
	end

	local amount = parseAmount(amountText)
	if not amount then
		sendResult(sender, "Enter a whole amount from 1 to " .. MAX_GRANT .. ".", false)
		return
	end

	local target = sender
	if targetText and targetText ~= "" then
		target = findPlayer(targetText)
	end

	if not target then
		sendResult(sender, "Player not found.", false)
		return
	end

	local cash = getCash(target)
	if not cash then
		sendResult(sender, "The target has no Cash value.", false)
		return
	end

	cash.Value += amount
	sendResult(sender, "Granted $" .. amount .. " to " .. target.Name .. ".", true)
end

local function handleCommand(sender, message)
	if not isAdmin(sender) then
		return
	end

	local arguments = string.split(message, " ")
	if string.lower(arguments[1] or "") ~= COMMAND_PREFIX then
		return
	end

	grantMoney(sender, arguments[2], arguments[3])
end

requestEvent.OnServerEvent:Connect(function(player, action, amountText, targetText)
	if action == "access" then
		resultEvent:FireClient(player, {
			action = "access",
			authorized = isAdmin(player),
		})
		return
	end

	if action == "grant" then
		grantMoney(player, amountText, targetText)
	end
end)

local function connectPlayer(player)
	player.Chatted:Connect(function(message)
		handleCommand(player, message)
	end)
end

Players.PlayerAdded:Connect(connectPlayer)

for _, player in Players:GetPlayers() do
	connectPlayer(player)
end
