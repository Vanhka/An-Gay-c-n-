local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - MASTER V4",
   LoadingTitle = "Đang chặn nút Rob Base 123456...",
   LoadingSubtitle = "Ưu tiên lụm Gems tuyệt đối",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 300   
_G.GemsRest = 2        
_G.FlyHeight = 225     
_G.DrillSpeed = 8      
_G.GemsSpeed = 18      

-- HÀM KIỂM TRA NÚT (NÉ ROB BASE 1-6)
local function isLegitGem(obj)
    local pText = (obj.ObjectText .. obj.ActionText):lower()
    
    -- 1. Nếu thấy chữ "gem" thì mới xét tiếp
    if pText:find("gem") then
        -- 2. Kiểm tra danh sách đen: né "rob base", "base", và các số 1,2,3,4,5,6 đi kèm base
        local blackList = {"rob base", "base 1", "base 2", "base 3", "base 4", "base 5", "base 6"}
        for _, word in ipairs(blackList) do
            if pText:find(word) then
                return false -- Thấy tên trong blacklist là loại ngay
            end
        end
        return true -- Không dính blacklist thì là Gems xịn
    end
    return false
end

local function getMyBase()
    local tycoons = workspace:FindFirstChild("The Nuke Tycoon Entirely Model") and workspace["The Nuke Tycoon Entirely Model"]:FindFirstChild("Tycoons")
    if tycoons then
        for _, b in ipairs(tycoons:GetChildren()) do
            local ownerValue = b:FindFirstChild("Owner")
            if ownerValue and (ownerValue.Value == game.Players.LocalPlayer or ownerValue.Value == game.Players.LocalPlayer.Name) then 
                return b 
            end
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
                if obj:IsA("ProximityPrompt") then
                    if isLegitGem(obj) then
                        targetGem = obj.Parent
                        break 
                    end
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
                                if o:IsA("ProximityPrompt") and isLegitGem(o) then
                                    qCheck = o.Parent break
                                end
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

local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Auto Gems (Né Base 1-6)", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateSlider({Name = "Tốc độ săn GEMS", Range = {1, 30}, Increment = 1, CurrentValue = 18, Callback = function(v) _G.GemsSpeed = v end})
ConfigTab:CreateSlider({Name = "Tốc độ đi KHOAN", Range = {1, 20}, Increment = 1, CurrentValue = 8, Callback = function(v) _G.DrillSpeed = v end})
ConfigTab:CreateInput({Name = "Nghỉ sau khi lụm Gems (s)", PlaceholderText = "2", Callback = function(t) _G.GemsRest = tonumber(t) or 2 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
