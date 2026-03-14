local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - BLUE GEMS FINDER",
   LoadingTitle = "Đang nhận diện màu Gems...",
   LoadingSubtitle = "Nhắm mục tiêu: Blue Gems",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 300   
_G.GemsRest = 2        
_G.FlyHeight = 225     
_G.DrillSpeed = 8      
_G.GemsSpeed = 22      

-- HÀM NHẬN DIỆN VIÊN GEMS MÀU XANH (BLUE)
local function isBlueGem(obj)
    local target = obj.Parent
    local text = (obj.ObjectText .. obj.ActionText):lower()
    
    -- Kiểm tra 1: Phải có chữ Gems (né các nút Rob Base giả)
    if text:find("gems") and not text:find("rob base") then
        -- Kiểm tra 2: Kiểm tra màu sắc của viên Gems (Màu xanh dương)
        -- Trong Roblox, màu xanh này thường là 'Electric blue' hoặc 'Really blue'
        if target:IsA("BasePart") then
            local color = target.Color
            -- Lọc các màu có sắc xanh dương cao (R thấp, G trung bình, B cao)
            if color.B > 0.5 and color.R < 0.5 then
                return true
            end
        elseif target:IsA("Model") then
            -- Nếu là Model thì kiểm tra các Part bên trong
            for _, p in ipairs(target:GetChildren()) do
                if p:IsA("BasePart") and p.Color.B > 0.5 then
                    return true
                end
            end
        end
        -- Nếu không check được màu nhưng tên nút chuẩn "Rob The Base's Gems!" thì vẫn lụm
        if text:find("rob the base's gems!") then return true end
    end
    return false
end

-- [Các hàm getMyBase và safeGlide giữ nguyên như cũ để ổn định]
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

task.spawn(function()
    while task.wait(0.5) do
        local targetGem = nil
        if _G.AutoGems then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and isBlueGem(obj) then
                    targetGem = obj.Parent
                    break 
                end
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
                        if _G.AutoGems then
                            local qCheck = nil
                            for _, o in ipairs(workspace:GetDescendants()) do
                                if o:IsA("ProximityPrompt") and isBlueGem(o) then qCheck = o.Parent break end
                            end
                            if qCheck then break end
                        end
                        if drill:FindFirstChild("ProximityPrompt") then fireproximityprompt(drill.ProximityPrompt, 1, true) end
                        task.wait(0.2)
                    end
                    if _G.AutoFarm then safeGlide(giver.Position, _G.DrillSpeed) task.wait(1.5) end
                end
            end
        end
    end
end)

-- ANTI-AFK NÂNG CẤP
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Săn Blue Gems", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateSlider({Name = "Tốc độ săn", Range = {1, 40}, Increment = 1, CurrentValue = 22, Callback = function(v) _G.GemsSpeed = v end})
