--==================================================
-- 银行 + 仓库 + 8个装备卡槽
-- LocalScript
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Event = ReplicatedStorage.Events.RemoteFunction.SandboxSpawn

--==================================================
-- 银行数据
--==================================================

local Money = 600
local Level = 0
local MaxMoney = 22500
local MaxLevel = 9

local Running = true
local SelectedUnit = nil

local UpgradeCosts = {
    440,880,1320,1760,2200,
    2640,3080,3520,3960
}

--==================================================
-- 单位数据
--==================================================

local Units = {

    -- 普通
    {Name="真理鹈鹕",ID=151,Rank="B",Amount=8,Price=20000,Cooldown=200,Image=102009551876604,Category="普通"},
    {Name="棍子",ID=109,Rank="B",Amount=8,Price=10000,Cooldown=100,Image=81963847967960,Category="普通"},
    {Name="黑暗轰炸机战士",ID=22,Rank="B",Amount=4,Price=1000,Cooldown=25,Image=93022672755160,Category="普通"},
    {Name="魔法生成器",ID=24,Rank="B",Amount=4,Price=1600,Cooldown=50,Image=101930259026845,Category="普通"},

    -- 僵尸
    {Name="保持微笑",ID=144,Rank="A",Amount=2,Price=1000,Cooldown=35,Image=134391460910247,Category="僵尸"},
    {Name="披萨",ID=136,Rank="A",Amount=2,Price=500,Cooldown=50,Image=76810868926793,Category="僵尸"},
    {Name="保护僵尸",ID=135,Rank="A",Amount=2,Price=900,Cooldown=70,Image=117471233334728,Category="僵尸"},

    -- 天使
    {Name="诺曼",ID=104,Rank="B",Amount=2,Price=800,Cooldown=60,Image=76163313488934,Category="天使"},
    {Name="审判",ID=115,Rank="B",Amount=6,Price=2000,Cooldown=50,Image=76008989733506,Category="天使"},

    -- 死亡
    {Name="McBlast",ID=116,Rank="B",Amount=4,Price=300,Cooldown=30,Image=83665706736688,Category="死亡"},
    {Name="粉碎机",ID=121,Rank="B",Amount=4,Price=8000,Cooldown=800,Image=132780898159572,Category="死亡"},
    {Name="极限",ID=72,Rank="B",Amount=4,Price=20000,Cooldown=500,Image=90530027731674,Category="死亡"},
    {Name="巨魔袭击",ID=105,Rank="B",Amount=4,Price=200,Cooldown=25,Image=119281801828499,Category="死亡"},
    {Name="束缚状态",ID=69,Rank="B",Amount=4,Price=1200,Cooldown=20,Image=90355776344408,Category="死亡"},

    {Name="双黑暗之心",ID=54,Rank="B",Amount=10,Price=300,Cooldown=10,Image=90816086906198,Category="死亡"},
    {Name="贝蒂",ID=56,Rank="B",Amount=10,Price=300,Cooldown=15,Image=112152174802483,Category="死亡"},
    {Name="血角",ID=65,Rank="B",Amount=10,Price=800,Cooldown=20,Image=73907201693668,Category="死亡"},

    {
        Name="原子",
        ID=118,
        Rank="B",
        Amount=10,
        Price=500,
        Cooldown=20,
        Image=72643510567320,
        Category="死亡",
        Args={Health=50}
    },

    {Name="顶级",ID=94,Rank="B",Amount=10,Price=1000,Cooldown=25,Image=103544184383951,Category="死亡"},

    -- 地狱
    {Name="地狱",ID=39,Rank="B",Amount=8,Price=2000,Cooldown=50,Image=113366045982105,Category="地狱"},
    {Name="天才",ID=89,Rank="B",Amount=4,Price=1200,Cooldown=60,Image=139624564209954,Category="地狱"},
    {Name="疯狂化学家",ID=60,Rank="B",Amount=4,Price=3000,Cooldown=100,Image=134686338431581,Category="地狱"},
    {Name="Speeddemon",ID=150,Rank="B",Amount=4,Price=2400,Cooldown=70,Image=73440841269995,Category="地狱"},
    {Name="盾牌战士",ID=29,Rank="B",Amount=4,Price=300,Cooldown=30,Image=87500073270346,Category="地狱"},
    {Name="吉他英雄",ID=35,Rank="B",Amount=4,Price=2000,Cooldown=100,Image=117913123207840,Category="地狱"},
    {Name="地狱火",ID=40,Rank="B",Amount=4,Price=12000,Cooldown=500,Image=95516325060350,Category="地狱"}
}

