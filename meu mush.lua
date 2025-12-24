-- coded by tyz

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

-- FALLBACK 1: Método de auto-reinjeção com queue_on_teleport (Solução 1)
if type(queue_on_teleport) == "function" then
    print("DEBUG: queue_on_teleport disponível. Configurando auto-reinjeção.")
    -- String de comando simples e direta
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/hyper165hz-oss/musyo.lua/refs/heads/main/meu%20mush.lua"))()')
else
    warn("DEBUG AVISO CRÍTICO: queue_on_teleport NÃO está disponível.")
    warn("O script NÃO reiniciará automaticamente após teleporte.")
    warn("Será necessário reexecutá-lo manualmente em cada novo servidor.")
end

-- FALLBACK 2: Sistema de detecção de novo servidor com arquivo de cache (Solução 3)
-- Este sistema tenta detectar se estamos em um novo servidor para reiniciar lógicas críticas
local currentJobId = game.JobId
local function setupServerChangeDetection()
    local cacheFile = "serverhop_cache.txt"
    local previousJobId = nil
    
    -- Tenta ler o JobId anterior do cache
    if pcall(function()
        if readfile then
            previousJobId = HttpService:JSONDecode(readfile(cacheFile))
        end
    end) then
        print("DEBUG: JobId anterior lido:", previousJobId)
    end
    
    -- Se o JobId mudou, estamos em um novo servidor
    if previousJobId and previousJobId ~= currentJobId then
        print("DEBUG: Novo servidor detectado! JobId atual:", currentJobId)
    end
    
    -- Salva o JobId atual para a próxima execução
    if pcall(function()
        if writefile then
            writefile(cacheFile, HttpService:JSONEncode(currentJobId))
        end
    end) then
        print("DEBUG: JobId atual salvo no cache:", currentJobId)
    end
end

-- Executa a detecção
setupServerChangeDetection()

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
txt.Text = "MADE BY tyz dev | MOD: ZED v2"

-- NOCLIP
local noclipConn
local function enableNoclip()
    if noclipConn then 
        noclipConn:Disconnect() 
        print("DEBUG: Conexão noclip anterior desconectada.")
    end
    
    noclipConn = RunService.Stepped:Connect(function()
        if char and char.Parent then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        else
            -- Personagem não está mais válido, aguarda um novo
            if noclipConn then
                noclipConn:Disconnect()
            end
            char = plr.Character or plr.CharacterAdded:Wait()
            enableNoclip()
        end
    end)
    print("DEBUG: Noclip ativado.")
end

enableNoclip()

-- Monitor de personagem para recriar noclip se necessário
plr.CharacterAdded:Connect(function(newChar)
    print("DEBUG: Novo personagem detectado.")
    char = newChar
    enableNoclip()
end)

-- Lista de presentes
local gifts = {
    YellowGift = true, 
    RedGift = true, 
    GreenGift = true, 
    BlueGift = true
}

-- Função para verificar se ainda há presentes
local function hasGifts()
    if not workspace:FindFirstChild("Temp") then
        print("DEBUG: Pasta 'Temp' não encontrada na workspace.")
        return false
    end
    
    for _, obj in pairs(workspace.Temp:GetChildren()) do
        if gifts[obj.Name] then 
            return true 
        end
    end
    return false
end

-- SERVER HOP
local function hopServer()
    print("DEBUG: Iniciando server hop...")
    
    if noclipConn then 
        noclipConn:Disconnect()
        print("DEBUG: Noclip desativado para teleporte.")
    end
    
    task.wait(1.5)
    
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    print("DEBUG: Buscando servidores via URL:", url)
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url, true))
    end)
    
    if not success then
        warn("DEBUG: Falha na requisição HTTP. Tentando fallback em 5s.")
        task.wait(5)
        -- Fallback: teleporte simples para o mesmo lugar
        TeleportService:Teleport(game.PlaceId, plr)
        return
    end
    
    if not data or not data.data then
        warn("DEBUG: Dados de servidores inválidos. Usando fallback.")
        TeleportService:Teleport(game.PlaceId, plr)
        return
    end
    
    local foundServer = false
    for _, server in ipairs(data.data) do
        if server.playing < server.maxPlayers and 
           server.id ~= game.JobId and 
           server.playing > 1 then
            
            print("DEBUG: Servidor encontrado - ID:", server.id, "Jogadores:", server.playing, "/", server.maxPlayers)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, plr)
            foundServer = true
            break
        end
    end
    
    if not foundServer then
        print("DEBUG: Nenhum servidor adequado encontrado. Usando teleporte padrão.")
        TeleportService:Teleport(game.PlaceId, plr)
    end
