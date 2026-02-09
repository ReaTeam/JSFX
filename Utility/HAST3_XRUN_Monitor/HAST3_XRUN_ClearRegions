reaper.Undo_BeginBlock2(0)

local num_markers_regions = reaper.CountProjectMarkers(0)

for i = num_markers_regions-1, 0, -1 do
  local retval, isrgn, pos, rgnend, name, markrgnindex =
    reaper.EnumProjectMarkers(i)

  if retval and name and name:sub(1,4) == "XRUN" then
    reaper.DeleteProjectMarkerByIndex(0, i)
  end
end

reaper.Undo_EndBlock2(0, "Delete XRUN Regions", -1)