--==================================================
-- 卡槽数据
--==================================================

local Slots = {}
local SlotCards = {}
local WarehouseCards = {}

for i=1,8 do
    Slots[i] = {Unit=nil}
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "BankAndInventory"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
Gui.Parent = Player:WaitForChild("PlayerGui")

local function Corner(obj,radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius or 7)
    c.Parent = obj
end

local function Button(parent,name,text,size,pos,z)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = z or 100
    b.Parent = parent
    Corner(b,7)
    return b
end

local function Label(parent,name,text,size,pos,z)
    local l = Instance.new("TextLabel")
    l.Name = name
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.Text = text
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    l.ZIndex = z or 100
    l.Parent = parent
    return l
end

--==================================================
-- 银行
--==================================================

local Bank = Instance.new("Frame")
Bank.Name = "Bank"
Bank.Size = UDim2.new(0,230,0,155)
Bank.Position = UDim2.new(0,15,0,45)
Bank.BackgroundColor3 = Color3.fromRGB(20,20,20)
Bank.BorderSizePixel = 0
Bank.ZIndex = 100
Bank.Parent = Gui
Corner(Bank,10)

Label(Bank,"Title","银行",
    UDim2.new(1,0,0,30),
    UDim2.new(0,0,0,3))

local MoneyLabel = Label(Bank,"Money","资金：600",
    UDim2.new(1,-10,0,28),
    UDim2.new(0,5,0,35))

local LevelLabel = Label(Bank,"Level","等级：0",
    UDim2.new(1,-10,0,25),
    UDim2.new(0,5,0,65))

local UpgradeButton = Button(Bank,"Upgrade","升级银行",
    UDim2.new(0.94,0,0,35),
    UDim2.new(0.03,0,0,105))

local function UpdateMoney()
    MoneyLabel.Text = "资金："..math.floor(Money)
    LevelLabel.Text = "等级："..Level

    if Level >= MaxLevel then
        UpgradeButton.Text = "等级已满"
    else
        UpgradeButton.Text = "升级："..UpgradeCosts[Level+1]
    end
end

--==================================================
-- 主按钮
--==================================================

local StartButton = Button(Gui,"Start","开始",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-190,0,45))

local StopButton = Button(Gui,"Stop","停止",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-95,0,45))

local WarehouseButton = Button(Gui,"WarehouseButton","仓库",
    UDim2.new(0,85,0,38),
    UDim2.new(1,-95,0,90))

--==================================================
-- 卡槽区域
--==================================================

local SlotArea = Instance.new("Frame")
SlotArea.Name = "EquipmentSlots"
SlotArea.Size = UDim2.new(0.54,0,0,112)
SlotArea.Position = UDim2.new(0.5,0,1,-115)
SlotArea.AnchorPoint = Vector2.new(0.5,0)
SlotArea.BackgroundTransparency = 1
SlotArea.ZIndex = 100
SlotArea.Parent = Gui

local SlotGrid = Instance.new("UIGridLayout")
SlotGrid.CellSize = UDim2.new(0.235,0,0,48)
SlotGrid.CellPadding = UDim2.new(0.01,0,0,6)
SlotGrid.FillDirection = Enum.FillDirection.Horizontal
SlotGrid.FillDirectionMaxCells = 4
SlotGrid.SortOrder = Enum.SortOrder.LayoutOrder
SlotGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
SlotGrid.VerticalAlignment = Enum.VerticalAlignment.Center
SlotGrid.Parent = SlotArea

--==================================================
-- 冷却计算
--==================================================

local function GetRemaining(unit)
    if not unit or not unit.Last then
        return 0
    end

    return math.max(
        0,
        unit.Cooldown-(os.clock()-unit.Last)
    )
