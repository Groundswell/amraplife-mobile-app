
local DATA_POINT_NUMERIC_ATTRIBUTES = { 'time_delta','acceleration_xaxis','acceleration_yaxis','acceleration_zaxis','acceleration_xaxis_delta','acceleration_yaxis_delta','acceleration_zaxis_delta','acceleration_xaxis_delta_sum','acceleration_yaxis_delta_sum','acceleration_zaxis_delta_sum','acceleration_xaxis_corner','acceleration_yaxis_corner','acceleration_zaxis_corner','acceleration_xaxis_velocity','acceleration_yaxis_velocity','acceleration_zaxis_velocity','acceleration_xaxis_distance','acceleration_yaxis_distance','acceleration_zaxis_distance','angular_velocity_xaxis','angular_velocity_yaxis','angular_velocity_zaxis' }



local movements = {
	laydown={
		name='Laydown',
		paths={
			{ -- path start
				prerequisites={
					ranges={
						{ acceleration_xaxis_abs={ 0.9, 1.1 }, acceleration_yaxis_abs={ 0, 0.1 }, acceleration_zaxis_abs={ 0, 0.1 } }
					}, -- ranges end
				}, -- prerequisites end
				vectors={
					{ -- vector start
						ranges={
							{ acceleration_xaxis_abs={ 0.9, 1.1 }, acceleration_yaxis_abs={ 0, 0.1 }, acceleration_zaxis_abs={ 0, 0.1 } }
						},
						complete={
							sums={ { time_delta={ 1.0, nil } } }
						},
					} -- vector end
				}, -- vectors end
			}, -- path end
		}, -- paths end
	}, -- movement end: laydown
}


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function matchDataPointToMovementPaths( dataPoint, movement )
	local paths = false

	for path_index, path in ipairs( movement['paths'] ) do
		local matches = false
		if path['prerequisites']['ranges'] then

			for range_index, range in ipairs( path['prerequisites']['ranges'] ) do
				matches = matches or matchDataPoint( dataPoint, range )
			end

		end

		if matches then
			paths = paths or {}
			table.insert( paths, path )
		end

	end

	return paths
end

local function findMovement( dataPoint )

end

local function allMovements()
	return movements
end

local function newActiveMovement( dataPoint, movement )

	local activeMovement = {
		dataPoints={},
		pathStates={},
		sums={
			data_point_count=1
		},
		movement=movement,
		complete=false,
		status='started',
	}


	local activePaths = matchDataPointToMovementPaths( dataPoint, movement )


	for index, activePath in ipairs(activePaths) do
		local pathState = { path=activePath, vector=1, complete=false }

		table.insert( activeMovement['pathStates'], pathState )
		-- print( dataPointAttribute, activeMovement['sums'][dataPointAttribute] )
	end

	for index, dataPointAttribute in ipairs(DATA_POINT_NUMERIC_ATTRIBUTES) do
		activeMovement['sums'][dataPointAttribute] = ( dataPoint[dataPointAttribute] or 0.0 )
		-- print( dataPointAttribute, activeMovement['sums'][dataPointAttribute] )
	end

	table.insert( activeMovement['dataPoints'], dataPoint )

	return activeMovement
end

function matchDataPoint( dataPoint, ranges )
	local match = true

	for attribute,value in pairs( ranges ) do
		-- print( '    -> attribute', attribute )
		local abs = string.ends( attribute, '_abs' )

		if abs then
			attribute = string.sub( attribute, 0, -5 )
		end


		local dataPointAttributeValue = dataPoint[attribute]
		if abs then
			dataPointAttributeValue = math.abs( dataPointAttributeValue )
		end


		match = match and evaluateRange( dataPointAttributeValue, value )

	end

	return match
end


function evaluateRange( value, range )
	local match = true

	if not( range[1] == nil ) then
		match = match and (value >= range[1])
	end

	if not( range[2] == nil ) then
		match = match and (value <= range[2])
	end

	-- print( 'evaluateRange', value, dump( range ), dump( match ) )

	return match
end


local function updateActiveMovement( dataPoint, activeMovement )

	-- update running sums
	for index, dataPointAttribute in ipairs(DATA_POINT_NUMERIC_ATTRIBUTES) do
		activeMovement['sums'][dataPointAttribute] = activeMovement['sums'][dataPointAttribute] + ( dataPoint[dataPointAttribute] or 0.0 )
	end

	activeMovement['sums']['data_point_count'] = activeMovement['sums']['data_point_count'] + 1

	-- add new data point
	table.insert( activeMovement['dataPoints'], dataPoint )

	-- determine which paths are still in use
	local remainingPathStates = {}
	for pathStateIndex, pathState in ipairs(activeMovement['pathStates']) do
		local currentPath = pathState['path']
		local currentVector = currentPath['vectors'][pathState['vector']]

		-- test if data point meets vector range requirements
		local rangeMatch = true
		if currentVector['ranges'] then
			rangeMatch = false
			for index, range in ipairs(currentVector['ranges']) do
				rangeMatch = rangeMatch or matchDataPoint( dataPoint, range )
			end
		end

		local vectorMatch = true
		-- @todo test if the added data point completes the vector or disqualifies it

		local complete = false
		if currentVector['complete'] then

			local sumsMatch = false
			if currentVector['complete']['sums'] then
				for index, sum in ipairs( currentVector['complete']['sums'] ) do
					sumsMatch = sumsMatch or matchDataPoint( activeMovement['sums'], sum )
				end
			end

			complete = sumsMatch
		end

		pathState['complete'] = pathState['complete'] or complete
		activeMovement['qualified'] = activeMovement['qualified'] or complete

		if rangeMatch and vectorMatch then
			table.insert( remainingPathStates, pathState )
		elseif pathState['complete'] then
			activeMovement['complete'] = true
		end

	end

	activeMovement['pathStates'] = remainingPathStates

	if activeMovement['complete'] then
		activeMovement['status'] = 'completed' -- rep is complete
	elseif activeMovement['qualified'] then
		activeMovement['status'] = 'qualified' -- rep is complete, but still active
	-- elseif  then
	--	activeMovement['status'] = 'verified' -- movement is verified
	elseif table.getn( activeMovement['pathStates'] ) == 0 then
		activeMovement['status'] = 'started' -- movement has started, but has not been verified
	end


	return activeMovement

end

local function meetsMovementStartCriteria( dataPoint, movement )
	local activePaths = matchDataPointToMovementPaths( dataPoint, movement )
	return activePaths and table.getn( activePaths ) > 0
end

return {
	find=findMovement,
	all=allMovements,
	meetsMovementStartCriteria=meetsMovementStartCriteria,
	newActiveMovement=newActiveMovement,
	updateActiveMovement=updateActiveMovement,
}
