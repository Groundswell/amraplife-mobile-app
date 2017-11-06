
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


		ui.gyroXLabel = display.newText( group, "gyro x:", 10, 100, 'Lato', 12 )
		ui.gyroXLabel.anchorX = 0
		ui.gyroXLabel.fill = Theme.colors.red
		ui.gyroYLabel = display.newText( group, "gyro y:", 10, 120, 'Lato', 12 )
		ui.gyroYLabel.anchorX = 0
		ui.gyroYLabel.fill = Theme.colors.green
		ui.gyroZLabel = display.newText( group, "gyro z:", 10, 140, 'Lato', 12 )
		ui.gyroZLabel.anchorX = 0
		ui.gyroZLabel.fill = Theme.colors.blue

		ui.gyroX = display.newText( group, "0", 60, 100, 'Lato', 12 )
		ui.gyroX.anchorX = 0
		ui.gyroX.fill = Theme.colors.red
		ui.gyroY = display.newText( group, "0", 60, 120, 'Lato', 12 )
		ui.gyroY.anchorX = 0
		ui.gyroY.fill = Theme.colors.green
		ui.gyroZ = display.newText( group, "0", 60, 140, 'Lato', 12 )
		ui.gyroZ.anchorX = 0
		ui.gyroZ.fill = Theme.colors.blue

		ui.accelXLabel = display.newText( group, "accel x:", centerX-40, 100, 'Lato', 12 )
		ui.accelXLabel.anchorX = 0
		ui.accelXLabel.fill = Theme.colors.red
		ui.accelYLabel = display.newText( group, "accel y:", centerX-40, 120, 'Lato', 12 )
		ui.accelYLabel.anchorX = 0
		ui.accelYLabel.fill = Theme.colors.green
		ui.accelZLabel = display.newText( group, "accel z:", centerX-40, 140, 'Lato', 12 )
		ui.accelZLabel.anchorX = 0
		ui.accelZLabel.fill = Theme.colors.blue

		ui.accelX = display.newText( group, "0", centerX+10, 100, 'Lato', 12 )
		ui.accelX.anchorX = 0
		ui.accelX.fill = Theme.colors.red
		ui.accelY = display.newText( group, "0", centerX+10, 120, 'Lato', 12 )
		ui.accelY.anchorX = 0
		ui.accelY.fill = Theme.colors.green
		ui.accelZ = display.newText( group, "0", centerX+10, 140, 'Lato', 12 )
		ui.accelZ.anchorX = 0
		ui.accelZ.fill = Theme.colors.blue

		ui.instantXLabel = display.newText( group, "instant x:", centerX+90, 100, 'Lato', 12 )
		ui.instantXLabel.anchorX = 0
		ui.instantXLabel.fill = Theme.colors.red
		ui.instantYLabel = display.newText( group, "instant y:", centerX+90, 120, 'Lato', 12 )
		ui.instantYLabel.anchorX = 0
		ui.instantYLabel.fill = Theme.colors.green
		ui.instantZLabel = display.newText( group, "instant z:", centerX+90, 140, 'Lato', 12 )
		ui.instantZLabel.anchorX = 0
		ui.instantZLabel.fill = Theme.colors.blue

		ui.instantX = display.newText( group, "0", centerX+150, 100, 'Lato', 12 )
		ui.instantX.anchorX = 0
		ui.instantX.fill = Theme.colors.red
		ui.instantY = display.newText( group, "0", centerX+150, 120, 'Lato', 12 )
		ui.instantY.anchorX = 0
		ui.instantY.fill = Theme.colors.green
		ui.instantZ = display.newText( group, "0", centerX+150, 140, 'Lato', 12 )
		ui.instantZ.anchorX = 0
		ui.instantZ.fill = Theme.colors.blue


		local accelGraphBox = display.newRect( group, centerX, 280, screenWidth-20, 225 )
		accelGraphBox.fill = { 0, 0, 0, 0 }
		accelGraphBox.strokeWidth = 1
		accelGraphBox:setStrokeColor( 1, 1, 1, 1 )

		ui.accelXdots = {}
		ui.accelYdots = {}
		ui.accelZdots = {}

		
		ui.accelZdot = display.newCircle( group, centerX, centerY-40, 3 )
		ui.accelZdot.fill = Theme.colors.blue

		ui.accelXdot = display.newCircle( group, centerX, centerY-40, 3 )
		ui.accelXdot.fill = Theme.colors.red

		ui.accelYdot = display.newCircle( group, centerX, centerY-40, 3 )
		ui.accelYdot.fill = Theme.colors.green

		


		-- lets test a ragdoll

		physics.start()
		
		--physics.setDrawMode( "hybrid" )
		
		physics.setGravity( 0, 0.5 )
		physics.pause()

		local ground = display.newRect( group, centerX, screenHeight-10, screenWidth, 10 )
		ground.fill = Theme.colors.dkGreen
		physics.addBody( ground, "static", { bounce=0.2, friction=0.99} )

		local ceiling = display.newRect( group, centerX, screenHeight-280, screenWidth, 1 )
		ceiling.fill = { 0, 0, 0, 0 }
		physics.addBody( ceiling, "static", { bounce=0.2, friction=0.99} )

		local lWall= display.newRect( group, -2, screenHeight-100, 1, 250 )
		lWall.fill = Theme.colors.dkGreen
		physics.addBody( lWall, "static", { bounce=0.2, friction=0.99} )

		local rWall= display.newRect( group, screenWidth+2, screenHeight-100, 1, 250 )
		rWall.fill = Theme.colors.dkGreen
		physics.addBody( rWall, "static", { bounce=0.2, friction=0.99} )

		



		local head = display.newCircle( group, centerX+ 5, screenHeight-198, 16 )
		head.fill = Theme.colors.yellow
		physics.addBody( head, "dynamic", {density=0.01, friction=0.9, bounce=0.2, radius=8} )

		local torso = display.newRect( group, centerX, screenHeight-145, 10, 68 )
		torso.fill = Theme.colors.blue
		physics.addBody( torso, "dynamic", {density=1, friction=0.9, bounce=0.2} )
		
		local neckJoint = physics.newJoint( "pivot", head, torso, head.x, head.y, torso.x, torso.y-30 )

		local arm = display.newRect( group, centerX+30, screenHeight-170, 62, 10 )
		arm.fill = Theme.colors.yellow
		physics.addBody( arm, "dynamic", {density=1, friction=0.9, bounce=0.2} )

		local shoulderJoint = physics.newJoint( "pivot", torso, arm, torso.x+5, torso.y-20, arm.x-32, arm.y )
		--shoulderJoint


		local femur = display.newRect( group, centerX, screenHeight-90, 10, 50 )
		femur.fill = Theme.colors.red
		physics.addBody( femur, "dynamic", {density=1, friction=0.9, bounce=0.2} )


		local hipJoint = physics.newJoint( "pivot", torso, femur, torso.x, torso.y+34, femur.x, femur.y-25 )
		hipJoint.isLimitEnabled = true
		hipJoint:setRotationLimits( -140, 15 )


		local tibia = display.newRect( group, centerX, screenHeight-45, 10, 42 )
		tibia.fill = Theme.colors.yellow
		physics.addBody( tibia, "dynamic", {density=1, friction=0.9, bounce=0.2} )

		local kneeJoint = physics.newJoint( "pivot", femur, tibia, femur.x, femur.y+25, tibia.x, tibia.y-21 )
		kneeJoint.isLimitEnabled = true
		kneeJoint:setRotationLimits( -15, 150 )

		local foot = display.newRect( group, centerX+8, screenHeight-20, 35, 8 )
		foot.fill = Theme.colors.red
		physics.addBody( foot, "dynamic", {density=20, friction=0.9, bounce=0.1} )

		local ankleJoint = physics.newJoint( "pivot", tibia, foot, tibia.x, tibia.y+21, foot.x, foot.y-5 )
		ankleJoint.isLimitEnabled = true
		ankleJoint:setRotationLimits( -25, 60 )
		
		physics.start()

		--torso:applyLinearImpulse( -1, -1, torso.x, torso.y+34 )


		local deviceFrame = display.newCircle( group, centerX + screenWidth*0.333, centerY-40, 30 )
		deviceFrame.fill = { 0, 0, 0, 0 }
		deviceFrame.strokeWidth = 1
		deviceFrame:setStrokeColor( unpack( Theme.colors.blue) )

		local deviceIndicator = display.newLine( group, centerX + screenWidth*0.333, centerY-10, centerX + screenWidth*0.333, centerY-70 )
		deviceIndicator:setStrokeColor( 1, 0, 1 )
		deviceIndicator.anchorSegments = true
		deviceIndicator.anchorX, deviceIndicator.anchorY = 0.5, 0.5
		deviceIndicator.y = centerY-40
		
		local device = display.newRoundedRect( group, centerX + screenWidth*0.333, centerY-40, 10, 20, 4 )
		device.fill = { 1, 0, 1 }
		device.anchorX, device.anchorY = 0.5, 0.5


		local function onGyro( event )
			ui.gyroX.text = string.format( "%1.3f", event.xRotation*(180/math.pi) )
			ui.gyroY.text = string.format( "%1.3f", event.yRotation*(180/math.pi) )
			ui.gyroZ.text = string.format( "%1.3f", event.zRotation *(180/math.pi))

			device:rotate( event.xRotation*(180/math.pi) )
			deviceIndicator:rotate( event.xRotation*(180/math.pi) )


		end

		local function onAccelerate( event )
			ui.accelX.text = string.format( "%1.3f", event.xGravity )
			ui.accelY.text = string.format( "%1.3f", event.yGravity )
			ui.accelZ.text = string.format( "%1.3f", event.zGravity )

			ui.instantX.text = string.format( "%1.3f", event.xInstant )
			ui.instantY.text = string.format( "%1.3f", event.yInstant )
			ui.instantZ.text = string.format( "%1.3f", event.zInstant )

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


			if event.xInstant > 0.01 or event.yInstant > 0.01 then
				torso:applyLinearImpulse( event.xInstant, event.yInstant, torso.x, torso.y+34 )
			end
		end

		Runtime:addEventListener ("accelerometer", onAccelerate)
		Runtime:addEventListener ("gyroscope", onGyro)

	

	end
	
end

function scene:hide( event )
	local group = self.view

	if event.phase == "will" then
		system.setAccelerometerInterval( 10 )
		Runtime:removeEventListener("accelerometer")
		Runtime:removeEventListener("gyroscope")

		physics.stop()


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

