--[[ Times Illusion 登场音乐 v4 (客户端，含音频自动下载 + 死亡停音乐)
     用法：
       getgenv().TimesIllusionPlay()            -- 手动播一次（无视 oncePerGame）
       getgenv().TimesIllusionStopAll()         -- 立刻停全部音乐
       getgenv().TimesIllusionReload()          -- 重新检查/下载音频并重建 SoundId
       getgenv().TimesIllusionCfg.stopOnBaseRemoved = false
       getgenv().TimesIllusionCfg.stopOnUnitDeath   = false   -- 关掉"单位死亡停音乐"
       getgenv().__TI_Cleanup()                 -- 全部卸载
--]]

local SoundService = game:GetService("SoundService")

local cfg = {
    path        = "Times_Illusion_from_19s.mp3",
    units       = {"Chronos"},
    anyUnit     = false,
    volume      = 2,
    oncePerGame = true,
    stopMusic   = true,
    stopOnBaseRemoved = true,
    baseNames   = {"Base", "BaseCore", "BaseHealth", "Goal", "Nexus"},
    settleDelay = 0.8,
    soundName   = "TimesIllusion_Once",

    ---- 新增：单位死亡相关 ----
    stopOnUnitDeath  = true,  -- 单位死亡 / 模型被移除时停止音乐
    replayAfterDeath = true,  -- 场上没有存活单位后，下一只登场可重新播放

    -- 下载相关
    downloadUrl  = "",                                       -- ★ 填 mp3 直链，留空则不下载
    autoDownload = true,
    forceDownload = false,                                   -- true = 每次上车都重下覆盖
    minBytes     = 20 * 1024,
    androidDir   = "/storage/emulated/0/Delta/Workspace",
}
getgenv().TimesIllusionCfg = cfg

--====================== 音频文件自动下载 ======================--
local function fileSize(p)
    local ok, d = pcall(readfile, p)
    if ok and type(d) == "string" then return #d end
    return -1
end

local function ensureDir()
    if type(isfolder) ~= "function" or type(makefolder) ~= "function" then return end
    pcall(function()
        if not isfolder("/storage/emulated/0/Delta") then makefolder("/storage/emulated/0/Delta") end
        if not isfolder(cfg.androidDir) then makefolder(cfg.androidDir) end
    end)
end

local function fetchBody(url)
    local env = (getgenv and getgenv()) or {}
    local req = rawget(env, "request") or request
    if type(req) == "function" then
        local ok, r = pcall(req, {Url = url, Method = "GET"})
        if ok and type(r) == "table" and type(r.Body) == "string" and #r.Body > 0 then return r.Body end
    end
    local hr = rawget(env, "http_request") or http_request
    if type(hr) == "function" then
        local ok, r = pcall(hr, {Url = url, Method = "GET"})
        if ok and type(r) == "table" and type(r.Body) == "string" and #r.Body > 0 then return r.Body end
        local ok2, r2 = pcall(hr, url, "GET")
        if ok2 and type(r2) == "string" and #r2 > 0 then return r2 end
    end
    if game.HttpGet then
        local ok, r = pcall(function() return game:HttpGet(url, true) end)
        if ok and type(r) == "string" and #r > 0 then return r end
    end
    return nil
end

local audioFile, audioWhy = nil, "未检查"

