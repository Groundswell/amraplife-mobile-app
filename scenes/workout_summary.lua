---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

local Composer = require( "composer" )
local scene = Composer.newScene()

local mFloor = math.floor  

local Btn = require( 'ui.btn' )
local Theme = require( 'ui.theme' )
local UI = require( 'ui.factory' )
local Clock = require( 'objects.clock' )
local json = require( 'json' )
local FileUtils = require( "utilities.file" )
local TextBox = require( "ui.text_box" )
local TextField = require( "ui.text_field" )

local Widget = require( 'widget' )
Widget.setTheme( "widget_theme_android_holo_dark" )

local Debug = require( 'utilities.debug' )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}
local all_results, results, noteBox, rxSwitch, valueField


local function finalizeResults() 
	local function urlResp( e )
			--native.showAlert( 'posted', 'Results posted', { 'Ok' } )
		Composer.gotoScene( 'scenes.home', { effect = 'fade', time = 1000 } )
	end

	local jsonResults = {}
	local unit = 'secs'

	results.summary.notes = noteBox.textBox.text
	results.summary.rx = tostring( rxSwitch.isOn )
	results.summary.unit = unit

	if results.summary.workout_type == 'amrap' then
		results.summary.sub_value = valueField.textField.text
		results.summary.unit = 'rds'
	elseif results.summary.workout_type == 'strength' then 
		results.summary.value = valueField.textField.text
		results.summary.unit = 'lbs'
	end

	-- Only save last 5 results locally to device
	-- if user has acct, save 30
	-- if user pays, save all-time?
	if #all_results == 5 then table.remove( all_results ) end
	table.insert( all_results, 1, results )
	FileUtils.saveTable( all_results, "all_results.json" )

	jsonResults = {
		workout_id = results.summary.workout_id,
		started_at = results.summary.started_at,
		ended_at = results.summary.ended_at,
		notes = results.summary.notes,
		rx = results.summary.rx,
		tmp_id = results.summary.tmp_id,
		value = results.summary.value,
		sub_value = results.summary.sub_value,
		unit = results.summary.unit,
		segment_results = results.segments
	}

	print( "Json Reuslts for server: " .. json.prettify( jsonResults ) )

	jsonResults = json.encode( jsonResults )

	local url = "http://localhost:3008/workout_results"
	network.request( url, 'POST', urlResp, { body="result="..jsonResults } )
end

local function rxToggle()
	print( "Rx is " .. tostring( rxSwitch.isOn ) )
	if rxSwitch.isOn then
		ui.rxReminder.text = "\r\nNotes:"
	else
		ui.rxReminder.text = "Be sure to record any modifications and/or weight used in the notes below:"
	end
end

-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view

