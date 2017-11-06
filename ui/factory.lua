
-- General UI convenience methods for things like setting background, 
-- creating headers, keypads, native textboxes, etc...

local Composer = require( 'composer' )
local Btn = require( 'ui.btn' )
local Theme = require( 'ui.theme' )

local bgDefaults = {
	x 			= centerX,
	y 			= centerY,
	width 		= screenWidth,
	height 		= screenHeight,
	fill 		= Theme.colors.ltGray,
}

local headerDefaults = {
	x 			= centerX,
	y 			= 0,
	backLabel 	= 'back',
	backTo 		= 'scenes.home',
	backBtn 	= true,
	fontSize 	= 24,
	fontColor 	= { 0.95, 0.95, 0.95, 1 },
	bgColor 	= Theme.colors.mdGrey,
	btnColor 	= Theme.colors.green,
	borderColor = Theme.colors.dkGrey
}

local M = {}




function M:setBg( opts )

	-- uses fills for images, etc. see: 
	-- https://coronalabs.com/blog/2013/11/07/tutorial-repeating-fills-in-graphics-2-0/
	
	if opts == nil then opts = bgDefaults end
	
	-- fill in any missing opts from module defaults
	for key, value in pairs( bgDefaults ) do
		if opts[key] == nil then 
			opts[key] = bgDefaults[key]
		end
	end


	bg = display.newRect( opts.x, opts.y, opts.width, opts.height )
	bg.x = opts.x
	bg.y = opts.y

	if opts.group then
		opts.group:insert( bg )
	elseif opts.parent then 
		opts.parent:insert( bg )
	end

	if opts.wrapX then 
		display.setDefault( "textureWrapX", opts.wrapX )
	end
	if opts.wrapY then 
		display.setDefault( "textureWrapY", opts.wrapY )
	end

	bg.fill = opts.fill

	if opts.fillScale then

		local xFactor = 1 ; local yFactor = 1
		if ( bg.width > bg.height ) then
			yFactor = bg.width / bg.height
		else
			xFactor = bg.height / bg.width
		end
		bg.fill.scaleX =  xFactor * opts.fillScale
		bg.fill.scaleY =  yFactor * opts.fillScale
	end

	if opts.fillX then bg.fill.x = opts.fillX end
	if opts.fillY then bg.fill.y = opts.fillY end
	if opts.fillRotation then bg.fill.rotation = opts.fillRotation end


	return bg
end

function M:setHeader( opts )
	if opts == nil then opts = headerDefaults end
	
	-- fill in any missing opts from module defaults
	for key, value in pairs( headerDefaults ) do
		if opts[key] == nil then 
			opts[key] = headerDefaults[key]
		end
	end

	local header = display.newGroup()
	if opts.group then
		opts.group:insert( header )
	elseif opts.parent then 
		opts.parent:insert( header )
	end

	if display.topStatusBarContentHeight > 0 then
		header.statusBarBg = display.newRect( header, 0, 0, display.contentWidth, display.topStatusBarContentHeight )
		header.statusBarBg.anchorX, header.statusBarBg.anchorY = 0, 0
		header.statusBarBg.fill = Theme.colors.ltGrey
		opts.y = opts.y + display.topStatusBarContentHeight
	end

	header.bg = display.newRect( header, opts.x, opts.y, opts.width, opts.height )
	header.bg.anchorY = 0
	header.bg.fill = opts.bgColor

	header.back_btn = Btn:new({
		parent 			= header,
		label 			= opts.backLabel,
		labelColor  	= { 0 } ,
		bgColor 		= Theme.colors.red,
		bgColorPressed 	= Theme.colors.dkRed,
		width			= 30,
		height			= 30,
		strokeWidth 	= 1,
		x				= 20,
		y				= opts.y + opts.height/2,
		font 			= Theme.font,
		fontSize		= 12,
		onRelease 		= function() Composer.gotoScene( opts.backTo ) end
	})

	header.menu_btn = Btn:new({
		parent 			= header,
		--label 			= '...',
		imageIcon 		= 'assets/images/menu-icon.png',
		labelColor  	= opts.fontColor,
		bgColor 		= Theme.colors.blue,
		bgColorPressed 	= Theme.colors.dkBlue,
		width			= 30,
		height			= 30,
		strokeWidth 	= 1,
		x				= opts.width - 20,
		y				= opts.y + opts.height/2,
		fontSize		= 36,
		labelY 			= opts.y + opts.height/4,
		--onRelease 		= function() if Composer.getVariable( 'overlay' ) then Composer.hideOverlay( 'slideRight' ); else Composer.showOverlay( "scenes.menu_overlay", { effect='fromRight', time=800 } ); end end
		onRelease 		= function() if Composer.getVariable( 'overlay' ) then transition.to( header.menu_btn.imageIcon, { rotation = 0 } ); Composer.hideOverlay( 'slideRight' ) else transition.to( header.menu_btn.imageIcon, { rotation = 90 } ); Composer.showOverlay( "scenes.menu_overlay", { effect='fromRight', time=800 } ) end end
	})

	header.connectionIndicator = display.newCircle( header, opts.width - 50, opts.y + opts.height/2, 6 )
	header.connectionIndicator.fill = { 0.66, 0.66, 0.66 }

	function header:updateConnectionIndicator()
		local fill = Theme.colors.dkRed
		if connectionStatus == 'online' then 
			fill = Theme.colors.green
		end
		self.connectionIndicator.fill = fill
	end

	



	header.title = display.newText({
		parent 		= header, 
		text 		= opts.title,
		x 			= opts.width - 75, 
		y 			= opts.y + opts.height/2,
		font 		= Theme.fonts.light,
		fontSize 	= opts.fontSize 
	})
	header.title.fill = opts.fontColor
	header.title.anchorX = 1

	header.border = display.newLine( header, 0, opts.y + opts.height, screenWidth, opts.y + opts.height )
	--header.border.stroke = {type="image", filename="assets/images/brushes/blur_brush1x4.png"}
	header.border:setStrokeColor( unpack( opts.borderColor ) )
	header.border.strokeWidth = 1

	return header
end



return M
