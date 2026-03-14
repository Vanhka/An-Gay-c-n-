local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - MASTER MENU",
   LoadingTitle = "Đang gộp lại tất cả tính năng...",
   LoadingSubtitle = "Auto Khoan + Gems 6 Base + Config",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- TOẠ ĐỘ TRÍCH XUẤT TỪ HÌNH ẢNH CỦA KHA
local BasePositions = {
    [1] = CFrame.new(-26.0, 147.8, -616.7),
    [2] = CFrame.new(509.3, 147.7, 370.1),
    [3] = CFrame.new(-8.8, 147.7, 1379.9),
    [4] = CFrame.new(-1121.4, 147.7, 1756.2),
    [5] = CFrame.new(-2013.4, 147.7, 513.3),
    [6] = CFrame.new(-1368.7, 147.7, -557.8)
}

-- BIẾN CÀI ĐẶT (CONFIG)
_G.AutoLoopGems = false
_G.AutoDrill = false
_G.SpeedHax = 16
_G.WaitTimeBase = 2.5 -- Thời gian đứng lại lụm gems
_G.MagRange = 50      -- Phạm vi tự lụm
_G.FlyHeight = 148    -- Độ cao khi lướt

-- TAB TREO MÁY
local TabFarm = Window:CreateTab("Treo Máy", 4483362458)

TabFarm:CreateToggle({
   Name = "Auto Săn Gems (6 Base Sẵn)",
   CurrentValue = false,
   Callback = function(v) _G.AutoLoopGems = v end,
})

TabFarm:CreateToggle({
   Name = "Auto Khoan (Drill)",
   CurrentValue = false,
   Callback = function(v) _G.AutoDrill = v end,
})

-- TAB CÀI ĐẶT (PHỤC HỒI)
local TabConfig = Window:CreateTab("Cài Đặt", 4483362458)

TabConfig:CreateSlider({
   Name = "Tốc độ chạy",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) _G.SpeedHax = v end,
})

TabConfig:CreateSlider({
   Name = "Thời gian chờ lụm Gems (s)",
   Range = {1, 10},
   Increment = 0.5,
   CurrentValue = 2.5,
   Callback = function(v) _G.WaitTimeBase = v end,
})

TabConfig:CreateSlider({
   Name = "Phạm vi lụm (Mag Range)",
   Range = {10, 100},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v) _G.MagRange = v end,
})

-- HÀM LẤY BASE CỦA KHA ĐỂ KHOAN
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

-- HỆ THỐNG XỬ LÝ CHÍNH
task.spawn(function()
    while true do
        task.wait(0.5)
        
        -- ƯU TIÊN 1: AUTO GEMS (NẾU BẬT)
        if _G.AutoLoopGems then
            for i = 1, 6 do
                if not _G.AutoLoopGems then break end
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and BasePositions[i] then
                    hrp.CFrame = BasePositions[i]
                    task.wait(_G.WaitTimeBase)
                end
            end
            
        -- ƯU TIÊN 2: AUTO KHOAN (NẾU KHÔNG ĐANG ĐI SĂN GEMS)
        elseif _G.AutoDrill then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                if drill and drill:FindFirstChild("ProximityPrompt") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = drill.Position
                    fireproximityprompt(drill.ProximityPrompt, 1, true)
                end
            end
        end
    end
end)

-- VÒNG LẶP QUÉT LỤM GEMS TỰ ĐỘNG
task.spawn(function()
    while task.wait(0.2) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - obj.Parent.Position).Magnitude <= _G.MagRange then
                    if obj.ObjectText:find("Gems") or obj.ActionText:find("Gems") then
                        fireproximityprompt(obj, 1, true)
                    end
                end
            end
        end
    end
end)

-- GIỮ TỐC ĐỘ + ANTI AFK
task.spawn(function()
    while task.wait(0.5) do
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedHax
        end
    end
end)

local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

Rayfield:Notify({Title = "KHA PRO", Content = "Đã hồi phục Auto Khoan và Cài đặt!", Duration = 5})
