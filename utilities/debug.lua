
local mFloor = math.floor
local sGetInfo = system.getInfo
local sGetTimer = system.getTimer


local M = {}

local prevTime = 0
M.added = true
local function createText()
    local memory = display.newText('00 00.00 000',10,0, 'Helvetica', 18 );
    --memory:setFillColor(255,53,247)
    memory:setFillColor(1)
    memory.anchorY = 0
    memory.x, memory.y = display.contentCenterX, screenHeight - 50
    function memory:tap ()
        collectgarbage('collect')
        if M.added then
            Runtime:removeEventListener('enterFrame', M.labelUpdater)
            M.added = false
        --memory.alpha = .01
        else
            Runtime:addEventListener('enterFrame', M.labelUpdater)
            M.added = true
        memory.alpha = 1
        end
    end
    memory:addEventListener('tap', memory)
    return memory
end

function M.labelUpdater(event)
    local curTime = sGetTimer()
    M.text.text = 'FPS: ' .. tostring(mFloor( 1000 / (curTime - prevTime))) .. ' TexMem:' ..
            tostring(mFloor(sGetInfo('textureMemoryUsed') * 0.0001) * 0.01) .. ' LuaMem:' ..
            tostring(mFloor(collectgarbage('count')))
    M.text:toFront()
    prevTime = curTime
end

function M:newPerformanceMeter()
    self.text = createText(self)
    Runtime:addEventListener('enterFrame', M.labelUpdater)
end


function M.printTable( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end



return M