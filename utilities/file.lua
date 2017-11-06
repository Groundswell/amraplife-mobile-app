local M = {}
local json = require("json")
local DefaultLocation = system.DocumentsDirectory
local RealDefaultLocation = DefaultLocation
local ValidLocations = {
   [system.DocumentsDirectory] = true,
   [system.CachesDirectory] = true,
   [system.TemporaryDirectory] = true
}

function M.saveTable(t, filename, location)
    if location and (not ValidLocations[location]) then
     error("Attempted to save a table to an invalid location", 2)
    elseif not location then
      location = DefaultLocation
    end
    
    local path = system.pathForFile( filename, location )
    local file = io.open( path, "w" )
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end
 
function M.loadTable(filename, location)
    if location and (not ValidLocations[location]) then
     error("Attempted to load a table from an invalid location", 2)
    elseif not location then
      location = DefaultLocation
    end
    local path = system.pathForFile( filename, location)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = json.decode( contents )
        io.close( file )
        return myTable
    else
        return nil
    end
end

--check a file
-- if fileExists("imageName", system.CachesDirectory) then
--     --load image
-- else
--     --download image
-- end
function M.exists( fileName, dirName )
    local filePath = system.pathForFile( fileName, dirName )
    local results = false

    if filePath == nil then
        return false
    else
        local file = io.open( filePath, "r" )
        --If the file exists, return true
        if file then
            io.close( file )
            results = true
        end
        
        return results
    end
end

function M.changeDefault(location)
	if location and (not location) then
		error("Attempted to change the default location to an invalid location", 2)
	elseif not location then
		location = RealDefaultLocation
	end
	DefaultLocation = location
	return true
end

return M