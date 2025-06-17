--[ Defines ]-------------------------------------------------------------

hyper = { "⌘", "⌥", "⌃" } -- caps lock held down
shyper = { "⌘", "⌥", "⇧", "⌃" } -- caps lock held down, with shift
hs.window.animationDuration = 0

--[ Functions ]---------------------------------------------------------
function findOrLaunch(a)
	local app = hs.application.find(a)
	if not app then
		hs.application.launchOrFocus(a)
	end
	return hs.application.find(a)
end

function fancyNotify(t, m)
	hs.notify.new({ title = t, informativeText = m }):send():release()
end

--[ Bindings ]---------------------------------------------------------

-- hyper shortcuts
hs.fnutils.each({
	{
		key = "t",
		func = function()
			myTerm = findOrLaunch("ghostty")
			myTerm:selectMenuItem({ "Shell", "New Window" })
		end,
	},
	{
		key = "b",
		func = function()
			hs.execute("/Applications/Firefox.app/Contents/MacOS/firefox -P")
			-- ffox = hs.appfinder.appFromName("Firefox")
			-- ffox:selectMenuItem({ "File", "New Window" })
			-- ffox:activate()
		end,
	},
	{
		key = "z",
		func = function()
			finder = hs.appfinder.appFromName("Finder")
			finder:selectMenuItem({ "File", "New Finder Window" })
			finder:activate()
		end,
	},
}, function(object)
	hs.hotkey.bind(hyper, object.key, object.func)
end)

-- shyper shoutcuts
hs.fnutils.each({
	{
		key = "space",
		func = function()
			os.execute("pmset displaysleepnow")
		end,
	},
}, function(object)
	hs.hotkey.bind(shyper, object.key, object.func)
end)

--[ grid ]---------------------------------------------------------------------
-- home made grid system works with hammerspoon's grid

hs.grid.setGrid("2x2")
hs.grid.setMargins("0x0")

function moveWindow(x, y, w, h)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + (max.w * x)
	f.y = max.y + (max.h * y)
	f.w = max.w * w
	f.h = max.h * h
	win:setFrame(f)
end

hs.hotkey.bind(hyper, "h", function()
	moveWindow(0.0, 0.0, 0.5, 1.0)
end)
-- hs.hotkey.bind(hyper, "j", function()
-- 	moveWindow(0.0, 0.0, 1.0, 1.0)
-- end)
hs.hotkey.bind(hyper, "l", function()
	moveWindow(0.5, 0.0, 0.5, 1.0)
end)
hs.hotkey.bind(hyper, "k", function()
	moveWindow(0.0, 0.0, 1.0, 1.0)
end)

hs.loadSpoon("ClipboardTool")
if spoon.ClipboardTool then
	-- spoon.ClipboardTool.hist_size = 10
	spoon.ClipboardTool.hist_size = 50
	spoon.ClipboardTool.show_copied_alert = false
	spoon.ClipboardTool.show_in_menubar = false
	spoon.ClipboardTool:start()
	spoon.ClipboardTool:bindHotkeys({
		toggle_clipboard = { hyper, "v" },
	})
end

-- Set up the logger
local log = hs.logger.new("WindowMover", "info")

-- Function to get spaceId by space name
function getSpaceIdByName(spaceName)
	local spaceNames = hs.spaces.missionControlSpaceNames()
	for uuid, desktops in pairs(spaceNames) do
		log.i("UUID: " .. uuid) -- Log the UUID
		for index, name in pairs(desktops) do
			log.i("Index: " .. index .. ", Name: " .. tostring(name)) -- Log the index and name
			if name == spaceName then
				log.i("Found spaceId for " .. spaceName .. ": " .. index)
				return index
			end
		end
	end
	log.w("Space not found: " .. spaceName)
	return nil
end

-- Function to move focused window to a specific space
function moveFocusedWindowToSpace(spaceNumber)
	local spaceName = "Desktop " .. spaceNumber
	log.i("Attempting to move window to " .. spaceName)
	local spaceId = getSpaceIdByName(spaceName)
	if spaceId then
		local focusedWindow = hs.window.focusedWindow()
		if focusedWindow then
			log.i("Moving window " .. focusedWindow:title() .. " to spaceId " .. spaceId)
			hs.spaces.moveWindowToSpace(focusedWindow:id(), spaceId)
		else
			log.w("No focused window")
			hs.alert.show("No focused window")
		end
	else
		log.w("Space not found: " .. spaceName)
		hs.alert.show("Space not found: " .. spaceName)
	end
end

-- Bind keys cmd + shift + 1-6
for i = 1, 6 do
	hs.hotkey.bind({ "cmd", "shift" }, tostring(i), function()
		log.i("Hotkey pressed: cmd + shift + " .. i)
		moveFocusedWindowToSpace(i)
	end)
end
