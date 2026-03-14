local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - ANTI-BASE GEMS",
   LoadingTitle = "Đang khôi phục cài đặt gốc...",
   LoadingSubtitle = "Chỉ tập trung vào Gems thật",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT (KHÔI PHỤC Y HỆT ẢNH GỐC)
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 300   
_G.GemsRest = 2        
_G.FlyHeight = 225     
_G.DrillSpeed = 8      
_G.GemsSpeed = 20      

-- TỌA ĐỘ 6 CĂN CỨ CỦA KHA
local BasePositions = {
    Vector3.new(-26.0, 147.8, -616.7),
    Vector3.new(509.3, 147.7, 370.1),
    Vector3.new(-8.8, 147.7, 1379.9),
    Vector3.new(-1121.4, 147.7, 1756.2),
    Vector3.new(-2013.4, 147.7, 513.3),
    Vector3.new(-1368.7, 147.7, -557.8)
}

-- HÀM LỌC GEMS (BỎ ROB BASE 1-6)
local function checkRealGem(obj)
    local text = (obj.ObjectText .. obj.ActionText):lower()
    local pName = obj.Parent.Name:lower()
    local isBase = text:find("base") or pName:find("base") or text:find("rob base")
    if text:find("gems") and not isBase then return true end
    return false
end

-- HÀM TÌM NHÀ CỦA KHA
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

-- HÀM BAY LƯỚT AN TOÀN (SAFE GLIDE)
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
        if _G.AutoGems then
            -- Chạy tuần tra 6 Base để tìm Gems thật
            for i = 1, 6 do
                if not _G.AutoGems then break end
                safeGlide(BasePositions[i], _G.GemsSpeed)
                task.wait(_G.GemsRest) -- Dừng 2s lụm gems tại Base
            end
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

-- GIAO DIỆN TAB TREO MÁY (Y HỆT ẢNH GỐC)
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Săn Gems (Đã lọc Base)", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

-- GIAO DIỆN TAB CÀI ĐẶT (Y HỆT ẢNH GỐC)
local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateSlider({Name = "Tốc độ bay Săn GEMS", Range = {1, 50}, Increment = 1, CurrentValue = 20, Callback = function(v) _G.GemsSpeed = v end})
ConfigTab:CreateSlider({Name = "Tốc độ bay đi KHOAN", Range = {1, 30}, Increment = 1, CurrentValue = 8, Callback = function(v) _G.DrillSpeed = v end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

Rayfield:Notify({Title = "KHA PRO", Content = "Đã khôi phục hoàn toàn Cài đặt gốc!", Duration = 5})
