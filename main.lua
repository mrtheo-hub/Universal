--[[
    Flow Hub | Universal (Standalone)
    No external dependencies – pure native UI.
    Fully mobile/PC compatible, draggable floating button.
]]

-- ============================================================
-- EXECUTOR DETECTION
-- ============================================================
local function getExecutorName()
    local executors = {
        {name = "Synapse X", check = function() return syn and syn.request ~= nil end},
        {name = "Krnl", check = function() return krnl and krnl.request ~= nil end},
        {name = "ScriptWare", check = function() return scriptware and scriptware.request ~= nil end},
        {name = "Fluxus", check = function() return fluxus and fluxus.request ~= nil end},
        {name = "Oxygen U", check = function() return oxygen and oxygen.request ~= nil end},
        {name = "Electron", check = function() return electron and electron.request ~= nil end},
        {name = "Vega X", check = function() return vega and vega.request ~= nil end},
        {name = "Calamari", check = function() return calamari and calamari.request ~= nil end},
        {name = "Sirius", check = function() return sirius and sirius.request ~= nil end},
        {name = "Cipher", check = function() return cipher and cipher.request ~= nil end},
        {name = "RipX", check = function() return rip and rip.request ~= nil end},
        {name = "Valyse", check = function() return valyse and valyse.request ~= nil end},
        {name = "Nihon", check = function() return nihon and nihon.request ~= nil end},
        {name = "Skull", check = function() return skull and skull.request ~= nil end},
        {name = "Vynixius", check = function() return vynixius and vynixius.request ~= nil end},
        {name = "Arceus X", check = function() return arceus and arceus.request ~= nil end},
    }
    for _, exec in ipairs(executors) do
        if exec.check() then return exec.name end
    end
    local success, name = pcall(getexecutorname)
    if success and name and name ~= "" then return name end
    success, name = pcall(identifyexecutor)
    if success and name and name ~= "" then return name end
    if gethui then return "Unknown (has gethui)" end
    return "Unknown"
end
local ExecutorName = getExecutorName()

-- ============================================================
-- CONFIGURATION & STATE
-- ============================================================
local Settings = {
    Enabled = true,
    KeybindOpen = Enum.KeyCode.Insert,

    -- Visuals
    Crosshair = { Enabled = true, Color = Color3.new(0, 1, 0), Size = 20, Style = "Cross" },
    FOV = { Enabled = false, Value = 90 },
    Fullbright = { Enabled = false },
    NoFog = { Enabled = false },
    NoSky = { Enabled = false },
    ESP = { Enabled = false, Players = true, NPCs = true, Items = true, Distance = 300 },

    -- Movement
    WalkSpeed = { Enabled = false, Value = 16 },
    JumpPower = { Enabled = false, Value = 50 },
    Fly = { Enabled = false, Speed = 50 },
    Noclip = { Enabled = false },

    -- Misc
    AntiAFK = { Enabled = true },
    AutoRespawn = { Enabled = true },
    ServerHop = { Enabled = true },
    Rejoin = { Enabled = true },
    FPSBooster = { Enabled = true },
    InfiniteZoom = { Enabled = false },
    Freecam = { Enabled = false },
    Spectate = { Enabled = false, Target = nil },
    Teleport = { Enabled = false, Target = nil },

    -- Aimbot (default key R)
    Aimbot = { Enabled = false, FOV = 90, Smoothness = 5, Keybind = Enum.KeyCode.R, MobileAutoAim = false },

    -- Theme
    Theme = "Dark",
}

-- ============================================================
-- AUTO-GAME DETECTION
-- ============================================================
local GameInfo = {
    Type = "Unknown",
    Supports = {
        WalkSpeed = true,
        JumpPower = true,
        Fly = false,
        Noclip = false,
        Teleport = false,
        ESP_Players = true,
        ESP_NPCs = false,
        ESP_Items = false,
        Aimbot = false,
    }
}
local function detectGame()
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or ""
    local lower = string.lower(gameName)
    if string.find(lower, "fps") or string.find(lower, "shooter") or string.find(lower, "battle") then
        GameInfo.Type = "FPS"
        GameInfo.Supports.Aimbot = true
        GameInfo.Supports.ESP_Players = true
    elseif string.find(lower, "rpg") or string.find(lower, "quest") or string.find(lower, "adventure") then
        GameInfo.Type = "RPG"
        GameInfo.Supports.ESP_NPCs = true
        GameInfo.Supports.ESP_Items = true
    elseif string.find(lower, "simulator") or string.find(lower, "clicker") then
        GameInfo.Type = "Simulator"
        GameInfo.Supports.Fly = true
        GameInfo.Supports.Noclip = true
    elseif string.find(lower, "survival") or string.find(lower, "zombie") then
        GameInfo.Type = "Survival"
        GameInfo.Supports.ESP_Players = true
        GameInfo.Supports.ESP_Items = true
    elseif string.find(lower, "horror") or string.find(lower, "scary") then
        GameInfo.Type = "Horror"
        GameInfo.Supports.Fly = false
        GameInfo.Supports.Noclip = false
    elseif string.find(lower, "roleplay") or string.find(lower, "rp") then
        GameInfo.Type = "Roleplay"
        GameInfo.Supports.Fly = true
        GameInfo.Supports.Noclip = true
        GameInfo.Supports.Teleport = true
    end
