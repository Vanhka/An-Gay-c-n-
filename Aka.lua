local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - ANTI-BASE GEMS",
   LoadingTitle = "Đang nạp chế độ GHI SỐ...",
   LoadingSubtitle = "Đã gỡ bỏ thanh kéo - Chỉ dùng ô nhập",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT (GHI NHỚ THÔNG SỐ)
_G.AutoFarm = false   
_G.AutoGems = false
_G.WaitAtDrill = 590   
_G.GemsRest = 10       
_G.FlyHeight = 170     
_G.DrillSpeed = 3      
_G.GemsSpeed = 20      

-- 6 TỌA ĐỘ TELE CỦA KHA
local BasePositions = {
    Vector3.new(-26.0, 147.8, -616.7),
    Vector3.new(509.3, 147.7, 370.1),
    Vector3.new(-8.8, 147.7, 1379.9),
    Vector3.new(-1121.4, 147.7, 1756.2),
    Vector3.new(-2013.4, 147.7, 513.3),
    Vector3.new(-1368.7, 147.7, -557.8)
}

-- HÀM LỌC GEMS
local function checkRealGem(obj)
    local text = (obj.ObjectText .. obj.ActionText):lower()
    local pName = obj.Parent.Name:lower()
    if text:find("gems") and not (text:find("base") or pName:find("base")) then
        return true
    end
    return false
end

-- HÀM BAY VÀ HẠ CÁNH (ĐÃ SỬA)
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

    -- HẠ CÁNH ĐỂ LỤM
    if _G.AutoFarm or _G.AutoGems then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.5, targetPos.Z)
        task.wait(0.3)
    end
end

-- VÒNG LẶP SĂN GEMS 6 TOẠ ĐỘ
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoGems then
            for i = 1, 6 do
                if not _G.AutoGems then break end
                safeGlide(BasePositions[i], _G.GemsSpeed)
                
                -- Lụm gems tại chỗ vừa đáp
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and checkRealGem(obj) then
                        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - obj.Parent.Position).Magnitude <= 30 then
                            fireproximityprompt(obj, 1, true)
                        end
                    end
                end
                task.wait(_G.GemsRest) 
            end
        end
    end
end)

-- GIAO DIỆN
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Săn Gems (6 Toạ Độ)", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)

-- ĐÃ CHUYỂN TOÀN BỘ SANG Ô "GHI" (INPUT)
ConfigTab:CreateInput({
    Name = "Độ cao bay (Ghi số)",
    PlaceholderText = "Ví dụ: 170",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.FlyHeight = tonumber(t) end end
})

ConfigTab:CreateInput({
    Name = "Tốc độ bay (Ghi số)",
    PlaceholderText = "Ví dụ: 20",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.GemsSpeed = tonumber(t) end end
})

ConfigTab:CreateInput({
    Name = "Thời gian nghỉ lụm (Ghi số)",
    PlaceholderText = "Ví dụ: 10",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.GemsRest = tonumber(t) end end
})

ConfigTab:CreateInput({
    Name = "Thời gian khoan (Ghi số)",
    PlaceholderText = "Ví dụ: 590",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) if tonumber(t) then _G.WaitAtDrill = tonumber(t) end end
})

Rayfield:LoadConfiguration()
