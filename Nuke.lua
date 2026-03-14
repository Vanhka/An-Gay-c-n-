local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - DRILL & GEMS V2",
   LoadingTitle = "Đang tách tốc độ di chuyển...",
   LoadingSubtitle = "Auto Khoan & Auto Lụm Gems",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 300   
_G.DrillRest = 2       
_G.GemsRest = 5        
_G.FlyHeight = 225     
_G.DrillSpeed = 8      -- Tốc độ riêng khi đi khoan
_G.GemsSpeed = 12      -- Tốc độ riêng khi đi lụm Gems (Nhanh hơn)

local function getMyBase()
    for _, b in ipairs(workspace["The Nuke Tycoon Entirely Model"].Tycoons:GetChildren()) do
        if b:FindFirstChild("Owner") and b.Owner.Value == game.Players.LocalPlayer then return b end
    end
    return nil
end

-- HÀM BAY LƯỚT VỚI TỐC ĐỘ TÙY CHỈNH (SPEED_TYPE)
local function safeGlide(targetPos, speed)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    -- Bay lên độ cao an toàn
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoGems) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
        task.wait()
        if hrp.Position.Y > _G.FlyHeight then break end
    end
    -- Lướt ngang với tốc độ được truyền vào
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 4 and (_G.AutoFarm or _G.AutoGems) do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * speed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    -- Đáp xuống
    if _G.AutoFarm or _G.AutoGems then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.2, targetPos.Z)
        task.wait(0.3)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- VÒNG LẶP CHÍNH
task.spawn(function()
    while task.wait() do
        local myBase = getMyBase()
        if not myBase then task.wait(1) continue end

        local gemTarget = nil
        if _G.AutoGems then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and (obj.ObjectText:find("Gems") or obj.ActionText:find("Rob")) then
                    gemTarget = obj.Parent
                    break
                end
            end
        end

        if gemTarget and _G.AutoGems then
            -- Sử dụng tốc độ lụm Gems
            safeGlide(gemTarget.Position, _G.GemsSpeed)
            fireproximityprompt(gemTarget:FindFirstChildOfClass("ProximityPrompt"), 1, true)
            task.wait(_G.GemsRest)
        
        elseif _G.AutoFarm then
            local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
            local giver = myBase.Essentials:FindFirstChild("Giver")
            
            if drill and giver then
                -- Sử dụng tốc độ đi khoan
                safeGlide(drill.Position, _G.DrillSpeed)
                local drillStart = tick()
                
                while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                    if _G.AutoGems then
                        local quickCheck = nil
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") and (obj.ObjectText:find("Gems") or obj.ActionText:find("Rob")) then
                                quickCheck = obj.Parent break
                            end
                        end
                        if quickCheck then break end 
                    end
                    if drill:FindFirstChild("ProximityPrompt") then fireproximityprompt(drill.ProximityPrompt, 1, true) end
                    task.wait(0.2)
                end
                
                task.wait(_G.DrillRest)
                if _G.AutoFarm then safeGlide(giver.Position, _G.DrillSpeed) task.wait(2) end
            end
        end
    end
end)

-- GIAO DIỆN
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Bật Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Bật Auto Lụm Gems", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateSection("TỐC ĐỘ RIÊNG BIỆT")
ConfigTab:CreateInput({Name = "Tốc độ đi KHOAN", PlaceholderText = "8", Callback = function(t) _G.DrillSpeed = tonumber(t) or 8 end})
ConfigTab:CreateInput({Name = "Tốc độ lụm GEMS", PlaceholderText = "12", Callback = function(t) _G.GemsSpeed = tonumber(t) or 12 end})

ConfigTab:CreateSection("THÔNG SỐ KHÁC")
ConfigTab:CreateInput({Name = "Độ cao bay", PlaceholderText = "225", Callback = function(t) _G.FlyHeight = tonumber(t) or 225 end})
ConfigTab:CreateInput({Name = "Thời gian khoan (s)", PlaceholderText = "300", Callback = function(t) _G.WaitAtDrill = tonumber(t) or 300 end})
ConfigTab:CreateInput({Name = "Nghỉ sau khi lụm Gems (s)", PlaceholderText = "5", Callback = function(t) _G.GemsRest = tonumber(t) or 5 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
