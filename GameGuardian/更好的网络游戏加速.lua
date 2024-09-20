local jilu = false
local accSpeed = nil
local accDur = nil
local decSpeed = 0.45

-- 提示设置
function TS()
    gg.alert("请先设置加速倍速和加速时间。", "确定", nil, nil)
    showMenu()
end

-- 初始化加速倍速和持续时间
function initVals()
    local speedInp = gg.prompt({"请输入加速倍速（默认1.2）:"}, {"1.2"})
    local durInp = gg.prompt({"请输入加速持续时间（秒，默认30秒）:"}, {"30"})
    local newSpeed = tonumber(speedInp[1]) or 1.2
    local newDur = tonumber(durInp[1]) or 30
    accSpeed = newSpeed
    accDur = newDur
    jilu = true
end

-- 计算补偿时间
function calcCompTime()
    if not accSpeed or not accDur then
        TS()
        return
    end
    local speed = accSpeed
    local dur = accDur
    local compTimeMs = math.floor((dur * 1000) / speed)
    local timeParts = formatTime(compTimeMs)
    local msg = string.format(
        "加速倍率：%s倍\n加速时长：%d小时%d分%d秒0毫秒\n\n根据计算得知加速：%s倍 加速时间为：%d秒需要进行服务器补偿时长为：\n%d小时%d分%d秒%d毫秒",
        speed,
        math.floor(dur / 3600),
        math.floor((dur % 3600) / 60),
        dur % 60,
        speed,
        dur,
        timeParts.hours,
        timeParts.minutes,
        timeParts.seconds,
        timeParts.milliseconds
    )
    gg.alert(msg, "确定", nil, nil)
end

-- 格式化时间
function formatTime(ms)
    local hrs = math.floor(ms / 3600000)
    local mins = math.floor((ms % 3600000) / 60000)
    local secs = math.floor(((ms % 3600000) % 60000) / 1000)
    local msecs = ms % 1000
    return {hours = hrs, minutes = mins, seconds = secs, milliseconds = msecs}
end

-- 单次加速与减速补偿
function accelOnce()
    if not accSpeed or not accDur then
        TS()
        return
    end
    gg.setSpeed(accSpeed)
    gg.toast("加速中：" .. accSpeed .. "倍速")
    gg.sleep(accDur * 1000)
    local compTimeMs = math.floor((accDur * 1000) / accSpeed * decSpeed)
    gg.setSpeed(decSpeed)
    gg.toast("减速补偿中：" .. decSpeed .. "倍速")
    gg.sleep(compTimeMs)
    gg.setSpeed(1.0)
    gg.toast("速度已重置")
end

-- 循环加速
function loopAccel()
    if not accSpeed or not accDur then
        TS()
        return
    end
    
    local confirmResult = gg.alert("确认开启循环加速吗？", "确定", "取消")
    if confirmResult ~= 1 then
        return
    end
    
    while true do
        gg.setSpeed(accSpeed)
        gg.toast("加速中：" .. accSpeed .. "倍速")
        gg.sleep(accDur * 1000)
        local compTimeMs = math.floor((accDur * 1000) / accSpeed * decSpeed)
        gg.setSpeed(decSpeed)
        gg.toast("减速补偿中：" .. decSpeed .. "倍速")
        gg.sleep(compTimeMs)
        gg.setSpeed(1.0)
        gg.toast("速度已重置")
    end
end

-- 显示主菜单
function showMenu()
    if not jilu then
        initVals()
    end
    local ch = gg.choice({
        "设置",
        "计算补偿时间",
        "单次加速",
        "循环加速",
        "退出"
    }, nil, "请选择操作")
    if ch == 1 then
        initVals()
    elseif ch == 2 then
        calcCompTime()
    elseif ch == 3 then
        accelOnce()
    elseif ch == 4 then
        loopAccel()
    elseif ch == 5 then
        print("程序已结束")
        os.exit()
    end
end

function main()
    initVals()
    showMenu()
end

local WMX = 0
while true do
    if gg.isVisible(true) then
        WMX = 1
        gg.setVisible(false)
    end
    gg.clearResults()
    if WMX == 1 then
        showMenu()
        WMX = 0
    end
end
