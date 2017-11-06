
local osDate = os.date
local osTime = os.time

local Clock = require( 'objects.clock' )
local Composer = require( 'composer' )
local Theme = require( 'ui.theme' )
local UI = require( 'ui.factory' )
local Btn = require( 'ui.btn' )
local json = require( 'json' )
local TextToSpeech = require( 'plugin.texttospeech' )

local Debug = require( 'utilities.debug' )

local FileUtils = require( "utilities.file" )

local M = {}



M.defaults = {
	slug 	= 'cindy'
}

function M:new( opts )
	local Layout = require( 'ui.layout_' .. screenOrient )

	if opts == nil then opts = M.defaults end
	
	-- fill in any missing opts from module defaults
	for key, value in pairs( M.defaults ) do
		if opts[key] == nil then 
			opts[key] = M.defaults[key]
		end
	end

	local workout = display.newGroup()
	workout.isVisible = false 

	local settings = FileUtils.loadTable( "settings.json" )
	-- have to initialize settings in case file doesn't exist
	settings = settings or default_settings

	settings.audio = settings.audioVolume > 0
	audio.setVolume( settings.audioVolume )

	if opts.group then 
		opts.group:insert( workout )
	elseif opts.parent then 
		opts.parent:insert( workout )
	end

	workout.status = 'initialized'
	workout.slug = opts.slug
	workout.curSegmentIdx = 1

	workout.results = {}
	workout.anims = {}
	workout.audio = {}

	workout.audio.count = audio.loadSound( 'assets/audio/count_tone.mp3' )
	workout.audio.go = audio.loadSound( 'assets/audio/go_tone.wav' )
	workout.audio.round = audio.loadSound( 'assets/audio/powerup.wav' )
	workout.audio.finished = audio.loadSound( 'assets/audio/buzzer.mp3' )


	workout.totalRoundCount = 0
	workout.lastResultTime = 0

	workout.curSegment = {}

	-- workout display
	-- this is portrait
	-- ToDo Adjust layout for landscape


	workout.header = UI:setHeader({
			parent 	= workout,
			title 	= 'A Workout',
			x 		= Layout.centerX,
			y 		= 0,
			width 	= Layout.width,
			height 	= Layout.headerHeight
			})

	workout.clock = Clock:new({
		parent 		= workout,
		x 			= Layout.workout.clockX,
		y 			= Layout.workout.clockY,
		fontSize 	= Layout.workout.clockFontSize,
		fontFill 	= Theme.colors.dkRed,
		startAt 	= 0,
		endAt 		= -1,
		showHunds 	= true
		})
	workout.clock.anchorY = 0

	workout.infoDisplay = display.newText({
		parent 	= workout,
		text  	= "Round: 3/8",
		x 		= Layout.workout.infoDisplayX,
		y 		= Layout.workout.infoDisplayY,
		font 	= 'digital-7-mono.ttf',
		fontSize = Layout.workout.infoDisplayFontSize - 2,
		})
	workout.infoDisplay.anchorX = 0

	workout.segClock = Clock:new({
		parent 		= workout,
		x 			= Layout.workout.segClockX,
		y 			= Layout.workout.segClockY,
		fontSize 	= Layout.workout.segClockFontSize,
		startAt 	= 0,
		endAt 		= -1,
		fontFill 	= { 1 },
		showHunds 	= true
		})
	workout.segClock.anchorX = 1

	workout.infoSep = display.newLine( workout, Layout.workout.infoSepStartX, Layout.workout.infoSepStartY, Layout.workout.infoSepEndX, Layout.workout.infoSepEndY )
	workout.infoSep.alpha = 0.5

	workout.segmentsDisplay = {}
	workout.segmentsDisplay.activeY = Layout.workout.activeSegmentY

	workout.actionBtn = Btn:new({
		parent 		= workout,
		label 		= 'Action',
		x 			= Layout.workout.actionBtnX,
		y 			= Layout.workout.actionBtnY,
		width  		= Layout.workout.actionBtnWidth,
		height  	= Layout.workout.actionBtnHeight,
		bgColor 	= Theme.colors.dkGreen,
		bgColorPressed 	= Theme.colors.green,
		})


	local function animateResult( opts )
		-- used to show fancy animations at end of rounds
		opts.font = opts.font or 'digital-7-mono.ttf'
		opts.largest_size = opts.largest_size or 100
		opts.time = opts.time or 600
		opts.end_x = opts.end_x or Layout.centerX
		opts.end_y = opts.end_y or Layout.centerY

		local textToAnimate = display.newText({
				parent 	= workout,
				text 	= opts.text,
				x 		= Layout.centerX ,
				y 		= Layout.centerY,
				font 	= opts.font,
				fontSize = 1
				})
			workout.anims[#workout.anims+1] = transition.to( textToAnimate, { size=opts.largest_size, time=opts.time, onComplete=function() transition.to( textToAnimate, { size=20, time=opts.time, x=opts.end_x, y=opts.end_y, onComplete=function() display.remove( textToAnimate ); end } ) end } )
	end


	local function countIn()
		local countTxt = display.newText({
			text = workout.countInCount,
			x 		= Layout.centerX,
			y 		= Layout.centerY,
			font 	= 'Lato-Black.ttf',
			fontSize = 1
			})

		local trxn = easing.outInExpo
		if workout.countInCount > 0 then 
			if settings.audio then TextToSpeech.speak( count, { pitch = 0.9, volume = 0.98 } ) end--audio.play( workout.audio.count ) end 
			transition.to( countTxt, { size=500, time=900, transition=trxn, onComplete=function() display.remove( countTxt ) end } )
		else
			countTxt.text = 'Go!'
			--TextToSpeech.speak( 'Go!', { pitch = 0.9, volume = 0.98 } )
			transition.to( countTxt, { size=300, time=300, onComplete = function() display.remove( countTxt ); workout:start() end } )	
		end
		workout.countInCount = workout.countInCount - 1 
	end



	function workout:advanceSegment( opts )
		opts = opts or {}
		if opts.record == nil then opts.record = true end
		-- Can't double-click protect this cause it's called by code
		if opts.btn then
			if self.lastActionTime and ( self.clock.elapsedTime - self.lastActionTime < 1000 ) then 
				return false
			end
			self.lastActionTime = self.clock.elapsedTime
		end

		if opts.btn then 
			animateResult({ text = self.segClock:human_string() })
		end

		if opts.record then self:recordResults() end

		self.curSegmentIdx = self.curSegmentIdx + 1
		if self.curSegmentIdx > #self.data.segments then 
			self:finish()
		else
			self.curSegment = self.data.segments[self.curSegmentIdx]
			if settings.audio then audio.play( self.audio.round ) end
			self:initCurSegment()
			if self.curSegment.start_on == 'ready' then
				-- ToDo
				-- show 'ready, ready' and/or countin
			else
				self.segClock:start()
			end
		end
	end

	function workout:cleanup()
		workout.clock:pause()
		workout.clock:cleanup()
		workout.segClock:pause()
		workout.segClock:cleanup()
		
		for i=1, #workout.anims do 
			transition.cancel( workout.anims[i] )
		end
		for i=1, #workout.audio do 
			audio.dispose( workout.audio[i] )
		end

		display.remove( self )
	end

	function workout:countEmom()
		-- slightly different from normal, since we just record results and let user rest
		self:recordResults()

		self.actionBtn.label.text = 'Resting'
		self.actionBtn.onRelease = function() return false end
	end

	function workout:countRound()
		-- Used for AMRAP and RFT

		if settings.audio then audio.play( self.audio.round ) end
		
		if self.lastActionTime and ( self.clock.elapsedTime - self.lastActionTime < 1000 ) then 
			-- Double Click -- too fast
			return false
		end
		self.lastActionTime = self.clock.elapsedTime

		self.curSegment.roundCount = self.curSegment.roundCount + 1
		--TextToSpeech.speak( self.curSegment.roundCount, { pitch = 0.9, volume = 0.98 } )

		self.totalRoundCount = self.totalRoundCount + 1

		self:recordResults()
		self:initInfoDisplay()

		--if not( self.curSegment.duration ) then
			self.segClock:reset()
			self.segClock:start()
		--end

		animateResult({ text = self.curSegment.roundCount, largest_size=400 })

		if self.curSegment.segment_type == 'rft' and self.curSegment.roundCount >= self.curSegment.repeat_count then 
			self:advanceSegment()
		end

		
	end

	function workout:finish()
		if settings.audio then audio.play( self.audio.finished ) end
		self.clock:pause()
		self.segClock:pause()
		self.endedAt = osDate( "%Y-%m-%d %H:%M" )

		self:recordResults({ final=true })

		Composer.setVariable( 'workoutResults', self.results )

		-- ToDo... play some kind of animation here?
		-- for now, a slight delay to let the animations finish
		timer.performWithDelay( 500, function() Composer.gotoScene( 'scenes.workout_summary' ) end )
	end

	function workout:initActionBtn( opts )
		if self.curSegment.segment_type == 'rest' then 
			self.actionBtn.label.text = 'Resting'
			self.actionBtn.onRelease = function() end
		elseif self.curSegment.segment_type == 'emom' then 
			self.actionBtn.label.text = 'Done'
			self.actionBtn.onRelease = function() self:countEmom() end
		elseif self.curSegment.segment_type == 'amrap' or self.curSegment.segment_type == 'rft' then 
			self.actionBtn.label.text = 'Count Round'
			self.actionBtn.onRelease = function() self:countRound() end
		elseif self.curSegment.segment_type == 'tabata' then
			self.actionBtn.isVisible = false
		elseif self.curSegment.segment_type == 'accumulate' then 
			self.actionBtn.label.text = 'Stop'
			self.actionBtn.onRelease = function() self:stopAccumulate() end
		else 
			self.actionBtn.label.text = 'Advance'
			self.actionBtn.onRelease = function() self:advanceSegment( { btn=true } ) end
		end
	end

	function workout:initClock()
		-- primary clock pretty much always runs up
		-- because we're disabling screen-lock, we'll cap all workouts out 
		-- at 2hrs max for now....
		local clockStart, clockEnd = 0, ( 1000*120*60 )

		-- Run primary clock down if we have a one-segment amrap (e.g. cindy)
		if #self.data.segments == 1 and self.curSegment.segment_type == 'amrap' then 
			clockStart = self.curSegment.duration * 1000
			self.curSegment.duration = nil
			clockEnd = 0 
		end
		self.clock:reset( clockStart, clockEnd )
	end

	function workout:initCurSegment()
		self.curSegment.cycleCount = 1
		self.curSegment.roundCount = 0
		self.curSegment.roundsToComplete = 0

		self:initInfoDisplay()
		self:initSegClock()
		self:initSegmentsDisplay()
		self:initActionBtn()
	end

	function workout:initInfoDisplay( opts )
		-- initialize to ft
		local label = "For Time"
		local info = ""

		if self.curSegment.segment_type == 'accumulate' then
			label 	= "Accumulate: "
		elseif self.curSegment.segment_type == 'amrap' then
			label 	= "Rounds: "
			info 	= self.curSegment.roundCount
		elseif self.curSegment.segment_type == 'emom' then 
			label 	= 'EMoM: '
			info 	= self.curSegment.cycleCount .. "/" .. self.curSegment.repeat_count
		elseif self.curSegment.segment_type == 'rest' then 
			label = "Resting"
		elseif self.curSegment.segment_type == 'rft' then 
			label 	= "Round: "
			info 	= self.curSegment.roundCount+1 .. "/" .. self.curSegment.repeat_count
		elseif self.curSegment.segment_type == 'tabata' then 
			label 	= 'TABATA: '
			info 	= self.curSegment.cycleCount .. "/" .. self.curSegment.repeat_count
		end

		self.infoDisplay.text = label .. info
	end

	function workout:initSegClock()
		-- similar to primary clock, but we'll let segment clock run forever
		-- since workout clock will terminate workout, and user may not want
		-- to micro-manage rounds
		local segStart, segEnd = 0, -1

		-- run the segment clock down to zero if this segment is part of several and is timed
		if #self.data.segments > 1 and self.curSegment.duration and self.curSegment.duration > 0 then 
			segStart = self.curSegment.duration * 1000
			segEnd = 0 
		end

		if self.curSegment.segment_type == 'emom' or self.curSegment.segment_type == 'tabata' then 
			segStart = workout.curSegment.repeat_interval * 1000
			segEnd = 0 
		end 

		-- single-segment for time (e.g. Fran) doesn't need a segment clock
		if #self.data.segments == 1 and self.curSegment.segment_type == 'ft' then 
			self.segClock.isVisible = false 
		end

		self.segClock:reset( segStart, segEnd )

	end

	function workout:initSegmentsDisplay( opts )
		opts = opts or {}
		idx = opts.idx or self.curSegmentIdx

		if workout.segmentsDisplay[idx-1] then 
			local prevDisp = workout.segmentsDisplay[idx-1]
			workout.anims[#workout.anims+1] = transition.to( prevDisp, { y=prevDisp.y-50, alpha=0.01, time=500, onComplete=function() display.remove( prevDisp ) end} )
		end

		for i=idx, #workout.segmentsDisplay do
			display.remove( workout.segmentsDisplay[i] )
		end

		-- first segment is active one
		workout.segmentsDisplay[idx] = display.newText({
			parent 	= workout,
			text 	= self.data.segments[idx].content,
			width 	= Layout.width-20,
			align 	= 'center',
			y 		= workout.segmentsDisplay.activeY,
			x 		= centerX,
			font 	= Layout.workout.segmentsDisplayActiveFont,
			fontSize = Layout.workout.segmentsDisplayFontSize
		})
		workout.segmentsDisplay[idx].anchorY = 0

		-- now go through any remaining
		for i=idx+1, #self.data.segments do
			local font = 'Lato-Hairline.ttf'
			local y = self.segmentsDisplay[i-1].y + self.segmentsDisplay[i-1].contentHeight + Layout.workout.segmentsDisplayYOffset
			self.segmentsDisplay[i] = display.newText({
				parent 	= workout,
				text 	= self.data.segments[i].content,
				width 	= screenWidth-20,
				align 	= 'center',
				y 		= y,
				x 		= centerX,
				font 	= font,
				fontSize = Layout.workout.segmentsDisplayFontSize
				})
			self.segmentsDisplay[i].anchorY = 0
		end
	end

	function workout:recordResults( opts )
		opts = opts or {}
		local final = opts.final or false

		local unit = 'secs'
		if self.curSegment.segment_type == 'rest' then return end

		if final then
			local value = self.clock.elapsedTime / 1000
			if self.data.workout_type == 'amrap' then 
				value 	= self.totalRoundCount
				unit 	= 'rds'
			end

			self.results.summary =  { 
				tmp_id 			= self.slug .. '_' .. osTime(),
				workout_id		= self.slug,
				total_time		= self.clock.elapsedTime / 1000,
				started_at		= self.startedAt,
				ended_at		= self.endedAt,
				workout_title	= self.title,
				workout_type	= self.data.workout_type,
				cover_img		= self.data.cover_img,
				value 			= value,
				unit 			= unit
				}
		else
			
			local value = ( self.clock.elapsedTime - self.lastResultTime ) / 1000
			self.lastResultTime = self.clock.elapsedTime
			
			if value == 0 then return end

			local content = self.curSegment.content
			if self.curSegment.segment_type == 'accumulate' or self.curSegment.segment_type == 'amrap' or self.curSegment.segment_type == 'rft' then 
				content = "Round: " .. self.curSegment.roundCount
			end
			if self.curSegment.segment_type == 'emom' then 
				content = "Round: " .. self.curSegment.cycleCount
			end

			if self.results.segments == nil then self.results.segments = {} end
			table.insert( self.results.segments, { 
				segment_id		= self.curSegment.id,
				segment_type 	= self.curSegment.segment_type,
				content 		= content,
				value 			= value,
				unit 			= unit,
				recorded_at 	= osDate( "%Y-%m-%d %H:%M:%S" )
				})
		end
	end

	function workout:start()
		if settings.audio then audio.play( self.audio.go ) end
		self.startedAt = osDate( "%Y-%m-%d %H:%M" )
		self.isVisible = true
		self.clock:start()
		self.segClock:start()
	end

	function workout:startAccumulate()
		self.segClock:start()
		self.lastResultTime = self.clock.elapsedTime
		self.actionBtn.label.text = 'Stop'
		self.actionBtn.onRelease = function() self:stopAccumulate() end
	end

	function workout:stopAccumulate()
		self.segClock:pause() 
		self.curSegment.roundCount = self.curSegment.roundCount + 1
		self:recordResults()
		self.actionBtn.label.text = 'Start'
		self.actionBtn.onRelease = function() self:startAccumulate() end
	end

	function workout:tick()
		-- for now this is just a listener for TABATA
		-- ToDo: may add halfway sound effects, scripted sounds, etc..
		if not( self.curSegment.segment_type == 'tabata' ) then return end 
		if self.segClock.elapsedTime >= 20 * 1000 then 
			self.infoDisplay.text = 'Rest'
		end
	end

	function workout:timesUp()
		print( "Segment Clock Expired! " )
		if self.curSegment.segment_type == 'emom' or self.curSegment.segment_type == 'tabata' then 
			self.curSegment.cycleCount = self.curSegment.cycleCount + 1
			if workout.curSegment.cycleCount >= workout.curSegment.repeat_count + 1 then 
				self:advanceSegment( { record=false } ) 
			else
				self.lastResultTime = self.clock.elapsedTime
				self:initActionBtn()
				self:initInfoDisplay()
				self:initSegClock()
				self.segClock:start()
			end
		elseif self.curSegment.segment_type == 'accumulate' then 
			self:advanceSegment( { record=true } )
		else
			self:advanceSegment( { record=false } )
		end
	end

	

	function M:loadData( slug )
		local function getData( e )

			connectionStatus = 'online'
			workout.header:updateConnectionIndicator()

			local data = json.decode( e.response )

			if workout.slug == 'quickWorkout' then 
				data = Composer.getVariable( 'workoutData' )

			elseif e.isError or data == nil then
				connectionStatus = 'offline'
				workout.header:updateConnectionIndicator()

				local response = require( 'local_data.workouts.' .. workout.slug )
				data = json.decode( response )
			end
			workout.data = data
			workout.header.title.text = workout.data.title
			workout.title = workout.data.title 

			table.sort( workout.data.segments, function(a,b) return a.seq < b.seq end )

			-- initialize the workout clock
			workout:initClock()

			-- set curSegment
			workout.curSegment = workout.data.segments[workout.curSegmentIdx]

			-- have to initialize segment variables on load
			-- initialize cycle count used for auto-advance segments like emom & tabata
			workout:initCurSegment()

			workout.clock:addEventListener( 'timesUp', function() workout:finish() end )
			workout.segClock:addEventListener( 'timesUp', workout )
			workout.segClock:addEventListener( 'tick', workout )

			-- Everything's setup. Kick this mofo off.
			-- now, we can make the count in a setting: 0, 3, 5, 10
			workout.countInCount = settings.countIn
			local delay = 1000 
			if settings.countIn < 1 then delay = 100 end
			workout.countInTimer = timer.performWithDelay( delay, countIn, settings.countIn + 1 )
		end

		local url = 'http://localhost:3008/workouts/' .. workout.slug .. '.json'
		network.request( url, 'GET', getData )

	end

	self:loadData( slug )

	return workout 
end

return M