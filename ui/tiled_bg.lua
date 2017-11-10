local M = {}
local mCeil = math.ceil
local mFloor = math.floor
local mAbs = math.abs


-- The defaults for a new bg
M.defaults = { 
	image 			= 'tileBG.jpg',
	sheet_width		= display.contentWidth,
	sheet_height		= display.contentHeight,
	tile_width		= 100,
	tile_height		= 100
}


function M:new( settings )
	if settings == nil then settings = M.defaults end
	
	-- fill in any missing settings from module defaults
	for key, value in pairs( M.defaults ) do
		settings[key] = settings[key] or M.defaults[key]
	end

	local sheet = display.newGroup()

	if settings.group then settings.group:insert( sheet ) end

	local repeat_x = mCeil( settings.sheet_width / settings.tile_width ) --number of times to repeat tiles on x axis
	local repeat_y = mCeil( settings.sheet_height / settings.tile_height ) --number of times to repeat tiles on y axis
	local tile_count = repeat_x * repeat_y -- total tiles placed

	if settings.debug then
		print( 'Creating tiled BG with image: ' .. settings.image )
		print( 'BG Width: ' .. settings.sheet_width )
		print( 'BG Height: ' .. settings.sheet_height )
		print( 'Repeat X: ' .. repeat_x )
		print( 'Repeat Y: ' .. repeat_y )
	end

	local x_position = 0
	local y_position = 0

	for bgY = 1, repeat_y do
		x_position = 0 --reset x position each time we go to next row
		for bgX = 1, repeat_x do
			local tile = display.newImageRect( sheet, settings.image, settings.tile_width, settings.tile_height )
			tile.anchorX, tile.anchorY = 0, 0
			tile.x = x_position
			tile.y = y_position

			x_position = x_position + settings.tile_width
		end
		y_position = y_position + settings.tile_height
	end

	sheet.y = -settings.group.contentHeight/2

	function sheet:cleanup()
		if sheet.numChildren then
			while sheet.numChildren > 0 do   -- we have have tiles left in the sheet group, so first clean them out		
					sheet:remove( sheet.numChildren ) -- clean out the last member of the group (work from the top down!)
			end
		end	
	end

	return sheet
end

return M