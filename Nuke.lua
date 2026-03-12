local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - ANTI ANTI-CHEAT V7",
   LoadingTitle = "Đang nạp hệ thống bay lướt an toàn...",
   LoadingSubtitle = "Không Teleport - 100% Lướt",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoBuild = false  
_G.UseNoclip = false

-- Thông số Khoan
_G.WaitAtDrill = 300   -- Thời gian đứng khoan
_G.DrillRest = 2       -- Thời gian nghỉ tại máy khoan trước khi đi lấy tiền

-- Thông số Nâng Cấp (Build)
_G.BuildTime = 20      -- Thời gian đi nâng cấp
_G.BuildRest = 10      -- Thời gian nghỉ giữa các đợt nâng cấp

-- Thông số Bay (Chống Anti)
_G.FlyHeight = 195     
_G.MoveSpeed = 5      

-- DANH SÁCH TÊN NÚT CHÍNH XÁC (TỪ HÌNH ẢNH CỦA KHA)
local TargetNames = {
    "Front Door",
    "Rookie Armor",
    "ACS_NoDamage",
    "UraniumButton",
    "Dropper1",
    "Wall1",
    "Base Paths"
}

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

-- HÀM BAY LƯỚT MƯỢT MÀ (KHÔNG TELEPORT ĐỂ CHỐNG ANTI)
local function safeGlide(targetPos)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    
    -- 1. Bay lên độ cao an toàn trước
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 2 and (_G.AutoFarm or _G.AutoBuild) do
        local dir = Vector3.new(0, (_G.FlyHeight - hrp.Position.Y), 0).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (dir * 2)
        task.wait()
    end

    -- 2. Lướt ngang tới mục tiêu
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 3 and (_G.AutoFarm or _G.AutoBuild) do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * _G.MoveSpeed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    
    -- 3. Hạ cánh dẫm lún (Dành cho nâng cấp)
    if _G.AutoBuild then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, -1.2, 0))
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ==========================================
-- VÒNG LẶP 1: KHOAN & NHẬN TIỀN (CHỈ BAY)
-- ==========================================
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                
                if drill and giver then
                    safeGlide(drill.Position) -- Bay tới máy khoan
                    
                    local drillStart = tick()
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(drill.ProximityPrompt, 1, true)
                        end
                        task.wait(0.2)
                    end

                    task.wait(_G.DrillRest) -- Nghỉ một chút trước khi lấy tiền

                    if _G.AutoFarm then
                        safeGlide(giver.Position) -- Bay tới chỗ lấy tiền
                        task.wait(2)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- VÒNG LẶP 2: NÂNG CẤP ĐỘC LẬP (CHỈ BAY THEO TÊN)
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
                    
                    -- Tìm đúng tên trong danh sách của Kha
                    for _, name in ipairs(TargetNames) do
                        for _, obj in ipairs(myBase:GetDescendants()) do
                            if obj.Name == name and obj:IsA("BasePart") and obj.Transparency < 1 then
                                target = obj; break
                            end
                        end
                        if target then break end
                    end

                    if target then
                        safeGlide(target.Position)
                        task.wait(0.5)
                    else
                        task.wait(1) -- Không thấy nút thì đợi quét lại
                    end
                end
                
                if not _G.UseNoclip then toggleNoclip(false) end
                task.wait(_G.BuildRest) -- Thời gian nghỉ của Auto Nâng Cấp
            end
        end
    end
end)

-- GIAO DIỆN
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Bật Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Bật Auto Nâng Cấp", CurrentValue = false, Callback = function(v) _G.AutoBuild = v end})
MainTab:CreateToggle({Name = "Xuyên Tường (Noclip)", CurrentValue = false, Callback = function(v) _G.UseNoclip = v; toggleNoclip(v) end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateSection("MÁY KHOAN")
ConfigTab:CreateInput({Name = "Thời gian khoan (s)", PlaceholderText = "300", Callback = function(t) _G.WaitAtDrill = tonumber(t) or 300 end})
ConfigTab:CreateInput({Name = "Thời gian nghỉ khoan (s)", PlaceholderText = "2", Callback = function(t) _G.DrillRest = tonumber(t) or 2 end})

ConfigTab:CreateSection("NÂNG CẤP")
ConfigTab:CreateInput({Name = "Thời gian đi nâng (s)", PlaceholderText = "20", Callback = function(t) _G.BuildTime = tonumber(t) or 20 end})
ConfigTab:CreateInput({Name = "Thời gian nghỉ nâng (s)", PlaceholderText = "10", Callback = function(t) _G.BuildRest = tonumber(t) or 10 end})

ConfigTab:CreateSection("BAY LƯỚT")
ConfigTab:CreateInput({Name = "Tốc độ lướt", PlaceholderText = "5", Callback = function(t) _G.MoveSpeed = tonumber(t) or 5 end})
ConfigTab:CreateInput({Name = "Độ cao bay", PlaceholderText = "195", Callback = function(t) _G.FlyHeight = tonumber(t) or 195 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
