
-- This module is a native TextBox wrapper

-- use via: 
-- TextBox = require( "ui.text_box" )
-- my_box = TextBox:new({ my_opts })

-- Here are all available opts so far...


-- x 				= x coordinate for field
-- y 				= y coordinate for field
-- width 			= width of field
-- height 			= height of field
-- font 			= font to use for label
-- fontSize
-- label 			= label text
-- labelFont
-- labelFontSize
-- labelXOffset
-- labelYoffset
-- strokeWidth 		= border to draw outline container (0 for no container)
-- cornerRadius 	= corner radius for border (half height for circle)
-- placeholder 
-- listener
-- bgColor
-- textColor
-- labelColor

local M = {}

M.defaults = {
	x 				= centerX,
	y 				= centerY,
	width 			= screenWidth * 0.8,
	height 			= 80,
	strokeWidth 	= 0,
	bgColor 		= { 1, 1, 1 },
	strokeColor 	= { 0.5, 0.5, 0.5 },
}


function M:new( opts )
	if opts == nil then opts = M.defaults end
	
	-- fill in any missing opts from module defaults
	for key, value in pairs( M.defaults ) do
		if opts[key] == nil then 
			opts[key] = M.defaults[key]
		end
	end

	opts.fontSize = opts.fontSize or 14

	opts.cornerRadius = opts.cornerRadius or 4

	opts.font = opts.font or native.systemFont
	opts.labelFont = opts.labelFont or opts.font

	opts.labelColor = opts.labelColor or opts.textColor
	opts.labelFontSize = opts.labelFontSize or opts.fontSize
	opts.labelXOffset = opts.labelXOffset or -( opts.width / 2 )
	opts.labelYOffset = opts.labelYOffset or -( opts.labelFontSize * 2 )

	local field = display.newGroup()
	if opts.group then
		opts.group:insert( field )
	end

	field.bg = display.newRoundedRect( field, 0, 0, opts.width, opts.height, opts.cornerRadius )
	field.bg.fill = opts.bgColor
	field.x = opts.x 
	field.y = opts.y

	if opts.strokeWidth > 0 then
		field.bg.stroke = {type="image", filename="assets/images/brushes/brush1x4.png"}
		field.bg.strokeWidth = opts.strokeWidth
		field.bg:setStrokeColor( unpack( opts.strokeColor ) )
	end

	if opts.label then 
		field.label = display.newText( field, opts.label, 0, 0, opts.labelFont, opts.labelFontSize )
		field.label.anchorX = 0
		field.label.x =  opts.labelXOffset
		field.label.y = opts.labelYOffset 
		field.label.fill = opts.labelColor
	end

	local tHeight = opts.height - opts.strokeWidth * 2
	local tWidth = opts.width - opts.cornerRadius

	field.textBox = native.newTextBox( 0, 0, tWidth, tHeight )
	field.textBox.x = field.x
	field.textBox.y = field.y
	field.textBox.hasBackground = false
	field.textBox.isEditable = true
	field.textBox.text = opts.text


	-- cache reference to the bg image so we can change color, highlight, etc. on focus
	field.textBox.bg = field.bg

	field.textBox.font = native.newFont( opts.font )

	field.yDelta = centerY - ( field.textBox.y + field.textBox.height * 0.5 )

	
	-- if opts.fontSize then 
	-- 	local deviceScale = ( display.pixelWidth / display.contentWidth ) * 0.5
	-- 	field.textField.size = opts.fontSize * deviceScale
	-- else
	-- 	field.textField:resizeFontToFitHeight()
	-- end

	if opts.textColor then 
		field.textBox:setTextColor( unpack( opts.textColor ) )
	end

	function field:setPlaceholder( text )
		self.placeholder = text 
		self.textArea.text = text
	end

	function field.inputHandler( e )
		if e.phase == 'began' then 

			e.target.bg:setStrokeColor( 118/255, 167/255, 215/255 )
			e.target.bg.strokeWidth = 2

			if field.yDelta < 0 then 
				transition.to( e.target.parent, { y=e.target.parent.y + field.yDelta, time=1000, transition=easing.outElastic } )
			end

			if e.target.text == field.placeholder then 
				e.target.text = ''
			end
		end

		if e.phase == 'ended' or e.phase == "submitted" then 

			native.setKeyboardFocus( nil )

			e.target.bg.strokeWidth = 0

			if field.yDelta < 0 then 
				transition.to( e.target.parent, { y=0, time=1000, transition=easing.outElastic } )
			end

			if e.target.text == nil or e.target.text == '' then 
				if field.placeholder then
					e.target.text = field.placeholder
				end
			end
		end
	end

	if ( opts.listener and type( opts.listener ) == "function" ) then
		field.textBox:addEventListener( "userInput", opts.listener )
	else
		field.textBox:addEventListener( 'userInput', field.inputHandler )
	end

	function field:finalize( e )
		print( 'removing text box')
		e.target.textBox:removeSelf()
	end
	field:addEventListener( "finalize" ) 


	return field
end

return M