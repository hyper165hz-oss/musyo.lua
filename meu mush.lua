-- coded by tyz

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

-- reinjetar com DELAY DE 5s
if queue_on_teleport then
	queue_on_teleport([[
		task.wait(5)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Tyzzzzz/mushyo/main/mushok"))()
	]])
end

-- GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.ResetOnSpawn = false
local txt = Instance.new("TextLabel", gui)
txt.Size = UDim2.new(0,220,0,40)
txt.Position = UDim2.new(0,10,0,10)
txt.BackgroundTransparency = 0.3
txt.BackgroundColor3 = Color3.new(0,0,0)
txt.TextColor3 = Color3.new(1,1,1)
txt.TextScaled = true
txt.Font = Enum.Font.GothamBold
txt.Text = "MADE BY tyz dev"

-- NOCLIP
local noclipConn
noclipConn = RunService.Stepped:Connect(function()
	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)

local gifts = {
	YellowGift=true, RedGift=true, GreenGift=true, BlueGift=true
}

local function hasGifts()
	for _,o in pairs(workspace.Temp:GetChildren()) do
		if gifts[o.Name] then return true end
	end
	return false
end

-- SERVER HOP (outro server)
local function hopServer()
	if noclipConn then noclipConn:Disconnect() end
	task.wait(1)

	local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
	local data = HttpService:JSONDecode(game:HttpGet(url))

	for _,sv in ipairs(data.data) do
		if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, plr)
			return
		end
	end

	-- fallback
	TeleportService:Teleport(game.PlaceId, plr)
end

while true do
	if not hasGifts() then
		hopServer()
		break
	end

	for _,o in pairs(workspace.Temp:GetChildren()) do
		if gifts[o.Name] then
			char:PivotTo(o:GetPivot() + Vector3.new(0,3,0))
			task.wait(0.25)
		end
	end
end