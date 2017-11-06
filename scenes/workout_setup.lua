---------------------------------------------------------------------------------
--
-- Used to setup a quik workout:
-- Quick AMRAP: enter total time, we add round/rep counter
-- Quick RFT: enter rounds to complete, we add round counter
-- Quick FT: we just run up a clock
-- Quick Interval (EotM): enter interval and total intervals
-- Quick TABATA
--
---------------------------------------------------------------------------------

local Composer = require( "composer" )
local scene = Composer.newScene()

local Widget = require( "widget" )
Widget.setTheme( "widget_theme_android_holo_dark" )

local Btn = require( 'ui.btn' )
local Theme = require( 'ui.theme' )
local UI = require( 'ui.factory' )
local Keypad = require( 'ui.keypad' )
local TextBox = require( 'ui.text_box' )
local json = require( 'json' )

local units = 'Mins'
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}

local workout_type = 'amrap'

-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view
end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then
		Composer.setVariable( 'prevScene', 'scenes.workouts_index' )

		local function centerDisplay()
			local width = ui.userVal.contentWidth + ui.valUnits.contentWidth + 10
			ui.userVal.anchorX = 0
			ui.valUnits.anchorX = 0
			ui.userVal.x = display.contentWidth * 0.5 - ( width * 0.5 )
			ui.valUnits.x = ui.userVal.x + ui.userVal.contentWidth + 10
			ui.box.x = ui.userVal.x + ( ui.userVal.contentWidth/2 )
			ui.box.width = ui.userVal.contentWidth + 8 
		end

		local function go()
			local title = "Quick "
			local repeat_count = 0 
			local duration
			if workout_type == 'amrap' then
				title = title .. 'AMRAP'
				duration = tonumber( ui.userVal.text ) * 60
			elseif workout_type == 'ft' then 
				title = title .. 'Workout for Time'
			elseif workout_type == 'rft' then 
				title = title .. 'RFT'
				repeat_count = tonumber( ui.userVal.text )
			elseif workout_type == 'tabata' then 
				title = title .. 'TABATA'
			end
			local workoutData = {
				title 			= title, 
				workout_type 	= workout_type
			}
			workoutData.segments = {
				{
					segment_type	 = workout_type,
					duration 		= duration,
					repeat_count 	= repeat_count,
					content 		= ui.descriptionBox.textBox.text
				}
			}

			Composer.setVariable( 'objType', 'workout' )
			Composer.setVariable( 'objSlug', 'quickWorkout' )

			Composer.setVariable( 'workoutData', workoutData )

			Composer.gotoScene( "scenes.workout_run", { effect='fade', time=500 } )

		end

		local function setUnit()
			for i=1, #ui.switches do 
				if ui.switches[i].isOn then 
					workout_type = ui.switches[i].id 
					break
				end
			end
			if workout_type == 'tabata' or workout_type == 'ft' then
				ui.userVal.isVisible = false
				ui.valUnits.isVisible = false
				ui.box.isVisible = false
				ui.valTitleTxt.isVisible = false
			elseif workout_type == 'rft' then 
				ui.valTitleTxt.isVisible = false
				ui.userVal.isVisible = true
				ui.valUnits.isVisible = true
				ui.box.isVisible = true
				units = 'Rounds'
				ui.keypad.label = units
			else
				ui.valTitleTxt.isVisible = true
				ui.userVal.isVisible = true
				ui.valUnits.isVisible = true
				ui.box.isVisible = true
				units = 'Mins'
				ui.keypad.label = units
			end
			ui.userVal.text = '0'
			ui.valUnits.text = units
			centerDisplay()
			ui.keypad:updateDisp()
		end

		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'Quick Workout',
			x 		= centerX,
			y 		= 0,
			width 	= screenWidth,
			height 	= 50
			})

		ui.title = display.newText({
			parent 		= group,
			text 		= 'Workout Type:',
			x 			= 20,
			y 			= 100,
			font 		= Theme.fonts.hairline,
			fontSize 	= 24
			})
		ui.title.anchorX = 0

		ui.switches = {}
		local switchGroup = display.newGroup()

		local switches = {
			{
				label 	= 'AMRAP',
				id 		= 'amrap',
				y 		= 120,
				x 	 	= 50,
				init 	= 'true',
				fontSize = 14,
			},
			{
				label 	= 'For Time',
				id 		= 'ft' ,
				y 		= 150,
				x 	 	= 50,
				fontSize = 14,
			},
			{
				label 	= 'Rounds for Time',
				id 		= 'rft' ,
				y 		= 180,
				x 	 	= 50,
				fontSize = 14,
			},
			{
				label 	= 'TABATA',
				id 		= 'tabata' ,
				y 		= 210,
				x 	 	= 50,
				fontSize = 14,
			},
		}
		

		for i = 1, #switches do 
			ui.switches[i] = Widget.newSwitch({
				group 		= switchGroup,
				style		= 'radio',
				id 			= switches[i].id,
				left		= switches[i].x,
				top			= switches[i].y,
				initialSwitchState = switches[i].init,
				onPress = setUnit
			})

			ui.switches[i].label = display.newText({
				parent 	= switchGroup,
				text 	= switches[i].label,
				x 		= switches[i].x + 40,
				y 		= switches[i].y + 17,
				font 	= Theme.font,
				fontSize = 16
				})
			ui.switches[i].label.anchorX = 0
			ui.switches[i].label:addEventListener( 'tap', function(e) ui.switches[i]:setState({ isOn=true }); setUnit() end )
		end
		group:insert( switchGroup )

		ui.valTitleTxt = display.newText({
			parent 		= group,
			text 		= 'Duration:',
			x 			= 20,
			y 			= ui.switches[#switches].y + 30,
			font 		= Theme.fonts.hairline,
			fontSize 	= 24
			})
		ui.valTitleTxt.anchorX = 0


		ui.userVal = display.newText({
			parent 	= group,
			text 	= '0',
			x 		= display.contentCenterX - 25,
			y 		= ui.valTitleTxt.y + 50,
			fontSize = 32,
			})
		ui.userVal:addEventListener( 'tap', function(e) ui.descriptionBox.textBox.isVisible=false; ui.descriptionBox.isVisible=false; ui.keypad:show() end )
		ui.userVal.anchorX = 1

		ui.box = display.newRoundedRect( group, ui.userVal.x, ui.userVal.y, ui.userVal.contentWidth*2, ui.userVal.contentHeight+8, 4 )
		ui.box.fill = Theme.colors.dkGrey
		ui.box.strokeWidth = 2
		ui.box:setStrokeColor( unpack( Theme.colors.ltGrey ) )
		ui.box:toBack()
		ui.box:addEventListener( 'tap', function(e) ui.descriptionBox.textBox.isVisible=false; ui.descriptionBox.isVisible=false; ui.keypad:show() end )

		ui.valUnits = display.newText({
			parent 	= group,
			text 	= units,
			x 		= display.contentCenterX,
			y 		= ui.userVal.y,
			fontSize = 32,
			})
		ui.valUnits:addEventListener( 'tap', function(e) ui.descriptionBox.textBox.isVisible=false; ui.descriptionBox.isVisible=false; ui.keypad:show() end )
		ui.valUnits.anchorX = 0

		centerDisplay()


		ui.descTitleTxt = display.newText({
			parent 		= group,
			text 		= 'Description:',
			x 			= 20,
			y 			= ui.valUnits.y + 50,
			font 		= Theme.fonts.hairline,
			fontSize 	= 24
			})
		ui.descTitleTxt.anchorX = 0

		ui.descriptionBox = TextBox:new({
			parent 	= group,
			x 		= centerX,
			y 		= ui.descTitleTxt.y + 70,
			width 	= screenWidth - 80,
			height 	= 80,
			})



		ui.go_btn = Btn:new({
			group 	= group,
			x 		= centerX,
			y 		= screenHeight - 50,
			fontSize 	= 20,
			label 	= "Ready! Ready!",
			bgColor 	= Theme.colors.dkGreen,
			bgColorPressed 	= Theme.colors.green,
			onRelease 	= go
			})

		ui.keypad = Keypad:new({
			parent 		= group,
			bindTo 		= ui.userVal,
			onComplete 	= function() ui.descriptionBox.isVisible=true; ui.descriptionBox.textBox.isVisible=true; end
			})
		ui.keypad:addEventListener( 'keyPress', centerDisplay )
		

	end
	
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then
		display.remove( ui.keypad )
		if ui.switches then
			for i=1, #ui.switches do 
				display.remove( ui.switches[i] )
			end
		end

		display.remove( ui.userVal )
		display.remove( ui.valUnits )
		display.remove( ui.box )

		display.remove( ui.descriptionBox )
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

