local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local MONEY_VALUE = 10
local RESPAWN_SECONDS = 15
local PICKUP_LIFETIME = 0
local PICKUP_SIZE = Vector3.new(2, 0.5, 2)
local PICKUP_COLOR = Color3.fromRGB(85, 255, 127)

local COLLECTION_SOUND_ID = "rbxassetid://6026984224"
local COLLECTION_SOUND_VOLUME = 0.8
local COLLECTION_SOUND_PLAYBACK_SPEED = 1
local COLLECTION_PARTICLE_COUNT = 30
local COLLECTION_PARTICLE_LIFETIME = NumberRange.new(0.45, 0.8)
local COLLECTION_PARTICLE_SPEED = NumberRange.new(7, 12)
local COLLECTION_PARTICLE_COLOR = ColorSequence.new(PICKUP_COLOR)

local spawnFolder = workspace:FindFirstChild("MoneySpawnPoints")
if not spawnFolder then
	spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "MoneySpawnPoints"
	spawnFolder.Parent = workspace
	warn("MoneySpawner created workspace.MoneySpawnPoints. Add Parts inside it to define money locations.")
end

local activePickups = {}

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

local function createLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	if not getCash(player) then
		local cash = Instance.new("IntValue")
		cash.Name = "Cash"
		cash.Value = 0
		cash.Parent = leaderstats
	end
end

local function playCollectionEffects(cframe)
	local effectPart = Instance.new("Part")
	effectPart.Name = "MoneyCollectionEffect"
	effectPart.Size = Vector3.new(0.2, 0.2, 0.2)
	effectPart.CFrame = cframe
	effectPart.Anchored = true
	effectPart.CanCollide = false
	effectPart.CanTouch = false
	effectPart.CanQuery = false
	effectPart.Transparency = 1
	effectPart.Parent = workspace

	local sound = Instance.new("Sound")
	sound.Name = "CollectionSound"
	sound.SoundId = COLLECTION_SOUND_ID
	sound.Volume = COLLECTION_SOUND_VOLUME
	sound.PlaybackSpeed = COLLECTION_SOUND_PLAYBACK_SPEED
	sound.Parent = effectPart
	sound:Play()

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "CollectionParticles"
	emitter.Color = COLLECTION_PARTICLE_COLOR
	emitter.Lifetime = COLLECTION_PARTICLE_LIFETIME
	emitter.Speed = COLLECTION_PARTICLE_SPEED
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Rate = 0
	emitter.LightEmission = 0.7
	emitter.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.35),
	NumberSequenceKeypoint.new(1, 0),
})
	emitter.Parent = effectPart
	emitter:Emit(COLLECTION_PARTICLE_COUNT)

	Debris:AddItem(effectPart, 3)
end

local function spawnMoney(spawnPoint)
	if activePickups[spawnPoint] or not spawnPoint:IsA("BasePart") then
		return
	end

	local pickup = Instance.new("Part")
	pickup.Name = "MoneyPickup"
	pickup.Size = PICKUP_SIZE
	pickup.CFrame = spawnPoint.CFrame + Vector3.new(0, 2, 0)
	pickup.Anchored = true
	pickup.CanCollide = false
	pickup.CanTouch = true
	pickup.Material = Enum.Material.Neon
	pickup.Color = PICKUP_COLOR
	pickup.Shape = Enum.PartType.Cylinder
	pickup.Parent = workspace

	activePickups[spawnPoint] = pickup
	local collected = false

	local touchConnection
	touchConnection = pickup.Touched:Connect(function(hit)
		if collected then
			return
		end

		local character = hit.Parent
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		local cash = getCash(player)
		if not cash then
			return
		end

		collected = true
		cash.Value += MONEY_VALUE
		playCollectionEffects(pickup.CFrame)
		activePickups[spawnPoint] = nil
		touchConnection:Disconnect()
		pickup:Destroy()

		task.delay(RESPAWN_SECONDS, function()
			if spawnPoint.Parent then
				spawnMoney(spawnPoint)
			end
		end)
	end)

	if PICKUP_LIFETIME > 0 then
		Debris:AddItem(pickup, PICKUP_LIFETIME)
	end
end

Players.PlayerAdded:Connect(createLeaderstats)

for _, player in Players:GetPlayers() do
	createLeaderstats(player)
end

for _, spawnPoint in spawnFolder:GetChildren() do
	spawnMoney(spawnPoint)
end

spawnFolder.ChildAdded:Connect(function(spawnPoint)
	spawnMoney(spawnPoint)
end)

spawnFolder.ChildRemoved:Connect(function(spawnPoint)
	local pickup = activePickups[spawnPoint]
	if pickup then
		activePickups[spawnPoint] = nil
		pickup:Destroy()
	end
end)