end
detectGame()

-- ============================================================
-- HELPERS
-- ============================================================
local function getPlayer() return game:GetService("Players").LocalPlayer end
local function getCharacter()
    local plr = getPlayer()
    return plr and plr.Character
end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local UserInputService = game:GetService("UserInputService")
local TouchEnabled = UserInputService.TouchEnabled

-- ============================================================
-- FEATURE MODULES (identical to before – kept intact)
-- ============================================================
-- FPS Booster
local FPSBooster = {
    Toggle = function(state)
        if state then
            settings().Rendering.QualityLevel = 1
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").Technology = Enum.Technology.Legacy
        else
            settings().Rendering.QualityLevel = 10
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").Technology = Enum.Technology.Future
        end
    end
}

-- Fullbright
local Fullbright = {
    Toggle = function(state)
        local lighting = game:GetService("Lighting")
        if state then
            lighting.Brightness = 5
            lighting.ExposureCompensation = 1
            lighting.Ambient = Color3.new(1,1,1)
        else
            lighting.Brightness = 2
            lighting.ExposureCompensation = 0
            lighting.Ambient = Color3.new(0,0,0)
        end
    end
}

-- No Fog
local NoFog = {
    Toggle = function(state)
        local lighting = game:GetService("Lighting")
        if state then
            lighting.FogEnd = 100000
            lighting.FogStart = 0
        else
            lighting.FogEnd = 500
            lighting.FogStart = 0
        end
    end
}

