-- openfetch 1.0 | by ethernalsteve

local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local term = require("term")
local gpu = component.gpu

local logos = {
  {
    "  %%%%(///////(%%%    ",
    " %%###(///%%%/(%%%%%  ",
    " %%###(///%%%/(%%%%%  ",
    " %%###(///////(%%%%%  ",
    " %%%%%%%%%%%%%%%%%%%  ",
    " %%%%%%%%%%%%%%%%%%%  ",
    " %%               %%  ",
    " %%               %%  ",
    " %%%%%%%%%%%%%%%%%%%  ",
    "  %%%%%%%%%%%%%%%%%   "
  },
  {
    "  %%%%%(///////////////(%%%%      ",
    " %%%###(//////%%%%%%///(%%%%%%%   ",
    " %%%###(//////%%%%%%///(%%%%%%%   ",
    " %%%###(//////%%%%%%///(%%%%%%%   ",
    " %%%###(//////%%%%%%///(%%%%%%%   ",
    " %%%###(///////////////(%%%%%%%   ",
    " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
    " %%%((((((((((((((((((((((((%%%   ",
    " %%%((((((((((((((((((((((((%%%   ",
    " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
    " %%%                        %%%   ",
    " %%%////////////////////////%%%   ",
    " %%%                        %%%   ",
    " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
    "  %%%%%%%%%%%%%%%%%%%%%%%%%%%%    "
  },
  {
    "  %%%%%%%%%%(///////////////////////(%%%%%%%      ",
    " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%    ",
    " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
    " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
    " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
    " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
    " %%%%%%#####(///////////%%%%%%%/////(%%%%%%%%%%   ",
    " %%%%%%#####(///////////////////////(%%%%%%%%%%   ",
    " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
    " %%%%%%((((((((((((((((((((((((((((((((((%%%%%%   ",
    " %%%%%%((((((((((((((((((((((((((((((((((%%%%%%   ",
    " %%%%%%((((((((((((((((((((((((((((((((((%%%%%%   ",
    " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
    " %%%%%%                                  %%%%%%   ",
    " %%%%%%                                  %%%%%%   ",
    " %%%%%%                                  %%%%%%   ",
    " %%%%%%//////////////////////////////////%%%%%%   ",
    " %%%%%%                                  %%%%%%   ",
    " %%%%%%                                  %%%%%%   ",
    " %%%%%%                                  %%%%%%   ",
    " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   ",
    "  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    "
  }
}

local w, h = gpu.maxResolution()

local function getGPUTier()
  if w == 160 and h == 50 then 
    return 3
  elseif w == 80 and h == 25 then 
    return 2
  else 
    return 1
  end
end

local function osDefinition()
  if fs.exists("/lib/core") then 
    return "OpenOS"
  elseif fs.exists("/root") then 
    return "Plan9k"
  end
  return ""
end

local function getParsedUptime()
  local seconds = math.floor(computer.uptime())
  local minutes, hours = 0, 0

  if seconds >= 60 then
    minutes = math.floor(seconds / 60)
    seconds = seconds % 60
  end
  if minutes >= 60 then
    hours = math.floor(minutes / 60)
    minutes = minutes % 60
  end
  if getGPUTier() == 1 then
    return string.format("|Uptime|: %02d:%02d:%02d", hours, minutes, seconds)
  else
    local time = "|Uptime|: "
    if hours == 1 then
      time = hours .. " hour, "    
    elseif hours >= 2 then
      time = hours .. " hours, " 
    end
    if minutes == 1 then
      time = time .. minutes .. " min, "
    elseif minutes >= 2 then
      time = time .. minutes .. " mins, "
    end
    time = time .. seconds .. " sec"
    return time
  end
end

local logo = logos[getGPUTier()]

local function addCharacteristics()
  logo[2] = logo[2] .. "|OS|: " .. osDefinition()
  logo[3] = logo[3] .. getParsedUptime()
  logo[4] = logo[4] .. "|Resolution|: " .. math.floor(w) .. "x" .. math.floor(h)
  logo[5] = logo[5] .. "|Architecture|: " .. computer.getArchitecture()
  logo[6] = logo[6] .. "|GPU|: " .. getGPUTier() .. " Tier"
  logo[7] = logo[7] .. "|Memory|: " .. math.floor(computer.totalMemory() / 1024 - computer.freeMemory() / 1024) .. " KB / " .. math.floor(computer.totalMemory() / 1024) .. " KB"
end

gpu.setResolution(w, h)
addCharacteristics()
term.clear()
print()

for i = 1, #logo do
  local logoLine, tmp, f = {}, {}, false
  logo[i]:gsub(".",function(c) table.insert(logoLine,c) end)
  for ii = 1, #logoLine do
    if f then
      if string.match(logoLine[ii], "|") then
        f = false
      else
        if osDefinition() == "OpenOS" then
        gpu.setForeground(0x30ff80)
        elseif osDefinition() == "Plan9k" then
          gpu.setForeground(0xff0000)
        end
        io.write(logoLine[ii])
      end
    else
      if logoLine[ii] == "%" then
        if osDefinition() == "OpenOS" then
          gpu.setForeground(0x228822)
        elseif osDefinition() == "Plan9k" then
          gpu.setForeground(0xff0000)
        end
        io.write(logoLine[ii])
      elseif logoLine[ii] == "/" then
        gpu.setForeground(0xfffafa)
        io.write(logoLine[ii])
      elseif logoLine[ii] == "#" then
        gpu.setForeground(0x585858)
        io.write(logoLine[ii])
      elseif logoLine[ii] == "(" then
        gpu.setForeground(0xc0c0c0)
        io.write(logoLine[ii])
      elseif string.match(logoLine[ii], "|") then
        f = true
      else
        gpu.setForeground(0xffffff)
        io.write(logoLine[ii])
      end
    end
  end
  io.write("\n")
end