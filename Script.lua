-- LocalScript в StarterPlayer.StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем папку для чекпоинтов в Workspace
local checkpointFolder = Instance.new("Folder")
checkpointFolder.Name = "PlayerCheckpoints"
checkpointFolder.Parent = workspace

-- Создаем интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheckpointSystem"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
mainFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = mainFrame

-- Заголовок с кнопкой сворачивания
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0) -- Занимает всю ширину
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Чекпоинты"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Center -- Выравнивание по центру
title.Parent = titleBar

-- Кнопка сворачивания
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(1, -30, 0, 0)
collapseBtn.Text = "-"
collapseBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.Parent = titleBar

-- Контейнер для содержимого (будет скрываться при сворачивании)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local createBtn = Instance.new("TextButton")
createBtn.Size = UDim2.new(0, 280, 0, 35)
createBtn.Position = UDim2.new(0.5, -140, 0, 10)
createBtn.Text = "Создать чекпоинт"
createBtn.BackgroundColor3 = Color3.new(0.2, 0.5, 0.9)
createBtn.TextColor3 = Color3.new(1, 1, 1)
createBtn.Parent = contentFrame

local deleteAllBtn = Instance.new("TextButton")
deleteAllBtn.Size = UDim2.new(0, 280, 0, 35)
deleteAllBtn.Position = UDim2.new(0.5, -140, 0, 55)
deleteAllBtn.Text = "Удалить все чекпоинты"
deleteAllBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
deleteAllBtn.TextColor3 = Color3.new(1, 1, 1)
deleteAllBtn.Parent = contentFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 280)
scrollFrame.Position = UDim2.new(0, 10, 0, 100)
scrollFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

-- Переменные для GUI
local checkpoints = {}
local teleportState = {}
local lastPosition = nil
local activeCheckpoint = nil -- Текущий активный чекпоинт для возврата

-- Переменные для перетаскивания
local dragging = false
local dragInput
local dragStart
local startPos

-- Функция для перетаскивания GUI
local function updateInput(input)
    local delta = input.Position - dragStart
    local newPosition = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
    mainFrame.Position = newPosition
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Функция сворачивания/разворачивания GUI
local function toggleGUI()
    if contentFrame.Visible then
        -- Сворачиваем
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 320, 0, 30)
        collapseBtn.Text = "+"
    else
        -- Разворачиваем
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 320, 0, 450)
        collapseBtn.Text = "-"
    end
end

collapseBtn.MouseButton1Click:Connect(toggleGUI)

-- Мгновенная функция телепортации
local function teleportToPosition(position)
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Мгновенная телепортация - напрямую меняем позицию
    humanoidRootPart.CFrame = CFrame.new(position)
    
    -- Дополнительно сбрасываем скорость для предотвращения нежелательного движения
    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
end

-- Функция сброса состояния всех чекпоинтов
local function resetAllCheckpointStates()
    for checkpoint, _ in pairs(teleportState) do
        teleportState[checkpoint] = false
    end
    activeCheckpoint = nil
end

