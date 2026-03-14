local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - GEMS FIX",
   LoadingTitle = "Đang nhắm mục tiêu Gems xịn...",
   LoadingSubtitle = "Lọc chuẩn Rob The Base's Gems!",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 300   
_G.GemsRest = 2        
_G.FlyHeight = 225     
_G.DrillSpeed = 8      
_G.GemsSpeed = 22      -- Tăng tốc độ để cướp cho nhanh

-- HÀM LỌC NÚT CHUẨN THEO YÊU CẦU CỦA KHA
local function isRealGem(obj)
    local text = obj.ObjectText .. " " .. obj.ActionText
    
    -- ƯU TIÊN 1: Phải khớp đúng dòng chữ Kha báo
    if text:find("Rob The Base's Gems!") then
        return true
    end
    
    -- ƯU TIÊN 2: Kiểm tra các biến thể Gems khác nhưng né Rob Base 1-6
    if text:lower():find("gems") and not text:lower():find("rob base %d") then
        return true
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
                if obj:IsA("ProximityPrompt") and isRealGem(obj) then
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
                                if o:IsA("ProximityPrompt") and isRealGem(o) then
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
MainTab:CreateToggle({Name = "Săn Gems (Đã Fix Tên)", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateSlider({Name = "Tốc độ săn GEMS", Range = {1, 40}, Increment = 1, CurrentValue = 22, Callback = function(v) _G.GemsSpeed = v end})
ConfigTab:CreateInput({Name = "Nghỉ sau khi lụm (s)", PlaceholderText = "2", Callback = function(t) _G.GemsRest = tonumber(t) or 2 end})

Rayfield:Notify({Title = "KHA PRO", Content = "Đã cập nhật bộ lọc 'Rob The Base's Gems!'", Duration = 5})
