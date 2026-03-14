local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - AUTO GEMS 6 BASE",
   LoadingTitle = "Đang nạp tọa độ & Auto lụm...",
   LoadingSubtitle = "Tọa độ chuẩn từ hình ảnh của Kha",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- TOẠ ĐỘ ĐÃ NẠP SẴN TỪ HÌNH ẢNH
local BasePositions = {
    [1] = CFrame.new(-26.0, 147.8, -616.7),
    [2] = CFrame.new(509.3, 147.7, 370.1),
    [3] = CFrame.new(-8.8, 147.7, 1379.9),
    [4] = CFrame.new(-1121.4, 147.7, 1756.2),
    [5] = CFrame.new(-2013.4, 147.7, 513.3),
    [6] = CFrame.new(-1368.7, 147.7, -557.8)
}

_G.SpeedHax = 16
_G.AutoLoop = false
_G.MagRange = 50 -- Phạm vi lụm gems

-- MENU ĐIỀU KHIỂN
local TabMain = Window:CreateTab("Treo Máy", 4483362458)

TabMain:CreateToggle({
   Name = "Bật Auto Chạy 6 Base",
   CurrentValue = false,
   Callback = function(Value) _G.AutoLoop = Value end,
})

TabMain:CreateSlider({
   Name = "Tốc độ chạy (WalkSpeed)",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
       _G.SpeedHax = Value
       task.spawn(function()
           while task.wait(0.5) do
               if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                   game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedHax
               end
           end
       end)
   end,
})

-- HỆ THỐNG AUTO LỤM GEMS TRONG PHẠM VI
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoLoop then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local pText = (obj.ObjectText .. obj.ActionText):lower()
                    -- Chỉ nhắm vào Gems
                    if pText:find("gem") then
                        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - obj.Parent.Position).Magnitude <= _G.MagRange then
                            fireproximityprompt(obj, 1, true)
                        end
                    end
                end
            end
        end
    end
end)

-- VÒNG LẶP CHẠY QUA 6 TOẠ ĐỘ SẴN
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoLoop then
            for i = 1, 6 do
                if not _G.AutoLoop then break end
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and BasePositions[i] then
                    hrp.CFrame = BasePositions[i]
                    task.wait(2.5) -- Đợi 2.5 giây lụm gems rồi đi tiếp
                end
            end
        end
    end
end)

-- ANTI-AFK CHỐNG VĂNG
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

Rayfield:Notify({Title = "Xong rồi Kha!", Content = "Bật Toggle để bắt đầu đi săn Gems 6 Base nhé.", Duration = 5})
