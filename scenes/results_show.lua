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
local Clock = require( 'objects.clock' )
local UI = require( 'ui.factory' )
local json = require( 'json' )
local FileUtils = require( 'utilities.file' )
local Debug = require( 'utilities.debug' )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}
local data

-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view
end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then
		Composer.setVariable( 'prevScene', 'scenes.results_index' )

		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'Workout Result',
			x 		= centerX,
			y 		= 0,
			width 	= screenWidth,
			height 	= 50,
			backTo 	= Composer.getSceneName( 'previous' )
			})

		
		ui.workoutTitle = display.newText({
			parent 	= group,
			text 	= "Title",
			x 		= centerX,
			y 		= 90,
			font 	= 'Lato-Bold.ttf',
			fontSize 	= 24
			})

		ui.totalDisp = display.newText({
			parent 	= group,
			text 	= "Score: ",
			x 		= centerX,
			y 		= 125,
			font 	= 'Lato.ttf',
			fontSize = 20
			})

		ui.dateDisp = display.newText({
			parent 	= group,
			text 	= "Completed: ",
			x 		= centerX,
			y 		= 155,
			font 	= 'Lato.ttf',
			fontSize = 14
			})


		ui.sep = display.newLine( group, 25, 175, screenWidth-25, 175 )
		ui.sep.alpha = 0.5


		ui.resultsBoxTitle = display.newText({
			parent 	= group,
			text 	= 'Segment Splits',
			x 		= centerX,
			y 		= 200,
			font 	= 'Lato.ttf',
			fontSize = 18
			})


		ui.resultBox = Widget.newScrollView({
			top 		= 225,
			left		= 10,
			width 		= screenWidth-25,
			topPadding 	= 20,
			bottomPadding = 20,
			height 		= screenHeight - ( 225 + 220 ),
			horizontalScrollDisabled = true,
			backgroundColor = { 0, 0.1 }
			})
		group:insert( ui.resultBox )



		ui.notesTitle = display.newText({
			parent 	= group,
			text 	= "Notes:",
			x 		= centerX,
			y 		= screenHeight - 175,
			font 	= 'Lato.ttf',
			fontSize = 20
			})

		ui.notesDisp = display.newText({
			parent 	= group,
			text 	= "Notes:",
			x 		= centerX,
			y 		= screenHeight - 120,
			font 	= 'Lato.ttf',
			fontSize = 18
			})



		local slug = Composer.getVariable( 'objSlug' )

		local function getData( e )
			
			connectionStatus = 'online'
			ui.header:updateConnectionIndicator()
			data =  json.decode( e.response )

			if e.isError or data == nil then
				connectionStatus = 'offline'
				ui.header:updateConnectionIndicator()

				local all_results = FileUtils.loadTable( "all_results.json" )
				-- have to initialize settings in case file doesn't exist
				all_results = all_results or {}
				-- loop through all results until result tmp_id key
				for i=1, #all_results do
					print( "results[" .. i .."] is: " )
					Debug.printTable( all_results[i] )

					-- the last entry contains the summary data
					if all_results[i].summary.tmp_id == slug then 
						data = all_results[i]
					end
				end
			end

			ui.workoutTitle.text = data.summary.workout_title
			ui.dateDisp.text = ui.dateDisp.text .. data.summary.ended_at

			local totalTxt = "Total Time: " .. Clock.humanizeTime( { time = data.summary.value, secs = true } )
			if data.summary.workout_type == 'amrap' then 
				totalTxt = "Rounds: " .. data.summary.value 
				if data.summary.sub_value then 
					totalTxt = totalTxt .. ' & ' .. data.summary.sub_value .. ' reps'
				end
			end
			ui.totalDisp.text = totalTxt


			local y = 0
			local yPad = 28 

			ui.segResultsContDisp = {}
			ui.segResultsValDisp = {}

			for i=1, #data.segments do 
				local formattedTime = Clock.humanizeTime( { time = data.segments[i].value, secs = true } )
				
				local content = data.segments[i].content or ""
				ui.segResultsContDisp[i] = display.newText({
					parent 	= group,
					text 	= content .. ': ',
					x 		= 20,
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
					x 		= screenWidth-40,
					y 		= y,
					font 	= 'Lato.ttf',
					fontSize = 14
					})
				ui.segResultsValDisp[i].anchorY = 0
				ui.segResultsValDisp[i].anchorX = 1
				ui.resultBox:insert( ui.segResultsValDisp[i] )

				y = y + yPad
			end

			ui.notesDisp.text = data.summary.notes

		end

		local url = 'http://localhost:3008/workout_results/' .. slug .. '.json'
		network.request( url, 'GET', getData )
	end
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then
		display.remove( ui.workoutTitle )
		display.remove( ui.totalDisp )
		display.remove( ui.dateDisp )
		display.remove( ui.resultBox )
		display.remove( ui.notesDisp )
		display.remove( ui.bg )
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