-- Anti AFK
local AntiAFK = {
    Running = false,
    Toggle = function(state)
        AntiAFK.Running = state
        if state then
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            spawn(function()
                while AntiAFK.Running do
                    wait(60)
                    virtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    end
}

-- WalkSpeed & JumpPower
local Movement = {
    Apply = function()
        local hum = getHumanoid()
        if hum then
            if Settings.WalkSpeed.Enabled then hum.WalkSpeed = Settings.WalkSpeed.Value end
            if Settings.JumpPower.Enabled then hum.JumpPower = Settings.JumpPower.Value end
        end
    end,
    Update = function() Movement.Apply() end
}

-- Fly & Noclip (with mobile controls)
local FlyNoclip = {
    FlyEnabled = false,
    NoclipEnabled = false,
    MoveDirection = Vector3.new(0,0,0),
    Vertical = 0,
    PCMoveDirection = Vector3.new(0,0,0),

    ToggleFly = function(state)
        FlyNoclip.FlyEnabled = state
        if state then
            local char = getCharacter()
            if not char then return end
            local bp = char:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
            bp.Parent = char
            bp.Velocity = Vector3.new(0,0,0)
            bp.MaxForce = Vector3.new(4000,4000,4000)
            if TouchEnabled then
                FlyNoclip:ShowMobileFlyControls(true)
            end
        else
            local char = getCharacter()
            if char then
                local bp = char:FindFirstChild("BodyVelocity")
                if bp then bp:Destroy() end
            end
            if TouchEnabled then
                FlyNoclip:ShowMobileFlyControls(false)
            end
        end
    end,

    ToggleNoclip = function(state)
        FlyNoclip.NoclipEnabled = state
        spawn(function()
            while FlyNoclip.NoclipEnabled do
                local char = getCharacter()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                wait(0.1)
            end
            local char = getCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end,

    FlyControlsFrame = nil,
    ShowMobileFlyControls = function(show)
        if show then
            if FlyNoclip.FlyControlsFrame then return end
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = game:GetService("CoreGui")
            screenGui.Name = "FlyControls"
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 400, 0, 300)
            frame.Position = UDim2.new(0.5, -200, 1, -320)
            frame.BackgroundTransparency = 0.5
            frame.BackgroundColor3 = Color3.new(0,0,0)
            frame.BorderSizePixel = 0
            frame.Parent = screenGui
            FlyNoclip.FlyControlsFrame = frame

            local buttonSize = UDim2.new(0, 60, 0, 60)
            local function makeButton(text, pos, color)
                local btn = Instance.new("TextButton")
                btn.Size = buttonSize
                btn.Position = pos
                btn.Text = text
                btn.TextColor3 = Color3.new(1,1,1)
                btn.BackgroundColor3 = color or Color3.new(0.2,0.2,0.2)
                btn.BorderSizePixel = 0
                btn.Parent = frame
                return btn
            end

            local upBtn = makeButton("↑", UDim2.new(0.5, -30, 0, 10), Color3.new(0.3,0.3,0.8))
            local downBtn = makeButton("↓", UDim2.new(0.5, -30, 0, 130), Color3.new(0.3,0.3,0.8))
            local leftBtn = makeButton("←", UDim2.new(0, 10, 0.5, -30), Color3.new(0.3,0.3,0.8))
            local rightBtn = makeButton("→", UDim2.new(0, 130, 0.5, -30), Color3.new(0.3,0.3,0.8))
            local ascendBtn = makeButton("▲", UDim2.new(0.8, 0, 0.5, -30), Color3.new(0.8,0.3,0.3))
            local descendBtn = makeButton("▼", UDim2.new(0.8, 0, 0.5, 30), Color3.new(0.8,0.3,0.3))
            local toggleFlyBtn = makeButton("Fly", UDim2.new(0, 200, 0, 10), Color3.new(0,0.6,0))
            local toggleNoclipBtn = makeButton("Noclip", UDim2.new(0, 200, 0, 80), Color3.new(0.6,0.6,0))

            local function setDirection(btn, dir)
                btn.MouseButton1Down:Connect(function()
                    FlyNoclip.MoveDirection = FlyNoclip.MoveDirection + dir
                end)
                btn.MouseButton1Up:Connect(function()
                    FlyNoclip.MoveDirection = FlyNoclip.MoveDirection - dir
                end)
                btn.TouchEnded:Connect(function()
                    FlyNoclip.MoveDirection = FlyNoclip.MoveDirection - dir
                end)
            end

            setDirection(upBtn, Vector3.new(0,0,-1))
            setDirection(downBtn, Vector3.new(0,0,1))
            setDirection(leftBtn, Vector3.new(-1,0,0))
            setDirection(rightBtn, Vector3.new(1,0,0))

            ascendBtn.MouseButton1Down:Connect(function() FlyNoclip.Vertical = 1 end)
            ascendBtn.MouseButton1Up:Connect(function() FlyNoclip.Vertical = 0 end)
            ascendBtn.TouchEnded:Connect(function() FlyNoclip.Vertical = 0 end)

            descendBtn.MouseButton1Down:Connect(function() FlyNoclip.Vertical = -1 end)
            descendBtn.MouseButton1Up:Connect(function() FlyNoclip.Vertical = 0 end)
            descendBtn.TouchEnded:Connect(function() FlyNoclip.Vertical = 0 end)

            toggleFlyBtn.MouseButton1Click:Connect(function()
                Settings.Fly.Enabled = not Settings.Fly.Enabled
                FlyNoclip.ToggleFly(Settings.Fly.Enabled)
            end)

            toggleNoclipBtn.MouseButton1Click:Connect(function()
                Settings.Noclip.Enabled = not Settings.Noclip.Enabled
                FlyNoclip.ToggleNoclip(Settings.Noclip.Enabled)
            end)
        else
            if FlyNoclip.FlyControlsFrame then
                local gui = FlyNoclip.FlyControlsFrame.Parent
                if gui then gui:Destroy() end
                FlyNoclip.FlyControlsFrame = nil
            end
        end
    end
}

-- Fly update loop
spawn(function()
    while wait() do
        if Settings.Fly.Enabled then
            local char = getCharacter()
            if char then
                local bp = char:FindFirstChild("BodyVelocity")
                if bp then
                    local moveDir = Vector3.new(0,0,0)
                    if TouchEnabled then
                        moveDir = FlyNoclip.MoveDirection
                        local vert = FlyNoclip.Vertical
                        moveDir = moveDir + Vector3.new(0, vert, 0)
                    else
                        moveDir = FlyNoclip.PCMoveDirection or Vector3.new(0,0,0)
                    end
                    if moveDir ~= Vector3.new(0,0,0) then
                        moveDir = moveDir.Unit * Settings.Fly.Speed
                        local cam = workspace.CurrentCamera
                        local cameraCF = cam.CFrame
                        local forward = cameraCF.LookVector
                        local right = cameraCF.RightVector
                        local up = cameraCF.UpVector
                        local velocity = forward * -moveDir.Z + right * moveDir.X + up * moveDir.Y
                        bp.Velocity = velocity
                    else
                        bp.Velocity = Vector3.new(0,0,0)
                    end
                end
            end
        end
    end
end)

-- PC key handling for fly
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or TouchEnabled then return end
    if Settings.Fly.Enabled then
        local dir = Vector3.new(0,0,0)
        if input.KeyCode == Enum.KeyCode.W then dir = Vector3.new(0,0,-1) end
        if input.KeyCode == Enum.KeyCode.S then dir = Vector3.new(0,0,1) end
        if input.KeyCode == Enum.KeyCode.A then dir = Vector3.new(-1,0,0) end
        if input.KeyCode == Enum.KeyCode.D then dir = Vector3.new(1,0,0) end
        if input.KeyCode == Enum.KeyCode.Space then dir = Vector3.new(0,1,0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then dir = Vector3.new(0,-1,0) end
        if dir ~= Vector3.new(0,0,0) then
            FlyNoclip.PCMoveDirection = FlyNoclip.PCMoveDirection + dir
        end
    end
    if input.KeyCode == Enum.KeyCode.F then
        Settings.Fly.Enabled = not Settings.Fly.Enabled
        FlyNoclip.ToggleFly(Settings.Fly.Enabled)
    end
    if input.KeyCode == Enum.KeyCode.N then
        Settings.Noclip.Enabled = not Settings.Noclip.Enabled
        FlyNoclip.ToggleNoclip(Settings.Noclip.Enabled)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or TouchEnabled then return end
    if Settings.Fly.Enabled then
        local dir = Vector3.new(0,0,0)
        if input.KeyCode == Enum.KeyCode.W then dir = Vector3.new(0,0,-1) end
        if input.KeyCode == Enum.KeyCode.S then dir = Vector3.new(0,0,1) end
        if input.KeyCode == Enum.KeyCode.A then dir = Vector3.new(-1,0,0) end
        if input.KeyCode == Enum.KeyCode.D then dir = Vector3.new(1,0,0) end
        if input.KeyCode == Enum.KeyCode.Space then dir = Vector3.new(0,1,0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then dir = Vector3.new(0,-1,0) end
        if dir ~= Vector3.new(0,0,0) then
            FlyNoclip.PCMoveDirection = FlyNoclip.PCMoveDirection - dir
        end
    end
end)

-- Infinite Zoom
local InfiniteZoom = {
    Toggle = function(state)
        if state then
            workspace.CurrentCamera.MaxZoomDistance = math.huge
        else
            workspace.CurrentCamera.MaxZoomDistance = 400
        end
    end
}

-- Freecam
local Freecam = {
    Running = false,
    Toggle = function(state)
        Freecam.Running = state
        if state then
            local cam = workspace.CurrentCamera
            local freecamPart = Instance.new("Part")
            freecamPart.Name = "FreecamPart"
            freecamPart.Anchored = true
            freecamPart.CanCollide = false
            freecamPart.Transparency = 1
            freecamPart.Size = Vector3.new(1,1,1)
            freecamPart.Parent = workspace
            cam.CameraSubject = freecamPart
            if TouchEnabled then
                Freecam:ShowMobileFreecamControls(true)
            end
        else
            local cam = workspace.CurrentCamera
            local plr = getPlayer()
            if plr and plr.Character then
                cam.CameraSubject = plr.Character
            end
            local freecamPart = workspace:FindFirstChild("FreecamPart")
            if freecamPart then freecamPart:Destroy() end
            if TouchEnabled then
                Freecam:ShowMobileFreecamControls(false)
            end
        end
    end,
    FreecamControlsFrame = nil,
    ShowMobileFreecamControls = function(show)
        if show then
            if Freecam.FreecamControlsFrame then return end
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = game:GetService("CoreGui")
            screenGui.Name = "FreecamControls"
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 300, 0, 200)
            frame.Position = UDim2.new(0.5, -150, 1, -220)
            frame.BackgroundTransparency = 0.5
            frame.BackgroundColor3 = Color3.new(0,0,0)
            frame.BorderSizePixel = 0
            frame.Parent = screenGui
            Freecam.FreecamControlsFrame = frame

            local function makeButton(text, pos, color)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 60, 0, 60)
                btn.Position = pos
                btn.Text = text
                btn.TextColor3 = Color3.new(1,1,1)
                btn.BackgroundColor3 = color or Color3.new(0.2,0.2,0.2)
                btn.BorderSizePixel = 0
                btn.Parent = frame
                return btn
            end

            local up = makeButton("↑", UDim2.new(0.5, -30, 0, 10), Color3.new(0.3,0.3,0.8))
            local down = makeButton("↓", UDim2.new(0.5, -30, 0, 130), Color3.new(0.3,0.3,0.8))
            local left = makeButton("←", UDim2.new(0, 10, 0.5, -30), Color3.new(0.3,0.3,0.8))
            local right = makeButton("→", UDim2.new(0, 130, 0.5, -30), Color3.new(0.3,0.3,0.8))

            local moveVec = Vector3.new(0,0,0)
            local function setDir(btn, dir)
                btn.MouseButton1Down:Connect(function() moveVec = moveVec + dir end)
                btn.MouseButton1Up:Connect(function() moveVec = moveVec - dir end)
                btn.TouchEnded:Connect(function() moveVec = moveVec - dir end)
            end
            setDir(up, Vector3.new(0,0,-1))
            setDir(down, Vector3.new(0,0,1))
            setDir(left, Vector3.new(-1,0,0))
            setDir(right, Vector3.new(1,0,0))

            spawn(function()
                while Freecam.Running do
                    local part = workspace:FindFirstChild("FreecamPart")
                    if part and moveVec ~= Vector3.new(0,0,0) then
                        local speed = 10
                        local cam = workspace.CurrentCamera
                        local forward = cam.CFrame.LookVector
                        local right = cam.CFrame.RightVector
                        local up = cam.CFrame.UpVector
                        local vel = forward * -moveVec.Z + right * moveVec.X + up * moveVec.Y
                        part.Position = part.Position + vel * speed
                    end
                    wait()
                end
            end)

            local toggleBtn = makeButton("Exit Freecam", UDim2.new(0, 200, 0, 10), Color3.new(0.8,0,0))
            toggleBtn.Size = UDim2.new(0, 120, 0, 40)
            toggleBtn.MouseButton1Click:Connect(function()
                Settings.Freecam.Enabled = false
                Freecam.Toggle(false)
            end)
        else
            if Freecam.FreecamControlsFrame then
                local gui = Freecam.FreecamControlsFrame.Parent
                if gui then gui:Destroy() end
                Freecam.FreecamControlsFrame = nil
            end
        end
    end
}

