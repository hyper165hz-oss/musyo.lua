-- coded by tyz -- MODIFICADO POR ZED PARA REENTRADA AUTOMÁTICA

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

-- Re-injetar script após teleport (DELAY DE 5s)
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
txt.Text = "MADE BY tyz dev

-- NOCLIP
local noclipConn
local function enableNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if char then
            for _,v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end
enableNoclip() -- Ativar noclip inicial

-- Lista de presentes
local gifts = {
    YellowGift=true, RedGift=true, GreenGift=true, BlueGift=true
}

-- Função para verificar se ainda há presentes no servidor ATUAL
local function hasGifts()
    for _,o in pairs(workspace.Temp:GetChildren()) do
        if gifts[o.Name] then return true end
    end
    return false
end

-- SERVER HOP (função aprimorada para ciclo contínuo)
local function hopServer()
    if noclipConn then noclipConn:Disconnect() end -- Desativa noclip antes do teleport
    task.wait(1)

    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if not success then
        warn("Falha ao buscar servidores. Tentando novamente em 10s.")
        task.wait(10)
        hopServer()
        return
    end

    for _,sv in ipairs(data.data) do
        -- Encontra um servidor diferente, com vaga e não vazio
        if sv.playing < sv.maxPlayers and sv.id ~= game.JobId and sv.playing > 1 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, plr)
            return
        end
    end

    -- Fallback: se não achou um bom servidor, teleporta para o lugar geral
    TeleportService:Teleport(game.PlaceId, plr)
end

-- FUNÇÃO PRINCIPAL DE FARM (executada em loop até não haver presentes)
local function farmLoop()
    while true do
        if not char or not char.Parent then
            char = plr.Character or plr.CharacterAdded:Wait()
            enableNoclip() -- Reativa noclip se o personagem respawnar
        end

        if not hasGifts() then
            break -- Sai do loop de farm para fazer server hop
        end

        -- Farm dos presentes com noclip
        for _,o in pairs(workspace.Temp:GetChildren()) do
            if gifts[o.Name] and char and char:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(o:GetPivot() + Vector3.new(0,3,0))
                task.wait(0.25) -- Delay entre cada presente
            end
        end
        task.wait(1) -- Delay entre verificações de lote
    end
end

-- LOOP INFINITO DE REENTRADA EM SERVERS
while true do
    farmLoop()      -- Farma até acabar os presentes neste servidor
    hopServer()     -- Pula para um novo servidor
    -- Após o teleport, o queue_on_teleport reiniciará o script no novo servidor.
    -- Esta instância atual será encerrada, e um novo ciclo começará lá.
    task.wait(5)    -- Pequena pausa de segurança antes do fim (se o teleport falhar)
end
