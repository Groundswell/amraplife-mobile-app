
local sysGetTimer = system.getTimer
local sysSetIdle = system.setIdleTimer
local mFloor = math.floor
local mAbs = math.abs

local Debug = require( 'utilities.debug' )


local function get_ms( time )
	return mFloor( time % 1000 )
end

local function get_hundredths( time )
	return mFloor( get_ms( time ) / 10 )
end

local function get_seconds( time, formatDisp )
	if formatDisp == nil then formatDisp = true end
	if formatDisp then 
		return mFloor( time / 1000 ) % 60
	else
		return mFloor( time / 1000 )
	end
end

local function get_minutes( time, formatDisp )
	if formatDisp == nil then formatDisp = true end
	if formatDisp then
		return mFloor( get_seconds( time, false ) / 60 ) % 60
	else 
		return mFloor( get_seconds( time, false ) / 60 )
	end
end

local function get_hours( time, formatDisp )
	if formatDisp == nil then formatDisp = true end
	if formatDisp then
		return mFloor( get_minutes( time, false ) / 60 ) % 60
	else 
		return mFloor( get_minutes( time, false ) / 60 )
	end
end


local M = {}

M.getHours = get_hours
M.getMinutes = get_minutes
M.getSeconds = get_seconds
M.getHundredths = get_hundredths

function M.humanizeTime( opts )
	opts = opts or {} 
	local time = opts.time
	if opts.secs then time = time * 1000 end

	return string.format( "%02d", get_minutes( time ) ) .. ':' .. string.format( "%02d", get_seconds( time ) ) .. '.' .. string.format( "%02d", get_hundredths( time ) )
end

-- The defaults for a new clock
M.defaults = { 
	font			= 'digital-7-mono.ttf',
	fontSize		= 80,
	fontFill		= { 1, 0, 0, 1 },
	showHunds 		= false,
	showHours 		= false,
	x 				= centerX,
	y				= centerY,
	hourSep 		= ":",
	minSep 			= ":",
	startAt			= 0, 	-- in seconds
	endAt			= 60 	-- time to end at. Always ends at 0. -1 means run forever until stopped by code.
}

