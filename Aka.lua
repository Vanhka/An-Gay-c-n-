local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - ANTI-BASE GEMS",
   LoadingTitle = "Đang nạp hệ thống Ghi Số...",
   LoadingSubtitle = "Đã thêm Nghỉ Khoan & Bay Nhận Tiền",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT (MẶC ĐỊNH)
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 590   -- Thời gian khoan
_G.DrillRest = 10      -- Thời gian nghỉ sau khi nhận tiền
_G.GemsRest = 10       -- Nghỉ sau khi hết 6 base gems
_G.FlyHeight = 170     
_G.DrillSpeed = 3      
_G.GemsSpeed = 20      

-- 6 TỌA ĐỘ TELE GEMS
local BasePositions = {
    Vector3.new(-26.0, 147.8, -616.7),
    Vector3.new(509.3, 147.7, 370.1),
    Vector3.new(-8.8, 147.7, 1379.9),
    Vector3.new(-1121.4, 147.7, 1756.2),
    Vector3.new(-2013.4, 147.7, 513.3),
    Vector3.new(-1368.7, 147.7, -557.8)
}

local function getMyBase()
    local tycoons = workspace:FindFirstChild("The Nuke Tycoon Entirely Model") and workspace["The Nuke Tycoon Entirely Model"]:FindFirstChild("Tycoons")
    if tycoons then
        for _, b in ipairs(tycoons:GetChildren()) do
            local o = b:FindFirstChild("Owner")
            if o and (o.Value == game.Players.LocalPlayer or o.Value == game.Players.LocalPlayer.Name) then return b end
        end
    end
    return nil
end

local function safeGlide(targetPos, speed)
    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- Bay lên
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoGems) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 8, 0)
        task.wait()
    end
    -- Lướt tới
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 4 and (_G.AutoFarm or _G.AutoGems) do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * speed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    -- Hạ cánh
    if _G.AutoFarm or _G.AutoGems then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.5, targetPos.Z)
        task.wait(0.5)
    end
end

-- VÒNG LẶP CHÍNH
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoGems then
            -- Bay 6 base rồi nghỉ tổng
            for i = 1, 6 do
                if not _G.AutoGems then break end
                safeGlide(BasePositions[i], _G.GemsSpeed)
                task.wait(1) 
            end
            task.wait(_G.GemsRest)
        elseif _G.AutoFarm then
            local myBase = getMyBase()
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                if drill and giver then
                    -- 1. Bay tới khoan
                    safeGlide(drill.Position, _G.DrillSpeed)
                    local startTime = tick()
                    -- 2. Đang khoan cho đến khi hết thời gian ghi
                    while (tick() - startTime < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then fireproximityprompt(drill.ProximityPrompt, 1, true) end
                        task.wait(0.2)
                    end
                    -- 3. Hết thời gian khoan -> Tự động bay tới nhận tiền
                    if _G.AutoFarm then
                        safeGlide(giver.Position, _G.DrillSpeed)
                        task.wait(2) -- Chờ nhận tiền xong
                        -- 4. Thời gian nghỉ khoan sau khi nhận tiền
                        print("Nhận tiền xong, nghỉ khoan...")
                        task.wait(_G.DrillRest)
                    end
                end
            end
        end
    end
end)

-- GIAO DIỆN
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Auto Khoan (Nhận tiền & Nghỉ)", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Săn Gems (6 Base & Nghỉ tổng)", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)

-- PHẦN GHI SỐ (INPUT)
ConfigTab:CreateInput({
    Name = "Ghi Thời Gian Khoan",
    PlaceholderText = "Mặc định: 590s",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.WaitAtDrill = tonumber(t) end end
})

ConfigTab:CreateInput({
    Name = "Ghi Thời Gian Nghỉ Khoan",
    PlaceholderText = "Nghỉ sau khi nhận tiền",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.DrillRest = tonumber(t) end end
})

ConfigTab:CreateInput({
    Name = "Ghi Thời Gian Nghỉ Gems",
    PlaceholderText = "Nghỉ sau 6 base",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.GemsRest = tonumber(t) end end
})

ConfigTab:CreateInput({
    Name = "Ghi Độ Cao Bay",
    PlaceholderText = "Mặc định: 170",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.FlyHeight = tonumber(t) end end
})

ConfigTab:CreateInput({
    Name = "Ghi Tốc Độ Bay",
    PlaceholderText = "Mặc định: 20",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.GemsSpeed = tonumber(t) end end
})

Rayfield:LoadConfiguration()
