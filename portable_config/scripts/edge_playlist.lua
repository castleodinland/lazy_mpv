--[[
edge_playlist.lua — 左侧边缘触发文件浏览器（potplayer 风格）

功能：
  - 鼠标移动到屏幕左侧边缘并短暂停留 → 自动打开 uosc 文件浏览器
    （菜单贴左侧、高度铺满播放器上下沿；定位到当前播放文件所在目录，高亮当前文件，点击即切换播放）
  - 鼠标移出列表矩形（上/下/左/右任一方向）或离开窗口 → 自动收回
  - 仅作用于“由本脚本触发打开”的文件浏览器，不影响用户通过按钮/快捷键手动打开的菜单
  - 保持 uosc 文件浏览器原有 UI 完全不变，只新增这一种触发方式

依赖：
  - uosc 脚本（通过 user-data/uosc/menu/type 与 user-data/uosc/menu/rect 通信）
  - Menu.lua 已在 update_coordinates / destroy 中暴露并清除 rect
  - Menu.lua 已对 open-file 类型菜单做贴左+全高布局处理

可选配置（在 script-opts.conf 中添加，均可省略，使用下方默认值）：
  script-opts-append = edge_playlist-enabled=yes
  script-opts-append = edge_playlist-edge_width=100
  script-opts-append = edge_playlist-open_delay=0.2
  script-opts-append = edge_playlist-close_delay=0.4
  script-opts-append = edge_playlist-edge_min_y_ratio=0
  script-opts-append = edge_playlist-edge_max_y_ratio=0.85
  script-opts-append = edge_playlist-debug=no

排查不触发问题时，临时设 edge_playlist-debug=yes，OSD 会实时显示鼠标位置与距左边缘的距离。
]]

local mp = mp
local msg = require('mp.msg')
local opt = require('mp.options')

-- 触发的菜单类型：uosc 的文件浏览器（open-file），会自动定位到当前播放文件所在目录
local MENU_TYPE = 'open-file'

local opts = {
	edge_width = 100,      -- 左边缘触发热区宽度（OSD 像素）
	open_delay = 0.2,      -- 鼠标停留多久后打开（秒）
	close_delay = 0.4,     -- 鼠标移出列表后多久关闭（秒）
	edge_min_y_ratio = 0,  -- 热区起始 y 占屏幕高度的比例（0=顶部）
	edge_max_y_ratio = 0.85,-- 热区结束 y 占屏幕高度的比例（避开底部控制栏）
	enabled = true,        -- 总开关
	debug = false,         -- 调试模式：在 OSD 实时显示鼠标位置与距左边缘的距离
}
opt.read_options(opts, 'edge_playlist')

-- 规范化各选项类型（兼容 yes/no/true/false 字符串）
local function to_bool(v) return type(v) == 'string' and (v:lower() == 'yes' or v == 'true') or v == true end
if type(opts.enabled) == 'string' then opts.enabled = to_bool(opts.enabled) end
if type(opts.debug) == 'string' then opts.debug = to_bool(opts.debug) end
opts.edge_width = tonumber(opts.edge_width) or 100
opts.open_delay = tonumber(opts.open_delay) or 0.2
opts.close_delay = tonumber(opts.close_delay) or 0.4
opts.edge_min_y_ratio = tonumber(opts.edge_min_y_ratio) or 0
opts.edge_max_y_ratio = tonumber(opts.edge_max_y_ratio) or 0.85

-- 运行时状态
local S = {
	open_pending = false,   -- 是否正在等待“打开”计时
	close_pending = false,  -- 是否正在等待“关闭”计时
	opened_by_edge = false, -- 当前菜单是否由本脚本触发打开
}

-- 打开计时器：鼠标在边缘停留 open_delay 秒后触发打开
local open_timer = mp.add_timeout(opts.open_delay, function()
	S.open_pending = false
	-- 仅在当前没有任何菜单打开时才触发，避免覆盖用户正在使用的菜单
	if not mp.get_property_native('user-data/uosc/menu/type') then
		S.opened_by_edge = true
		msg.info('触发打开文件浏览器')
		mp.command('script-binding uosc/open-file')
	end
end)
open_timer:kill()

-- 关闭计时器：鼠标移出列表 close_delay 秒后触发关闭
local close_timer = mp.add_timeout(opts.close_delay, function()
	S.close_pending = false
	if S.opened_by_edge and mp.get_property_native('user-data/uosc/menu/type') == MENU_TYPE then
		mp.commandv('script-message', 'close-menu', MENU_TYPE)
		S.opened_by_edge = false
	end
end)
close_timer:kill()

