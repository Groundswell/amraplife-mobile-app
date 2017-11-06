
---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

local Composer = require( "composer" )
local scene = Composer.newScene()

local Widget = require( "widget" )
Widget.setTheme( "widget_theme_android_holo_dark" )


local Btn = require( 'ui.btn' )
local Theme = require( 'ui.theme' )
local UI = require( 'ui.factory' )
local TextBox = require( 'ui.text_box' )
local TextField = require( 'ui.text_field' )

local json = require( 'json' )
local FileUtils = require( "utilities.file" )

local Debug = require( 'utilities.debug' )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}


-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view

end

function scene:show( event )

	if event.phase == 'did' then
		print( Composer.getVariable( 'prevScene' ) )
	end
	
	local group = self.view

	if event.phase == "will" then
		Composer.setVariable( 'prevScene', 'scenes.home' )

		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'Life Meter',
			x 		= centerX,
			y 		= 0,
			width 	= screenWidth,
			height 	= 50
			})


		ui.title = TextField:new({
			parent 	= group,
			x 		= centerX,
			y 		= 115,
			width 	= screenWidth - 80,
			height 	= 40,
			cornerRadius 	= 4
			})

	end
	
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then
		group.y = 0
		display.remove( ui.title )
	end
	
end

function scene:destroy( event )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene

