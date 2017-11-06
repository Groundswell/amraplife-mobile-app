
---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

local Composer = require( "composer" )
local scene = Composer.newScene()

local Widget = require( "widget" )
Widget.setTheme( "widget_theme_android_holo_dark" )

local mFloor = math.floor  

local Btn = require( 'ui.btn' )
local Theme = require( 'ui.theme' )
local UI = require( 'ui.factory' )
local Clock = require( 'objects.clock' )
local json = require( 'json' )
local FileUtils = require( "utilities.file" )

local Debug = require( 'utilities.debug' )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}
local summaryGroup, data, data_table

-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view

end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then
		Composer.setVariable( 'prevScene', 'scenes.workouts_index' )

		-- ui.bg = UI:setBg({
		-- 	parent 		= group,
		-- 	width 		= Layout.width,
		-- 	height 		= Layout.height,
		-- 	x 			= Layout.centerX,
		-- 	y 			= Layout.centerY,
		-- 	fill 		= Theme.colors.coal,
		-- 	})

		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'Results',
			x 		= centerX,
			y 		= 0,
			width 	= screenWidth,
			height 	= 50
			})


		local function getData( e )
			data =  json.decode( e.response )

			if not( e.isError ) and not( data == nil ) then
				connectionStatus = 'online'
				ui.header:updateConnectionIndicator()
				
				for i = 1, #data do
					-- Insert a row into the tableView
					data_table:insertRow({
						rowColor = { default={ 0, 0.01}, over={ 0, 0.25} },
						params = { 
							slug 			= data[i].summary.tmp_id,
							label			= data[i].summary.workout_title,
							started_at 		= data[i].summary.started_at,
							value 			= data[i].summary.value,
							rx 				= data[i].summary.rx,
							unit 			= data[i].summary.unit,
							sub_value 		= data[i].summary.sub_value,
							workout_type 	= data[i].summary.workout_type,
						}
					})
				end	

			else
				connectionStatus = 'offline'
				ui.header:updateConnectionIndicator()
				--native.showAlert( 'Connection Error', e.response .. "\nUsing local data.", { 'Ok' } )
				-- for whatever reason, we're offline
				-- use local results cache instead
				local results = FileUtils.loadTable( "all_results.json" )
				-- have to initialize settings in case file doesn't exist
				results = results or {}
				
				for i = 1, #results do
					-- Insert a row into the tableView
					data_table:insertRow({
						rowColor = { default={ 0, 0, 0, 0.5}, over={1, 0.5, 0 ,0.8} },
						params = { 
							slug 	= results[i].summary.tmp_id,
							label	= results[i].summary.workout_title,
							started_at = results[i].summary.started_at,
							value 		= results[i].summary.value,
							rx 			= results[i].summary.rx,
							unit 		= results[i].summary.unit,
							sub_value  	= results[i].summary.sub_value,
							workout_type = results[i].summary.workout_type,
						}
					})
				end
			end
			
			
		end

		local url = 'http://localhost:3008/workout_results.json'
		network.request( url, 'GET', getData )



		local function onRowTouch( e )
			local slug = e.target.params.slug
			Composer.setVariable( 'objType', 'result' )
			Composer.setVariable( 'objSlug', slug )
			Composer.gotoScene( "scenes.results_show" )
		end

		local function onRowRender( e )

			-- print( 'rendering row with prams:' )
			-- Debug.printTable( e.row.params )

			local row = e.row
			-- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
			local rowHeight = row.contentHeight
			local rowWidth = row.contentWidth
			
			local rowTitle = display.newText( row, row.params.label, 0, 0, Theme.font, 10 )
			rowTitle:setFillColor( 0.75, 0.75, 0.75 )
			-- Align the label left and vertically centered
			rowTitle.anchorX, rowTitle.x  = 0, 10
			rowTitle.y = rowHeight * 0.5

			local rowStarted = display.newText( row, row.params.started_at, 0, 0, Theme.font, 10 )
			rowStarted:setFillColor( 0.75, 0.75, 0.75 )
			-- Align the label left and vertically centered
			rowStarted.anchorX, rowStarted.x  = 0, screenWidth*0.45
			rowStarted.y = rowHeight * 0.5

			local result

			if row.params.workout_type == 'amrap' then 
				result = row.params.value .. ' Rds'
				if row.params.sub_value then 
					result = result .. ' & ' .. row.params.sub_value .. ' reps'
				end
			elseif row.params.workout_type == 'strength' then
			 	result = row.params.value .. ' ' .. row.params.unit
			else
				result = Clock.humanizeTime( { time = row.params.value, secs = true } )
			end

			local rowResult = display.newText( row, result, 0, 0, Theme.font, 10 )
			rowResult:setFillColor( 0.75, 0.75, 0.75 )
			-- Align the label left and vertically centered
			rowResult.anchorX, rowResult.x  = 0, screenWidth * 0.75
			rowResult.y = rowHeight * 0.5

			if row.params.rx == 'true' then 
				rowResult.text = rowResult.text .. ' Rx' 
				rowResult.fill = Theme.colors.green
			end

		end

		data_table = Widget.newTableView({
			left 			= 10,
			top 			= 80, -- should be headerHeight (50) plus statusbar height
			height 			= screenHeight - 60,
			width 			= screenWidth - 2*10,
			hideBackground  = true,
			onRowRender 	= onRowRender,
			onRowTouch 		= onRowTouch,
			listener 		= scrollListener
		})

		group:insert( data_table )

	end
	
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then
		display.remove( data_table )
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

