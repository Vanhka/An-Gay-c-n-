local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KHA PRO - ANTI-BASE GEMS",
   LoadingTitle = "Đang tải hệ thống...",
   LoadingSubtitle = "Đã sửa lỗi hạ cánh & Lưu thông số",
   ConfigurationSaving = {Enabled = true, FolderName = "KhaConfig"}
})

-- BIẾN CÀI ĐẶT
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

-- HÀM LỌC GEMS (BỎ ROB BASE)
local function checkRealGem(obj)
    local text = (obj.ObjectText .. obj.ActionText):lower()
    local pName = obj.Parent.Name:lower()
    if text:find("gems") and not (text:find("base") or pName:find("base")) then
        return true
    end
    return false
end

-- LOGIC DI CHUYỂN (ĐÃ SỬA LỖI HẠ CÁNH)
local function safeGlide(targetPos, speed)
    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Bay lên độ cao an toàn
    while math.abs(hrp.Position.Y - _G.FlyHeight) > 3 and (_G.AutoFarm or _G.AutoGems) do
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 8, 0)
        task.wait()
        if hrp.Position.Y > _G.FlyHeight then break end
    end
    
    -- Lướt tới tọa độ
    local dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    while dist > 4 and (_G.AutoFarm or _G.AutoGems) do
        local direction = (Vector3.new(targetPos.X, _G.FlyHeight, targetPos.Z) - hrp.Position).Unit
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = hrp.CFrame + (direction * speed)
        dist = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        task.wait()
    end
    
    -- HẠ CÁNH XUỐNG ĐẤT ĐỂ LỤM GEMS (Lỗi bản trước nằm ở đây)
    if _G.AutoFarm or _G.AutoGems then
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y - 1.5, targetPos.Z)
        task.wait(0.2)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- VÒNG LẶP TREO MÁY
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoGems then
            for i = 1, 6 do
                if not _G.AutoGems then break end
                
                -- Bay tới và Hạ cánh xuống Base i
                safeGlide(BasePositions[i], _G.GemsSpeed)
                
                -- LỤM GEMS XUNG QUANH TỌA ĐỘ
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and checkRealGem(obj) then
                        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - obj.Parent.Position).Magnitude <= 50 then
                            fireproximityprompt(obj, 1, true)
                        end
                    end
                end
                
                -- Đứng lại chờ (theo thời gian đã chỉnh trên Slider)
                task.wait(_G.GemsRest) 
            end
        elseif _G.AutoFarm then
            local myBase = (function()
                local tycoons = workspace:FindFirstChild("The Nuke Tycoon Entirely Model") and workspace["The Nuke Tycoon Entirely Model"]:FindFirstChild("Tycoons")
                if tycoons then
                    for _, b in ipairs(tycoons:GetChildren()) do
                        local o = b:FindFirstChild("Owner")
                        if o and (o.Value == game.Players.LocalPlayer or o.Value == game.Players.LocalPlayer.Name) then return b end
                    end
                end
                return nil
            end)()
            
            if myBase then
                local drill = myBase.PurchasedObjects:FindFirstChild("RockStart") and myBase.PurchasedObjects.RockStart:FindFirstChild("manual_drill")
                local giver = myBase.Essentials:FindFirstChild("Giver")
                if drill and giver then
                    safeGlide(drill.Position, _G.DrillSpeed)
                    local drillStart = tick()
                    while (tick() - drillStart < _G.WaitAtDrill) and _G.AutoFarm do
                        if drill:FindFirstChild("ProximityPrompt") then fireproximityprompt(drill.ProximityPrompt, 1, true) end
                        task.wait(0.2)
                    end
                    if _G.AutoFarm then safeGlide(giver.Position, _G.DrillSpeed) task.wait(1.5) end
                end
            end
        end
    end
end)

-- GIAO DIỆN TAB TREO MÁY
local MainTab = Window:CreateTab("Treo Máy", 4483362458)
MainTab:CreateToggle({Name = "Auto Khoan", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
MainTab:CreateToggle({Name = "Săn Gems (Đã lọc Base)", CurrentValue = false, Callback = function(v) _G.AutoGems = v end})

-- GIAO DIỆN TAB CÀI ĐẶT (TRỞ VỀ SLIDER NHƯ TRONG ẢNH)
local ConfigTab = Window:CreateTab("Cài Đặt", 4483362458)

ConfigTab:CreateSlider({Name = "Tốc độ bay đi KHOAN", Range = {1, 30}, Increment = 1, CurrentValue = 3, Callback = function(v) _G.DrillSpeed = v end})
ConfigTab:CreateSlider({Name = "Độ cao bay (Fly Height)", Range = {100, 400}, Increment = 5, CurrentValue = 170, Callback = function(v) _G.FlyHeight = v end})
ConfigTab:CreateSlider({Name = "Thời gian khoan (Giây)", Range = {10, 600}, Increment = 10, CurrentValue = 590, Callback = function(v) _G.WaitAtDrill = v end})
ConfigTab:CreateSlider({Name = "Thời gian nghỉ lụm Gems", Range = {1, 30}, Increment = 1, CurrentValue = 10, Callback = function(v) _G.GemsRest = v end})
ConfigTab:CreateSlider({Name = "Tốc độ bay Săn GEMS", Range = {1, 50}, Increment = 1, CurrentValue = 20, Callback = function(v) _G.GemsSpeed = v end})

-- LỆNH LƯU/TẢI LẠI CẤU HÌNH (SẼ GHI NHỚ MỌI THỨ KHA CHỈNH)
Rayfield:LoadConfiguration()

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
