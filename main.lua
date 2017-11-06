-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local device = require( 'utilities.device' )

centerX = display.contentCenterX
centerY = display.contentCenterY
screenWidth = display.contentWidth
screenHeight = display.contentHeight

connectionStatus = 'offline'


default_settings = {
	audioVolume = 0.5,
	countIn 	= 3,
}

local Composer = require "composer"
local Theme = require( 'ui.theme' )

display.setDefault( 'background', unpack( Theme.colors.coal ) )

print ( "Physical Device Width: " .. device.physicalW )
print ( "Physical Device Height: " .. device.physicalH ) 

print( "Screen Height: " .. screenHeight )
print( "Screen Width: " .. screenWidth )

print( "Scale Factor: " .. display.pixelWidth / display.actualContentWidth )

display.setStatusBar( display.TranslucentStatusBar )

-- handle android key events
local function onKeyPress( event )

	local phase = event.phase
	local key_name = event.keyName

	-- nest these crazy ifs so we always return true s oAndroid doesn't grab the 'down' phase
	if key_name == "back" and phase == 'up' then
		if Composer.getVariable( 'overlay' ) then
				Composer.hideOverlay( 'slideRight' )
		else
			if Composer.getVariable( 'prevScene' ) and not( Composer.getSceneName( "current" ) == 'scenes.home' ) then
				Composer.gotoScene( Composer.getVariable( 'prevScene' ) )
			else
				native.requestExit()
			end
		end
		return true
	else
		return false
	end
end
--add the key callback
Runtime:addEventListener( "key", onKeyPress )

Composer.gotoScene( "scenes.home" )

