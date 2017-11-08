
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

local physics = require( "physics" )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local ui = {}



-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view

end

function scene:show( event )
	local group = self.view

	if event.phase == "will" then
		Composer.setVariable( 'prevScene', 'scenes.home' )

		system.setAccelerometerInterval( 60 )

		ui.header = UI:setHeader({
			parent 	= group,
			title 	= 'HuME',
			x 		= centerX,
			y 		= 0,
			width 	= screenWidth,
			height 	= 50
			})


		if not( system.hasEventSource("gyroscope")) or not( system.hasEventSource("accelerometer") ) then
			local msg = display.newText( group, "Motion events not supported on this device", centerX, centerY, native.systemFontBold, 16 )
			msg:setFillColor( 1, 0, 0 )
		end


		ui.gyroXLabel = display.newText( group, "gyro x:", 10, 90, 'Lato', 12 )
		ui.gyroXLabel.anchorX = 0
		ui.gyroXLabel.fill = Theme.colors.red
		ui.gyroYLabel = display.newText( group, "gyro y:", 10, 110, 'Lato', 12 )
		ui.gyroYLabel.anchorX = 0
		ui.gyroYLabel.fill = Theme.colors.green
		ui.gyroZLabel = display.newText( group, "gyro z:", 10, 130, 'Lato', 12 )
		ui.gyroZLabel.anchorX = 0
		ui.gyroZLabel.fill = Theme.colors.blue

		ui.gyroX = display.newText( group, "0", 60, 90, 'Lato', 12 )
		ui.gyroX.anchorX = 0
		ui.gyroX.fill = Theme.colors.red
		ui.gyroY = display.newText( group, "0", 60, 110, 'Lato', 12 )
		ui.gyroY.anchorX = 0
		ui.gyroY.fill = Theme.colors.green
		ui.gyroZ = display.newText( group, "0", 60, 130, 'Lato', 12 )
		ui.gyroZ.anchorX = 0
		ui.gyroZ.fill = Theme.colors.blue

		ui.accelXLabel = display.newText( group, "accel x:", centerX-40, 90, 'Lato', 12 )
		ui.accelXLabel.anchorX = 0
		ui.accelXLabel.fill = Theme.colors.red
		ui.accelYLabel = display.newText( group, "accel y:", centerX-40, 110, 'Lato', 12 )
		ui.accelYLabel.anchorX = 0
		ui.accelYLabel.fill = Theme.colors.green
		ui.accelZLabel = display.newText( group, "accel z:", centerX-40, 130, 'Lato', 12 )
		ui.accelZLabel.anchorX = 0
		ui.accelZLabel.fill = Theme.colors.blue

		ui.accelX = display.newText( group, "0", centerX+10, 90, 'Lato', 12 )
		ui.accelX.anchorX = 0
		ui.accelX.fill = Theme.colors.red
		ui.accelY = display.newText( group, "0", centerX+10, 110, 'Lato', 12 )
		ui.accelY.anchorX = 0
		ui.accelY.fill = Theme.colors.green
		ui.accelZ = display.newText( group, "0", centerX+10, 130, 'Lato', 12 )
		ui.accelZ.anchorX = 0
		ui.accelZ.fill = Theme.colors.blue

		ui.instantXLabel = display.newText( group, "instant x:", centerX+90, 90, 'Lato', 12 )
		ui.instantXLabel.anchorX = 0
		ui.instantXLabel.fill = Theme.colors.red
		ui.instantYLabel = display.newText( group, "instant y:", centerX+90, 110, 'Lato', 12 )
		ui.instantYLabel.anchorX = 0
		ui.instantYLabel.fill = Theme.colors.green
		ui.instantZLabel = display.newText( group, "instant z:", centerX+90, 130, 'Lato', 12 )
		ui.instantZLabel.anchorX = 0
		ui.instantZLabel.fill = Theme.colors.blue

		ui.instantX = display.newText( group, "0", centerX+150, 90, 'Lato', 12 )
		ui.instantX.anchorX = 0
		ui.instantX.fill = Theme.colors.red
		ui.instantY = display.newText( group, "0", centerX+150, 110, 'Lato', 12 )
		ui.instantY.anchorX = 0
		ui.instantY.fill = Theme.colors.green
		ui.instantZ = display.newText( group, "0", centerX+150, 130, 'Lato', 12 )
		ui.instantZ.anchorX = 0
		ui.instantZ.fill = Theme.colors.blue


		ui.accelGraphBox = display.newRect( group, centerX, screenHeight*0.4, screenWidth-20, screenHeight*.3333 )
		ui.accelGraphBox.fill = { 0, 0, 0, 0 }
		ui.accelGraphBox.strokeWidth = 1
		ui.accelGraphBox:setStrokeColor( 1, 1, 1, 1 )

		ui.accelXdots = {}
		ui.accelYdots = {}
		ui.accelZdots = {}

		
		ui.accelZdot = display.newCircle( group, centerX, centerY-40, 3 )
		ui.accelZdot.fill = Theme.colors.blue

		ui.accelXdot = display.newCircle( group, centerX, centerY-40, 3 )
		ui.accelXdot.fill = Theme.colors.red

		ui.accelYdot = display.newCircle( group, centerX, centerY-40, 3 )
		ui.accelYdot.fill = Theme.colors.green

	

		ui.deviceGraphBox = display.newRect( group, centerX, screenHeight*0.75, screenWidth-20, screenHeight*.3333 )
		ui.deviceGraphBox.fill = { 0, 0, 0, 0 }
		ui.deviceGraphBox.strokeWidth = 1
		ui.deviceGraphBox:setStrokeColor( 1, 1, 1, 1 )



		local deviceGroup = display.newGroup()
		group:insert( deviceGroup )

		deviceGroup.anchorChildren = true

		ui.gravityFrameIndicator = display.newRect( deviceGroup, centerX, screenHeight*0.75, 1, 30 )
		ui.gravityFrameIndicator.anchorX, ui.gravityFrameIndicator.anchorY = 0.5, 1
		ui.gravityFrameIndicator.fill = Theme.colors.blue
		ui.gravityFrameIndicator:setStrokeColor( unpack( Theme.colors.blue) )

		ui.gravityFrame = display.newCircle( deviceGroup, centerX, screenHeight*0.75, 20 )
		ui.gravityFrame.fill = Theme.colors.coal
		ui.gravityFrame.strokeWidth = 1
		ui.gravityFrame:setStrokeColor( unpack( Theme.colors.blue) )


		ui.deviceIndicator = display.newLine( deviceGroup, centerX, screenHeight*0.75, centerX, screenHeight*0.75 + 18 )
		ui.deviceIndicator:setStrokeColor( 1, 0, 1 )
		ui.deviceIndicator.anchorSegments = true
		ui.deviceIndicator.anchorX, ui.deviceIndicator.anchorY = 0.5, 1

		ui.device = display.newRoundedRect( deviceGroup, centerX, screenHeight*0.75, 8, 16, 4 )
		ui.device.fill = { 1, 0, 1 }
		ui.device.anchorX, ui.device.anchorY = 0.5, 0.5

		



		-- lets test physics

		physics.start()
		
		--physics.setDrawMode( "hybrid" )
		
		physics.setGravity( 0, 0 )
		physics.pause()

		local dot = display.newCircle( centerX, screenHeight*0.75, 8 )
		physics.addBody( dot, "dynamic", { density=1, friction=0.9, bounce=0.2, radius=4 } )
		dot.fill = { 1, 1, 1, 0.25 }

		dot.linearDamping = 2

		deviceGroup.x, deviceGroup.y = dot.x, dot.y


		physics.start()

		local function eachFrame( e )
			
			-- dot:applyForce( 0, 0.2, dot.x, dot.y )
			-- dot:applyForce( 0.12, 0, dot.x, dot.y )

			-- if dot.x > screenWidth - 30 then
			-- 	dot.x = screenWidth - 30
			-- elseif dot.x < 10 then
			-- 	dot.x = 10
			-- end 

			-- if dot.y > screenHeight*0.75+(screenHeight*0.333/2)-20 then
			-- 	dot.y = screenHeight*0.75+(screenHeight*0.333/2)-20
			-- elseif dot.y < screenHeight*0.75-(screenHeight*0.333/2)+20 then
			-- 	dot.y = screenHeight*0.75-(screenHeight*0.333/2)+20
			-- end 


			-- deviceGroup.x, deviceGroup.y = dot.x, dot.y


		end


		local function onGyro( event )
			ui.gyroX.text = string.format( "%1.3f", event.xRotation*(180/math.pi) )
			ui.gyroY.text = string.format( "%1.3f", event.yRotation*(180/math.pi) )
			ui.gyroZ.text = string.format( "%1.3f", event.zRotation *(180/math.pi))

		end

		local function onAccelerate( event )
			print( "yInstant is: " .. event.yInstant )



			ui.accelX.text = string.format( "%1.3f", event.xGravity )
			ui.accelY.text = string.format( "%1.3f", event.yGravity )
			ui.accelZ.text = string.format( "%1.3f", event.zGravity )

			ui.instantX.text = string.format( "%1.3f", event.xInstant )
			ui.instantY.text = string.format( "%1.3f", event.yInstant )
			ui.instantZ.text = string.format( "%1.3f", event.zInstant )


			if math.abs( event.xInstant ) > 0.01 then
				dot:applyForce( event.xInstant*5, 0, dot.x, dot.y )
			end

			if math.abs( event.yInstant ) > 0.01 then
				dot:applyForce( 0, event.yInstant*5, dot.x, dot.y )
			end


		--	dot:applyForce( event.xInstant, event.yInstant, dot.x, dot.y )

			
			if dot.x > screenWidth - 30 then
				dot.x = screenWidth - 30
			elseif dot.x < 10 then
				dot.x = 10
			end 

			if dot.y > screenHeight*0.75+(screenHeight*0.333/2)-20 then
				dot.y = screenHeight*0.75+(screenHeight*0.333/2)-20
			elseif dot.y < screenHeight*0.75-(screenHeight*0.333/2)+20 then
				dot.y = screenHeight*0.75-(screenHeight*0.333/2)+20
			end 


			--deviceGroup.x, deviceGroup.y = dot.x, dot.y


			ui.gravityFrameIndicator.rotation = math.atan2( -event.xGravity, -event.yGravity )*(180/math.pi)

			ui.device.rotation = math.atan2( event.xGravity, -event.yGravity )*(180/math.pi)
			ui.deviceIndicator.rotation = ui.device.rotation


			ui.accelYdot.y = centerY-40 + (event.yInstant*80)
			
			local newYDot = display.newCircle( group, ui.accelYdot.x, ui.accelYdot.y, 1 )
			newYDot.fill = Theme.colors.green

			table.insert( ui.accelYdots, 1, newYDot )

			-- limit the length of the 'trail' to 500 dots
			if #ui.accelYdots > 500 then 
				table.remove( ui.accelYdots )
			end

			for i=1, #ui.accelYdots do
				ui.accelYdots[i].x = ui.accelYdots[i].x - 1
				ui.accelYdots[i].alpha = ui.accelYdots[i].alpha * 0.981
			end


			ui.accelXdot.x = centerX + (event.xInstant*80)
			local newXDot = display.newCircle( group, ui.accelXdot.x, ui.accelXdot.y, 1 )
			newXDot.fill = Theme.colors.red

			table.insert( ui.accelXdots, 1, newXDot )

			if #ui.accelXdots > 500 then 
				table.remove( ui.accelXdots )
			end

			for i=1, #ui.accelXdots do
				ui.accelXdots[i].y = ui.accelXdots[i].y - 1
				ui.accelXdots[i].alpha = ui.accelXdots[i].alpha * 0.981
			end

			ui.accelZdot.x = centerX + (event.zInstant*80)
			local newZDot = display.newCircle( group, ui.accelZdot.x, ui.accelZdot.y, 1 )
			newZDot.fill = Theme.colors.blue

			table.insert( ui.accelZdots, 1, newZDot )

			if #ui.accelZdots > 500 then 
				table.remove( ui.accelZdots )
			end

			for i=1, #ui.accelZdots do
				ui.accelZdots[i].y = ui.accelZdots[i].y - 1
				ui.accelZdots[i].x = ui.accelZdots[i].x - 1
				ui.accelZdots[i].alpha = ui.accelZdots[i].alpha * 0.981
			end

		end

		Runtime:addEventListener ("accelerometer", onAccelerate)
		Runtime:addEventListener ("gyroscope", onGyro)


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

