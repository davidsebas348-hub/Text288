local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Kit = Workspace:WaitForChild("Kit")
local Garge = Kit:WaitForChild("Garge")
local Door = Garge:WaitForChild("Door")
local Button = Garge:WaitForChild("Button")

local HumFolder = Workspace:WaitForChild("Hum")

-- ROOT
local function getRoot()
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

-- TELEPORT + ACTIVAR PROMPT
local function teleportAndActivate(prompt, part)
	local root = getRoot()
	root.CFrame = part.CFrame + Vector3.new(0,3,0)
	task.wait(0.2)
	pcall(function()
		fireproximityprompt(prompt)
	end)
end

-- CHEQUEAR PUERTA CERRADA
local CLOSED_SIZE = Vector3.new(11.138, 5.964, 0.094)
local function isDoorClosed()
	return (Door.Size - CLOSED_SIZE).Magnitude <= 0.01
end

-- BUSCAR PROMPT DE LA PUERTA
local function findButtonPrompt()
	if Button then
		local prompt = Button:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			return prompt, Button
		end
	end
	return nil, nil
end

-- ABRIR PUERTA
local function openDoor()
	local prompt, part = findButtonPrompt()
	if prompt and part then
		teleportAndActivate(prompt, part)
		print("Puerta abierta automáticamente por desaparición de modelo sin Done=true")
	end
end

-- SEGUIMIENTO DE MODELOS
local modelStates = {}

-- Registrar modelos existentes al inicio
for _, model in pairs(HumFolder:GetChildren()) do
	if model:IsA("Model") then
		modelStates[model] = model:GetAttribute("Done")
	end
end

-- Cuando aparece un modelo nuevo
HumFolder.ChildAdded:Connect(function(model)
	if model:IsA("Model") then
		modelStates[model] = model:GetAttribute("Done")
	end
end)

-- Cuando desaparece un modelo
HumFolder.ChildRemoved:Connect(function(model)
	if model:IsA("Model") then
		local doneValue = modelStates[model] or false
		modelStates[model] = nil

		-- Solo abrir la puerta si la puerta estaba cerrada y el modelo nunca puso Done=true
		if isDoorClosed() and not doneValue then
			openDoor()
		end
	end
end)
