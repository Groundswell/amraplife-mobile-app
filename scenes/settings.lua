---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

local Composer = require( "composer" )
local scene = Composer.newScene()

local Btn = require( 'ui.btn' )
local Theme = require( 'ui.theme' )
local UI = require( 'ui.factory' )
local TextField = require( 'ui.text_field' )

local Widget = require( 'widget' )
Widget.setTheme( "widget_theme_android_holo_dark" )

local FileUtils = require( "utilities.file" )
local Debug = require( "utilities.debug" )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}
local countin_field, volume_slider


-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view
end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then
		Composer.setVariable( 'prevScene', 'scenes.home' )

		reOrientEnabled = false

		-- ui.bg = UI:setBg({
		-- 	parent 		= group,
		-- 	width 		= Layout.width,
		-- 	height 		= Layout.height,
		-- 	x 			= Layout.width * 0.5,
		-- 	y 			= Layout.centerY,
		-- 	fill 		= Theme.colors.coal,
		-- 	})

		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'Settings',
			x 		= centerX,
			y 		= 0,
			width 	= screenWidth,
			height 	= 50
			})

		local settings = FileUtils.loadTable( "settings.json" )
		-- have to initialize settings in case file doesn't exist
		settings = settings or default_settings


		ui.volumeLabel = display.newText( group, "Volume", 50, 100, 'Lato.ttf', 18 )
		ui.volumeLabel.anchorX, ui.volumeLabel.anchorY = 0, 0

		volume_slider = Widget.newSlider({
		    left 	= 150,
		    top 	= 95,
		    width 	= 150,
		    value 	= tonumber( settings.audioVolume ) * 100,
		})
		group:insert( volume_slider )

		ui.countinLabel = display.newText( group, "Count In From", 50, 150, 'Lato.ttf', 18 )
		ui.countinLabel.anchorX, ui.countinLabel.anchorY = 0, 0

		countin_field = TextField:new({
			parent 		= group,
			cornerRadius 	= 4,
			width 		= 50,
			height 		= 30,
			x 			= 260,
			y 			= 160,
			text 		= settings.countIn
			})

	end
	
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then
		

		local settings = {
			audioVolume 	= tonumber( volume_slider.value ) / 100.0,
			countIn 		= tonumber( countin_field.textField.text )
		}

		Debug.printTable( settings )

		FileUtils.saveTable( settings, "settings.json" )
		
		display.remove( volume_slider )
		display.remove( countin_field )

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

