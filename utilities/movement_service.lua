
local DATA_POINT_NUMERIC_ATTRIBUTES = { 'time_delta','acceleration_xaxis','acceleration_yaxis','acceleration_zaxis','acceleration_xaxis_delta','acceleration_yaxis_delta','acceleration_zaxis_delta','acceleration_xaxis_delta_sum','acceleration_yaxis_delta_sum','acceleration_zaxis_delta_sum','acceleration_xaxis_velocity','acceleration_yaxis_velocity','acceleration_zaxis_velocity','acceleration_xaxis_distance','acceleration_yaxis_distance','acceleration_zaxis_distance','angular_velocity_xaxis','angular_velocity_yaxis','angular_velocity_zaxis' }



-- Movements
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local movements = {
	laydown={
		name='Laydown',
		paths={
			{ -- path 1 start
				vectors={
					{ -- vector 1 start
						transition={
							instance_acceleration_xaxis_abs={ 0.9, 1.1 },
							instance_acceleration_yaxis_abs={ 0, 0.1 },
							instance_acceleration_zaxis_abs={ 0, 0.35 },
						},
						destination={
							instance_acceleration_xaxis_abs={ 0.9, 1.1 },
							instance_acceleration_yaxis_abs={ 0, 0.1 },
							instance_acceleration_zaxis_abs={ 0, 0.35 },
							vector_time_delta={ 0.5, nil }, -- complete after holding for at least 1 second
						},
					} -- vector 1 end
				}, -- vectors end
			}, -- path 1 end
		}, -- paths end
	}, -- movement end: laydown
	plank={
		name='Plank',
		paths={
			{ -- path 1 start
				vectors={
					{ -- vector 1 start
						transition={
							instance_acceleration_xaxis_abs={ 0.85, 0.98 },
							instance_acceleration_yaxis_abs={ 0.1, 0.45 },
							instance_acceleration_zaxis_abs={ 0, 0.35 },
						},
						destination={
							instance_acceleration_xaxis_abs={ 0.85, 0.98 },
							instance_acceleration_yaxis_abs={ 0.1, 0.45 },
							instance_acceleration_zaxis_abs={ 0, 0.35 },
							vector_time_delta={ 0.5, nil }, -- complete after holding for at least 1 second
						},
					} -- vector 1 end
				}, -- vectors end
			}, -- path 1 end
		}, -- paths end
	}, -- movement end: plank
	pushup={
		name='Push Up',
		paths={
			{ -- path 1 start
				vectors={
					{ -- vector 1 start - laydown static position
						transition={
							instance_acceleration_xaxis_abs={ 0.9, 1.1 },
							instance_acceleration_yaxis_abs={ 0, 0.1 },
							instance_acceleration_zaxis_abs={ 0, 0.35 },
						},
						destination={
							instance_acceleration_xaxis_abs={ 0.9, 1.1 },
							instance_acceleration_yaxis_abs={ 0, 0.1 },
							instance_acceleration_zaxis_abs={ 0, 0.35 },
							vector_time_delta={ 0.1, nil },
						},
					}, -- vector 1 end - laydown static position
					{ -- vector 2 start - push up
						transition={ -- accelerate up
							instance_acceleration_xaxis_abs={ 0.4, 1.1 },
							instance_acceleration_yaxis_abs={ 0.1, 0.45 },
							vector_time_delta={ 0.0, 3.0 },
						},
						destination={ -- stop in plank
							instance_acceleration_xaxis_abs={ 0.85, 0.98 },
							instance_acceleration_yaxis_abs={ 0.1, 0.45 },
							instance_acceleration_zaxis_abs={ 0.0, 0.35 },
							vector_time_delta={ 0.0, nil },
						},
					}, -- vector 2 end - push up
					{ -- vector 3 start - plank
						transition={
							instance_acceleration_xaxis_abs={ 0.85, 0.98 },
							instance_acceleration_yaxis_abs={ 0.1, 0.45 },
							instance_acceleration_zaxis_abs={ 0, 0.35 },
						},
						destination={
							instance_acceleration_xaxis_abs={ 0.85, 0.98 },
							instance_acceleration_yaxis_abs={ 0.1, 0.45 },
							instance_acceleration_zaxis_abs={ 0, 0.35 },
							vector_time_delta={ 0.0, nil },
						},
					} -- vector 3 end - plank
				}, -- vectors end
			}, -- path 1 end
		}, -- paths end
	}, -- movement end: push up
}



