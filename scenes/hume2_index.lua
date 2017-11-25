
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

local json = require( 'json' )
local FileUtils = require( "utilities.file" )

local Debug = require( 'utilities.debug' )

local Device = require( "utilities.device" )

local TiledBg = require( 'ui.tiled_bg')

local MovementService = require( "utilities.movement_service" )


local MAX_DATA_POINT_CACHE_SIZE = 300
local GRAVITY_METERS_PER_SECOND = 9.8

local ui = {}
local activeMovements = {}

local angularVelocityXAxis = 0.0
local angularVelocityYAxis = 0.0
local angularVelocityZAxis = 0.0
local deltaTimeRotation = 0.0
local dataPointCache = {}
local lastDataPoint = nil
local timeDelta = 0.0
local timeStart = nil
local timeDeltaSum = 0

---------------------------------------------------------------------------------
-- Data Processing
---------------------------------------------------------------------------------

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


function hume2Start()
	print( "hume2Start()" )

	angularVelocityXAxis = 0.0
	angularVelocityYAxis = 0.0
	angularVelocityZAxis = 0.0
	deltaTimeRotation = 0.0
	dataPointCache = {}
	lastDataPoint = nil
	timeDelta = 0.0
	timeStart = os.time( os.date( '*t' ) )
	timeDeltaSum = 0

	activeMovements = {}

	if Device.isSimulator then
		Runtime:addEventListener( "enterFrame", hume2AccelerometerMonitorSimulator )
	end

	system.setGyroscopeInterval( 100 )
	system.setAccelerometerInterval( 100 )

	Runtime:addEventListener( "accelerometer", hume2AccelerometerMonitor )
	Runtime:addEventListener( "gyroscope", hume2GyroscopeMonitor )

end

function hume2Stop()
	print( "hume2Stop()" )
	Runtime:removeEventListener( "accelerometer", hume2AccelerometerMonitor )
	Runtime:removeEventListener( "gyroscope", hume2GyroscopeMonitor )

	if Device.isSimulator then

		Runtime:removeEventListener( "enterFrame", hume2AccelerometerMonitorSimulator )

	end


	if table.getn(dataPointCache) > 0 then

		local dataPointFlush = dataPointCache
		dataPointCache = {}

		sendRequest( dataPointFlush )

	end


end


function hume2AccelerometerMonitorSimulator()
	-- print( "hume2AccelerometerMonitorSimulator()" )

	local e = {
		xGravity=( 1.0 - math.random()/10 ),
		yGravity=( (math.random()*2-1)/100 ),
		zGravity=( (math.random()*2-1)/100 ),
		deltaTime=0.01,
	}

	hume2AccelerometerMonitor( e )
end

