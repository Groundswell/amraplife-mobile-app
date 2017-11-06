local sysInfo = system.getInfo

local M = {}

-- THIS IS TO FIND OUT IF THE APP RUNS ON A TABLET OR A SMALL DISPLAY
-- IF WE HAVE A TABLET, SCALE DOWN THE GUI TO THE HALF, OTHERWISE THE
-- WIDGETS APPEAR TOO BIG. YOU CAN USE ANY SCALE, BUT .5 IS FINE HERE.
-- CHANGING THE SCALE OF A WIDGET DOES NOT CHANGE ITS WIDTH OR HEIGHT,
-- IT JUST SCALES THE WIDGET GRAPHICS USED (BORDERS, ICONS, TEXT ETC.)
M.physicalW = math.round( (display.contentWidth  - display.screenOriginX*2) / display.contentScaleX)
M.physicalH = math.round( (display.contentHeight - display.screenOriginY*2) / display.contentScaleY)

M.isTablet     = false; if M.physicalW >= 1024 or M.physicalH >= 1024 then M.isTablet = true end
M.GUIScale     = M.isTablet == true and .5 or 1.0

-- Set up some defaults...
M.isApple = false
M.isAndroid = false
M.isGoogle = false
M.isKindleFire = false
M.isNook = false
M.is_iPad = false
M.isTall = false
M.isSimulator = false

local model = sysInfo( "model" )

-- Are we on the Simulator?
if (  sysInfo( "environment" ) == "simulator" ) then
	M.isSimulator = true
end

if ( display.pixelHeight/display.pixelWidth > 1.5 ) then
	M.isTall = true
end

-- Now identify the Apple family of devices:
if ( string.sub( model, 1, 2 ) == "iP" ) then 
	-- We are an iOS device of some sort
	M.isApple = true

	if ( string.sub( model, 1, 4 ) == "iPad" ) then
		M.is_iPad = true
	end
else
	 -- Not Apple, so it must be one of the Android devices
	M.isAndroid = true

	-- Let's assume we are on Google Play for the moment
	M.isGoogle = true

	-- All of the Kindles start with "K", although Corona builds before #976 returned
	-- "WFJWI" instead of "KFJWI" (this is now fixed, and our clause handles it regardless)
	if ( model == "Kindle Fire" or model == "WFJWI" or string.sub( model, 1, 2 ) == "KF" ) then
		M.isKindleFire = true
		M.isGoogle = false  --revert Google Play to false
	end

end

return M