-- Utility Functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function dump(o)
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

local function incrementDataTable( dataPoint, dataTable )

	for index, dataPointAttribute in ipairs(DATA_POINT_NUMERIC_ATTRIBUTES) do
		dataTable[dataPointAttribute] = ( dataTable[dataPointAttribute] or 0.0 ) + ( dataPoint[dataPointAttribute] or 0.0 )
	end
	dataTable['data_point_count'] = (dataTable['data_point_count'] or 0) + 1

end

-- Matching Functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function evaluateCriteria( value, criteria )
	local match = true

	if not( criteria[1] == nil ) then
		match = match and (value >= criteria[1])
	end

	if table.getn(criteria) == 3 and not( criteria[3] == nil ) then
		match = match and (value <= criteria[3])
	elseif table.getn(criteria) == 2 and not( criteria[2] == nil ) then
		match = match and (value <= criteria[2])
	end

	return match
end

local function matchStateAttribute( state, attribute, criteria )

	-- Extract Modifiers
	local abs = string.ends( attribute, '_abs' )
	if abs then
		attribute = string.sub( attribute, 0, -5 )
	end

	-- Extract Scope
	local instance_scope = string.starts( attribute, 'instance_' )
	-- local vector_scope = string.starts( attribute, 'vector_' )
	local state_scope = state['vector']
	if instance_scope then
		state_scope = state['instance']
		attribute = string.sub( attribute, 10, -1 )
	else
		attribute = string.sub( attribute, 8, -1 )
	end

	-- Get Value, and apply modifiers
	local stateValue = state_scope[attribute]
	if abs then
		stateValue = math.abs( stateValue )
	end

	-- evaluate criteria against specified value
	return evaluateCriteria( stateValue, criteria )
end


local function matchState( state, allCriteria )
	local match = true

	-- Match all attribute's criteria
	for attribute,criteria in pairs( allCriteria ) do
		match = match and matchStateAttribute( state, attribute, criteria )
	end

	return match
end


local function findMatchingMovementPaths( dataPoint, movement )
	local paths = false

	for path_index, path in ipairs( movement['paths'] ) do
		-- path matches if dataPoint matches the start criteria of it's first vector
		local firstVector = path['vectors'][1]
		local criteria = firstVector.trigger or firstVector.transition

		if matchState( { instance=dataPoint, vector=dataPoint, path=dataPoint }, criteria ) then
			paths = paths or {}
			table.insert( paths, path )
		end
	end

	return paths
end



-- Vector Functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function vectorIsViable( activeMovement, pathState, currentVector, dataPoint )
	local timeWindowEnded = not( currentVector['destination']['vector_time_delta'][2] == nil ) and pathState['vectorData']['time_delta'] >= currentVector['destination']['vector_time_delta'][2]

	local transitionValid = true
	if currentVector.transition then
		transitionValid = matchState( { instance=dataPoint, vector=pathState.vectorData, path=activeMovement.data }, currentVector.transition )
	end

	return not( timeWindowEnded ) and transitionValid
end

local function vectorIsComplete( activeMovement, pathState, currentVector, dataPoint )


	-- determine if this path is still valid - by seeing if the vector has hit it's target before it expires.
	-- @todo replace with an algorithm which charts the vector and determines if it's progressing along the vector within a margin of error
	-- local timeWindowOpened = pathState['vectorData']['time_delta'] >= currentVector['vector']['vector_time_delta'][1]

	local vectorHitTarget = matchState( { instance=dataPoint, vector=pathState.vectorData, path=activeMovement.data }, currentVector.destination )

	return vectorHitTarget