function hume2AccelerometerMonitor( event )
	-- print( "hume2AccelerometerMonitor()" )

	local accelerationXAxis = event.xGravity -- positive right, negative left
	local accelerationYAxis = event.yGravity -- positive up, negative down
	local accelerationZAxis = event.zGravity

	timeDelta = event.deltaTime
	timeDeltaSum = timeDeltaSum + timeDelta

	local dataPoint = {}

	if (lastDataPoint == nil) then
		lastDataPoint = dataPoint
	end

	dataPoint['device_name']					= 'humeapp'
	dataPoint['device_id']						= 'mike'
	dataPoint['time_start']						= timeStart
	dataPoint['time_now']						= timeStart + timeDeltaSum
	dataPoint['time_delta_sum']					= timeDeltaSum
	dataPoint['time_delta']						= timeDelta
	dataPoint['acceleration_xaxis']				= accelerationXAxis
	dataPoint['acceleration_yaxis']				= accelerationYAxis
	dataPoint['acceleration_zaxis']				= accelerationZAxis
	dataPoint['acceleration_xaxis_delta']		= accelerationXAxis - ( lastDataPoint['acceleration_xaxis'] )
	dataPoint['acceleration_yaxis_delta']		= accelerationYAxis - ( lastDataPoint['acceleration_yaxis'] )
	dataPoint['acceleration_zaxis_delta']		= accelerationZAxis - ( lastDataPoint['acceleration_zaxis'] )

	dataPoint['acceleration_xaxis_delta_sum']	= 0.0
	dataPoint['acceleration_yaxis_delta_sum']	= 0.0
	dataPoint['acceleration_zaxis_delta_sum']	= 0.0
	dataPoint['acceleration_xaxis_delta_sum']	= lastDataPoint['acceleration_xaxis_delta_sum'] + dataPoint['acceleration_xaxis_delta']
	dataPoint['acceleration_yaxis_delta_sum']	= lastDataPoint['acceleration_yaxis_delta_sum'] + dataPoint['acceleration_yaxis_delta']
	dataPoint['acceleration_zaxis_delta_sum']	= lastDataPoint['acceleration_zaxis_delta_sum'] + dataPoint['acceleration_zaxis_delta']

	dataPoint['acceleration_xaxis_velocity']	= 0.0
	dataPoint['acceleration_yaxis_velocity']	= 0.0
	dataPoint['acceleration_zaxis_velocity']	= 0.0
	-- dataPoint['acceleration_xaxis_velocity']	= lastDataPoint['acceleration_xaxis_velocity'] + ( dataPoint['acceleration_xaxis_delta_sum'] * GRAVITY_METERS_PER_SECOND * timeDelta )
	-- dataPoint['acceleration_yaxis_velocity']	= lastDataPoint['acceleration_yaxis_velocity'] + ( dataPoint['acceleration_yaxis_delta_sum'] * GRAVITY_METERS_PER_SECOND * timeDelta )
	-- dataPoint['acceleration_zaxis_velocity']	= lastDataPoint['acceleration_zaxis_velocity'] + ( dataPoint['acceleration_zaxis_delta_sum'] * GRAVITY_METERS_PER_SECOND * timeDelta )
	dataPoint['acceleration_xaxis_velocity']	= lastDataPoint['acceleration_xaxis_velocity'] + ( ( dataPoint['acceleration_xaxis_delta_sum'] + lastDataPoint['acceleration_xaxis_delta_sum'] ) / 2.0 * GRAVITY_METERS_PER_SECOND * timeDelta )
	dataPoint['acceleration_yaxis_velocity']	= lastDataPoint['acceleration_yaxis_velocity'] + ( ( dataPoint['acceleration_yaxis_delta_sum'] + lastDataPoint['acceleration_yaxis_delta_sum'] ) / 2.0 * GRAVITY_METERS_PER_SECOND * timeDelta )
	dataPoint['acceleration_zaxis_velocity']	= lastDataPoint['acceleration_zaxis_velocity'] + ( ( dataPoint['acceleration_zaxis_delta_sum'] + lastDataPoint['acceleration_zaxis_delta_sum'] ) / 2.0 * GRAVITY_METERS_PER_SECOND * timeDelta )

	dataPoint['acceleration_xaxis_distance']	= 0.0
	dataPoint['acceleration_yaxis_distance']	= 0.0
	dataPoint['acceleration_zaxis_distance']	= 0.0
	-- dataPoint['acceleration_xaxis_distance']	= lastDataPoint['acceleration_xaxis_distance'] + ( dataPoint['acceleration_xaxis_velocity'] * timeDelta )
	-- dataPoint['acceleration_yaxis_distance']	= lastDataPoint['acceleration_yaxis_distance'] + ( dataPoint['acceleration_yaxis_velocity'] * timeDelta )
	-- dataPoint['acceleration_zaxis_distance']	= lastDataPoint['acceleration_zaxis_distance'] + ( dataPoint['acceleration_zaxis_velocity'] * timeDelta )
	dataPoint['acceleration_xaxis_distance']	= lastDataPoint['acceleration_xaxis_distance'] + ( ( dataPoint['acceleration_xaxis_velocity'] + lastDataPoint['acceleration_xaxis_velocity'] ) / 2.0 * timeDelta )
	dataPoint['acceleration_yaxis_distance']	= lastDataPoint['acceleration_yaxis_distance'] + ( ( dataPoint['acceleration_yaxis_velocity'] + lastDataPoint['acceleration_yaxis_velocity'] ) / 2.0 * timeDelta )
	dataPoint['acceleration_zaxis_distance']	= lastDataPoint['acceleration_zaxis_distance'] + ( ( dataPoint['acceleration_zaxis_velocity'] + lastDataPoint['acceleration_zaxis_velocity'] ) / 2.0 * timeDelta )

	dataPoint['acceleration_xaxis_corner']		= ( lastDataPoint['acceleration_xaxis_delta'] > 0.0 and dataPoint['acceleration_xaxis_delta'] <= 0.0 ) or ( lastDataPoint['acceleration_xaxis_delta'] <= 0.0 and dataPoint['acceleration_xaxis_delta'] > 0.0 )
	dataPoint['acceleration_yaxis_corner']		= ( lastDataPoint['acceleration_yaxis_delta'] > 0.0 and dataPoint['acceleration_yaxis_delta'] <= 0.0 ) or ( lastDataPoint['acceleration_yaxis_delta'] <= 0.0 and dataPoint['acceleration_yaxis_delta'] > 0.0 )
	dataPoint['acceleration_zaxis_corner']		= ( lastDataPoint['acceleration_zaxis_delta'] > 0.0 and dataPoint['acceleration_zaxis_delta'] <= 0.0 ) or ( lastDataPoint['acceleration_zaxis_delta'] <= 0.0 and dataPoint['acceleration_zaxis_delta'] > 0.0 )
	dataPoint['angular_velocity_xaxis']			= angularVelocityXAxis
	dataPoint['angular_velocity_yaxis']			= angularVelocityYAxis
	dataPoint['angular_velocity_zaxis']			= angularVelocityZAxis
	-- dataPoint['angle_xaxis']				= angle_xaxis
	-- dataPoint['angle_yaxis']				= angle_yaxis
	-- dataPoint['angle_zaxis']				= angle_zaxis

	-- print( dumpDataPoint(dataPoint) )

	local movementListStr = ''
	for movement_key, activeMovement in pairs(activeMovements) do
		if activeMovement['status'] == 'qualified' then
			movementListStr = movementListStr .. movement_key .. "\n"
		end
	end

	if ui then
		ui.movements.text = movementListStr
	end

	lastDataPoint = dataPoint

	-- table.insert(dataPointCache, dataPoint)

	if table.getn(dataPointCache) >= MAX_DATA_POINT_CACHE_SIZE then

		local dataPointFlush = dataPointCache
		dataPointCache = {}

		sendRequest( dataPointFlush )

	end

	processDataPointForMovement( dataPoint )

    return dataPoint
