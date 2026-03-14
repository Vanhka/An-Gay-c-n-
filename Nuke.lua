local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - GEMS HUNTER",
   LoadingTitle = "Đang mở khóa vùng lụm Gems...",
   LoadingSubtitle = "Tự do săn Gems toàn bản đồ",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 300   
_G.GemsRest = 2        
_G.FlyHeight = 225     
_G.DrillSpeed = 8      
_G.GemsSpeed = 18      -- Tăng tốc độ cực nhanh để cướp Gems

-- HÀM DÒ TÌM CĂN CỨ (CHỈ DÙNG ĐỂ BIẾT CHỖ QUAY VỀ KHOAN)
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

-- HÀM LƯỚT TỚI MỤC TIÊU
local function safeGlide(targetPos, speed)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    if not hrp then return end

    -- Bay lên cao
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoGems) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 8, 0)
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

    -- Tiếp đất dẫm Gems/Nút
    if _G.AutoFarm or _G.AutoGems then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.5, targetPos.Z)
        task.wait(0.2)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- VÒNG LẶP SĂN GEMS VÀ KHOAN
task.spawn(function()
    while task.wait(0.5) do
        -- 1. TÌM GEMS TRÊN TOÀN MAP (KHÔNG GIỚI HẠN KHOẢNG CÁCH)
        local targetGem = nil
        if _G.AutoGems then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and (obj.ObjectText:find("Gems") or obj.ActionText:find("Rob")) then
                    targetGem = obj.Parent
                    break 
                end
            end
        end

        if targetGem then
            -- Nếu thấy Gems là bay tới ngay với tốc độ cực cao
            safeGlide(targetGem.Position, _G.GemsSpeed)
            fireproximityprompt(targetGem:FindFirstChildOfClass("ProximityPrompt"), 1, true)
            task.wait(_G.GemsRest)
        
        -- 2. NẾU KHÔNG CÓ GEMS THÌ MỚI QUAY VỀ KHOAN TẠI CĂN CỨ
        elseif _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                
                if drill and giver then
                    safeGlide(drill.Position, _G.DrillSpeed)
                    local drillStart = tick()
                    
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        -- Kiểm tra Gems liên tục để bỏ khoan đi lụm liền
                        local quickCheck = nil
                        for _, o in ipairs(workspace:GetDescendants()) do
                            if o:IsA("ProximityPrompt") and (o.ObjectText:find("Gems") or o.ActionText:find("Rob")) then
                                quickCheck = o.Parent break
                            end
                        end
                        if quickCheck and _G.AutoGems then break end

                        if drill:FindFirstChild("ProximityPrompt") then fireproximityprompt(drill.ProximityPrompt, 1, true) end
                        task.wait(0.2)
                    end
                    
                    if _G.AutoFarm then 
                        safeGlide(giver.Position, _G.DrillSpeed)
                        task.wait(1.5) 
                    end
                end
            end
        end
    end
end)

-- GIAO DIỆN
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Bật Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Bật Auto Lụm Gems (Toàn Map)", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)
ConfigTab:CreateInput({Name = "Tốc độ săn GEMS", PlaceholderText = "18", Callback = function(t) _G.GemsSpeed = tonumber(t) or 18 end})
ConfigTab:CreateInput({Name = "Tốc độ đi KHOAN", PlaceholderText = "8", Callback = function(t) _G.DrillSpeed = tonumber(t) or 8 end})
ConfigTab:CreateInput({Name = "Độ cao bay", PlaceholderText = "225", Callback = function(t) _G.FlyHeight = tonumber(t) or 225 end})

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