end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then

		local Layout = require( 'ui.layout_' .. screenOrient )

		-- ui.bg = UI:setBg({
		-- 	parent 		= group,
		-- 	width 		= Layout.width,
		-- 	height 		= Layout.height - Layout.headerHeight,
		-- 	x 			= Layout.width * 0.5,
		-- 	y 			= Layout.centerY,
		-- 	fillScale 	= 1,
		-- 	fill 		= { 0 },
		-- 	})

		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'Workout Summary',
			x 		= Layout.centerX,
			y 		= 0,
			width 	= Layout.width,
			height 	= Layout.headerHeight
			})

		all_results = FileUtils.loadTable( "all_results.json" )
		-- have to initialize settings in case file doesn't exist
		all_results = all_results or {}

		results = Composer.getVariable( 'workoutResults' )

		print( "results are:" )
		Debug.printTable( results )


		if results.summary.cover_img then 
			display.remove( ui.bg )
			local name = results.summary.cover_img:match( "([^/]+)$" )
			display.loadRemoteImage( results.summary.cover_img, 'GET', function(e) ui.bg = e.target;ui.bg.anchorY=0;group:insert( ui.bg );ui.bgDimmer=display.newRect( group, Layout.centerX, 50, Layout.width, Layout.height );ui.bgDimmer.anchorY=0;ui.bgDimmer.fill={ 0, 0, 0, 0.5 };ui.bgDimmer:toBack(); ui.bg:toBack(); end, name, Layout.centerX, 50 )
		end

		ui.workoutTitle = display.newText({
			parent 	= group,
			text 	= results.summary.workout_title,
			x 		= Layout.workout_summary.titleX,
			y 		= Layout.workout_summary.titleY,
			font 	= 'Lato-Bold.ttf',
			fontSize 	= 24
			})

		ui.dateDisp = display.newText({
			parent 	= group,
			text 	= "Performed at: " .. results.summary.started_at,
			x 		= Layout.workout_summary.dateX,
			y 		= Layout.workout_summary.dateY,
			font 	= 'Lato.ttf',
			fontSize = 14
			})


		local totalTxt = "Total Time: " .. Clock.humanizeTime( { time = results.summary.value, secs = true } )
		if results.summary.workout_type == 'amrap' then 
			totalTxt = "Rounds: " .. results.summary.value 
		end

		ui.totalDisp = display.newText({
			parent 	= group,
			text 	=  totalTxt,
			x 		= Layout.workout_summary.totalX,
			y 		= Layout.workout_summary.totalY,
			font 	= 'Lato.ttf',
			fontSize = 20
			})


		ui.sep = display.newLine( group, Layout.workout_summary.sepStartX, Layout.workout_summary.sepStartY, Layout.workout_summary.sepEndX, Layout.workout_summary.sepEndY )
		ui.sep.alpha = 0.5

		ui.resultBox = Widget.newScrollView({
			top 		= Layout.workout_summary.resultsBoxY,
			left		= 10,
			width 		= Layout.workout_summary.resultsBoxWidth,
			topPadding 	= 20,
			bottomPadding = 20,
			height 		= Layout.workout_summary.resultsBoxHeight,
			horizontalScrollDisabled = true,
			backgroundColor = { 0, 0, 0, 0.5 }
			})
		group:insert( ui.resultBox )


		ui.resultsBoxTitle = display.newText({
			parent 	= group,
			text 	= 'Segment Splits',
			x 		= Layout.workout_summary.resultsBoxTitleX,
			y 		= Layout.workout_summary.resultsBoxTitleY,
			font 	= 'Lato.ttf',
			fontSize = 18
			})

		local y = 0
		local yPad = 28 

		ui.segResultsContDisp = {}
		ui.segResultsValDisp = {}

		for i=1, #results.segments do 
			local formattedTime = Clock.humanizeTime( { time = results.segments[i].value, secs = true } )
			
			ui.segResultsContDisp[i] = display.newText({
				parent 	= group,
				text 	= results.segments[i].content .. ":  ",
				x 		= Layout.workout_summary.segResultsContDispX,
				y 		= y,
				font 	= 'Lato.ttf',
				fontSize = 14
				})
			ui.segResultsContDisp[i].anchorY = 0
			ui.segResultsContDisp[i].anchorX = 0
			ui.resultBox:insert( ui.segResultsContDisp[i] )

			ui.segResultsValDisp[i] = display.newText({
				parent 	= group,
				text 	= formattedTime,
				x 		= Layout.workout_summary.segResultsValDispX,
				y 		= y,
				font 	= 'Lato.ttf',
				fontSize = 14
				})
			ui.segResultsValDisp[i].anchorY = 0
			ui.segResultsValDisp[i].anchorX = 1
			ui.resultBox:insert( ui.segResultsValDisp[i] )

			y = y + yPad
		end



		noteBox = TextBox:new({
			parent 	= group,
			width 	= Layout.workout_summary.noteBoxWidth,
			x 		= Layout.workout_summary.noteBoxX,
			y 		= Layout.workout_summary.noteBoxY,
			})



		rxSwitch = Widget.newSwitch({
			x 		= Layout.workout_summary.rxSwitchX,
			y 		= Layout.workout_summary.rxSwitchY,
			style 	= 'checkbox',
			initialSwitchState 	= true,
			onRelease 	= rxToggle
			})
		rxSwitch.anchorX = 0

		ui.rxSwitchLabel = display.newText({
			parent 	= group,
			text 	= "Rx?",
			x 		= Layout.workout_summary.rxSwitchLabelX,
			y 		= Layout.workout_summary.rxSwitchLabelY
			})

		local valuePrompt = "Additional Reps?"
		if results.summary.workout_type == 'strength' then 
			valuePrompt = "Max Weight Used"
		end

		ui.valueLabel = display.newText({
			parent 	= group,
			text 	= valuePrompt,
			x 		= Layout.workout_summary.valueLabelX,
			y 		= Layout.workout_summary.valueLabelY,
			})

		valueField = TextField:new({
			parent 	= group,
			x 		= Layout.workout_summary.valueFieldX,
			y 		= Layout.workout_summary.valueFieldY,
			width 	= 40,
			height 	= 28,
			cornerRadius 	= 4,
			})

		if not( results.summary.workout_type == 'amrap' or results.summary.workout_type == 'strength' ) then 
			ui.valueLabel.isVisible = false
			valueField.isVisible = false
		end

		ui.rxReminder = display.newText({
			parent 	= group,
			text 	= "\r\nNotes:",
			x 		= Layout.workout_summary.rxReminderX,
			width 	= Layout.workout_summary.rxReminderWidth,
			y 		= Layout.workout_summary.rxReminderY,
			font 	= Theme.font,
			fontSize 	= 10,
			})
		ui.rxReminder.anchorX = 0

		ui.submitBtn = Btn:new({
			parent 		= group,
			x 			= Layout.workout_summary.submitX,
			y 			= Layout.workout_summary.submitY,
			width 		= Layout.workout_summary.submitWidth,
			height 		= Layout.workout_summary.submitHeight,
			label 		= 'Enter',
			bgColor 	= Theme.colors.dkGreen,
			onRelease 	= function() finalizeResults() end
			})
	end
	
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then
		display.remove( rxSwitch )
		display.remove( ui.workoutTitle )
		display.remove( valueField )
		display.remove( ui.valueLabel )
		display.remove( noteBox )
		display.remove( ui.resultBox )
		display.remove( ui.bg )
		display.remove( ui.totalDisp )
		
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

