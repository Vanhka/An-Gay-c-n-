local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "Nuke Tycoon Pro - KHA (FINAL)",
   LoadingTitle = "Đang tải bản chính thức (Nhập Số)...",
   LoadingSubtitle = "Khoan & Nâng Cấp - 100% Ghi Số Không Kéo",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- DANH SÁCH TÊN NÚT NÂNG CẤP
local TargetNames = {
    "ACS_NoDamage",
    "UraniumButton",
    "Dropper1",
    "Wall1",
    "Base Paths"
}

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false
_G.AutoBuild = false

-- Biến cho Máy Khoan & Giver
_G.WaitAtDrill = 300   
_G.FlySpeed = 2.5      
_G.DrillDelay = 0.2
_G.FlyHeight = 195     

-- Biến cho Nâng Cấp
_G.BuildDuration = 20  
_G.BuildCooldown = 30  
_G.BuildSpeed = 10     

local noclipConnection

-- 1. HÀM HỖ TRỢ CƠ BẢN
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

-- 2. HÀM BAY AN TOÀN (CHO KHOAN & GIVER)
local function safeFly(targetPos)
    local char = game.Players.LocalPlayer.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    while (hrp.Position.Y < _G.FlyHeight) and _G.AutoFarm do
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.01)
    end
    
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 5 and _G.AutoFarm do
        local lookAt = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
        hrp.CFrame = lookAt * CFrame.new(0, 0, -_G.FlySpeed)
        
        if math.abs(hrp.Position.Y - _G.FlyHeight) > 2 then
            hrp.CFrame = CFrame.new(hrp.Position.X, _G.FlyHeight, hrp.Position.Z) * hrp.CFrame.Rotation
        end
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    hrp.CFrame = CFrame.new(targetPos)
end

-- 3. HÀM LƯỚT NHANH (CHO NÂNG CẤP)
local function glideToBuild(targetPart)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    local targetPos = targetPart.Position
    
    while (hrp.Position - targetPos).Magnitude > 3 and _G.AutoBuild and _G.AutoFarm do
        local direction = (targetPos - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * _G.BuildSpeed)
        task.wait()
    end
    -- Dẫm lún nút chống xịt
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, -0.5, 0))
    task.wait(0.2)
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1, 0))
end

-- 4. LOGIC TÍCH HỢP (KHOAN + NÂNG CẤP) - Giữ nguyên 100%
task.spawn(function()
    local timeSinceLastBuild = _G.BuildCooldown 

    while task.wait() do
        if _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                if drill and giver and hrp then
                    local drillTimeLeft = _G.WaitAtDrill

                    safeFly(drill.Position + Vector3.new(0, 3, 0))

                    while drillTimeLeft > 0 and _G.AutoFarm do
                        
                        -- KIỂM TRA & ĐI NÂNG CẤP
                        if _G.AutoBuild and timeSinceLastBuild >= _G.BuildCooldown then
                            toggleNoclip(true)
                            
                            local buildStartTime = tick()
                            while (tick() - buildStartTime) < _G.BuildDuration and _G.AutoBuild and _G.AutoFarm do
                                local found = false
                                for _, nameToFind in ipairs(TargetNames) do
                                    for _, obj in ipairs(myBase:GetDescendants()) do
                                        if obj.Name == nameToFind and obj:IsA("BasePart") and obj.Transparency < 1 then
                                            glideToBuild(obj)
                                            found = true
                                            task.wait(0.5)
                                            break
                                        end
                                    end
                                    if found then break end
                                end
                                if not found then task.wait(0.5) end 
                            end
                            
                            -- Xong nâng cấp -> Quay lại khoan tiếp
                            toggleNoclip(false)
                            timeSinceLastBuild = 0
                            
                            if _G.AutoFarm then
                                safeFly(drill.Position + Vector3.new(0, 3, 0))
                            end
                        end

                        -- KHOAN & TRỪ THỜI GIAN
                        if drill:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(drill.ProximityPrompt, 1, true)
                        end
                        
                        task.wait(_G.DrillDelay)
                        drillTimeLeft = drillTimeLeft - _G.DrillDelay       
                        timeSinceLastBuild = timeSinceLastBuild + _G.DrillDelay 
                    end

                    -- HẾT THỜI GIAN KHOAN -> ĐI NHẬN TIỀN
                    if _G.AutoFarm then
                        safeFly(giver.Position) 
                        task.wait(1.2)
                    end
                end
            end
        end
    end
end)

-- 5. GIAO DIỆN CỦA KHA (100% NHẬP SỐ)
local MainTab = Window:CreateTab("Treo Máy", 4483362458)

MainTab:CreateToggle({
   Name = "1. Bật Auto Farm (Máy Khoan + Tiền)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if not Value then toggleNoclip(false) end 
   end,
})

MainTab:CreateToggle({
   Name = "2. Bật Auto Nâng Cấp (Chạy song song)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoBuild = Value
   end,
})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)

ConfigTab:CreateSection("CÀI ĐẶT KHOAN & NHẬN TIỀN")
ConfigTab:CreateInput({
   Name = "Tổng thời gian đứng khoan (s)",
   PlaceholderText = "VD: 300",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G.WaitAtDrill = tonumber(Text) or 300 end,
})
ConfigTab:CreateInput({
   Name = "Tốc Độ Bay Khoan/Tiền",
   PlaceholderText = "VD: 2.5",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G.FlySpeed = tonumber(Text) or 2.5 end,
})

ConfigTab:CreateSection("CÀI ĐẶT NÂNG CẤP (NHẬP SỐ)")
ConfigTab:CreateInput({
   Name = "Thời gian BAY ĐI nâng cấp (s)",
   PlaceholderText = "Nhập số giây đi dẫm nút (VD: 20)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G.BuildDuration = tonumber(Text) or 20 end,
})
ConfigTab:CreateInput({
   Name = "Thời gian NGHỈ CHỜ nâng cấp (s)",
   PlaceholderText = "Nhập số giây nghỉ (VD: 30)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G.BuildCooldown = tonumber(Text) or 30 end,
})
ConfigTab:CreateInput({
   Name = "Tốc Độ Lướt Dẫm Nút",
   PlaceholderText = "VD: 10",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G.BuildSpeed = tonumber(Text) or 10 end,
})

ConfigTab:CreateSection("HỆ THỐNG")
ConfigTab:CreateInput({
   Name = "Độ Cao Bay (Mặt đất là 147)",
   PlaceholderText = "VD: 195",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) _G.FlyHeight = tonumber(Text) or 195 end,
})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
