
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

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}

local movementData = {}
local deviceTrail = {}

local xVel, yVel = 0, 0

local isActive = false
local isCalibrating = false

local xThreshold, yThreshold, zThreshold = 0, 0, 0


local frameNum = 0


-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view

end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then
		Composer.setVariable( 'prevScene', 'scenes.home' )

		-- let's go with 30 per second device resolution at 60fps app speed
		system.setAccelerometerInterval( 60 )


		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'HuME',
			x 		= centerX,
			y 		= 0,
			width 	= screenWidth,
			height 	= 50
			})


		if not( system.hasEventSource("accelerometer") ) then
			local msg = display.newText( group, "Motion events not supported on this device", centerX, centerY, native.systemFontBold, 16 )
			msg:setFillColor( 1, 0, 0 )
		end


		ui.timeLabel = display.newText( group, "Time:", 10, 90, 'Lato', 12 )
		ui.timeLabel.anchorX = 0
		ui.timeLabel.fill = Theme.colors.red

		-- ui.gyroYLabel = display.newText( group, "x Vel:", 10, 110, 'Lato', 12 )
		-- ui.gyroYLabel.anchorX = 0
		-- ui.gyroYLabel.fill = Theme.colors.green
		-- ui.gyroZLabel = display.newText( group, "y Vel:", 10, 130, 'Lato', 12 )
		-- ui.gyroZLabel.anchorX = 0
		-- ui.gyroZLabel.fill = Theme.colors.blue

		ui.timeDisp = display.newText( group, "0", 60, 90, 'Lato', 12 )
		ui.timeDisp.anchorX = 0
		ui.timeDisp.fill = Theme.colors.red

		-- ui.gyroY = display.newText( group, "0", 60, 110, 'Lato', 12 )
		-- ui.gyroY.anchorX = 0
		-- ui.gyroY.fill = Theme.colors.green
		-- ui.gyroZ = display.newText( group, "0", 60, 130, 'Lato', 12 )
		-- ui.gyroZ.anchorX = 0
		-- ui.gyroZ.fill = Theme.colors.blue

		ui.accelXLabel = display.newText( group, "X Accel:", centerX-40, 90, 'Lato', 12 )
		ui.accelXLabel.anchorX = 0
		ui.accelXLabel.fill = Theme.colors.red
		ui.accelYLabel = display.newText( group, "Y Accel:", centerX-40, 110, 'Lato', 12 )
		ui.accelYLabel.anchorX = 0
		ui.accelYLabel.fill = Theme.colors.green
		ui.accelZLabel = display.newText( group, "Z Accel:", centerX-40, 130, 'Lato', 12 )
		ui.accelZLabel.anchorX = 0
		ui.accelZLabel.fill = Theme.colors.blue

		ui.accelXDisp = display.newText( group, "0", centerX+10, 90, 'Lato', 12 )
		ui.accelXDisp.anchorX = 0
		ui.accelXDisp.fill = Theme.colors.red
		ui.accelYDisp = display.newText( group, "0", centerX+10, 110, 'Lato', 12 )
		ui.accelYDisp.anchorX = 0
		ui.accelYDisp.fill = Theme.colors.green
		ui.accelZDisp = display.newText( group, "0", centerX+10, 130, 'Lato', 12 )
		ui.accelZDisp.anchorX = 0
		ui.accelZDisp.fill = Theme.colors.blue

		ui.deltaXLabel = display.newText( group, "Delta X:", centerX+90, 90, 'Lato', 12 )
		ui.deltaXLabel.anchorX = 0
		ui.deltaXLabel.fill = Theme.colors.red
		ui.deltaYLabel = display.newText( group, "Delta Y:", centerX+90, 110, 'Lato', 12 )
		ui.deltaYLabel.anchorX = 0
		ui.deltaYLabel.fill = Theme.colors.green
		ui.deltaZLabel = display.newText( group, "Delta Z:", centerX+90, 130, 'Lato', 12 )
		ui.deltaZLabel.anchorX = 0
		ui.deltaZLabel.fill = Theme.colors.blue

		ui.deltaXDisp = display.newText( group, "0", centerX+150, 90, 'Lato', 12 )
		ui.deltaXDisp.anchorX = 0
		ui.deltaXDisp.fill = Theme.colors.red
		ui.deltaYDisp = display.newText( group, "0", centerX+150, 110, 'Lato', 12 )
		ui.deltaYDisp.anchorX = 0
		ui.deltaYDisp.fill = Theme.colors.green
		ui.deltaZDisp = display.newText( group, "0", centerX+150, 130, 'Lato', 12 )
		ui.deltaZDisp.anchorX = 0
		ui.deltaZDisp.fill = Theme.colors.blue


		ui.accelGraphBox = display.newRect( group, centerX, screenHeight*0.4, screenWidth-20, screenHeight*.3333 )
		ui.accelGraphBox.fill = { 0, 0, 0, 0 }
		ui.accelGraphBox.strokeWidth = 1
		ui.accelGraphBox:setStrokeColor( 1, 1, 1, 1 )

		
		ui.accelDots = {}
		ui.accelDots.xAxis = {}
		ui.accelDots.yAxis = {}
		ui.accelDots.zAxis = {}


	

		local deviceContainer = display.newContainer( screenWidth-20, screenHeight*.3333 )
		deviceContainer:translate( centerX, screenHeight*0.75 )

		--deviceContainer.anchorChildren = false
		--deviceContainer.anchorChildren = false


		local testBg = TiledBg:new({
			debug 				= true,
			group 				= deviceContainer,
			image 				= 'assets/images/bgs/grid-bg.jpg',
			tile_width 			= 2560,
			tile_height 		= 1600,
			sheet_width 		= 5000,
			sheet_height		= 5000

		})
		testBg.x = -testBg.contentWidth/2
		testBg.y = -testBg.contentHeight/2

		testBg:toBack()
		

		-- local deviceBg1 = display.newImage( deviceContainer, "assets/images/bgs/grid-bg.jpg" )
		-- deviceBg1.x, deviceBg1.y = 0, 0
		
		-- local deviceBg2 = display.newImage( deviceContainer, "assets/images/bgs/grid-bg.jpg" )
		-- deviceBg2.x, deviceBg2.y = deviceBg1.width, 0

		-- local deviceBg3 = display.newImage( deviceContainer, "assets/images/bgs/grid-bg.jpg" )
		-- deviceBg3.x, deviceBg3.y = 0, deviceBg2.height


		deviceContainer:toBack()


		local deviceGroup = display.newGroup()
		group:insert( deviceGroup )

		deviceGroup.anchorChildren = true

		ui.gravityFrameIndicator = display.newRect( deviceGroup, centerX, screenHeight*0.75, 1, 30 )
		ui.gravityFrameIndicator.anchorX, ui.gravityFrameIndicator.anchorY = 0.5, 1
		ui.gravityFrameIndicator.fill = Theme.colors.whiteGrey
		ui.gravityFrameIndicator:setStrokeColor( unpack( Theme.colors.whiteGrey ) )

		ui.gravityFrame = display.newCircle( deviceGroup, centerX, screenHeight*0.75, 20 )
		ui.gravityFrame.fill = { 0, 0, 0, 0 }
		ui.gravityFrame.strokeWidth = 1
		ui.gravityFrame:setStrokeColor( unpack( Theme.colors.whiteGrey ) )


		ui.deviceIndicator = display.newLine( deviceGroup, centerX, screenHeight*0.75, centerX, screenHeight*0.75 + 18 )
		ui.deviceIndicator:setStrokeColor( 1, 0, 1 )
		ui.deviceIndicator.anchorSegments = true
		ui.deviceIndicator.anchorX, ui.deviceIndicator.anchorY = 0.5, 1

		ui.device = display.newRoundedRect( deviceGroup, centerX, screenHeight*0.75, 8, 16, 4 )
		ui.device.fill = { 1, 0, 1 }
		ui.device.anchorX, ui.device.anchorY = 0.5, 0.5

		

		deviceGroup.x, deviceGroup.y = centerX, screenHeight*0.75


		local function stopCalibrating()
			isCalibrating = false

			deviceGroup.x = centerX 
			deviceGroup.y = screenHeight*0.75

			ui.deviceIndicator.rotation = 0

			ui.calibrationLabel.text = "xThresh: " .. xThreshold .. "\nyThresh: " .. yThreshold
		end

		local function stopStart()
			isActive = not( isActive )

			if isActive then
				-- clear movement data
				for k in pairs( movementData ) do
					movementData[k] = nil
				end
				ui.stopStartBtn.label.text = 'Stop'
			else
				deviceGroup.x, deviceGroup.y = centerX, screenHeight*0.75
				xVel, yVel = 0, 0
				ui.stopStartBtn.label.text = 'Start'
			end
			
		end

		ui.stopStartBtn = Btn:new({
				group 			= group,
				label			= "Start",
				x				= 60,
				y				= 180,
				width			= 80,
				height			= 40,
				fontSize		= 12,
				onRelease 		= stopStart
			})

		ui.calibrationBtn = Btn:new({
				group 			= group,
				label			= "Calibrate",
				x				= screenWidth-60,
				y				= 180,
				width			= 80,
				height			= 40,
				fontSize		= 12,
				onRelease 		= function() xThreshold=0; yThreshold=0; isCalibrating=true; ui.calibrationLabel.text = 'Calibrating - Hold Still!'; timer.performWithDelay( 30, stopCalibrating );  end
			})

		ui.calibrationLabel = display.newText( group, "xThresh: " ..xThreshold ..  "\nyThresh: " .. yThreshold, screenWidth-60, 220, 'Lato', 12 )


		local function eachFrame( e )

			if not( isActive ) then return end

			frameNum = frameNum + 1

			if Device.isSimulator then
				table.insert( movementData, { time=system.getTimer(), xAccel = math.random()/100, yAccel=math.random()/100, zAccel=math.random()/100 } )

				print( "Frame: " .. frameNum )

			end


			if #movementData > 300 then 
				-- keep roughly 5 seconds of data. Can cache or post to server
				print( "Movement Table Full")
				for k in pairs( movementData ) do
					movementData[k] = nil
				end
			end


			if isCalibrating then
				-- set xThresh, yThresh base on max jitter
				if movementData[#movementData] then
					if math.abs( movementData[#movementData].xAccel ) > xThreshold then 
						xThreshold = math.abs( movementData[#movementData].xAccel )
					end
					if math.abs( movementData[#movementData].yAccel ) > yThreshold then 
						yThreshold = math.abs( movementData[#movementData].yAccel )
					end
					if math.abs( movementData[#movementData].zAccel ) > zThreshold then 
						zThreshold = math.abs( movementData[#movementData].zAccel )
					end
				end
			end
			

			local lastXAccel = 0
			local lastYAccel = 0
			local lastZAccel = 0

			local prevXAccel = 0 
			local prevYAccel = 0
			local prevZAccel = 0

			local deltaXAccel = 0 
			local deltaYAccel = 0
			local deltaZAccel = 0

			local deltaTime = 0

			if movementData[#movementData] then
				lastXAccel = movementData[#movementData].xAccel
				lastYAccel = movementData[#movementData].yAccel
				lastZAccel = movementData[#movementData].zAccel
			end

			if movementData[#movementData-1] then
				prevXAccel = movementData[#movementData-1].xAccel
				deltaXAccel = ((lastXAccel+prevXAccel)/2) - prevXAccel -- ghetto smoothing: take the average of the last 2 readings

				prevYAccel = movementData[#movementData-1].yAccel
				deltaYAccel = ((lastYAccel+prevYAccel)/2) - prevYAccel

				prevZAccel = movementData[#movementData-1].zAccel
				deltaZAccel = ((lastZAccel+prevZAccel)/2) - prevZAccel

				deltaTime = movementData[#movementData].time - movementData[#movementData-1].time
			end


			-- calculate velocities based on accelerations and deltaTime
			-- assumes acceleration is "raw" e.g. meters/second, multiply by 9.80665 if g-units

			if math.abs( deltaXAccel ) > xThreshold then 
				xVel = xVel + deltaXAccel * deltaTime * 0.981 -- meters per second * seconds (deltaTime is in millis)
			end

			if math.abs( deltaYAccel ) > yThreshold then 
				yVel = yVel + deltaYAccel * deltaTime * 0.981
			end

			-- this assumes 1 pixel = 1 meter?

			-- apply velocities
			-- for now, lets just move the bg, not the device itself

			testBg.x = testBg.x - xVel
			testBg.y = testBg.y - yVel

			-- move thetrail with the bg
			for i=1, #deviceTrail do 
				deviceTrail[i].x = deviceTrail[i].x - xVel
				deviceTrail[i].y = deviceTrail[i].y - yVel
			end


			-- rotate the device based on gravity - gyro is useless

			ui.gravityFrameIndicator.rotation = math.atan2( -lastXAccel, -lastYAccel )*(180/math.pi)

			ui.device.rotation = math.atan2( lastXAccel, -lastYAccel )*(180/math.pi)
			ui.deviceIndicator.rotation = ui.device.rotation

			-- leave a trail
			if frameNum % 10 == 0 then

				local trailDot = display.newCircle( deviceContainer, 0, 0, 2 )
				
				trailDot:toFront()
				trailDot.fill = { 1, 0, 1 }
				table.insert( deviceTrail, trailDot )
			end






			-- graph the acceleration vectors

			local dotX = centerX
			if math.abs( deltaXAccel ) > xThreshold then
				dotX = centerX + (deltaXAccel*100)
			end
			newDot = display.newCircle( group, dotX, centerY-40, 1 )
			newDot.fill = Theme.colors.red

			table.insert( ui.accelDots.yAxis, 1, newDot)

			for i=1, #ui.accelDots.yAxis do
				ui.accelDots.yAxis[i].y = ui.accelDots.yAxis[i].y - 1
				--ui.accelDots.yAxis[i].alpha = ui.accelDots.yAxis[i].alpha * 0.988
			end

			local dotY = centerY-40
			if math.abs( deltaYAccel ) > yThreshold then
				dotY = centerY-40 + (deltaYAccel*100)
			end
			newDot = display.newCircle( group, centerX, dotY, 1 )
			newDot.fill = Theme.colors.green

			table.insert( ui.accelDots.xAxis, 1, newDot)

			for i=1, #ui.accelDots.xAxis do
				ui.accelDots.xAxis[i].x = ui.accelDots.xAxis[i].x - 1
			end



			for i in pairs( ui.accelDots ) do
				if #ui.accelDots[i] > 200 then
					ui.accelDots[i][#ui.accelDots[i]]:removeSelf()
					ui.accelDots[i][#ui.accelDots[i]] = nil
					table.remove( ui.accelDots[i] )
				end
				for k in pairs( ui.accelDots[i] ) do
					ui.accelDots[i][k].alpha = ui.accelDots[i][k].alpha * 0.991
				end
			end



			if Device.isSimulator then

				print( "Delta time: " .. deltaTime  )
				print( "DeltaXAccel: " .. deltaXAccel )
				print( "DeltaYAccel: " .. deltaYAccel )
				print( "xVel: " .. xVel .. ' meters per second' )
				print( "yVel: " .. yVel .. ' meters per second' )

			end

			ui.timeDisp.text = string.format( "%1.3f", deltaTime )

			ui.accelXDisp.text = string.format( "%1.3f", lastXAccel )
			ui.accelYDisp.text = string.format( "%1.3f", lastYAccel )
			ui.accelZDisp.text = string.format( "%1.3f", lastZAccel )

			ui.deltaXDisp.text = string.format( "%1.3f", deltaXAccel )
			ui.deltaYDisp.text = string.format( "%1.3f", deltaYAccel )
			ui.deltaZDisp.text = string.format( "%1.3f", deltaZAccel )
			

			


		end



		local function onAccelerate( event )
			-- keep track of the last 5 seconds of acceleration data
			table.insert( movementData, { time=system.getTimer(), xAccel=event.xGravity, yAccel=event.yGravity, zAccel=event.zGravity } )
		end


		Runtime:addEventListener ("accelerometer", onAccelerate)

		Runtime:addEventListener ("enterFrame", eachFrame)

	end
	
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then
		system.setAccelerometerInterval( 10 )
		Runtime:removeEventListener("accelerometer")
		Runtime:removeEventListener("gyroscope")

		--physics.stop()


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