end

local function UpdateSlots()
    for i,data in ipairs(SlotCards) do
        local unit = Slots[i].Unit

        if unit then
            data.Icon.Image = "rbxassetid://"..unit.Image
            data.Icon.Visible = true
            data.PriceText.Text = "$"..unit.Price
            data.PriceText.Visible = true

            local remaining = GetRemaining(unit)

            if remaining > 0 then
                data.CooldownMask.Visible = true
                data.CooldownFill.Size = UDim2.new(
                    1,0,
                    math.clamp(remaining/unit.Cooldown,0,1),0
                )
                data.CooldownText.Text =
                    tostring(math.ceil(remaining))
            else
                data.CooldownMask.Visible = false
            end
        else
            data.Icon.Visible = false
            data.PriceText.Visible = false
            data.CooldownMask.Visible = false
        end
    end
end

--==================================================
-- 仓库界面
--==================================================

local Warehouse = Instance.new("Frame")
Warehouse.Name = "WarehousePanel"
Warehouse.Size = UDim2.new(0,370,0,420)
Warehouse.Position = UDim2.new(0.5,-185,0.5,-210)
Warehouse.BackgroundColor3 = Color3.fromRGB(20,20,20)
Warehouse.BorderSizePixel = 0
Warehouse.Visible = false
Warehouse.ZIndex = 120
Warehouse.Parent = Gui
Corner(Warehouse,10)

local WarehouseScale = Instance.new("UIScale")
WarehouseScale.Scale = 1
WarehouseScale.Parent = Warehouse

Label(Warehouse,"Title","单位仓库",
    UDim2.new(0.7,0,0,35),
    UDim2.new(0,5,0,3),121)

local CloseButton = Button(Warehouse,"Close","X",
    UDim2.new(0,35,0,30),
    UDim2.new(1,-42,0,5),130)

CloseButton.MouseButton1Click:Connect(function()
    Warehouse.Visible = false
end)

WarehouseButton.MouseButton1Click:Connect(function()
    Warehouse.Visible = not Warehouse.Visible
end)

--==================================================
-- 仓库缩放
--==================================================

local ScaleButton = Button(Warehouse,"ScaleButton","−",
    UDim2.new(0,32,0,30),
    UDim2.new(1,-80,0,5),130)

local IsSmall = false

ScaleButton.MouseButton1Click:Connect(function()
    IsSmall = not IsSmall

    if IsSmall then
        WarehouseScale.Scale = 0.75
        ScaleButton.Text = "+"
    else
        WarehouseScale.Scale = 1
        ScaleButton.Text = "−"
    end
end)

--==================================================
-- 仓库拖拽（支持手机）
--==================================================

local DragBar = Instance.new("TextButton")
DragBar.Name = "DragBar"
DragBar.Size = UDim2.new(1,-120,0,38)
DragBar.Position = UDim2.new(0,0,0,0)
DragBar.BackgroundTransparency = 1
DragBar.Text = ""
DragBar.AutoButtonColor = false
DragBar.Active = true
DragBar.ZIndex = 125
DragBar.Parent = Warehouse

local Dragging = false
local DragStart = nil
local StartPosition = nil
local DragInput = nil

DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = Warehouse.Position
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not Dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position-DragStart

        Warehouse.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset+delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset+delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == DragInput
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
        DragInput = nil
    end
end)

--==================================================
-- 分类筛选
--==================================================

local Categories = {
    "全部","普通","地狱","死亡","天使","僵尸"
}

local CurrentCategory = "全部"
local CurrentRank = "全部"

local CategoryFrame = Instance.new("Frame")
CategoryFrame.Size = UDim2.new(1,-10,0,32)
CategoryFrame.Position = UDim2.new(0,5,0,42)
CategoryFrame.BackgroundTransparency = 1
CategoryFrame.ZIndex = 121
CategoryFrame.Parent = Warehouse

local CategoryGrid = Instance.new("UIGridLayout")
CategoryGrid.CellSize = UDim2.new(1/6,-3,1,0)
CategoryGrid.CellPadding = UDim2.new(0,2,0,0)
CategoryGrid.Parent = CategoryFrame

