---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

local Composer = require( "composer" )
local scene = Composer.newScene()

local Theme = require( 'ui.theme' )
local Btn = require( 'ui.btn' )
local UI = require( 'ui.factory' )

local Debug = require( 'utilities.debug' )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}

-- Called when the scene's view does not exist:
function scene:create( event )
end

function scene:show( event )
	local group = self.view

	if event.phase == 'did' then
		print( Composer.getVariable( 'prevScene' ) )
	end

	if event.phase == 'will' then
		Composer.setVariable( 'prevScene', nil )

		ui.bg = UI:setBg({
			parent 		= group,
			width 		= screenWidth,
			height 		= screenHeight,
			x 			= centerX,
			y 			= centerY,
			wrapX 		= 'repeat',
			wrapY 		= 'repeat',
			fillScale 	= 1,
			fill 		= { type = 'image', filename = 'assets/images/bgs/bg6.jpg' },
			})


		ui.bgDim = display.newRect( group, centerX, centerY, screenWidth, screenHeight )
		ui.bgDim.fill = { 0, 0, 0, 0.5 }

		local buttons = {
			{
				label = 'Workouts',
				target 	= 'scenes.workouts_index',
				y 		= 120,
				height 	= 36,
				fontSize = 14,
			},
			{
				label = 'Life Meter',
				target 	= 'scenes.life_meter_index' ,
				y 		= 180,
				height 	= 36,
				fontSize = 14,
			},
			{
				label = 'HuME',
				target 	= 'scenes.hume_index' ,
				y 		= 240,
				height 	= 36,
				fontSize = 14,
			},
			{
				label = 'Settings',
				target 	= 'scenes.settings' ,
				y 		= 300,
				height 	= 36,
				fontSize = 14,
			},
		}
		ui.btns = {}

		for i = 1, #buttons do 
			ui.btns[i] = Btn:new({
				group 			= group,
				label			= buttons[i].label,
				x				= buttons[i].x,
				y				= buttons[i].y,
				width			= buttons[i].width,
				height			= buttons[i].height,
				fontSize		= buttons[i].fontSize,
				onRelease 		= function() Composer.gotoScene( buttons[i].target ) end
			})
		end

	end

	
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then

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

