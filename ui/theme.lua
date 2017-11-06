
-- just fonts and colors and some defaults
-- the rest is in layouts


local device = require( 'utilities.device' )
local colors = require( 'ui.colors' )

local fonts = { 
	regular 	= 'Lato.ttf',
	light 		= 'Lato-Light.ttf',
	bold 		= 'Lato-Bold.ttf',
	black 		= 'Lato-Black.ttf',
	hairline 		= 'Lato-Hairline.ttf',
}

local T = {
	colors 	= colors,
	
	font 		= 'Lato.ttf',
	fonts 		= fonts,

	buttons 	= {
		width 		= screenWidth * 0.66,
		height 		= 60,
		fontSize 	= 24,
		iconHeight 	= 18,
		cornerRadius = 4,
		colors 		= {
			label				= { 0.8, 0.8, 0.8 },
			labelPressed		= { 1, 1, 1 },
			bg 			= colors.purple,
			bgPressed 	= colors.dkPurple,
		},
	},
}


function T.colorize( color )
	return color / 255
end

return T