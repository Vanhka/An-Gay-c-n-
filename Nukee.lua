local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - ANTI-BASE GEMS",
   LoadingTitle = "Đang khôi phục toàn bộ cài đặt...",
   LoadingSubtitle = "Đầy đủ Slider thông số cho Kha",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT GỐC
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 300   -- Thời gian ở lại khoan
_G.GemsRest = 2        -- Thời gian nghỉ lụm gems
_G.FlyHeight = 225     -- Độ cao bay
_G.DrillSpeed = 8      -- Tốc độ bay đi khoan
_G.GemsSpeed = 20      -- Tốc độ bay săn gems

-- HÀM LỌC CHÍNH XÁC (BỎ ROB BASE)
local function checkRealGem(obj)
    local text = (obj.ObjectText .. obj.ActionText):lower()
    local pName = obj.Parent.Name:lower()
    if text:find("gems") and not (text:find("base") or pName:find("base")) then
        return true
    end
    return false
end

local function getMyBase()
    local tycoons = workspace:FindFirstChild("The Nuke Tycoon Entirely Model") and workspace["The Nuke Tycoon Entirely Model"]:FindFirstChild("Tycoons")
    if tycoons then
        for _, b in ipairs(tycoons:GetChildren()) do
            local ownerValue = b:FindFirstChild("Owner")
            if ownerValue and (ownerValue.Value == game.Players.LocalPlayer or ownerValue.Value == game.Players.LocalPlayer.Name) then return b end
        end
    end
    return nil
end

local function safeGlide(targetPos, speed)
    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoGems) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 8, 0)
        task.wait()
        if hrp.Position.Y > _G.FlyHeight then break end
    end
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 4 and (_G.AutoFarm or _G.AutoGems) do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * speed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    if _G.AutoFarm or _G.AutoGems then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.5, targetPos.Z)
        task.wait(0.2)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- VÒNG LẶP TREO MÁY
task.spawn(function()
    while task.wait(0.5) do
        local targetGem = nil
        if _G.AutoGems then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and checkRealGem(obj) then targetGem = obj.Parent break end
            end
        end
        if targetGem then
            safeGlide(targetGem.Position, _G.GemsSpeed)
            fireproximityprompt(targetGem:FindFirstChildOfClass("ProximityPrompt"), 1, true)
            task.wait(_G.GemsRest)
        elseif _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                if drill and giver then
                    safeGlide(drill.Position, _G.DrillSpeed)
                    local drillStart = tick()
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then fireproximityprompt(drill.ProximityPrompt, 1, true) end
                        task.wait(0.2)
                    end
                    if _G.AutoFarm then safeGlide(giver.Position, _G.DrillSpeed) task.wait(1.5) end
                end
            end
        end
    end
end)

-- GIAO DIỆN TAB TREO MÁY
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Săn Gems (Đã lọc Base)", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

-- GIAO DIỆN TAB CÀI ĐẶT (PHỤC HỒI TẤT CẢ SLIDER)
local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)

ConfigTab:CreateSlider({Name = "Tốc độ bay Săn GEMS", Range = {1, 50}, Increment = 1, CurrentValue = 20, Callback = function(v) _G.GemsSpeed = v end})
ConfigTab:CreateSlider({Name = "Tốc độ bay đi KHOAN", Range = {1, 30}, Increment = 1, CurrentValue = 8, Callback = function(v) _G.DrillSpeed = v end})
ConfigTab:CreateSlider({Name = "Độ cao bay (Fly Height)", Range = {100, 400}, Increment = 5, CurrentValue = 225, Callback = function(v) _G.FlyHeight = v end})
ConfigTab:CreateSlider({Name = "Thời gian khoan (Giây)", Range = {10, 600}, Increment = 10, CurrentValue = 300, Callback = function(v) _G.WaitAtDrill = v end})
ConfigTab:CreateSlider({Name = "Thời gian nghỉ lụm Gems", Range = {1, 10}, Increment = 1, CurrentValue = 2, Callback = function(v) _G.GemsRest = v end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