end

-- FUNÇÃO PRINCIPAL DE FARM
local function farmLoop()
    print("DEBUG: Iniciando loop de farm...")
    
    while task.wait(0.5) do
        if not char or not char.Parent then
            print("DEBUG: Personagem não disponível. Aguardando...")
            char = plr.Character or plr.CharacterAdded:Wait()
            enableNoclip()
        end
        
        if not char:FindFirstChild("HumanoidRootPart") then
            print("DEBUG: HumanoidRootPart não encontrado. Aguardando...")
            task.wait(1)
            goto continue
        end
        
        if not hasGifts() then
            print("DEBUG: Não há mais presentes neste servidor.")
            return true  -- Sinaliza para fazer server hop
        end
        
        -- Farm dos presentes
        for _, obj in pairs(workspace.Temp:GetChildren()) do
            if gifts[obj.Name] and char and char:FindFirstChild("HumanoidRootPart") then
                local success = pcall(function()
                    char:PivotTo(obj:GetPivot() + Vector3.new(0, 3, 0))
                end)
                
                if not success then
                    print("DEBUG: Erro ao teletransportar para o presente:", obj.Name)
                end
                
                task.wait(0.3)
            end
        end
        
        ::continue::
    end
    
    return false
end

-- LOOP PRINCIPAL COM LÓGICA DE REINÍCIO
print("DEBUG: ===== INICIANDO SCRIPT PRINCIPAL =====")
print("DEBUG: JobId atual:", currentJobId)
print("DEBUG: PlaceId:", game.PlaceId)

local function main()
    while true do
        print("\nDEBUG: --- Novo ciclo iniciado ---")
        
        -- Executa o farm loop
        local shouldHop = farmLoop()
        
        if shouldHop then
            print("DEBUG: Preparando para server hop...")
            
            -- Mensagem final antes do hop
            if txt then
                txt.Text = "Saindo do servidor... | MOD: ZED v2"
            end
            
            hopServer()
            
            -- Espera um pouco antes de continuar (caso o teleporte falhe)
            print("DEBUG: Aguardando 10s antes de continuar (caso teleporte falhe)...")
            
            if txt then
                txt.Text = "Aguardando teleporte... | MOD: ZED v2"
            end
            
            for i = 1, 10 do
                task.wait(1)
                if txt then
                    txt.Text = "Aguardando teleporte... " .. (10 - i) .. "s | MOD: ZED v2"
                end
            end
            
            -- Se chegou aqui, o teleporte falhou
            print("DEBUG: Teleporte aparentemente falhou. Reiniciando ciclo...")
        else
            print("DEBUG: farmLoop retornou falso. Reiniciando...")
            task.wait(5)
        end
    end
end

-- Executa o script principal com proteção
local success, err = pcall(main)

if not success then
    warn("DEBUG: Erro crítico no script principal:", err)
    
    if txt then
        txt.Text = "ERRO: " .. tostring(err):sub(1, 50) .. " | MOD: ZED v2"
        txt.BackgroundColor3 = Color3.new(1, 0, 0)  -- Vermelho para erro
    end
    
    task.wait(5)
    
    -- Tenta reiniciar o script
    print("DEBUG: Tentando reiniciar o script após erro...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hyper165hz-oss/musyo.lua/refs/heads/main/meu%20mush.lua"))()
end