local CategoryButtons = {}

--==================================================
-- 等级筛选
--==================================================

local RankFrame = Instance.new("Frame")
RankFrame.Size = UDim2.new(1,-10,0,30)
RankFrame.Position = UDim2.new(0,5,0,78)
RankFrame.BackgroundTransparency = 1
RankFrame.ZIndex = 121
RankFrame.Parent = Warehouse

local RankA = Button(RankFrame,"RankA","A",
    UDim2.new(0.5,-3,1,0),
    UDim2.new(0,0,0,0),122)

local RankB = Button(RankFrame,"RankB","B",
    UDim2.new(0.5,-3,1,0),
    UDim2.new(0.5,3,0,0),122)

--==================================================
-- 仓库列表
--==================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "UnitList"
Scroll.Size = UDim2.new(1,-12,1,-120)
Scroll.Position = UDim2.new(0,6,0,113)
Scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ZIndex = 121
Scroll.Parent = Warehouse
Corner(Scroll,7)

local WarehouseGrid = Instance.new("UIGridLayout")
WarehouseGrid.CellSize = UDim2.new(0,75,0,75)
WarehouseGrid.CellPadding = UDim2.new(0,7,0,7)
WarehouseGrid.SortOrder = Enum.SortOrder.LayoutOrder
WarehouseGrid.Parent = Scroll

local EmptyLabel = Label(
    Warehouse,
    "Empty",
    "没有符合条件的单位",
    UDim2.new(1,-20,0,50),
    UDim2.new(0,10,0,250),
    140
)

EmptyLabel.Visible = false

--==================================================
-- 检查单位是否已装备
--==================================================

local function IsUnitEquipped(unit)
    for _,slot in ipairs(Slots) do
        if slot.Unit and slot.Unit.ID == unit.ID then
            return true
        end
    end

    return false
end

--==================================================
-- 更新仓库
--==================================================

local function UpdateWarehouse()
    for _,card in ipairs(WarehouseCards) do
        card:Destroy()
    end

    table.clear(WarehouseCards)

    local count = 0

    for _,unit in ipairs(Units) do
        local categoryMatch =
            CurrentCategory == "全部"
            or unit.Category == CurrentCategory

        local rankMatch =
            CurrentRank == "全部"
            or unit.Rank == CurrentRank

        if categoryMatch and rankMatch then
            count += 1

            local equipped = IsUnitEquipped(unit)

            local card = Button(
                Scroll,
                unit.Name,
                "",
                UDim2.new(0,75,0,75),
                UDim2.new(0,0,0,0),
                122
            )

            local icon = Instance.new("ImageLabel")
            icon.Name = "UnitImage"
            icon.Size = UDim2.new(1,0,1,0)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://"..unit.Image
            icon.ScaleType = Enum.ScaleType.Fit
            icon.ZIndex = 123
            icon.Parent = card
            Corner(icon,8)

            if equipped then
                card.BackgroundColor3 = Color3.fromRGB(65,65,65)

                local mask = Instance.new("Frame")
                mask.Size = UDim2.new(1,0,1,0)
                mask.BackgroundColor3 = Color3.new(0,0,0)
                mask.BackgroundTransparency = 0.45
                mask.BorderSizePixel = 0
                mask.ZIndex = 124
                mask.Parent = card
                Corner(mask,8)

                Label(
                    mask,
                    "Equipped",
                    "已装备",
                    UDim2.new(1,0,0,25),
                    UDim2.new(0,0,0.5,-12),
                    125
                )
            end

            if SelectedUnit == unit then
                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(255,220,0)
                stroke.Thickness = 3
                stroke.Parent = card
            end

            card.MouseButton1Click:Connect(function()

                -- 只有停止状态才能选择或更换单位
                if Running then
                    return
                end

                if IsUnitEquipped(unit) then
                    SelectedUnit = nil
                    UpdateWarehouse()
                    return
                end

                SelectedUnit = unit
                UpdateWarehouse()
            end)

            table.insert(WarehouseCards,card)
        end
    end

    EmptyLabel.Visible = count == 0
    Scroll.CanvasPosition = Vector2.new(0,0)
