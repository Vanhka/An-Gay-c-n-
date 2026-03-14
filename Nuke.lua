local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - AUTO BASE LOOP",
   LoadingTitle = "Đang gộp hệ thống Auto Loop...",
   LoadingSubtitle = "Tăng phạm vi lụm Gems",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN HỆ THỐNG
_G.SpeedHax = 16
_G.AutoLoop = false
_G.LoopDelay = 3 -- Thời gian chờ tại mỗi Base
_G.MagRange = 30 -- Phạm vi tự động kích hoạt nút bấm
local BasePositions = {}

-- MENU TỐC ĐỘ & CÀI ĐẶT
local TabMain = Window:CreateTab("Điều Khiển", 4483362458)

TabMain:CreateToggle({
   Name = "BẬT AUTO CHẠY 6 BASE",
   CurrentValue = false,
   Callback = function(Value) _G.AutoLoop = Value end,
})

TabMain:CreateSlider({
   Name = "Tốc độ chạy",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
       _G.SpeedHax = Value
       if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
           game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
       end
   end,
})

-- MENU GHI TỌA ĐỘ 6 BASE
local TabBase = Window:CreateTab("Ghi Tọa Độ", 4483362458)
for i = 1, 6 do
    TabBase:CreateSection("CĂN CỨ " .. i)
    TabBase:CreateButton({
        Name = "Ghi vị trí Base " .. i,
        Callback = function()
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                BasePositions[i] = hrp.CFrame
                Rayfield:Notify({Title = "Đã Lưu", Content = "Đã ghi tọa độ Base " .. i, Duration = 2})
            end
        end,
    })
end

-- HỆ THỐNG TỰ ĐỘNG LỤM GEMS TRONG PHẠM VI (MAGICAL RANGE)
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoLoop or _G.AutoGems then -- Hỗ trợ lụm khi đang chạy loop
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local pText = (obj.ObjectText .. obj.ActionText):lower()
                    -- Chỉ lụm Gems, né Rob Base giả
                    if pText:find("gem") and not pText:find("rob base") then
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

-- HỆ THỐNG CHẠY VÒNG TRÒN 6 BASE
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoLoop then
            for i = 1, 6 do
                if not _G.AutoLoop then break end
                if BasePositions[i] then
                    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- Dịch chuyển tới Base
                        hrp.CFrame = BasePositions[i]
                        -- Chờ một chút để lụm Gems (Phạm vi MagRange sẽ tự xử lý)
                        task.wait(_G.LoopDelay)
                    end
                end
            end
        end
    end
end)

-- ANTI-AFK & GIỮ TỐC ĐỘ
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = _G.SpeedHax
end)

Rayfield:Notify({Title = "Sẵn sàng Kha ơi!", Content = "Ghi 6 toạ độ rồi bật Auto Loop lên nhé.", Duration = 5})
