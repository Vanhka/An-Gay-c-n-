local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - CHU TRÌNH TỐI ƯU",
   LoadingTitle = "Đang cấu hình hệ thống...",
   LoadingSubtitle = "Khoan - Tiền - Nâng Cấp (Gõ Số)",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT (MẶC ĐỊNH)
_G.AutoFarm = false
_G.AutoBuild = false
_G.UseNoclip = false

_G.WaitAtDrill = 300   -- Thời gian ở máy khoan
_G.BuildDuration = 20  -- Thời gian đi nâng cấp
_G.FlyHeight = 195     -- Độ cao bay
_G.MoveSpeed = 10      -- Tốc độ bay/lướt

local noclipConnection

-- HÀM LẤY TYCOON CỦA BẠN
local function getMyBase()
    for _, b in ipairs(workspace["The Nuke Tycoon Entirely Model"].Tycoons:GetChildren()) do
        if b:FindFirstChild("Owner") and b.Owner.Value == game.Players.LocalPlayer then return b end
    end
    return nil
end

-- HÀM BẬT/TẮT NOCLIP
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
        if noclipConnection then 
            noclipConnection:Disconnect() 
            noclipConnection = nil
        end
    end
end

-- HÀM LƯỚT TỚI NÚT VÀ DẪM LÌ LỢM
local function glideToBuild(targetPart)
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid
    local targetPos = targetPart.Position
    
    local start = tick()
    -- Bay tới sát nút
    while (hrp.Position - targetPos).Magnitude > 2 and _G.AutoBuild and _G.AutoFarm and (tick() - start < 5) do
        local direction = (targetPos - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * _G.MoveSpeed)
        task.wait()
    end
    
    -- Logic Dẫm Lì Lợm: Dẫm lún & Nhảy nhấp nhô
    if _G.AutoBuild and _G.AutoFarm then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, -1.2, 0))
        task.wait(0.15)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.2)
    end
end

-- QUY TRÌNH CHÍNH THEO Ý KHA
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart

                if drill and giver then
                    -- BƯỚC 1: Ở LẠI MÁY KHOAN
                    hrp.CFrame = CFrame.new(drill.Position.X, _G.FlyHeight, drill.Position.Z)
                    local drillStart = tick()
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(drill.ProximityPrompt, 1, true)
                        end
                        task.wait(0.2)
                    end

                    -- BƯỚC 2: BAY ĐẾN CHỖ NHẬN TIỀN
                    if _G.AutoFarm then
                        hrp.CFrame = CFrame.new(giver.Position.X, _G.FlyHeight, giver.Position.Z)
                        task.wait(1.5)
                        hrp.CFrame = giver.CFrame -- Hạ cánh nhận tiền
                        task.wait(1)
                    end

                    -- BƯỚC 3: NẾU BẬT NÂNG CẤP -> BAY NÂNG CẤP XUNG QUANH
                    if _G.AutoFarm and _G.AutoBuild then
                        toggleNoclip(_G.UseNoclip)
                        local buildStart = tick()
                        while (tick() - buildStart < _G.BuildDuration) and _G.AutoBuild and _G.AutoFarm do
                            local targetNode = nil
                            -- Quét tìm nút có BillboardGui (Nút đang hiển thị chữ)
                            for _, obj in ipairs(myBase:GetDescendants()) do
                                if obj:IsA("BasePart") and obj.Transparency == 0 and obj:FindFirstChildOfClass("BillboardGui") then
                                    targetNode = obj
                                    break
                                end
                            end
                            
                            if targetNode then
                                glideToBuild(targetNode)
                                task.wait(0.3)
                            else
                                task.wait(0.5) -- Không thấy nút thì đợi quét lại
                            end
                        end
                        if not _G.UseNoclip then toggleNoclip(false) end
                    end
                    
                    -- HẾT THỜI GIAN NÂNG CẤP -> QUAY LẠI MÁY KHOAN
                    if _G.AutoFarm then
                        hrp.CFrame = CFrame.new(drill.Position.X, _G.FlyHeight, drill.Position.Z)
                    end
                end
            end
        end
    end
end)

-- GIAO DIỆN RAYFIELD (CHỈ NHẬP SỐ - KHÔNG KÉO)
local MainTab = Window:CreateTab("Treo Máy", 4483362458)

MainTab:CreateToggle({
    Name = "1. Bật Auto Chu Trình (Khoan - Tiền)",
    CurrentValue = false,
    Callback = function(v) _G.AutoFarm = v end
})

MainTab:CreateToggle({
    Name = "2. Kèm Auto Nâng Cấp",
    CurrentValue = false,
    Callback = function(v) _G.AutoBuild = v end
})

MainTab:CreateToggle({
    Name = "Bật Noclip (Xuyên tường)",
    CurrentValue = false,
    Callback = function(v) 
        _G.UseNoclip = v 
        toggleNoclip(v)
    end
})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)

ConfigTab:CreateInput({
    Name = "Thời gian ở máy khoan (s)",
    PlaceholderText = "Mặc định: 300",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _G.WaitAtDrill = tonumber(t) or 300 end
})

ConfigTab:CreateInput({
    Name = "Thời gian đi nâng cấp (s)",
    PlaceholderText = "Mặc định: 20",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _G.BuildDuration = tonumber(t) or 20 end
})

ConfigTab:CreateInput({
    Name = "Độ cao bay",
    PlaceholderText = "Mặc định: 195",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _G.FlyHeight = tonumber(t) or 195 end
})

ConfigTab:CreateInput({
    Name = "Tốc độ di chuyển",
    PlaceholderText = "Mặc định: 10",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _G.MoveSpeed = tonumber(t) or 10 end
})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
