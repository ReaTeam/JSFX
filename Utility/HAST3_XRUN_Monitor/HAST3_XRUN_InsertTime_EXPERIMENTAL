--CONFIG
local offset = 0

local NAMESPACE = "xrun_monitor"
reaper.gmem_attach(NAMESPACE)

local srate = reaper.gmem_read(0)

local no=1
local i=4
local prev_offsync = 0

reaper.Undo_BeginBlock2(0)

while reaper.gmem_read(i) == 42 do
  local time_os = reaper.gmem_read(i+1)
  local time_audio = reaper.gmem_read(i+2)
  local len = reaper.gmem_read(i+3)
  
  
  local offsync = time_os - time_audio
  
  local sync_len = offsync - prev_offsync
  
  if sync_len > 0 then
    reaper.GetSet_LoopTimeRange2(0, true, false, (time_audio + offset)/srate, (time_audio + sync_len + offset)/srate, false)
    reaper.Main_OnCommand(40200, 0)
    prev_offsync = prev_offsync + sync_len
  end
  
  no = no + 1
  i = i + 4
end

reaper.Undo_EndBlock2(0, "Insert XRUN compensation in project", -1)
