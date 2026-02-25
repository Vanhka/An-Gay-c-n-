local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ExitBtn = Instance.new("TextButton")
local ProfileInput = Instance.new("TextBox")
local RecordBtn = Instance.new("TextButton")
local PlayBtn = Instance.new("TextButton")
local AutoReplayBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- Chống lỗi khi chạy lại nhiều lần
if game:GetService("CoreGui"):FindFirstChild("DucAnMacroMaster") then
    game:GetService("CoreGui").DucAnMacroMaster:Destroy()
end

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "DucAnMacroMaster"

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "ĐỨC AN MACRO PRO"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

ExitBtn.Parent = MainFrame
ExitBtn.Text = "X"
ExitBtn.Position = UDim2.new(0.85, 0, 0, 5)
ExitBtn.Size = UDim2.new(0, 25, 0, 25)
ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local AllMacros = {}
local currentMacro = {}
local isRecording = false
local isPlaying = false
local autoReplay = false

ProfileInput.Parent = MainFrame
ProfileInput.PlaceholderText = "Nhập tên Macro..."
ProfileInput.Size = UDim2.new(0.9, 0, 0, 35)
ProfileInput.Position = UDim2.new(0.05, 0, 0.15, 0)
ProfileInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ProfileInput.TextColor3 = Color3.fromRGB(255, 255, 255)

RecordBtn.Parent = MainFrame
RecordBtn.Text = "BẬT GHI (RECORD)"
RecordBtn.Size = UDim2.new(0.9, 0, 0, 40)
RecordBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
RecordBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RecordBtn.Font = Enum.Font.SourceSansBold

RecordBtn.MouseButton1Click:Connect(function()
    if ProfileInput.Text == "" then StatusLabel.Text = "Lỗi: Hãy nhập tên!" return end
    isRecording = not isRecording
    RecordBtn.Text = isRecording and "ĐANG GHI... (Bấm dừng)" or "BẬT GHI (RECORD)"
    RecordBtn.BackgroundColor3 = isRecording and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
    if isRecording then
        currentMacro = {}
        StatusLabel.Text = "Đang ghi: " .. ProfileInput.Text
    else
        AllMacros[ProfileInput.Text] = currentMacro
        StatusLabel.Text = "Đã lưu: " .. ProfileInput.Text
    end
end)

local mouse = game.Players.LocalPlayer:GetMouse()
mouse.Button1Down:Connect(function()
    if isRecording and game.Players.LocalPlayer.Character then
        table.insert(currentMacro, {
            CharPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame,
            TargetPos = mouse.Hit.p
        })
    end
end)

PlayBtn.Parent = MainFrame
PlayBtn.Text = "CHẠY MACRO (PLAY)"
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
PlayBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayBtn.Font = Enum.Font.SourceSansBold

PlayBtn.MouseButton1Click:Connect(function()
    local macroToPlay = AllMacros[ProfileInput.Text]
    if not macroToPlay then StatusLabel.Text = "Lỗi: Không tìm thấy tên!" return end
    isPlaying = not isPlaying
    PlayBtn.Text = isPlaying and "ĐANG CHẠY... (Bấm dừng)" or "CHẠY MACRO (PLAY)"
    task.spawn(function()
        while isPlaying do
            for _, step in pairs(macroToPlay) do
                if not isPlaying then break end
                local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then
                    hum:MoveTo(step.CharPos.Position)
                    hum.MoveToFinished:Wait()
                end
                task.wait(1)
            end
            task.wait(1)
        end
    end)
end)

AutoReplayBtn.Parent = MainFrame
AutoReplayBtn.Text = "AUTO REPLAY: TẮT"
AutoReplayBtn.Size = UDim2.new(0.9, 0, 0, 40)
AutoReplayBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
AutoReplayBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoReplayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

AutoReplayBtn.MouseButton1Click:Connect(function()
    autoReplay = not autoReplay
    AutoReplayBtn.Text = autoReplay and "AUTO REPLAY: BẬT" or "AUTO REPLAY: TẮT"
    AutoReplayBtn.BackgroundColor3 = autoReplay and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

task.spawn(function()
    while true do
        if autoReplay then
            pcall(function()
                for _, v in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
           
