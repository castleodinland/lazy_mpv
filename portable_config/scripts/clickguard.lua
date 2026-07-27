-- clickguard.lua
-- 分离鼠标左键单击与双击，避免“双击全屏”误触“单击暂停/播放”。
--
-- 策略（单击零延迟 + 双击还原）：
--   单击按下时：记录当前 pause 状态(paused0)，立即把它置反（暂停↔播放），并进入
--     一个长度为 ARM 的“武装窗口”。
--   若武装窗口内收到 MBTN_LEFT_DBL（双击）：把 pause 还原为 paused0，再切换全屏。
--     于是双击对暂停状态的净影响为 0，只切换全屏。
--   若武装窗口内未收到双击（即真单击）：暂停状态保持已置反的值，单击生效，零延迟。
--   第二次按下若落在武装窗口内，不再次置反（交给双击事件还原），避免来回 toggle。
--
-- ARM 取 mpv 的 input-doubleclick-time（双击判定窗口，默认 300ms），保证 mpv 认定
-- 为双击的两次按下一定落在武装窗口内。可在 script-opts.conf 用
--   script-opts-append = clickguard-arm_window=0.3
-- 覆盖（单位秒，0 表示自动取 input-doubleclick-time）。

local msg = require('mp.msg')
local opt = require('mp.options')

local opts = { arm_window = 0 }
opt.read_options(opts, 'clickguard')

local ARM = tonumber(opts.arm_window)
if not ARM or ARM <= 0 then
	ARM = (mp.get_property_number('input-doubleclick-time', 300) or 300) / 1000
end

local armed = false        -- 是否处于“可能成为双击”的武装窗口
local paused0 = false      -- 按下前的 pause 状态（用于双击时还原）
local arm_timer = nil

local function disarm()
	armed = false
	if arm_timer then arm_timer:kill(); arm_timer = nil end
end

-- 兼容两种回调签名：function(event) 或 function(name, event)
local function evt_arg(a, b)
	return type(a) == 'table' and a or b
end

-- 单击：立即置反 pause（零延迟），并进入武装窗口
local function on_single(a, b)
	local e = evt_arg(a, b)
	if not e or (e.event ~= 'down' and e.event ~= 'press') then return end
	if armed then return end  -- 双击中的第二次按下：不重复 toggle，等双击事件还原
	paused0 = mp.get_property_native('pause', false)
	armed = true
	mp.set_property_native('pause', not paused0)
	arm_timer = mp.add_timeout(ARM, disarm)
end

-- 双击：还原单击造成的暂停变化，再切换全屏
local function on_double(a, b)
	local e = evt_arg(a, b)
	if not e or (e.event ~= 'down' and e.event ~= 'press') then return end
	if armed then
		mp.set_property_native('pause', paused0)
		disarm()
	end
	mp.command('cycle fullscreen')
end

mp.add_key_binding(nil, 'single', on_single, { complex = true })
mp.add_key_binding(nil, 'double', on_double, { complex = true })
msg.info(string.format('clickguard 已加载：单击零延迟，双击还原+全屏（武装窗口 %.0fms）', ARM * 1000))