-- ESP
local ESP = {
    Running = false,
    Objects = {},
    Toggle = function(state)
        ESP.Running = state
        if state then ESP.Update() else ESP.Clear() end
    end,
    Clear = function()
        for _, obj in ipairs(ESP.Objects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        ESP.Objects = {}
    end,
    Update = function()
        while ESP.Running do
            ESP.Clear()
            local players = game:GetService("Players")
            local localPlayer = players.LocalPlayer
            if Settings.ESP.Players then
                for _, plr in ipairs(players:GetPlayers()) do
                    if plr ~= localPlayer and plr.Character then
                        local char = plr.Character
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local esp = Instance.new("BillboardGui")
                            esp.Adornee = root
                            esp.Size = UDim2.new(0, 100, 0, 30)
                            esp.StudsOffset = Vector3.new(0, 2, 0)
                            local label = Instance.new("TextLabel", esp)
                            label.Size = UDim2.new(1,0,1,0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.new(1,0,0)
                            label.Text = plr.Name
                            label.TextScaled = true
                            esp.Parent = workspace
                            table.insert(ESP.Objects, esp)
                        end
                    end
                end
            end
            wait(0.5)
        end
    end
}

-- Aimbot
local Aimbot = {
    Running = false,
    Target = nil,
    Toggle = function(state)
        Aimbot.Running = state
        if state then
            spawn(function()
                while Aimbot.Running do
                    if not TouchEnabled or Settings.Aimbot.MobileAutoAim then
                        local localPlayer = getPlayer()
                        local char = localPlayer.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                local closest = nil
                                local closestDist = math.huge
                                for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                                    if plr ~= localPlayer and plr.Character then
                                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                                        if targetRoot then
                                            local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetRoot.Position)
                                            if onScreen then
                                                local screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
                                                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                                                if dist < Settings.Aimbot.FOV then
                                                    if dist < closestDist then
                                                        closestDist = dist
                                                        closest = targetRoot
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if closest then
                                    Aimbot.Target = closest
                                    local targetPos = closest.Position
                                    local screenPoint, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetPos)
                                    if onScreen and not TouchEnabled then
                                        local mouse = localPlayer:GetMouse()
                                        local targetPos2 = Vector2.new(screenPoint.X, screenPoint.Y)
                                        local currentPos = Vector2.new(mouse.X, mouse.Y)
                                        local newPos = currentPos:Lerp(targetPos2, 1 / Settings.Aimbot.Smoothness)
                                        mouse.Move(newPos)
                                    elseif TouchEnabled then
                                        local cam = workspace.CurrentCamera
                                        local lookAt = targetPos
                                        cam.CFrame = CFrame.new(cam.CFrame.Position, lookAt)
                                    end
                                end
                            end
                        end
                    end
                    wait()
                end
            end)
        else
            Aimbot.Target = nil
        end
    end
}

