local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO V5 - UU TIEN MAY KHOAN",
   LoadingTitle = "Đang cấu hình logic ưu tiên...",
   LoadingSubtitle = "Khoan là chính - Nâng cấp là phụ",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

_G.AutoFarm = false
_G.AutoBuild = false
_G.WaitAtDrill = 300   
_G.BuildDuration = 20  
_G.BuildSpeed = 12     

local noclipConnection

local function getMyBase()
    for _, b in ipairs(workspace["The Nuke Tycoon Entirely Model"].Tycoons:GetChildren()) do
        if b:FindFirstChild("Owner") and b.Owner.Value == game.Players.LocalPlayer then return b end
    end
    return nil
end

local function toggleNoclip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            if game.Players.LocalPlayer.Character then
                for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

local function glideToBuild(targetPart)
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid
    local start = tick()
    while (hrp.Position - targetPart.Position).Magnitude > 2 and (tick() - start < 5) and _G.AutoBuild and _G.AutoFarm do
        local dir = (targetPart.Position - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (dir * _G.BuildSpeed)
        task.wait()
    end
    if _G.AutoBuild and _G.AutoFarm then
        for i = 1, 2 do
            hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, -1.5, 0))
            task.wait(0.1)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.2)
        end
    end
end

-- VÒNG LẶP CHU TRÌNH THEO Ý KHA
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart

                if drill and giver then
                    -- BƯỚC 1: LUÔN Ở MÁY KHOAN TRƯỚC
                    hrp.CFrame = drill.CFrame + Vector3.new(0, 3, 0)
                    local drillStart = tick()
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(drill.ProximityPrompt, 1, true)
                        end
                        task.wait(0.2)
                    end

                    -- BƯỚC 2: NHẬN TIỀN
                    if _G.AutoFarm then
                        hrp.CFrame = giver.CFrame + Vector3.new(0, 3, 0)
                        task.wait(1.5)
                    end

                    -- BƯỚC 3: CHỈ NÂNG CẤP NẾU CẢ 2 NÚT ĐỀU BẬT
                    if _G.AutoFarm and _G.AutoBuild then
                        toggleNoclip(true)
                        local buildStart = tick()
                        while (tick() - buildStart < _G.BuildDuration) and _G.AutoBuild and _G.AutoFarm do
                            local target = nil
                            for _, obj in ipairs(myBase:GetDescendants()) do
                                if obj:IsA("BasePart") and obj.Transparency == 0 and obj:FindFirstChildOfClass("BillboardGui") then
                                    target = obj
                                    break
                                end
                            end
                            if target then
                                glideToBuild(target)
                                task.wait(0.3)
                            else
                                break 
                            end
                        end
                        toggleNoclip(false)
                    end
                    
                    -- SAU KHI XONG HOẶC NẾU TẮT NÂNG CẤP -> QUAY LẠI MÁY KHOAN NGAY
                    if _G.AutoFarm then
                        hrp.CFrame = drill.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end
end)

local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({
    Name = "1. Bật Auto Farm (BẮT BUỘC)", 
    CurrentValue = false, 
    Callback = function(v) _G.AutoFarm = v end
})
MainTab:CreateToggle({
    Name = "2. Kèm Auto Nâng Cấp (Cần bật nút 1)", 
    CurrentValue = false, 
    Callback = function(v) _G.AutoBuild = v end
})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateInput({Name = "Thời gian khoan (s)", PlaceholderText = "300", RemoveTextAfterFocusLost = false, Callback = function(t) _G.WaitAtDrill = tonumber(t) or 300 end})
ConfigTab:CreateInput({Name = "Thời gian dạo nâng (s)", PlaceholderText = "20", RemoveTextAfterFocusLost = false, Callback = function(t) _G.BuildDuration = tonumber(t) or 20 end})
ConfigTab:CreateInput({Name = "Tốc độ lướt", PlaceholderText = "12", RemoveTextAfterFocusLost = false, Callback = function(t) _G.BuildSpeed = tonumber(t) or 12 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
