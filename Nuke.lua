local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - DRILL & GEMS V3",
   LoadingTitle = "Đang đồng bộ căn cứ của Kha...",
   LoadingSubtitle = "Fix lỗi dò tìm & Tốc độ Gems",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 300   
_G.DrillRest = 2       
_G.GemsRest = 3        
_G.FlyHeight = 225     
_G.DrillSpeed = 8      
_G.GemsSpeed = 15      -- Tốc độ lụm Gems nhanh hơn hẳn

-- HÀM DÒ TÌM CĂN CỨ CHÍNH XÁC (FIX LỖI)
local function getMyBase()
    local tycoons = workspace:FindFirstChild("The Nuke Tycoon Entirely Model") and workspace["The Nuke Tycoon Entirely Model"]:FindFirstChild("Tycoons")
    if tycoons then
        for _, b in ipairs(tycoons:GetChildren()) do
            -- Kiểm tra giá trị Owner xem có trùng với tên của Kha không
            local ownerValue = b:FindFirstChild("Owner")
            if ownerValue and (ownerValue.Value == game.Players.LocalPlayer or ownerValue.Value == game.Players.LocalPlayer.Name) then 
                return b 
            end
        end
    end
    return nil
end

-- HÀM BAY LƯỚT VỚI TỐC ĐỘ TÙY CHỈNH
local function safeGlide(targetPos, speed)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    if not hrp then return end

    -- Bay lên độ cao an toàn
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoGems) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 7, 0)
        task.wait()
        if hrp.Position.Y > _G.FlyHeight then break end
    end

    -- Lướt ngang
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

-- VÒNG LẶP XỬ LÝ
task.spawn(function()
    while task.wait() do
        local myBase = getMyBase()
        
        -- ƯU TIÊN LỤM GEMS
        local gemTarget = nil
        if _G.AutoGems and myBase then
            -- Chỉ lụm Gems xuất hiện trong hoặc gần căn cứ của mình để tránh bay lung tung
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and (obj.ObjectText:find("Gems") or obj.ActionText:find("Rob")) then
                    -- Kiểm tra nếu cục Gems nằm gần căn cứ của mình (khoảng cách < 150)
                    local distToBase = (obj.Parent.Position - myBase.Essentials.Giver.Position).Magnitude
                    if distToBase < 150 then
                        gemTarget = obj.Parent
                        break
                    end
                end
            end
        end

        if gemTarget and _G.AutoGems then
            safeGlide(gemTarget.Position, _G.GemsSpeed)
            fireproximityprompt(gemTarget:FindFirstChildOfClass("ProximityPrompt"), 1, true)
            task.wait(_G.GemsRest)
        
        -- KHOAN NẾU KHÔNG CÓ GEMS
        elseif _G.AutoFarm and myBase then
            local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
            local giver = myBase.Essentials:FindFirstChild("Giver")
            
            if drill and giver then
                safeGlide(drill.Position, _G.DrillSpeed)
                local drillStart = tick()
                
                while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                    -- Check Gems nhanh để ngắt khoan
                    if _G.AutoGems then
                        local quickGem = nil
                        for _, o in ipairs(workspace:GetDescendants()) do
                            if o:IsA("ProximityPrompt") and (o.ObjectText:find("Gems") or o.ActionText:find("Rob")) then
                                quickGem = o.Parent break
                            end
                        end
                        if quickGem then break end
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
ConfigTab:CreateSection("TỐC ĐỘ (SPEED)")
ConfigTab:CreateInput({Name = "Tốc độ lụm GEMS", PlaceholderText = "15", Callback = function(t) _G.GemsSpeed = tonumber(t) or 15 end})
ConfigTab:CreateInput({Name = "Tốc độ đi KHOAN", PlaceholderText = "8", Callback = function(t) _G.DrillSpeed = tonumber(t) or 8 end})

ConfigTab:CreateSection("THÔNG SỐ KHÁC")
ConfigTab:CreateInput({Name = "Nghỉ sau khi lụm (s)", PlaceholderText = "3", Callback = function(t) _G.GemsRest = tonumber(t) or 3 end})
ConfigTab:CreateInput({Name = "Độ cao bay", PlaceholderText = "225", Callback = function(t) _G.FlyHeight = tonumber(t) or 225 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
