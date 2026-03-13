local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - ONLY DRILL MODE",
   LoadingTitle = "Đang khởi động chế độ khoan...",
   LoadingSubtitle = "Tập trung khai thác tài nguyên",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT (QUAY VỀ NHƯ CŨ)
_G.AutoFarm = false   
_G.WaitAtDrill = 300   -- Thời gian đứng khoan
_G.DrillRest = 2       -- Nghỉ sau khi khoan
_G.FlyHeight = 225     
_G.MoveSpeed = 8      

local function getMyBase()
    for _, b in ipairs(workspace["The Nuke Tycoon Entirely Model"].Tycoons:GetChildren()) do
        if b:FindFirstChild("Owner") and b.Owner.Value == game.Players.LocalPlayer then return b end
    end
    return nil
end

-- HÀM BAY LƯỚT CHỈ DÙNG CHO KHOAN
local function safeGlide(targetPos)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    
    -- Bay vọt lên trời tránh vật cản
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and _G.AutoFarm do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
        task.wait()
        if hrp.Position.Y > _G.FlyHeight then break end
    end

    -- Lướt ngang tới máy khoan/giver
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 4 and _G.AutoFarm do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * _G.MoveSpeed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    
    -- Đáp xuống vị trí
    if _G.AutoFarm then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.2, targetPos.Z)
        task.wait(0.3)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- VÒNG LẶP KHOAN NGUYÊN BẢN
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                
                if drill and giver then
                    -- 1. Đi tới máy khoan
                    safeGlide(drill.Position)
                    local drillStart = tick()
                    
                    -- 2. Đứng khoan theo thời gian cài đặt
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then 
                            fireproximityprompt(drill.ProximityPrompt, 1, true) 
                        end
                        task.wait(0.2)
                    end
                    
                    task.wait(_G.DrillRest)
                    
                    -- 3. Đi lấy tiền
                    if _G.AutoFarm then 
                        safeGlide(giver.Position)
                        task.wait(2) 
                    end
                end
            end
        end
    end
end)

-- GIAO DIỆN MENU (ĐÃ LƯỢC BỎ AUTO NÂNG)
local MainTab = Window:CreateTab("Treo Máy", 4483362458)

MainTab:CreateToggle({
    Name = "Bật Auto Khoan", 
    CurrentValue = false, 
    Callback = function(v) _G.AutoFarm = v end
})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)

ConfigTab:CreateInput({
    Name = "Thời gian đứng khoan (s)", 
    PlaceholderText = "300", 
    Callback = function(t) _G.WaitAtDrill = tonumber(t) or 300 end
})

ConfigTab:CreateInput({
    Name = "Tốc độ bay", 
    PlaceholderText = "8", 
    Callback = function(t) _G.MoveSpeed = tonumber(t) or 8 end
})

ConfigTab:CreateInput({
    Name = "Độ cao bay", 
    PlaceholderText = "225", 
    Callback = function(t) _G.FlyHeight = tonumber(t) or 225 end
})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