function M:new( opts )
	if opts == nil then opts = M.defaults end
	
	-- fill in any missing opts from module defaults
	for key, value in pairs( M.defaults ) do
		if opts[key] == nil then 
			opts[key] = M.defaults[key]
		end
	end

	-- convert secs to millisecs
	-- NO, DON'T DO THIS
	-- opts.startAt = opts.startAt * 1000
	-- opts.endAt = opts.endAt * 1000

	local clock = display.newGroup()

	if opts.group then 
		opts.group:insert( clock )
	elseif opts.parent then 
		opts.parent:insert( clock )
	end


	if opts.debug then 
		print( "clock is currently : " .. clock.status  )
		print( "  clock will run for " .. get_minutes( clock.duration ) .. "mins " .. clock.direction .. " from " .. clock.startAt .. "ms to " .. clock.endAt .. "ms" )
	end

	if opts.showHours then 
		clock.hourSep = display.newText({
			parent 		= clock,
			text 		= opts.hourSep,
			x 			= opts.x,
			y 			= opts.y,
			font 		= opts.font,
			fontSize 	= opts.fontSize
			})
		clock.hourSep.fill = opts.fontFill
		if not( clock.hourSep.text == ':' ) and not( clock.hourSep.text == '.' ) then 
			clock.hourSep:scale( 0.5, 0.5 )
			clock.hourSep.y = clock.hourSep.y + clock.hourSep.contentHeight * 0.25
		end

		clock.hoursDisplay = display.newText({
			parent 		= clock,
			text 		= string.format( "%02d", get_hours( opts.startAt ) ),
			x 			= opts.x,
			y 			= opts.y,
			font 		= opts.font,
			fontSize 	= opts.fontSize
			})
		clock.hoursDisplay.fill = opts.fontFill 
	end

	clock.minSep = display.newText({
		parent 		= clock,
		text 		= opts.minSep,
		x 			= opts.x,
		y 			= opts.y,
		font 		= opts.font,
		fontSize 	= opts.fontSize
		})
	clock.minSep.fill = opts.fontFill
	if not( clock.minSep.text == ':' ) and not( clock.minSep.text == '.' ) then 
		clock.minSep:scale( 0.5, 0.5 )
		clock.minSep.y = clock.minSep.y + clock.minSep.contentHeight * 0.25
	end

	clock.minDisplay = display.newText({
		parent 		= clock,
		text 		= string.format( "%02d", get_minutes( opts.startAt ) ),
		x 			= opts.x,
		y 			= opts.y,
		font 		= opts.font,
		fontSize 	= opts.fontSize
		})
	clock.minDisplay.fill = opts.fontFill 

	clock.secDisplay = display.newText({
		parent 		= clock,
		text 		= string.format( "%02d", get_seconds( opts.startAt ) ),
		x 			= opts.x,
		y 			= opts.y,
		font 		= opts.font,
		fontSize 	= opts.fontSize
		})
	clock.secDisplay.fill = opts.fontFill 

	if opts.showHunds then
		clock.hundsDisplay = display.newText({
			parent 		= clock,
			text 		= string.format( "%02d", get_hundredths( opts.startAt ) ),
			x 			= opts.x,
			y 			= opts.y,
			font 		= opts.font,
			fontSize 	= opts.fontSize / 2
			})
		clock.hundsDisplay.fill = opts.fontFill 
		clock.hundsDisplay.anchorY = 1
		clock.hundsDisplay.y = opts.y + (clock.minDisplay.contentHeight / 2.5 ) 
	end

	clock.minDisplay.x = (opts.x - clock.minDisplay.contentWidth / 1.5)
	clock.secDisplay.x = (opts.x + clock.secDisplay.contentWidth / 1.5)
	
	if opts.showHunds then clock.hundsDisplay.x = clock.secDisplay.x + clock.secDisplay.contentWidth end
	if opts.showHours then 
		clock.hoursDisplay.x = clock.minDisplay.x - clock.minDisplay.contentWidth * 1.25
		clock.hourSep.x = clock.minDisplay.x - clock.minDisplay.contentWidth / 1.66
	end

	clock.anchorChildren = true 
	clock.anchorX, clock.anchorY = 0.5, 0.5
	clock.x = opts.x
	clock.y = opts.y

	function clock:cleanup()
		Runtime:removeEventListener( 'enterFrame', self )
		sysSetIdle( true )
		display.remove( self )
	end

	function clock:start()
		if opts.debug then print( "starting clock. Status is: " .. self.status ) end
		if self.status == 'running' then 
			-- if running already, just bail. Do nothing.
			return true 
		end
		-- any other status (e.g. start or resume from pause )
		-- set status and kicks off the frame listener

		-- to turn off screen timeout
		sysSetIdle( false )
		self.lastTickTime = sysGetTimer()
		self.status = 'running'
		Runtime:addEventListener( 'enterFrame', self )
		if opts.debug then print( "Cloack started. Status is: " .. self.status  ) end
	end

	function clock:pause()
		if self.status == 'running'	then 
			Runtime:removeEventListener( 'enterFrame', self )
			-- to turn screen timeout back on 
			sysSetIdle( true )
			self.status = 'paused'
			if opts.debug then print( "Clock Paused. Elapsed time: " .. clock.elapsedTime ) end
		end
	end

	function clock:reset( start_at, end_at )
		start_at = start_at or 0
		end_at = end_at or -1

		clock.status = 'initialized'
		clock.startAt = start_at
		clock.endAt = end_at
		clock.duration = mAbs( clock.endAt - clock.startAt )
		clock.elapsedTime = 0
		clock.lastTickTime = 0
		clock.displayTime = clock.startAt
		
		if clock.endAt < 0 then
			-- end_at = -1 is continuous running upward timer
			clock.direction = 'up'
			clock.duration = -1
		elseif clock.endAt == 0 then
			clock.direction = 'down'
		elseif clock.startAt < clock.endAt then
			clock.direction = 'up'
		else
			clock.direction = 'down'
		end

		self:updateDisplay()
	end

	function clock:enterFrame( e )
		if self.status == 'running' then
			local tickDuration = sysGetTimer() - self.lastTickTime
			
			self.elapsedTime = self.elapsedTime + tickDuration

			if self then self:dispatchEvent( { name = 'tick', target = self } ) end

			if( self.direction == 'up' ) then
				self.displayTime = self.displayTime + tickDuration
			else
				self.displayTime = self.displayTime - tickDuration
			end

			if self.duration > 0 and self.elapsedTime >= self.duration then 
				-- we've run long enough. Stop the clock. Stop the madness.
				self:pause()
				-- set the clock to an even display just to account for random frame variations
				self.displayTime = clock.endAt
				self:updateDisplay()

				print( "Time's Up!" )
				self:dispatchEvent( { name = 'timesUp', target = self } )
			end

			self.lastTickTime = sysGetTimer()

			self:updateDisplay()
		end
	end

	function clock:getX()
		return self.minDisplay.x
	end

	function clock:getY()
		return self.minDisplay.y
	end

	function clock:getHW()
		-- ToDo
		local h, w 
		h = self.minDisplay.contentHeight + self.secDisplay.contentHeight
		w = self.minDisplay.contentWidth + self.secDisplay.contentWidth
		-- add hours, huns if present
		-- add x & y offset distances
		return h, w
	end


	function clock:human_string( time_type )
		time_type = time_type or 'elapsed'

		local time = self.elapsedTime

		if time_type == 'current' then
			time = self.displayTime
		end

		return M.humanizeTime({ time = time })

	end

	function clock:updateDisplay()
		self.minDisplay.text = string.format( "%02d", get_minutes( self.displayTime ) )
		local secs = get_seconds( self.displayTime )
		secs = secs % 60
		self.secDisplay.text = string.format( "%02d", secs )
		if opts.showHunds then self.hundsDisplay.text = string.format( "%02d", get_hundredths( self.displayTime ) ) end
		if opts.showHours then self.hoursDisplay.text = string.format( "%02d", get_hours( self.displayTime ) ) end
	end


	clock:reset( opts.startAt, opts.endAt )

	return clock

end


return M