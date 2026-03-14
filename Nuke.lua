local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - TEST VERSION",
   LoadingTitle = "Đang tải bản Test riêng biệt...",
   LoadingSubtitle = "Auto Khoan & Bay 6 Base",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaTestConfig"}
})

-- TỌA ĐỘ 6 CĂN CỨ TỪ HÌNH ẢNH
local BasePositions = {
    Vector3.new(-26.0, 147.8, -616.7),
    Vector3.new(509.3, 147.7, 370.1),
    Vector3.new(-8.8, 147.7, 1379.9),
    Vector3.new(-1121.4, 147.7, 1756.2),
    Vector3.new(-2013.4, 147.7, 513.3),
    Vector3.new(-1368.7, 147.7, -557.8)
}

-- BIẾN HỆ THỐNG
_G.SpeedHax = 16
_G.AutoLoopGems = false
_G.AutoDrill = false
_G.FlySpeed = 100 
_G.MagRange = 50

-- TAB TREO MÁY (PHẦN TEST CHÍNH)
local TabFarm = Window:CreateTab("Treo Máy", 4483362458)

TabFarm:CreateToggle({
   Name = "Bật Bay Săn Gems (Dừng 2s/Base)",
   CurrentValue = false,
   Callback = function(v) _G.AutoLoopGems = v end,
})

TabFarm:CreateToggle({
   Name = "Bật Auto Khoan (Drill)",
   CurrentValue = false,
   Callback = function(v) _G.AutoDrill = v end,
})

-- TAB CÀI ĐẶT (ĐÃ KHÔI PHỤC)
local TabConfig = Window:CreateTab("Cài Đặt", 4483362458)

TabConfig:CreateSlider({
   Name = "Tốc độ chạy (WalkSpeed)",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) _G.SpeedHax = v end,
})

TabConfig:CreateSlider({
   Name = "Tốc độ Bay (Né Anti)",
   Range = {50, 400},
   Increment = 10,
   CurrentValue = 100,
   Callback = function(v) _G.FlySpeed = v end,
})

-- HÀM LƯỚT BAY AN TOÀN
local function SmoothFly(targetPos)
    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local distance = (hrp.Position - targetPos).Magnitude
        local duration = distance / _G.FlySpeed
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- HÀM TÌM NHÀ CỦA KHA
local function getMyBase()
    local tycoons = workspace:FindFirstChild("The Nuke Tycoon Entirely Model") and workspace["The Nuke Tycoon Entirely Model"]:FindFirstChild("Tycoons")
    if tycoons then
        for _, b in ipairs(tycoons:GetChildren()) do
            local owner = b:FindFirstChild("Owner")
            if owner and (owner.Value == game.Players.LocalPlayer or owner.Value == game.Players.LocalPlayer.Name) then return b end
        end
    end
    return nil
end

-- VÒNG LẶP XỬ LÝ
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoLoopGems then
            for i = 1, 6 do
                if not _G.AutoLoopGems then break end
                SmoothFly(BasePositions[i])
                task.wait(2) -- Dừng lại 2 giây để lụm Gems
            end
        elseif _G.AutoDrill then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                if drill and drill:FindFirstChild("ProximityPrompt") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = drill.CFrame
                    fireproximityprompt(drill.ProximityPrompt, 1, true)
                end
            end
        end
    end
end)

-- HỆ THỐNG AUTO LỤM GEMS TRONG PHẠM VI
task.spawn(function()
    while task.wait(0.3) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and (obj.ObjectText:find("Gems") or obj.ActionText:find("Gems")) then
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - obj.Parent.Position).Magnitude <= _G.MagRange then
                    fireproximityprompt(obj, 1, true)
                end
            end
        end
    end
end)

-- CẬP NHẬT TỐC ĐỘ CHẠY LIÊN TỤC
task.spawn(function()
    while task.wait(0.5) do
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedHax
        end
    end
end)

Rayfield:Notify({Title = "Bản Test Sẵn Sàng", Content = "Đã có Tốc độ, Khoan và Bay 6 Base.", Duration = 5})