end

--==================================================
-- 分类按钮
--==================================================

for _,category in ipairs(Categories) do
    local button = Button(
        CategoryFrame,
        category,
        category,
        UDim2.new(1,0,1,0),
        UDim2.new(0,0,0,0),
        122
    )

    CategoryButtons[category] = button

    button.MouseButton1Click:Connect(function()
        CurrentCategory = category

        for name,other in pairs(CategoryButtons) do
            other.BackgroundColor3 =
                name == category
                and Color3.fromRGB(40,130,70)
                or Color3.fromRGB(45,45,45)
        end

        UpdateWarehouse()
    end)
end

CategoryButtons["全部"].BackgroundColor3 =
    Color3.fromRGB(40,130,70)

--==================================================
-- A / B 筛选
--==================================================

RankA.MouseButton1Click:Connect(function()
    CurrentRank = CurrentRank == "A" and "全部" or "A"

    RankA.BackgroundColor3 =
        CurrentRank == "A"
        and Color3.fromRGB(40,130,70)
        or Color3.fromRGB(45,45,45)

    RankB.BackgroundColor3 = Color3.fromRGB(45,45,45)

    UpdateWarehouse()
end)

RankB.MouseButton1Click:Connect(function()
    CurrentRank = CurrentRank == "B" and "全部" or "B"

    RankB.BackgroundColor3 =
        CurrentRank == "B"
        and Color3.fromRGB(40,130,70)
        or Color3.fromRGB(45,45,45)

    RankA.BackgroundColor3 = Color3.fromRGB(45,45,45)

    UpdateWarehouse()
end)

--==================================================
-- 创建8个卡槽
--==================================================

for i=1,8 do
    local card = Button(
        SlotArea,
        "Slot"..i,
        "",
        UDim2.new(0,0,0,0),
        UDim2.new(0,0,0,0),
        101
    )

    card.LayoutOrder = i

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1,0,1,0)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Visible = false
    icon.ZIndex = 102
    icon.Parent = card
    Corner(icon,7)

    local priceText = Instance.new("TextLabel")
    priceText.Name = "PriceText"
    priceText.Size = UDim2.new(1,0,0,18)
    priceText.Position = UDim2.new(0,0,1,-18)
    priceText.BackgroundColor3 = Color3.fromRGB(0,0,0)
    priceText.BackgroundTransparency = 0.25
    priceText.TextColor3 = Color3.new(1,1,1)
    priceText.TextScaled = true
    priceText.Font = Enum.Font.GothamBold
    priceText.ZIndex = 107
    priceText.Visible = false
    priceText.Parent = card

    local cooldownMask = Instance.new("Frame")
    cooldownMask.Name = "CooldownMask"
    cooldownMask.Size = UDim2.new(1,0,1,0)
    cooldownMask.BackgroundColor3 = Color3.fromRGB(0,0,0)
    cooldownMask.BackgroundTransparency = 0.48
    cooldownMask.BorderSizePixel = 0
    cooldownMask.ClipsDescendants = true
    cooldownMask.Visible = false
    cooldownMask.ZIndex = 104
    cooldownMask.Parent = card
    Corner(cooldownMask,7)

    local cooldownFill = Instance.new("Frame")
    cooldownFill.Size = UDim2.new(1,0,1,0)
    cooldownFill.BackgroundColor3 = Color3.fromRGB(130,130,130)
    cooldownFill.BackgroundTransparency = 0.25
    cooldownFill.BorderSizePixel = 0
    cooldownFill.ZIndex = 105
    cooldownFill.Parent = cooldownMask

    local cooldownText = Label(
        cooldownMask,
        "CooldownText",
        "",
        UDim2.new(1,0,0,25),
        UDim2.new(0,0,0.5,-12),
        106
    )

    cooldownText.TextStrokeTransparency = 0

    SlotCards[i] = {
        Button = card,
        Icon = icon,
        PriceText = priceText,
        CooldownMask = cooldownMask,
        CooldownFill = cooldownFill,
        CooldownText = cooldownText
    }

    --==================================================
    -- 卡槽点击逻辑
    --==================================================

    card.MouseButton1Click:Connect(function()

        -- 停止状态：允许装备、替换、清空
        if not Running then

            -- 已选择仓库单位：装备或替换
            if SelectedUnit ~= nil then

                -- 防止重复装备
                for slotIndex,slot in ipairs(Slots) do
                    if slotIndex ~= i
                    and slot.Unit
                    and slot.Unit.ID == SelectedUnit.ID then
                        SelectedUnit = nil
                        UpdateWarehouse()
                        return
                    end
                end

                Slots[i].Unit = SelectedUnit
                SelectedUnit = nil

                UpdateSlots()
                UpdateWarehouse()
                return
            end

            -- 没有选择仓库单位：清空当前卡槽
            if Slots[i].Unit ~= nil then
                Slots[i].Unit = nil

                UpdateSlots()
                UpdateWarehouse()
            end

            return
        end

        --==================================================
        -- 开始状态：只能召唤
        --==================================================

        local unit = Slots[i].Unit

        if not unit then
            return
        end

        if GetRemaining(unit) > 0 then
            return
        end

        if Money < unit.Price then
            return
        end

        Money -= unit.Price
        unit.Last = os.clock()

        UpdateMoney()
        UpdateSlots()

        task.spawn(function()
            local success,err = pcall(function()
                Event:InvokeServer(
                    "Enemy",
                    unit.ID,
                    unit.Rank,
                    unit.Amount,
                    unit.Args or {}
                )
            end)

            if not success then
                warn("召唤失败：",err)
            end
        end)
    end)