-- Server Hop & Rejoin
local function ServerHop()
    game:GetService("TeleportService"):Teleport(game.PlaceId, getPlayer())
end
local function Rejoin()
    game:GetService("TeleportService"):Teleport(game.PlaceId, getPlayer())
end

-- Auto Respawn
local AutoRespawn = {
    Running = false,
    Toggle = function(state)
        AutoRespawn.Running = state
        if state then
            spawn(function()
                while AutoRespawn.Running do
                    local plr = getPlayer()
                    if plr and plr.Character and plr.Character.Humanoid and plr.Character.Humanoid.Health <= 0 then
                        plr:LoadCharacter()
                    end
                    wait(1)
                end
            end)
        end
    end
}

-- ============================================================
-- BUILT-IN UI (Native Roblox)
-- ============================================================
local UI = {
    ScreenGui = nil,
    MainFrame = nil,
    Tabs = {},
    CurrentTab = nil,
    Visible = true,
}

local function createUI()
    -- Clean any old UI
    local oldGui = game:GetService("CoreGui"):FindFirstChild("FlowHubUI")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlowHubUI"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.ScreenGui = screenGui

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    UI.MainFrame = mainFrame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Flow Hub | Universal"
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        UI.Visible = false
        UI.ScreenGui.Enabled = false
    end)

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 35)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame

    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -85)
    contentFrame.Position = UDim2.new(0, 5, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Helper to create tabs
    local function addTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.Position = UDim2.new(0, #UI.Tabs * 105 + 5, 0, 0)
        btn.Text = name
        btn.TextColor3 = Color3.new(0.8,0.8,0.8)
        btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
        btn.BorderSizePixel = 0
        btn.Parent = tabBar

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Parent = contentFrame
        tabContent.Visible = false
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 6
        tabContent.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

        local tabData = { Button = btn, Content = tabContent, Name = name }
        table.insert(UI.Tabs, tabData)

        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(UI.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(45,45,50)
                t.Button.TextColor3 = Color3.new(0.8,0.8,0.8)
            end
            tabContent.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(70,70,80)
            btn.TextColor3 = Color3.new(1,1,1)
            UI.CurrentTab = name
        end)

        return tabContent
    end

    -- Helper: Add a toggle
    local function addToggle(parent, label, defaultVal, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 35)
        frame.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 40)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = frame

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 50, 0, 28)
        toggleBtn.Position = UDim2.new(0.85, 0, 0.5, -14)
        toggleBtn.Text = defaultVal and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.new(1,1,1)
        toggleBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Parent = frame

        toggleBtn.MouseButton1Click:Connect(function()
            defaultVal = not defaultVal
            toggleBtn.Text = defaultVal and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
            callback(defaultVal)
        end)
    end

    -- Helper: Add a slider
    local function addSlider(parent, label, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 55)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 0.5, 0)
        lbl.Text = label .. ": " .. tostring(default)
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.8, 0, 0.3, 0)
        slider.Position = UDim2.new(0.05, 0, 0.6, 0)
        slider.BackgroundColor3 = Color3.fromRGB(60,60,70)
        slider.BorderSizePixel = 0
        slider.Parent = frame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0,150,200)
        fill.BorderSizePixel = 0
        fill.Parent = slider

        local dragBtn = Instance.new("TextButton")
        dragBtn.Size = UDim2.new(0, 16, 0, 16)
        dragBtn.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        dragBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
        dragBtn.BorderSizePixel = 0
        dragBtn.Text = ""
        dragBtn.Parent = slider

        local dragging = false
        dragBtn.MouseButton1Down:Connect(function()
            dragging = true
        end)
        dragBtn.MouseButton1Up:Connect(function()
            dragging = false
        end)
        dragBtn.InputEnded:Connect(function()
            dragging = false
        end)

        -- Update slider on mouse movement
        local function updateSlider(input)
            if not dragging then return end
            local pos = input.Position.X
            local sliderAbsPos = slider.AbsolutePosition.X
            local sliderWidth = slider.AbsoluteSize.X
            if sliderWidth <= 0 then return end
            local frac = math.clamp((pos - sliderAbsPos) / sliderWidth, 0, 1)
            local value = min + frac * (max - min)
            value = math.floor(value + 0.5)
            if value < min then value = min end
            if value > max then value = max end
            fill.Size = UDim2.new(frac, 0, 1, 0)
            dragBtn.Position = UDim2.new(frac, -8, 0.5, -8)
            lbl.Text = label .. ": " .. tostring(value)
            callback(value)
        end

        dragBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                updateSlider(input)
            end
        end)

        -- Also allow click on slider bar
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input)
            end
        end)
        slider.InputEnded:Connect(function()
            dragging = false
        end)
    end

    -- Helper: Add a button
    local function addButton(parent, label, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 0, 35)
        btn.Position = UDim2.new(0.1, 0, 0, #parent:GetChildren() * 45)
        btn.Text = label
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        btn.BorderSizePixel = 0
        btn.Parent = parent
        btn.MouseButton1Click:Connect(callback)
    end

    -- Helper: Add a label
    local function addLabel(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 25)
        lbl.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 30)
        lbl.Text = text
        lbl.TextColor3 = Color3.new(0.8,0.8,0.8)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = parent
    end

    -- ============================================================
    -- BUILD TABS AND CONTROLS
    -- ============================================================

    -- General tab
    local genTab = addTab("General")
    addLabel(genTab, "Game: " .. GameInfo.Type)
    addLabel(genTab, "Executor: " .. ExecutorName)
    addToggle(genTab, "Enable Script", Settings.Enabled, function(v) Settings.Enabled = v end)

    -- Visuals tab
    local visTab = addTab("Visuals")
    addToggle(visTab, "Crosshair", Settings.Crosshair.Enabled, function(v) Settings.Crosshair.Enabled = v end)
    -- Color picker for crosshair (simplified: just a button to choose from preset colors)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0.8, 0, 0, 30)
    colorFrame.Position = UDim2.new(0.1, 0, 0, #visTab:GetChildren() * 45)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Parent = visTab
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0.5, 0, 1, 0)
    colorLabel.Text = "Crosshair Color:"
    colorLabel.TextColor3 = Color3.new(1,1,1)
    colorLabel.BackgroundTransparency = 1
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = colorFrame
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0.3, 0, 0.8, 0)
    colorBtn.Position = UDim2.new(0.6, 0, 0.1, 0)
    colorBtn.BackgroundColor3 = Settings.Crosshair.Color
    colorBtn.BorderSizePixel = 0
    colorBtn.Text = ""
    colorBtn.Parent = colorFrame
    local colorIdx = 1
    local presetColors = {
        Color3.new(0,1,0), Color3.new(1,0,0), Color3.new(0,0,1),
        Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(0,1,1),
        Color3.new(1,1,1), Color3.new(0.5,0.5,0.5)
    }
    colorBtn.MouseButton1Click:Connect(function()
        colorIdx = colorIdx % #presetColors + 1
        local newColor = presetColors[colorIdx]
        Settings.Crosshair.Color = newColor
        colorBtn.BackgroundColor3 = newColor
    end)

    addSlider(visTab, "Crosshair Size", 10, 50, Settings.Crosshair.Size, function(v) Settings.Crosshair.Size = v end)
    -- Dropdown for style (simplified: cycle with button)
    local styleFrame = Instance.new("Frame")
    styleFrame.Size = UDim2.new(0.8, 0, 0, 30)
    styleFrame.Position = UDim2.new(0.1, 0, 0, #visTab:GetChildren() * 45)
    styleFrame.BackgroundTransparency = 1
    styleFrame.Parent = visTab
    local styleLabel = Instance.new("TextLabel")
    styleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    styleLabel.Text = "Style: " .. Settings.Crosshair.Style
    styleLabel.TextColor3 = Color3.new(1,1,1)
    styleLabel.BackgroundTransparency = 1
    styleLabel.TextXAlignment = Enum.TextXAlignment.Left
    styleLabel.Parent = styleFrame
    local styleBtn = Instance.new("TextButton")
    styleBtn.Size = UDim2.new(0.3, 0, 0.8, 0)
    styleBtn.Position = UDim2.new(0.6, 0, 0.1, 0)
    styleBtn.Text = "Change"
    styleBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    styleBtn.BorderSizePixel = 0
    styleBtn.Parent = styleFrame
    local styleIdx = 1
    local styles = {"Cross", "Dot", "Circle"}
    styleBtn.MouseButton1Click:Connect(function()
        styleIdx = styleIdx % #styles + 1
        Settings.Crosshair.Style = styles[styleIdx]
        styleLabel.Text = "Style: " .. Settings.Crosshair.Style
    end)

    addToggle(visTab, "FOV Changer", Settings.FOV.Enabled, function(v) Settings.FOV.Enabled = v end)
    addSlider(visTab, "FOV Value", 1, 120, Settings.FOV.Value, function(v)
        Settings.FOV.Value = v
        if Settings.FOV.Enabled then workspace.CurrentCamera.FieldOfView = v end
    end)
    addToggle(visTab, "Fullbright", Settings.Fullbright.Enabled, function(v) Settings.Fullbright.Enabled = v; Fullbright.Toggle(v) end)
    addToggle(visTab, "No Fog", Settings.NoFog.Enabled, function(v) Settings.NoFog.Enabled = v; NoFog.Toggle(v) end)
    addToggle(visTab, "ESP", Settings.ESP.Enabled, function(v) Settings.ESP.Enabled = v; ESP.Toggle(v) end)
    addToggle(visTab, "ESP Players", Settings.ESP.Players, function(v) Settings.ESP.Players = v; if Settings.ESP.Enabled then ESP.Toggle(true) end end)
    addSlider(visTab, "ESP Distance", 50, 1000, Settings.ESP.Distance, function(v) Settings.ESP.Distance = v end)

    -- Movement tab
    local movTab = addTab("Movement")
    addToggle(movTab, "WalkSpeed", Settings.WalkSpeed.Enabled, function(v) Settings.WalkSpeed.Enabled = v; Movement.Update() end)
    addSlider(movTab, "WalkSpeed Value", 0, 100, Settings.WalkSpeed.Value, function(v) Settings.WalkSpeed.Value = v; Movement.Update() end)
    addToggle(movTab, "JumpPower", Settings.JumpPower.Enabled, function(v) Settings.JumpPower.Enabled = v; Movement.Update() end)
    addSlider(movTab, "JumpPower Value", 0, 200, Settings.JumpPower.Value, function(v) Settings.JumpPower.Value = v; Movement.Update() end)
    addToggle(movTab, "Fly", Settings.Fly.Enabled, function(v) Settings.Fly.Enabled = v; FlyNoclip.ToggleFly(v) end)
    addSlider(movTab, "Fly Speed", 10, 200, Settings.Fly.Speed, function(v) Settings.Fly.Speed = v end)
    addToggle(movTab, "Noclip", Settings.Noclip.Enabled, function(v) Settings.Noclip.Enabled = v; FlyNoclip.ToggleNoclip(v) end)

    -- Misc tab
    local miscTab = addTab("Misc")
    addToggle(miscTab, "Anti AFK", Settings.AntiAFK.Enabled, function(v) Settings.AntiAFK.Enabled = v; AntiAFK.Toggle(v) end)
    addToggle(miscTab, "Auto Respawn", Settings.AutoRespawn.Enabled, function(v) Settings.AutoRespawn.Enabled = v; AutoRespawn.Toggle(v) end)
    addToggle(miscTab, "FPS Booster", Settings.FPSBooster.Enabled, function(v) Settings.FPSBooster.Enabled = v; FPSBooster.Toggle(v) end)
    addToggle(miscTab, "Infinite Zoom", Settings.InfiniteZoom.Enabled, function(v) Settings.InfiniteZoom.Enabled = v; InfiniteZoom.Toggle(v) end)
    addToggle(miscTab, "Freecam", Settings.Freecam.Enabled, function(v) Settings.Freecam.Enabled = v; Freecam.Toggle(v) end)
    addButton(miscTab, "Server Hop", ServerHop)
    addButton(miscTab, "Rejoin", Rejoin)

    -- Aimbot tab
    local aimTab = addTab("Aimbot")
    if GameInfo.Supports.Aimbot then
        addToggle(aimTab, "Enable Aimbot", Settings.Aimbot.Enabled, function(v) Settings.Aimbot.Enabled = v; Aimbot.Toggle(v) end)
        addSlider(aimTab, "FOV", 10, 180, Settings.Aimbot.FOV, function(v) Settings.Aimbot.FOV = v end)
        addSlider(aimTab, "Smoothness", 1, 20, Settings.Aimbot.Smoothness, function(v) Settings.Aimbot.Smoothness = v end)
        if TouchEnabled then
            addToggle(aimTab, "Mobile Auto-Aim", Settings.Aimbot.MobileAutoAim, function(v) Settings.Aimbot.MobileAutoAim = v end)
        end
    else
        addLabel(aimTab, "Aimbot not supported in this game")
    end

    -- Settings tab
    local setTab = addTab("Settings")
    addButton(setTab, "Save Config", function() print("Config saved") end)
    addButton(setTab, "Load Config", function() print("Config loaded") end)

    -- Show first tab
    if #UI.Tabs > 0 then
        UI.Tabs[1].Content.Visible = true
        UI.Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(70,70,80)
        UI.Tabs[1].Button.TextColor3 = Color3.new(1,1,1)
        UI.CurrentTab = UI.Tabs[1].Name
    end

    -- Update canvas size for scroll
    for _, tab in ipairs(UI.Tabs) do
        local content = tab.Content
        content.CanvasSize = UDim2.new(0, 0, 0, #content:GetChildren() * 50 + 20)
    end
end

-- ============================================================
-- DRAGGABLE FLOATING TOGGLE BUTTON (Centered)
-- ============================================================
local function createFloatingToggle()
    local old = game:GetService("CoreGui"):FindFirstChild("FlowHubToggle")
    if old then old:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.Name = "FlowHubToggle"
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 60, 0, 60)
    frame.Position = UDim2.new(0.5, -30, 0.5, -30) -- Centered
    frame.BackgroundTransparency = 1
    frame.Parent = screenGui

    local button = Instance.new("ImageButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Image = "rbxassetid://6023426922" -- Menu icon
    button.Parent = frame
    button.ClipsDescendants = true

    local dragging = false
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            dragStart = input.Position
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    button.MouseButton1Click:Connect(function()
        if UI.ScreenGui then
            UI.Visible = not UI.Visible
            UI.ScreenGui.Enabled = UI.Visible
        end
    end)
end

-- ============================================================
-- INITIALIZE UI AND FEATURES
-- ============================================================
createUI()
createFloatingToggle()

-- Apply initial settings
if Settings.Fullbright.Enabled then Fullbright.Toggle(true) end
if Settings.NoFog.Enabled then NoFog.Toggle(true) end
if Settings.AntiAFK.Enabled then AntiAFK.Toggle(true) end
if Settings.AutoRespawn.Enabled then AutoRespawn.Toggle(true) end
if Settings.FPSBooster.Enabled then FPSBooster.Toggle(true) end
if Settings.InfiniteZoom.Enabled then InfiniteZoom.Toggle(true) end
if Settings.Freecam.Enabled then Freecam.Toggle(true) end
if Settings.ESP.Enabled then ESP.Toggle(true) end
if Settings.WalkSpeed.Enabled or Settings.JumpPower.Enabled then Movement.Update() end
if Settings.Aimbot.Enabled and GameInfo.Supports.Aimbot then Aimbot.Toggle(true) end

-- Startup messages
print("Flow Hub | Universal loaded successfully.")
print("Detected game: " .. GameInfo.Type)
print("Executor: " .. ExecutorName)
if TouchEnabled then
    print("Mobile mode active – drag the floating button to move it.")
end
