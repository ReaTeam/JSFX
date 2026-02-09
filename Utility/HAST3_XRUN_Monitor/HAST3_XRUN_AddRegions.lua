-- @noindex

reaper.Undo_BeginBlock2(0)

--config
local color_gain = 24000

local NAMESPACE = "xrun_monitor"
reaper.gmem_attach(NAMESPACE)

local srate = reaper.gmem_read(0)

local no=1
local i=4

while reaper.gmem_read(i) == 42 do
  local time_os = reaper.gmem_read(i+1)
  local time_audio = reaper.gmem_read(i+2)
  local len = reaper.gmem_read(i+3)
  
  local intensity = math.floor(math.abs(len*color_gain))
  if intensity > 255 then intensity = 255 end
  local xrunstring = string.format("XRUN%d %.0f %.0f", no, len, (time_os-time_audio))
  
  if len > 0 then
    local color = reaper.ColorToNative(intensity,0,0) | 0x01000000
    reaper.AddProjectMarker2(
      0,
      true,
      time_audio / srate,
      (time_audio + len) / srate,
      xrunstring,
      -1,
      color
      )
  else
    local color = reaper.ColorToNative(0,0,128) | 0x01000000
    reaper.AddProjectMarker2(
      0,
      true,
      time_audio / srate,
      (time_audio + len) / srate,
      xrunstring,
      -1,
      color
      )
  end
    
  no = no + 1
  i = i + 4
end

reaper.Undo_EndBlock2(0, "Update XRUN Regions", -1)
