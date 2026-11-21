local pd  = game.Players.LocalPlayer.PlayerData
local lib = require(game.ReplicatedStorage.Modules.FriendlyNPCLibrary)
local ups = pd.Upgrades.Units

local have = {}
for _, v in ipairs(ups:GetChildren()) do have[tonumber(v.Name)] = true end

for id, data in pairs(lib) do
    if type(id) == "number" and type(data) == "table" and not have[id] then
        local lv = Instance.new("NumberValue")   -- 等级表（UI 依据）
        lv.Name, lv.Value, lv.Parent = tostring(id), 35, ups

        local root = pd.Unlocked.Unit:FindFirstChild(data.Type)
        if root then                              -- 解锁标记
            local nv = Instance.new("NumberValue")
            nv.Name, nv.Value, nv.Parent = "UnitID", id, root
        end
    end
end

game.ReplicatedStorage.Events.BindableEvents.MenuSelect:Fire("Loadout") -- 刷新界面