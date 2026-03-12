local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - FINAL GHOST (GREEN SCAN)",
   LoadingTitle = "Đang gộp hệ thống Mắt Thần...",
   LoadingSubtitle = "Khoan & Nâng Cấp Tự Động (Only Fly)",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoBuild = false  
_G.UseNoclip = false

-- Thông số Khoan
_G.WaitAtDrill = 300   
_G.DrillRest = 2       

-- Thông số Nâng Cấp (Dùng Mắt Thần)
_G.BuildTime = 20      
_G.BuildRest = 10      

-- Thông số Bay
_G.FlyHeight = 225     
_G.MoveSpeed = 8      

local noclipConnection

local function getMyBase()
    for _, b in ipairs(workspace["The Nuke Tycoon Entirely Model"].Tycoons:GetChildren()) do
        if b:FindFirstChild("Owner") and b.Owner.Value == game.Players.LocalPlayer then return b end
    end
    return nil
end

local function toggleNoclip(state)
    if state then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                if game.Players.LocalPlayer.Character then
                    for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    end
end

-- HÀM KIỂM TRA MÀU XANH LÁ (MÀU TIỀN)
local function isMoneyGreen(gui)
    if gui:IsA("TextLabel") or gui:IsA("TextBox") then
        local color = gui.TextColor3
        if color.G > 0.5 and color.R < 0.5 and color.B < 0.5 then return true end
    end
    return false
end

-- HÀM BAY LƯỚT CHỐNG ANTI (KHÔNG TELEPORT)
local function safeGlide(targetPos)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    
    -- 1. Bay vọt lên trời
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoBuild) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
        task.wait()
        if hrp.Position.Y > _G.FlyHeight then break end
    end

    -- 2. Lướt ngang tới mục tiêu
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 4 and (_G.AutoFarm or _G.AutoBuild) do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * _G.MoveSpeed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    
    -- 3. Đáp xuống dẫm
    if _G.AutoBuild or _G.AutoFarm then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.2, targetPos.Z)
        task.wait(0.3)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ==========================================
-- VÒNG LẶP KHOAN (GIỮ NGUYÊN)
-- ==========================================
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                if drill and giver then
                    safeGlide(drill.Position)
                    local drillStart = tick()
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then fireproximityprompt(drill.ProximityPrompt, 1, true) end
                        task.wait(0.2)
                    end
                    task.wait(_G.DrillRest)
                    if _G.AutoFarm then safeGlide(giver.Position); task.wait(2) end
                end
            end
        end
    end
end)

-- ==========================================
-- VÒNG LẶP NÂNG CẤP (THẾ THẾ BẰNG MẮT THẦN)
-- ==========================================
task.spawn(function()
    while task.wait() do
        if _G.AutoBuild then
            local myBase = getMyBase()
            if myBase then
                toggleNoclip(_G.UseNoclip)
                local buildStart = tick()
                
                while (tick() - buildStart < _G.BuildTime) and _G.AutoBuild do
                    local target = nil
                    for _, obj in ipairs(myBase:GetDescendants()) do
                        if obj:IsA("BillboardGui") then
                            for _, child in ipairs(obj:GetDescendants()) do
                                if isMoneyGreen(child) and obj.Parent:IsA("BasePart") and obj.Parent.Transparency < 1 then
                                    -- Né Cửa và Bồn chứa bằng logic cũ
                                    local pName = obj.Parent.Name:lower()
                                    if not (pName:find("door") or pName:find("tank") or pName:find("toggle")) then
                                        target = obj.Parent
                                        break
                                    end
                                end
                            end
                        end
                        if target then break end
                    end

                    if target then 
                        safeGlide(target.Position)
                        task.wait(1) 
                    end
                    task.wait(0.5)
                end
                
                if not _G.UseNoclip then toggleNoclip(false) end
                task.wait(_G.BuildRest)
            end
        end
    end
end)

-- GIAO DIỆN
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Bật Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Bật Auto Nâng Cấp (Mắt Thần)", CurrentValue = false, Callback = function(v) _G.AutoBuild = v end})
MainTab:CreateToggle({Name = "Noclip (Xuyên vật thể)", CurrentValue = false, Callback = function(v) _G.UseNoclip = v; toggleNoclip(v) end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateSection("MÁY KHOAN")
ConfigTab:CreateInput({Name = "Thời gian khoan (s)", PlaceholderText = "300", Callback = function(t) _G.WaitAtDrill = tonumber(t) or 300 end})
ConfigTab:CreateInput({Name = "Nghỉ khoan (s)", PlaceholderText = "2", Callback = function(t) _G.DrillRest = tonumber(t) or 2 end})

ConfigTab:CreateSection("NÂNG CẤP")
ConfigTab:CreateInput({Name = "Thời gian làm (s)", PlaceholderText = "20", Callback = function(t) _G.BuildTime = tonumber(t) or 20 end})
ConfigTab:CreateInput({Name = "Thời gian nghỉ (s)", PlaceholderText = "10", Callback = function(t) _G.BuildRest = tonumber(t) or 10 end})

ConfigTab:CreateSection("DI CHUYỂN")
ConfigTab:CreateInput({Name = "Tốc độ bay", PlaceholderText = "8", Callback = function(t) _G.MoveSpeed = tonumber(t) or 8 end})
ConfigTab:CreateInput({Name = "Độ cao bay", PlaceholderText = "225", Callback = function(t) _G.FlyHeight = tonumber(t) or 225 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