end

-- Public Functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function findMovement( dataPoint )

end

local function allMovements()
	return movements
end

local function newActiveMovement( dataPoint, movement )

	local movementData = {}
	incrementDataTable( dataPoint, movementData )

	local activeMovement = {
		pathStates={},
		movement=movement,
		complete=false,
		status='started',
		data=movementData
	}

	local activePaths = findMatchingMovementPaths( dataPoint, movement )

	for index, activePath in ipairs(activePaths) do
		local newVectorData = {}
		incrementDataTable( dataPoint, newVectorData )

		local pathState = { path=activePath, vectorIndex=1, complete=false, vectorData=newVectorData }
		table.insert( activeMovement['pathStates'], pathState )
	end

	return activeMovement
end

local function updateActiveMovement( dataPoint, activeMovement )

	-- update running sums for movement
	incrementDataTable( dataPoint, activeMovement.data )

	-- determine which paths are still in use
	local remainingPathStates = {}
	for pathStateIndex, pathState in ipairs(activeMovement['pathStates']) do
		local currentPath = pathState['path']
		local currentPathVectors = currentPath['vectors']
		local currentVector = currentPathVectors[pathState.vectorIndex]
		local nextVector = currentPathVectors[pathState.vectorIndex+1]
		local isLastVector = (nextVector == nil)

		-- update running sums for path
		incrementDataTable( dataPoint, pathState.vectorData )

		local isViable = vectorIsViable( activeMovement, pathState, currentVector, dataPoint )
		local isComplete = vectorIsComplete( activeMovement, pathState, currentVector, dataPoint )
		local pathRemains = (isViable or isComplete)
		local incrementVector = false
		local wasComplete = false

		if isComplete then
			pathState['lastCompletedVectorIndex'] = pathState.vectorIndex
		elseif pathState['lastCompletedVectorIndex'] == pathState.vectorIndex then
			wasComplete = true
		end

		if isComplete and isLastVector then
			activeMovement['qualified'] = true
		elseif ( wasComplete or isComplete ) and not( isLastVector ) then
			-- if was complete, but is not longer, check to see if the next vector
			-- matches, if so move to it.
			-- if wasComplete then
			-- 	print( dump( dataPoint ) )
			-- end

			incrementVector = matchState( { instance=dataPoint, vector=dataPoint, path=activeMovement.data }, ( nextVector.trigger or nextVector.transition ) )
		end


		-- print( activeMovement.movement.name, pathState.vectorIndex, 'wasComplete', dump(wasComplete), 'isComplete', dump(isComplete), 'isLastVector', dump(isLastVector), 'pathRemains', dump(pathRemains), 'incrementVector', dump(incrementVector) )


		if incrementVector then
			pathState.vectorIndex = pathState.vectorIndex + 1

			-- reset vector data
			pathState['vectorData'] = {}
			incrementDataTable( dataPoint, pathState['vectorData'] )
		end

		if pathRemains or incrementVector then
			table.insert( remainingPathStates, pathState )
		end
	end

	activeMovement['pathStates'] = remainingPathStates

	if activeMovement['qualified'] and table.getn( remainingPathStates ) == 0 then
		activeMovement['status'] = 'completed' -- rep is complete
	elseif activeMovement['qualified'] then
		activeMovement['status'] = 'qualified' -- rep is complete, but still active
	elseif table.getn( activeMovement['pathStates'] ) == 0 then
		activeMovement['status'] = 'failed' -- movement has started, but has not been verified
	end


	return activeMovement

end

local function meetsMovementStartCriteria( dataPoint, movement )
	local activePaths = findMatchingMovementPaths( dataPoint, movement )
	return activePaths and table.getn( activePaths ) > 0
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return {
	find=findMovement,
	all=allMovements,
	meetsMovementStartCriteria=meetsMovementStartCriteria,
	newActiveMovement=newActiveMovement,
	updateActiveMovement=updateActiveMovement,
}
