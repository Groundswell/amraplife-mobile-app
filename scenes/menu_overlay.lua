---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Libraries & Modules
---------------------------------------------------------------------------------
local Composer = require( "composer" )
local scene = Composer.newScene()

local Btn = require( 'ui.btn' )
local Theme = require( 'ui.theme' )


---------------------------------------------------------------------------------
-- Scene Variables
---------------------------------------------------------------------------------
local panel = display.newGroup()
local ui = {}

---------------------------------------------------------------------------------
-- Scene Functions
---------------------------------------------------------------------------------
function scene:create( event )
	local group = self.view

end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then

		local Layout = require( 'ui.layout_' .. screenOrient )

		panel.frame = display.newRoundedRect( group, Layout.width, 70, Layout.width * 0.66, 300, 6 )
		panel.frame.anchorX, panel.frame.anchorY = 1, 0
		panel.frame.fill = Theme.colors.whiteGrey

		panel.frame.stroke = {type="image", filename="assets/images/brushes/blur_brush1x4.png"}
		panel.frame.strokeWidth = 6
		panel.frame:setStrokeColor( 0.25, 0.25, 0.25, 0.5 )
		
		local y = 90

		ui.home_link = display.newText({
			parent 	= panel,
			text 	= 'Home',
			font 	= 'Lato.ttf',
			fontSize 	= 16,
			x 		= Layout.width * 0.33 + 40,
			y 		= y
			})
		ui.home_link.anchorX = 0
		ui.home_link.fill = Theme.colors.dkGrey

		y = y + 20 
		ui.sep = display.newLine( panel, Layout.width * 0.33, y, Layout.width-40, y )
		ui.sep:setStrokeColor( 0.33 )
		y = y + 20 

		ui.results_link = display.newText({
			parent 	= panel,
			text 	= 'Results',
			font 	= 'Lato.ttf',
			fontSize 	= 16,
			x 		= Layout.width * 0.33 + 40,
			y 		= y
			})
		ui.results_link.anchorX = 0
		ui.results_link.fill = Theme.colors.dkGrey

		y = y + 20 
		ui.sep = display.newLine( panel, Layout.width * 0.33, y, Layout.width-40, y )
		ui.sep:setStrokeColor( 0.33 )
		y = y + 20 

		ui.settings_link = display.newText({
			parent 	= panel,
			text 	= 'Settings',
			font 	= 'Lato.ttf',
			fontSize 	= 16,
			x 		= Layout.width * 0.33 + 40,
			y 		= y
			})
		ui.settings_link.anchorX = 0
		ui.settings_link.fill = Theme.colors.dkGrey

		y = y + 20 
		ui.sep = display.newLine( panel, Layout.width * 0.33, y, Layout.width-40, y )
		ui.sep:setStrokeColor( 0.33 )
		y = y + 20 

		ui.workouts_link = display.newText({
			parent 	= panel,
			text 	= 'Workouts',
			font 	= 'Lato.ttf',
			fontSize 	= 16,
			x 		= Layout.width * 0.33 + 40,
			y 		= y
			})
		ui.workouts_link.anchorX = 0
		ui.workouts_link.fill = Theme.colors.dkGrey

		y = y + 20 
		ui.sep = display.newLine( panel, Layout.width * 0.33, y, Layout.width-40, y )
		ui.sep:setStrokeColor( 0.33 )
		y = y + 20 

		ui.movements_link = display.newText({
			parent 	= panel,
			text 	= 'Movements',
			font 	= 'Lato.ttf',
			fontSize 	= 16,
			x 		= Layout.width * 0.33 + 40,
			y 		= y
			})
		ui.movements_link.anchorX = 0
		ui.movements_link.fill = Theme.colors.dkGrey

		y = y + 20 
		ui.sep = display.newLine( panel, Layout.width * 0.33, y, Layout.width-40, y )
		ui.sep:setStrokeColor( 0.33 )
		y = y + 20 

		ui.account_link = display.newText({
			parent 	= panel,
			text 	= 'Account',
			font 	= 'Lato.ttf',
			fontSize 	= 16,
			x 		= Layout.width * 0.33 + 40,
			y 		= y
			})
		ui.account_link.anchorX = 0
		ui.account_link.fill = Theme.colors.dkGrey

		y = y + 20 
		ui.sep = display.newLine( panel, Layout.width * 0.33, y, Layout.width-40, y )
		ui.sep:setStrokeColor( 0.33 )
		y = y + 20 

		ui.logout_link = display.newText({
			parent 	= panel,
			text 	= 'Logout',
			font 	= 'Lato.ttf',
			fontSize 	= 16,
			x 		= Layout.width * 0.33 + 40,
			y 		= y
			})
		ui.logout_link.anchorX = 0
		ui.logout_link.fill = Theme.colors.dkGrey

		group:insert( panel )

	elseif event.phase == "did" then
		Composer.setVariable( 'overlay', true )
	end
	
end

function scene:hide( event )
	if event.phase == "will" then

	elseif event.phase == "did" then
		Composer.setVariable( 'overlay', false )
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