-- Функция обновления списка чекпоинтов в GUI
local function updateCheckpointList()
    -- Очищаем скролл фрейм
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Обновляем размер скролл фрейма
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #checkpoints * 70)
    
    -- Создаем элементы для каждого чекпоинта
    for i, checkpoint in ipairs(checkpoints) do
        local btnFrame = Instance.new("Frame")
        btnFrame.Size = UDim2.new(1, 0, 0, 60)
        btnFrame.BackgroundTransparency = 1
        btnFrame.Parent = scrollFrame
        
        -- Создаем превью местоположения как TextButton для обработки кликов
        local previewButton = Instance.new("TextButton")
        previewButton.Size = UDim2.new(1, 0, 1, 0)
        previewButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3) -- Единый серый цвет
        previewButton.BorderSizePixel = 1
        previewButton.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
        previewButton.Text = "" -- Убираем текст кнопки
        previewButton.AutoButtonColor = false -- Отключаем автоматическое изменение цвета
        previewButton.Parent = btnFrame
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = previewButton
        
        -- Название чекпоинта
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0.05, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = checkpoint.name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = previewButton
        
        -- Координаты в одной строке
        local coordLabel = Instance.new("TextLabel")
        coordLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
        coordLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
        coordLabel.BackgroundTransparency = 1
        coordLabel.Text = string.format("X:%.0f  Y:%.0f  Z:%.0f", checkpoint.position.X, checkpoint.position.Y, checkpoint.position.Z)
        coordLabel.TextColor3 = Color3.new(1, 1, 1)
        coordLabel.TextSize = 12
        coordLabel.Font = Enum.Font.SourceSans
        coordLabel.TextXAlignment = Enum.TextXAlignment.Left
        coordLabel.Parent = previewButton
        
        -- Смайлик (меняется в зависимости от состояния)
        local emojiLabel = Instance.new("TextLabel")
        emojiLabel.Size = UDim2.new(0.1, 0, 1, 0)
        emojiLabel.Position = UDim2.new(0.65, 0, 0, 0) -- Сдвинули вправо
        emojiLabel.BackgroundTransparency = 1
        emojiLabel.TextColor3 = Color3.new(1, 1, 1)
        emojiLabel.TextSize = 16
        emojiLabel.Parent = previewButton
        
        -- Устанавливаем смайлик в зависимости от состояния
        if teleportState[checkpoint] then
            -- Второе состояние: доступен возврат
            emojiLabel.Text = "😈"
        else
            -- Первое состояние: доступна телепортация к чекпоинту
            emojiLabel.Text = "😎"
        end
        
        -- Кнопка удаления
        local deleteBtn = Instance.new("TextButton")
        deleteBtn.Size = UDim2.new(0.2, 0, 0.5, 0)
        deleteBtn.Position = UDim2.new(0.8, 0, 0.5, 0)
        deleteBtn.Text = "Удалить"
        deleteBtn.BackgroundColor3 = Color3.new(0.7, 0.2, 0.2)
        deleteBtn.TextColor3 = Color3.new(1, 1, 1)
        deleteBtn.Parent = previewButton
        
        -- Обработчик нажатия на превью (телепортация)
        previewButton.MouseButton1Click:Connect(function()
            local character = player.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local currentPosition = humanoidRootPart.Position
            
            if not teleportState[checkpoint] then
                -- Первое нажатие: телепорт к чекпоинту
                
                -- Сбрасываем состояние предыдучного активного чекпоинта
                if activeCheckpoint and activeCheckpoint ~= checkpoint then
                    teleportState[activeCheckpoint] = false
                end
                
                lastPosition = currentPosition
                teleportToPosition(checkpoint.position)
                teleportState[checkpoint] = true
                activeCheckpoint = checkpoint
                updateCheckpointList() -- Обновляем интерфейс
            else
                -- Второе нажатие: возврат назад
                teleportToPosition(lastPosition)
                teleportState[checkpoint] = false
                activeCheckpoint = nil
                updateCheckpointList() -- Обновляем интерфейс
            end
        end)
        
        -- Обработчик нажатия на кнопку удаления
        deleteBtn.MouseButton1Click:Connect(function()
            -- Если удаляем активный чекпоинт, сбрасываем состояние
            if activeCheckpoint == checkpoint then
                teleportState[checkpoint] = false
                activeCheckpoint = nil
            end
            
            checkpoint.part:Destroy()
            teleportState[checkpoint] = nil
            table.remove(checkpoints, i)
            updateCheckpointList()
        end)
    end
end

-- Функция создания чекпоинта
local function createCheckpoint()
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Создаем невидимый чекпоинт
    local checkpoint = Instance.new("Part")
    checkpoint.Name = "Checkpoint_" .. #checkpoints + 1
    checkpoint.Size = Vector3.new(1, 1, 1)
    checkpoint.Position = humanoidRootPart.Position
    checkpoint.Anchored = true
    checkpoint.CanCollide = false
    checkpoint.Transparency = 1
    checkpoint.Parent = checkpointFolder
    
    local checkpointData = {
        part = checkpoint,
        position = humanoidRootPart.Position,
        name = "Чекпоинт " .. (#checkpoints + 1)
    }
    
    table.insert(checkpoints, checkpointData)
    teleportState[checkpointData] = false
    
    updateCheckpointList()
end

-- Функция удаления всех чекпоинтов
local function deleteAllCheckpoints()
    for _, checkpoint in ipairs(checkpoints) do
        checkpoint.part:Destroy()
        teleportState[checkpoint] = nil
    end
    checkpoints = {}
    activeCheckpoint = nil
    updateCheckpointList()
end

-- Обработчики событий
createBtn.MouseButton1Click:Connect(createCheckpoint)
deleteAllBtn.MouseButton1Click:Connect(deleteAllCheckpoints)

-- Обновляем размер скролл фрейма при изменении содержимого
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

-- Включаем GUI сразу
screenGui.Enabled = true
