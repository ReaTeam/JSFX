--FILE PATH:
local fname = "/path/to/file.csv"

local NAMESPACE = "xrun_monitor"
reaper.gmem_attach(NAMESPACE)

reaper.ClearConsole()

local srate = reaper.gmem_read(0)

local no=1
local i=4

if fname == "/path/to/file.csv" then
  reaper.ShowConsoleMsg('File path not set! Go to "Edit action..." and set it.\n')
  return
end

local f = io.open(fname, "w")
if not f then
  reaper.ShowConsoleMsg("Could not open file for writing\n")
  return
end

f:write(string.format("Sample rate: %d,unit:spl\nno,TimeOS,TimeAudio,Length\n", srate))

while reaper.gmem_read(i) == 42 do
  local time_os = reaper.gmem_read(i+1)
  local time_audio = reaper.gmem_read(i+2)
  local len = reaper.gmem_read(i+3)
    
  f:write(string.format("%.0f,%.1f,%.0f,%.1f\n", no, time_os, time_audio, len))
  reaper.ShowConsoleMsg(string.format("TimeOS: %.1f\n", time_os*srate))
  reaper.ShowConsoleMsg(string.format("TimeAudio: %.0f\n", time_audio*srate))
  reaper.ShowConsoleMsg(string.format("Length: %.1f\n\n", len*srate))
  no = no + 1
  i = i + 4
end

f:close()