-- 当菜单被关闭（无论何种方式）时，重置状态
mp.observe_property('user-data/uosc/menu/type', 'native', function(_, mtype)
	if not mtype then
		S.opened_by_edge = false
		S.close_pending = false
		close_timer:kill()
	end
end)

-- 判断鼠标是否处于左边缘热区
local function in_left_edge(x, y, osd_w, osd_h)
	return x <= opts.edge_width
		and y >= osd_h * opts.edge_min_y_ratio
		and y <= osd_h * opts.edge_max_y_ratio
end

-- 判断鼠标是否在列表矩形内
local function in_menu_rect(x, y, rect)
	return x >= rect.ax and x <= rect.bx and y >= rect.ay and y <= rect.by
end

-- debug 模式：在 OSD 实时显示鼠标位置与距左边缘的距离（节流，避免刷屏）
local last_debug_time = 0
local function debug_show(x, y, osd_w, osd_h, mtype, rect)
	if not opts.debug then return end
	local now = mp.get_time()
	if now - last_debug_time < 0.2 then return end
	last_debug_time = now
	local dist = x  -- 距左边缘的像素数
	local in_zone = in_left_edge(x, y, osd_w, osd_h)
	local in_rect = rect and in_menu_rect(x, y, rect) or false
	local y_pct = osd_h > 0 and math.floor(y / osd_h * 100) or 0
	local pending = S.open_pending and '计时中' or '否'
	local closing = S.close_pending and '关闭中' or '否'
	mp.osd_message(string.format(
		'edge_playlist 调试\n鼠标 (%d, %d)  距左边 %dpx  热区宽 %dpx\n在热区: %s  在列表内: %s\ny占比: %d%% (上限%d%%)  待打开: %s  关闭中: %s  菜单: %s',
		x, y, dist, opts.edge_width, tostring(in_zone), tostring(in_rect), y_pct, math.floor(opts.edge_max_y_ratio * 100), pending, closing, tostring(mtype)
	), 1)
end

-- 鼠标位置处理（核心逻辑）
mp.observe_property('mouse-pos', 'native', function(_, mouse)
	if not opts.enabled then return end

	-- 鼠标离开窗口：取消待打开；若菜单由边缘打开，则触发关闭
	if not mouse or not mouse.hover then
		S.open_pending = false
		open_timer:kill()
		if S.opened_by_edge and not S.close_pending then
			S.close_pending = true
			close_timer:kill()
			close_timer:resume()
		end
		return
	end

	local x, y = mouse.x, mouse.y
	local osd_w, osd_h = mp.get_osd_size()
	if not osd_w or osd_w <= 0 then return end

	local mtype = mp.get_property_native('user-data/uosc/menu/type')
	local rect = mp.get_property_native('user-data/uosc/menu/rect')

	if mtype == MENU_TYPE and S.opened_by_edge and rect then
		-- 文件浏览器已由本脚本打开（贴左侧全高显示）：
		-- 鼠标在列表矩形内 → 保持（取消关闭）
		-- 鼠标在列表矩形外（任何方向）→ 触发收回
		if in_menu_rect(x, y, rect) then
			if S.close_pending then
				S.close_pending = false
				close_timer:kill()
			end
		else
			if not S.close_pending then
				S.close_pending = true
				close_timer:kill()
				close_timer:resume()
			end
		end
		-- 已打开，取消任何待打开
		if S.open_pending then
			S.open_pending = false
			open_timer:kill()
		end
	elseif not mtype then
		-- 当前没有菜单打开：检测左边缘热区
		if in_left_edge(x, y, osd_w, osd_h) then
			if not S.open_pending then
				S.open_pending = true
				open_timer:kill()
				open_timer.timeout = opts.open_delay
				open_timer:resume()
			end
		else
			if S.open_pending then
				S.open_pending = false
				open_timer:kill()
			end
		end
	else
		-- 打开的是其他类型菜单（如字幕、章节等）：不干预，仅取消待打开
		if S.open_pending then
			S.open_pending = false
			open_timer:kill()
		end
	end

	debug_show(x, y, osd_w, osd_h, mtype, rect)
end)

msg.info('edge_playlist 已加载：左边缘触发文件浏览器（potplayer 风格） edge_width=' .. opts.edge_width .. ' debug=' .. tostring(opts.debug))