local function ensureAudioFile()
    if not cfg.forceDownload then
        local size = fileSize(cfg.path)
        if size >= cfg.minBytes then
            return cfg.path, ("已存在 %d 字节，跳过下载"):format(size)
        end
    end
    if not cfg.autoDownload then
        return fileSize(cfg.path) > 0 and cfg.path or nil, "文件缺失且 autoDownload = false"
    end
    if cfg.downloadUrl == "" then
        local size = fileSize(cfg.path)
        if size > 0 then return cfg.path, ("已存在 %d 字节（未配置下载地址）"):format(size) end
        return nil, "文件缺失，且 cfg.downloadUrl 未填写"
    end

    ensureDir()
    print("[TI] 开始下载音频: " .. cfg.downloadUrl)
    local body = fetchBody(cfg.downloadUrl)
    if not body then
        return nil, "下载失败（HTTP 无返回，检查直链/执行器 Http 权限）"
    end
    if #body < cfg.minBytes then
        return nil, ("下载内容过小 (%d 字节)，可能是错误页"):format(#body)
    end

    local ok1, err1 = pcall(writefile, cfg.path, body)
    if ok1 and fileSize(cfg.path) >= cfg.minBytes then
        print(("[TI] 下载完成 -> %s (%d 字节)"):format(cfg.path, #body))
        return cfg.path, "已下载"
    end

    local abs = cfg.androidDir .. "/" .. cfg.path
    local ok2, err2 = pcall(writefile, abs, body)
    if ok2 and fileSize(abs) >= cfg.minBytes then
        print(("[TI] 下载完成 -> %s (%d 字节)"):format(abs, #body))
        return abs, "已下载（绝对路径）"
    end

    return nil, "写入失败: " .. tostring(err1) .. " / " .. tostring(err2)
end

audioFile, audioWhy = ensureAudioFile()
print("[TI] 音频检查: " .. tostring(audioWhy))
--============================================================--

if getgenv().__TI_Cleanup then pcall(getgenv().__TI_Cleanup) end

local conns = {}
local function track(c)
    if c then conns[#conns + 1] = c end
    return c
end

local soundId

local function buildSoundId()
    local target = audioFile or cfg.path
    local ok, res = pcall(getcustomasset, target)
    if ok then
        soundId = res
        return true, nil
    end
    soundId = nil
    local msg = tostring(res) .. " | 文件检查: " .. tostring(audioWhy) ..
                " | 目标: " .. tostring(target) ..
                " | 文件必须位于执行器 workspace 目录: " .. cfg.path
    warn("[TI] getcustomasset 失败: " .. msg)
    return false, msg
end

buildSoundId()

local current, played = nil, false

local function destroySound(s)
    if s and s.Parent then pcall(function() s:Destroy() end) end
end

local function stopAllMusic()
    for _, d in ipairs(SoundService:GetDescendants()) do
        if d:IsA("Sound") and d.IsPlaying then
            pcall(function() d:Stop() end)
        end
    end
end

local function stopMusicNow()
    if current then destroySound(current); current = nil end
    stopAllMusic()
end

local function play(force)
    if not soundId then return nil, "SoundId 未就绪（getcustomasset 失败）" end
    if cfg.oncePerGame and played and not force then return nil, "本局已播过" end
    played = true

    if cfg.stopMusic then stopAllMusic() end

    destroySound(current)
    for _, d in ipairs(SoundService:GetChildren()) do
        if d:IsA("Sound") and d.Name == cfg.soundName then destroySound(d) end
    end

    local s = Instance.new("Sound")
    current = s
    pcall(function()
        s.Name    = cfg.soundName
        s.SoundId = soundId
        s.Volume  = cfg.volume
        s.Looped  = false
        s.Parent  = SoundService
    end)

    track(s.Ended:Once(function()
        if current == s then current = nil end
        destroySound(s)
    end))

    s:Play()
    return s
end

local function isUnit(m)
    if not m:IsA("Model") then return false end
    if not (m:FindFirstChildOfClass("Humanoid") or m:FindFirstChild("HumanoidRootPart")) then
        return false
    end
    if cfg.anyUnit then return true end
    for _, n in ipairs(cfg.units) do
        if m.Name == n then return true end
    end
    return false
end

local function resetHandled()
    _G.__TI_handled = setmetatable({}, {__mode = "k"})
    return _G.__TI_handled
end
local handled = resetHandled()

--====================== 单位死亡监听 ======================--
local function anyUnitAlive()
    for m in pairs(handled) do
        if m and m.Parent then return true end
    end
    return false
end

local function onUnitGone(m, why)
    if not m then return end
    handled[m] = nil

    if cfg.stopOnUnitDeath then
        print(("[TI] 单位 %s %s，停止音乐"):format(m.Name, tostring(why or "消失")))
        stopMusicNow()
    end

    if cfg.replayAfterDeath and not anyUnitAlive() then
        played = false     -- 下一只同名单单位登场可以再放
    end
end

local function hookUnit(m)
    if not cfg.stopOnUnitDeath then return end
    if m:GetAttribute("TI_deathHooked") then return end

    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum then
        -- Humanoid 可能还没复制过来，稍后重试
        task.delay(cfg.settleDelay, function()
            if m.Parent then hookUnit(m) end
        end)
        return
    end
    if m:GetAttribute("TI_deathHooked") then return end
    m:SetAttribute("TI_deathHooked", true)

    local done = false
    local function fire(why)
        if done then return end
        done = true
        pcall(function() m:SetAttribute("TI_deathHooked", false) end)
        onUnitGone(m, why)
    end

    pcall(function()
        track(hum.Died:Connect(function() fire("死亡") end))
        track(hum:GetPropertyChangedSignal("Health"):Connect(function()
            if hum.Health <= 0 then fire("死亡") end
        end))
    end)
    track(m.Destroying:Connect(function() fire("被移除") end))
    track(m.AncestryChanged:Connect(function(_, parent)
        if not parent then fire("被移除") end
    end))
end
--==========================================================--

local function check(m)
    if not isUnit(m) then return false end
    hookUnit(m)                    -- 先挂死亡监听（不管之前有没有播过）
    if handled[m] then return false end
    handled[m] = true
    if not soundId then buildSoundId() end
    play()
    return true
end

track(workspace.DescendantAdded:Connect(function(inst)
    if inst:IsA("Model") then
        if check(inst) then return end
        task.delay(cfg.settleDelay, function()
            if inst.Parent then check(inst) end
        end)
    elseif inst:IsA("Humanoid") or inst:IsA("BasePart") then
        task.delay(cfg.settleDelay, function()
            local m = inst:FindFirstAncestorOfClass("Model")
            if m and m.Parent then check(m) end
        end)
    end
end))

getgenv().TimesIllusionScan = function()
    for _, m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") then check(m) end
    end
end
getgenv().TimesIllusionScan()

local function isBase(m)
    local lname = string.lower(m.Name)
    for _, n in ipairs(cfg.baseNames) do
        if lname == string.lower(n) then return true end
    end
    return string.find(lname, "base", 1, true) ~= nil
end

track(workspace.DescendantRemoving:Connect(function(inst)
    如果      不..toString(audioWhy)..not cfg.stopOnBaseRemoved then return end
如果inst:Isa("型号")和isBase(inst)，则ifinst:Isa("Model")and isBase(inst)则if inst:IsA("Model") and isBase(inst) then
getgenv().TimesIllusionStopAll()
played=false
handled=resetHandled()
结束endend
结束))))

getgenv().TimesIllusionPlay=函数()返回play(true)结束函数()返回间隙(真)结束true)结束function() return play(true) end
getgenv().TimesIllusionStop=函数()函数()function()
如果当前，则pcall(功能()电流：停止()结束)结束if current then pcall(function()current:Stop()end)endif current then pcall(function() current:Stop() end) end
结束
getgenv().TimesIllusionStopAll=函数()函数()function()
stopMusicNow()
结束

getgenv().TimesIllusionReload=函数()函数()function()
AudioFile，audioWhy=确保音频文件()
打印("[TI]重新检查："..toString(audioWhy)"[TI]重新检查："..toString(audioWhy)"[TI]重新检查："..toString(audioWhy)"[TI] 重新检查: " .. tostring(audioWhy))
本地正常，消息=buildSoundId()本地ok，消息=buildSoundId()local ok, msg = buildSoundId()
返回确定，消息返回确定，消息return ok, msg
结束

getgenv().__TI_Cleanup=函数()函数()function()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) endfor _, c in ipairs(conns) do pcall(function() c:Disconnect() end) endfor _, c in ipairs(conns) do pcall(function() c:Disconnect() end) endfor _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
Conns={}
如果当前，则destroySound(当前)；当前=nil结束如果当前，则destroySound(当前)；当前=nil结束nil结束if current then destroySound(current); current = nil end
getgenv().TimesIllusionPlay=nilnil
getgenv().TimesIllusionStopAll=nilnil
getgenv().TimesIllusionStop=nilnil
getgenv().TimesIllusionScan=nilnil
getgenv().TimesIllusionReload=nilnil
getgenv().TimesIllusionCleanup=零
getgenv().__TI_Cleanup=零
print("[TI]已卸载")"[TI]已卸载")"[TI]已卸载")"[TI] 已卸载")
结束

timesIllusionCleanup=函数()getgenv()。__TI_Cleanup()结束函数()getgenv()。__TI_Cleanup()结束function() getgenv().__TI_Cleanup() end

打印("[TI]已挂载|触发单位："...."[TI]已挂载|触发单位：".. ..
(cfg.anyUnit和"(任意单位)"或table.concat(cfg.单位，"，"))。和"(任意单位)"或table.concat(cfg.units，"，"))。"(任意单位)"或table.concat(cfg.units，"，"))。and "(任意单位)" or table.concat(cfg.units, ", ")) ..
"|死亡停乐："..toString(cfg.stopOnUnitDeath).."|死亡停乐："..toString(cfg.stopOnUnitDeath)....toString(cfg.stopOnUnitDeath).." | 死亡停乐: " .. tostring(cfg.stopOnUnitDeath) ..
“|声：”...tostring(audioWhy).."|声音："...tostring(audioWhy).....tostring(audioWhy).." | 音频: "..toString(audioWhy)..
“|SoundId：”。。toString(soundId)“”|SoundId：“”。。toString(soundId)
