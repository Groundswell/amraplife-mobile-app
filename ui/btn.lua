
-- This module is a simple button creator
-- it uses rounded rectangle to create buttons from circles to rectangles
-- buttons can include a lable and/or an icon (icons require fontawesome module)
-- can someday extend to include an image or image-sheet


-- use via: 
-- Btn = require( "ui.btn" )
-- my_btn = Btn:new({ my_opts })

-- Here are all available opts so far...

-- onRelease 		= function to call when button is pressed
-- x 				= x coordinate for btn group
-- y 				= y coordinate for btn group
-- anchorX 			= x anchor for btn group
-- anchorY 			= y anchor for btn group
-- width 			= width of btn
-- height 			= height of btn
-- label 			= text to display 
-- labelX 			= x coord for label txt (defaults to btn center)
-- labelY 			= y coord for label txt (defaults to btn center)
-- labelAnchorX
-- labelAnchorY
-- font 			= font to use for label
-- fontSize
-- strokeWidth 		= border to draw outline container (0 for no container)
-- cornerRadius 	= corner radius for border (half height for circle)
-- fontIcon 		= icon to include (font awesome)
-- imageIcon		= icon image 
-- imageIconPressed = icon when pressed
-- iconX  			= x coord for icon (defaults to btn center if no label, 33% left if label)
-- iconY 			= y coord for icon (defaults to btn center)
-- iconWidth 		= width of icon		
-- iconHeight 		= height of icon (or font-size if FontAwesome)
-- labelColor
-- strokeColor
-- bgColor
-- labelColorPressed
-- strokeColorPressed
-- bgColorPressed

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenWidth = display.contentWidth
local screenHeight = display.contentHeight
local screenOrient = system.orientation

local Theme = require( 'ui.theme' )


local M = {}

M.defaults = {
	x 				= centerX,
	y 				= centerY,
	width 			= screenWidth * 0.66,
	height 			= Theme.buttons.height,
	anchorX 		= 0.5,
	anchorY 		= 0.5,
	bg 				= true,
	strokeWidth 	= 2,
	cornerRadius 	= Theme.buttons.cornerRadius,
	font 			= Theme.buttons.font,
	fontSize 			= Theme.buttons.fontSize,
	iconHeight 			= Theme.buttons.iconHeight,
	labelColor 			= Theme.buttons.colors.label,
	labelColorPressed 	= Theme.buttons.colors.labelPressed,
	bgColor 			= Theme.buttons.colors.bg,
	bgColorPressed 		= Theme.buttons.colors.bgPressed

}

function M:new( opts )
	if opts == nil then opts = M.defaults end
	
	-- fill in any missing opts from module defaults
	for key, value in pairs( M.defaults ) do
		if opts[key] == nil then 
			opts[key] = M.defaults[key]
		end
	end

	opts.fontSize = opts.fontSize or opts.height / 3

	opts.labelX = opts.labelX or opts.x
	opts.labelY = opts.labelY or opts.y

	if opts.label then
		opts.iconX = opts.iconX or opts.x - opts.width * 0.4
	else	
		opts.iconX = opts.iconX or opts.x
	end
	opts.iconY = opts.iconY or opts.y

	if opts.imageIcon then 
		opts.imageIconPressed = opts.imageIconPressed or opts.imageIcon 
	end

	opts.iconWidth = opts.iconWidth or opts.height * 0.66
	opts.iconHeight = opts.iconHeight or opts.height * 0.66

	opts.strokeColor = opts.strokeColor or opts.bgColor 
	opts.strokeColorPressed = opts.strokeColorPressed or opts.bgColorPressed

	opts.font = opts.font or UI_font

	opts.cornerRadius = opts.cornerRadius or opts.height / 2

	local btn = display.newGroup()

	if opts.group then
		opts.group:insert( btn )
	elseif opts.parent then 
		opts.parent:insert( btn )
	end

	if opts.onRelease and type( opts.onRelease ) == "function" then
		btn.onRelease = opts.onRelease
	else 
		btn.onRelease = function() native.showAlert( 'ToDo', 'Need to implement an onRelease handler for this', { 'Ok' } ) end
	end

	btn.anchorX, btn.anchorY = opts.anchorX, opts.anchorY

	if opts.bg then 

		btn.bg = display.newRoundedRect( btn, opts.x, opts.y, opts.width, opts.height, opts.cornerRadius )
		btn.bg.fill = opts.bgColor

		if opts.strokeWidth > 0 then
			btn.bg.stroke = {type="image", filename="assets/images/brushes/brush1x4.png"}
			btn.bg.strokeWidth = opts.strokeWidth
		
			btn.bg:setStrokeColor( unpack( opts.strokeColor ) )
		end
	end

	if opts.label then
		btn.label = display.newText( btn, opts.label, opts.labelX, opts.labelY, opts.font, opts.fontSize )
		if opts.labelAnchorX then btn.label.anchorX = opts.labelAnchorX end
		if opts.labelAnchorY then btn.label.anchorY = opts.labelAnchorY end

		btn.label.fill = opts.labelColor
	end

	if opts.fontIcon then
		btn.fontIcon = display.newText( btn, opts.fontIcon, opts.iconX, opts.iconY, 'FontAwesome', opts.iconHeight )
		btn.fontIcon:setFillColor( unpack(opts.labelColor) )
	end

	if opts.imageIcon then
		btn.imageIcon = display.newImageRect( btn, opts.imageIcon, opts.iconWidth, opts.iconHeight )
		btn.imageIcon.x = opts.iconX
		btn.imageIcon.y = opts.iconY
	end
	if opts.imageIconPressed then
		btn.imageIconPressed = display.newImageRect( btn, opts.imageIconPressed, opts.iconWidth, opts.iconHeight )
		btn.imageIconPressed.x = opts.iconX
		btn.imageIconPressed.y = opts.iconY
		btn.imageIconPressed.isVisible = false
	else
		btn.imageIconPressed = btn.imageIcon
	end

	function btn:touch( event )
		if event.phase == 'began' then
			display.getCurrentStage():setFocus( self )

			if opts.bg then 
				btn.bg.fill = opts.bgColorPressed
				btn.bg:setStrokeColor( unpack( opts.strokeColorPressed ) )
			end

			if btn.label then
				btn.label.fill = opts.labelColorPressed
			end
			if btn.fontIcon then
				btn.fontIcon.fill = opts.labelColorPressed
			end
			if btn.imageIcon then
				btn.imageIcon.isVisible = false
				btn.imageIconPressed.isVisible = true
			end
		end
		if event.phase == 'ended' or event.status == 'cancelled' then
			display.getCurrentStage():setFocus( nil )

			if opts.bg then 
				btn.bg.fill = opts.bgColor
				btn.bg:setStrokeColor( unpack( opts.strokeColor ) )
			end
			
			if btn.label then
				btn.label.fill = opts.labelColor
			end
			if btn.fontIcon then
				btn.fontIcon.fill = opts.labelColor
			end
			if btn.imageIcon then
				btn.imageIcon.isVisible = true
				btn.imageIconPressed.isVisible = false
			end
		end
		if event.phase == 'ended' then 
			btn.onRelease()
		end
		-- don't propagate button touches
		return true
	end
	btn:addEventListener( 'touch', btn )
	return btn
end

return M