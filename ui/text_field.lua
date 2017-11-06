
-- This module is a native TextField wrapper

-- use via: 
-- TextField = require( "ui.text_field" )
-- my_field = TextField:new({ my_opts })

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
-- icon 			= an image icon
-- iconWidth
-- iconHeight
-- iconXOffset
-- iconYoffset
-- strokeWidth 		= border to draw outline container (0 for no container)
-- cornerRadius 	= corner radius for border (half height for circle)
-- placeholder 
-- inputType
-- listener
-- bgColor
-- textColor
-- labelColor

local M = {}

M.defaults = {
	x 				= centerX,
	y 				= centerY,
	width 			= screenWidth * 0.66,
	height 			= 30,
	strokeWidth 	= 0,
	inputType 		= 'default',
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

	opts.fontSize = opts.fontSize or opts.height * 0.6

	opts.cornerRadius = opts.cornerRadius or opts.height * 0.33

	opts.font = opts.font or native.systemFont
	opts.labelFont = opts.labelFont or opts.font

	opts.labelColor = opts.labelColor or opts.textColor
	opts.labelFontSize = opts.labelFontSize or opts.fontSize
	opts.labelXOffset = opts.labelXOffset or -( opts.width / 2 )
	opts.labelYOffset = opts.labelYOffset or -( opts.labelFontSize * 2 )

	opts.iconHeight = opts.iconHeight or opts.height 
	opts.iconWidth = opts.iconWidth or opts.iconHeight 

	opts.iconSourceWidth = opts.iconSourceWidth or opts.iconWidth
	opts.iconSourceHeight = opts.iconSourceHeight or opts.iconHeight

	opts.iconXOffset = opts.iconXOffset or -(opts.width / 2 - opts.iconWidth)
	opts.iconYOffset = opts.iconYOffset or 0


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


	if opts.icon then 
		field.icon = display.newImageRect( field, opts.icon, opts.iconSourceWidth, opts.iconSourceHeight )
		local xScaleFactor = opts.iconWidth / opts.iconSourceWidth
		local yScaleFactor = opts.iconHeight / opts.iconSourceHeight
		
		field.icon:scale( xScaleFactor, yScaleFactor )

		field.icon.x = opts.iconXOffset
		field.icon.y = opts.iconYoffset
	end


	local tHeight = opts.height - opts.strokeWidth * 2
	local tWidth = opts.width - opts.cornerRadius
	if opts.icon then tWidth = tWidth - opts.iconWidth end 

	field.textField = native.newTextField( 0, 0, tWidth, tHeight )
	field.textField.x = field.x
	if opts.icon then field.textField.x = field.textField.x + opts.iconWidth end 
	field.textField.y = field.y+3
	field.textField.hasBackground = false
	field.textField.inputType = opts.inputType
	field.textField.text = opts.text

	-- cache reference to the bg image so we can change color, highlight, etc. on focus
	field.textField.bg = field.bg

	field.textField.font = native.newFont( opts.font )
	--field:insert( field.textField )

	if opts.isSecure then 
		field.textField.isSecure = true 
	end
	
	if opts.fontSize then 
		local deviceScale = ( display.pixelWidth / display.contentWidth ) * 0.5
		field.textField.size = opts.fontSize * deviceScale
	else
		field.textField:resizeFontToFitHeight()
	end

	if opts.textColor then 
		field.textField:setTextColor( unpack( opts.textColor ) )
	end

	field.yDelta = centerY - ( field.textField.y + field.textField.height * 0.5 )

	function field:setPlaceholder( text )
		self.placeholder = text 
		self.textField.text = text
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
		field.textField:addEventListener( "userInput", opts.listener )
	else
		field.textField:addEventListener( 'userInput', field.inputHandler )
	end

	function field:finalize( e )
		print( 'removing text field')
		e.target.textField:removeSelf()
	end
	field:addEventListener( "finalize" ) 


	return field
end

return M