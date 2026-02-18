local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local kit = workspace:WaitForChild("Kit")
local clientsValue = kit:WaitForChild("Clients")

local garge = kit:WaitForChild("Garge")
local door = garge:WaitForChild("Door")
local button = garge:WaitForChild("Button")

local CLOSED_SIZE = Vector3.new(11.138, 5.964, 0.094)
local FINAL_POSITION = Vector3.new(-36, 4, -492)

-- Root
local function getRoot()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local function teleport(pos)
	getRoot().CFrame = CFrame.new(pos)
end

local function isDoorClosed()
	return (door.Size - CLOSED_SIZE).Magnitude <= 0.01
end

local function closeDoorIfNeeded()
	if not isDoorClosed() then
		local prompt = button:FindFirstChildOfClass("ProximityPrompt")
		if prompt and prompt.Enabled then
			task.wait(2)
			teleport(button.Position + Vector3.new(0,3,0))
			task.wait(0.2)
			pcall(function()
				fireproximityprompt(prompt)
			end)
		end
	end
end

local function waitUntilClosed()
	while not isDoorClosed() do
		door:GetPropertyChangedSignal("Size"):Wait()
	end
end

local function checkSystem()
	if clientsValue.Value ~= 0 then return end

	print("Clients = 0 detectado")

	-- 1️⃣ Intentar cerrar si está abierta
	closeDoorIfNeeded()

	-- 2️⃣ Esperar hasta que REALMENTE esté cerrada
	waitUntilClosed()

	-- 3️⃣ Teleport final SIEMPRE
	print("Puerta cerrada → Teleport final")
	teleport(FINAL_POSITION)
end

clientsValue:GetPropertyChangedSignal("Value"):Connect(checkSystem)

player.CharacterAdded:Connect(function()
	task.wait(1)
	checkSystem()
end)

checkSystem()