end

--==================================================
-- 银行升级
--==================================================

UpgradeButton.MouseButton1Click:Connect(function()
    if not Running then
        return
    end

    if Level >= MaxLevel then
        return
    end

    local cost = UpgradeCosts[Level+1]

    if Money >= cost then
        Money -= cost
        Level += 1
        UpdateMoney()
    end
end)

--==================================================
-- 停止
--==================================================

StopButton.MouseButton1Click:Connect(function()
    Running = false
    Level = 0
    Money = 600
    SelectedUnit = nil

    for _,unit in ipairs(Units) do
        unit.Last = nil
    end

    UpdateMoney()
    UpdateSlots()
    UpdateWarehouse()
end)

--==================================================
-- 开始
--==================================================

StartButton.MouseButton1Click:Connect(function()
    if Running then
        return
    end

    Running = true
    SelectedUnit = nil

    -- 所有单位冷却归零
    -- 只有粉碎机进入完整800秒冷却
    for _,unit in ipairs(Units) do
        if unit.Name == "粉碎机" then
            unit.Last = os.clock()
        else
            unit.Last = nil
        end
    end

    UpdateMoney()
    UpdateSlots()
    UpdateWarehouse()
end)

--==================================================
-- 隐藏 / 显示主界面
--==================================================

local Hidden = false

local HideButton = Button(
    Gui,
    "HideButton",
    "隐藏",
    UDim2.new(0,85,0,35),
    UDim2.new(1,-95,0,135),
    1000000
)

HideButton.MouseButton1Click:Connect(function()
    Hidden = not Hidden

    Bank.Visible = not Hidden
    StartButton.Visible = not Hidden
    StopButton.Visible = not Hidden
    WarehouseButton.Visible = not Hidden
    SlotArea.Visible = not Hidden

    Warehouse.Visible = false
    HideButton.Text = Hidden and "显示" or "隐藏"
end)

--==================================================
-- 银行收入
--==================================================

task.spawn(function()
    while Gui.Parent do
        task.wait(0.1)

        if Running then
            Money = math.min(
                MaxMoney,
                Money + 1 + Level*10
            )

            UpdateMoney()
        end
    end
end)

--==================================================
-- 冷却刷新
--==================================================

task.spawn(function()
    while Gui.Parent do
        UpdateSlots()
        task.wait(0.1)
    end
end)

--==================================================
-- 初始化
--==================================================

UpdateMoney()
UpdateSlots()
UpdateWarehouse()

print("银行 + 仓库系统加载完成")
print("单位总数："..#Units)
