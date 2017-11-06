
local Btn = require( 'ui.btn' )
local Theme = require( 'ui.theme' )

local M = {}

M.defaults = {
	x 				= display.contentCenterX,
	y 				= display.contentHeight,
	width 			= 220,
	height 			= 310,
	cornerRadius 	= 8,
	digits 			= 2,
	onComplete = function() print( 'Keypad is done' ) end
}


function M:new( opts )
	if opts == nil then opts = M.defaults end
	
	-- fill in any missing opts from module defaults
	for key, value in pairs( M.defaults ) do
		if opts[key] == nil then 
			opts[key] = M.defaults[key]
		end
	end


	local keypad = display.newGroup()
	if opts.group then
		opts.parent = opts.group
	end
	if opts.parent then 
		opts.parent:insert( keypad )
	end
	

	if opts.onComplete and type( opts.onComplete ) == "function" then
		keypad.onComplete = opts.onComplete
	else 
		keypad.onComplete = M.defaults.onComplete
	end

	if opts.bindTo then 
		keypad.bindTo = opts.bindTo 
	end

	keypad.digits = opts.digits

	keypad.state = 'initialized'
	keypad.value = '0'
	keypad.label = 'Mins'

	keypad.bg = display.newRoundedRect( keypad, opts.x, opts.y, opts.width, opts.height, opts.cornerRadius )
	keypad.bg.fill = Theme.colors.dkGrey
	keypad.bg.anchorY = 0
	keypad.bg:setStrokeColor( 0.5, 0.5, 0.5 )
	keypad.bg.stroke = {type="image", filename="assets/images/brushes/brush1x2.png"}
	keypad.bg.strokeWidth = 1

	keypad.toggler = display.newRect( keypad, opts.x, opts.y+20, opts.width, 40 )
	keypad.toggler.fill = { 0, 0.01 }
	keypad.toggler:addEventListener( 'tap', function(e) keypad:show() end )


	keypad.amountTxt = display.newText({
		parent 	= keypad,
		text 	= keypad.value,
		x 		= display.contentCenterX,
		y 		= opts.y + 20,
		font 	= Theme.font,
		fontSize 	= 32
		})

	keypad.labelTxt = display.newText({
		parent 	= keypad,
		text 	= keypad.label,
		x 		= display.contentCenterX + 20,
		y 		= opts.y + 20,
		font 	= Theme.font,
		fontSize 	= 32
		})


	local startX = opts.x - opts.width * 0.33
	local x = startX
	local y = opts.y + 70
	keypad.btns = {}

	for i=1, 9 do
		keypad.btns[i] = Btn:new({ 
			parent 			= keypad,
			label 			= i, 
			x 				= x, 
			y 				= y,  
			width 			= 40, 
			height 			= 40, 
			cornerRadius 	= 20,
			font 			= Theme.fonts.hairline,
			strokeWidth 	= 1,
			strokeColor 	= Theme.colors.whiteGrey,
			bgColor 		= { 1, 0.1 },
			bgColorPressed 	= { 1, 0.5 },
			onRelease 		= function() 
								keypad:keyPress( i )
							end 
		})

		x = x + ( opts.width * 0.33 )
		if i % 3 == 0 then
			y = y + 60
			x = startX
		end
	end

	keypad.btns['x'] = Btn:new({ parent=keypad, label='undo', x = x, y = y, strokeWidth=1, strokeColor=Theme.colors.whiteGrey, bgColor={ 1, 0.1 }, bgColorPressed={ 1, 0.5 }, width=40, height=40, font = Theme.fonts.hairline, fontSize=12, onRelease=function() keypad:undo() end } )

	x = x + ( opts.width * 0.33 )
	keypad.btns['0'] = Btn:new({ parent=keypad, label = '0', x = x, y = y, cornerRadius=20, strokeWidth=1, strokeColor= Theme.colors.whiteGrey, bgColor={ 1, 0.1 }, bgColorPressed={ 1, 0.5 }, width=40, height=40, font = Theme.fonts.hairline, fontSize=12, onRelease=function() keypad:keyPress( '0' ) end } )

	x = x + ( opts.width * 0.33 )
	keypad.btns['go'] = Btn:new({ parent=keypad, label = 'done', x = x, y = y, strokeWidth=1, strokeColor = Theme.colors.whiteGrey, bgColor={ 1, 0.1 }, bgColorPressed = { 1, 0.5 }, width=40, height=40, font = Theme.fonts.hairline, fontSize=12, onRelease=function() keypad:go() end })

	
	function keypad:centerLabels()
		local width = keypad.amountTxt.contentWidth + keypad.labelTxt.contentWidth + 10
		keypad.amountTxt.anchorX = 0
		keypad.labelTxt.anchorX = 0
		keypad.amountTxt.x = opts.x - ( width * 0.5 )
		keypad.labelTxt.x = keypad.amountTxt.x + keypad.amountTxt.contentWidth + 10
	end

	function keypad:go()
		self.onComplete()
		self:hide()
	end

	function keypad:hide()
		transition.to( self, { y=opts.y, time=1000, onComplete=function() self.isVisible = false; end })
		self.value = 0
		self.state = 'locked'
		self:updateDisp()
	end

	function keypad:show()
		self.isVisible = true
		transition.to( self, { y = -self.bg.contentHeight+33, time=1000, transition=easing.outElastic })
		self.state = 'initialized'
		self:updateDisp()
	end

	function keypad:undo()
		self.value = string.gsub( self.value, ".$", '' )
		self.amountTxt.text = self.value
	end

	function keypad:updateDisp()
		self.amountTxt.text = self.value
		self.labelTxt.text = self.label
		self:centerLabels()
	end

	function keypad:keyPress( str )
		str = tostring( str )
		if self.state == 'initialized' then
			self.value = ''
			self.state = 'editing'
		end
		local tmp_str = self.value .. str
		if string.len( tmp_str ) > self.digits then
			tmp_str = string.sub( tmp_str, -self.digits )
		end
		self.value = tmp_str
		self.amountTxt.text = self.value
		if self.bindTo then 
			self.bindTo.text = self.value
		end
		self:centerLabels()
		self:dispatchEvent( { name = 'keyPress', target = self } )
	end

	keypad:hide()
	
	return keypad

end


return M