end


function hume2GyroscopeMonitor( event )
    -- Calculate approximate rotation traveled via delta time
    -- Remember that rotation rate is in radians per second
    -- local deltaRadians = event.yRotation * event.deltaTime
    -- local deltaDegrees = deltaRadians * (180/math.pi)

	angularVelocityXAxis = event.xRotation
	angularVelocityYAxis = event.yRotation
	angularVelocityZAxis = event.zRotation
	deltaTimeRotation = event.deltaTime

end


--------------------------------------------------------------------------------
-- Movement Matching Functions -------------------------------------------------
--------------------------------------------------------------------------------

function processDataPointForMovement( dataPoint )

	-- test/stop/progress active movements -------------------------------------
	local remainingActiveMovements = {}
	for movement_key, activeMovement in pairs(activeMovements) do

		MovementService.updateActiveMovement( dataPoint, activeMovement )

		-- keep if there are no path states or if not complete
		if activeMovement['status'] == 'completed' then
			print( 'COMPLETED!!! Moving on.' .. movement_key )
		elseif activeMovement['status'] == 'failed' then
			print( 'discard ' .. movement_key )
		elseif activeMovement['status'] == 'qualified' then
			print( 'qualified!!! keep ' .. movement_key )
			remainingActiveMovements[movement_key] = activeMovement
		else
			print( 'keep ' .. movement_key )
			remainingActiveMovements[movement_key] = activeMovement
		end

	end
	activeMovements = remainingActiveMovements

	-- add new active movements ------------------------------------------------
	----------------------------------------------------------------------------
	for movement_key, movement in pairs(MovementService.all()) do

    	if not( activeMovements[movement_key] ) and MovementService.meetsMovementStartCriteria( dataPoint, movement ) then

			print( "Start Movement: " .. tostring( movement_key ) )

			activeMovements[movement_key] = MovementService.newActiveMovement( dataPoint, movement )

		end

	end

	-- print( dump( activeMovements ) )

end

--------------------------------------------------------------------------------
-- Data Point Functions --------------------------------------------------------
--------------------------------------------------------------------------------


function dumpDataPoint(dataPoint)
	local s = ""
	s = s .. "{\n"
	s = s .. "  device_name: " .. tostring( dataPoint['device_name'] ) .. "\n"
	s = s .. "  device_id: " .. tostring( dataPoint['device_id'] ) .. "\n"
	s = s .. "  time_start: " .. tostring( dataPoint['time_start'] ) .. "\n"
	s = s .. "  time_now: " .. tostring( dataPoint['time_now'] ) .. "\n"
	s = s .. "  time_delta_sum: " .. tostring( dataPoint['time_delta_sum'] ) .. "\n"
	s = s .. "  time_delta: " .. tostring( dataPoint['time_delta'] ) .. "\n"
	s = s .. "  acceleration_xaxis: " .. tostring( dataPoint['acceleration_xaxis'] ) .. "\n"
	s = s .. "  acceleration_yaxis: " .. tostring( dataPoint['acceleration_yaxis'] ) .. "\n"
	s = s .. "  acceleration_zaxis: " .. tostring( dataPoint['acceleration_zaxis'] ) .. "\n"
	s = s .. "  acceleration_xaxis_delta: " .. tostring( dataPoint['acceleration_xaxis_delta'] ) .. "\n"
	s = s .. "  acceleration_yaxis_delta: " .. tostring( dataPoint['acceleration_yaxis_delta'] ) .. "\n"
	s = s .. "  acceleration_zaxis_delta: " .. tostring( dataPoint['acceleration_zaxis_delta'] ) .. "\n"
	s = s .. "  acceleration_xaxis_delta_sum: " .. tostring( dataPoint['acceleration_xaxis_delta_sum'] ) .. "\n"
	s = s .. "  acceleration_yaxis_delta_sum: " .. tostring( dataPoint['acceleration_yaxis_delta_sum'] ) .. "\n"
	s = s .. "  acceleration_zaxis_delta_sum: " .. tostring( dataPoint['acceleration_zaxis_delta_sum'] ) .. "\n"
	s = s .. "  acceleration_xaxis_corner: " .. tostring( dataPoint['acceleration_xaxis_corner'] ) .. "\n"
	s = s .. "  acceleration_yaxis_corner: " .. tostring( dataPoint['acceleration_yaxis_corner'] ) .. "\n"
	s = s .. "  acceleration_zaxis_corner: " .. tostring( dataPoint['acceleration_zaxis_corner'] ) .. "\n"
	s = s .. "  acceleration_xaxis_velocity: " .. tostring( dataPoint['acceleration_xaxis_velocity'] ) .. "\n"
	s = s .. "  acceleration_yaxis_velocity: " .. tostring( dataPoint['acceleration_yaxis_velocity'] ) .. "\n"
	s = s .. "  acceleration_zaxis_velocity: " .. tostring( dataPoint['acceleration_zaxis_velocity'] ) .. "\n"
	s = s .. "  acceleration_xaxis_distance: " .. tostring( dataPoint['acceleration_xaxis_distance'] ) .. "\n"
	s = s .. "  acceleration_yaxis_distance: " .. tostring( dataPoint['acceleration_yaxis_distance'] ) .. "\n"
	s = s .. "  acceleration_zaxis_distance: " .. tostring( dataPoint['acceleration_zaxis_distance'] ) .. "\n"
	s = s .. "  angular_velocity_xaxis: " .. tostring( dataPoint['angular_velocity_xaxis'] ) .. "\n"
	s = s .. "  angular_velocity_yaxis: " .. tostring( dataPoint['angular_velocity_yaxis'] ) .. "\n"
	s = s .. "  angular_velocity_zaxis: " .. tostring( dataPoint['angular_velocity_zaxis'] ) .. "\n"
	s = s .. "}\n"
	return s
end

--------------------------------------------------------------------------------
-- Network Functions -----------------------------------------------------------
--------------------------------------------------------------------------------


function networkListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        print ( "RESPONSE: " .. event.response )
    end
end

function sendRequest( payload_table )
	print( "sendRequest()" )
	if Device.isSimulator then
		return
	end

	local path = "https://hume-bridge.herokuapp.com/data"
	local payload = json.encode( payload_table )

	local headers = {}
	headers["Content-Type"] = "application/json"

	local params = {}
	params.headers = headers
	params.body = payload

	network.request( path, "POST", networkListener, params )

end



---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------


-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view

end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then
		Composer.setVariable( 'prevScene', 'scenes.home' )


		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'HuME 2',
			x 		= centerX,
			y 		= 0,
			width 	= screenWidth,
			height 	= 50
			})

		ui.movements = display.newText( group, "none", centerX, 100, 'Lato', 12 )



		hume2Start()

		-- trigger laydown
		-- processDataPointForMovement( { acceleration_xaxis=0.95, acceleration_yaxis=-0.001, acceleration_zaxis=0.001, time_delta=0.5 } )
		-- processDataPointForMovement( { acceleration_xaxis=0.95, acceleration_yaxis=-0.001, acceleration_zaxis=0.001, time_delta=0.5 } )
		-- processDataPointForMovement( { acceleration_xaxis=0.95, acceleration_yaxis=-0.001, acceleration_zaxis=0.001, time_delta=0.5 } )
		-- processDataPointForMovement( { acceleration_xaxis=0.01, acceleration_yaxis=-0.001, acceleration_zaxis=0.001, time_delta=0.5 } )
		-- processDataPointForMovement( { acceleration_xaxis=0.01, acceleration_yaxis=-0.001, acceleration_zaxis=0.001, time_delta=0.5 } )

	end

end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then

		hume2Stop()

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
