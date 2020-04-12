-- @noindex
-- @description Dumps the currently displayed curve from MIDI CC Mapper X.
-- @about 
-- @author Benjamin Talagan BAbut
-- @version 1.0
-- Licence: MIT
-- REAPER: 5.0+
-- Extensions: none

local user_lib_path = "Data/talagan_MIDI CC Mapper X/func/user_lib"; 

-- Split function
local function csplit(str,sep)
   local ret={}
   local n=1
   for w in str:gmatch("([^"..sep.."]*)") do
      ret[n] = w
      n = n + 1
   end
   return ret
end

local function getSaveParams(func)
  func   = func or ""
  
  local retval, retval_csv = reaper.GetUserInputs(
    "MIDI CC Mapper X : export...",
    1, 
    "Function sub path (without txt)", 
    func);

  local spath = csplit(retval_csv,'/');
  func        = spath[#spath];
  spath[#spath] = nil

  return retval, table.concat(spath,"/"), func
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function open_file_manager_on_path(path)
  local OS = reaper.GetOS()

  if OS == "OSX32" or OS == "OSX64" then
    os.execute('open "' .. path .. '"',2000)
  else
    os.execute('start "" "' .. path .. '"')
  end
end



local function finish_after_cmd(data)

    local retval            = true;
    local sub_path          = "";
    local func_id           = "";
    local things_are_ok     = false;
    local export_file_name  = nil;
    local export_folder     = nil;
    local propose           = "";
    
    while not things_are_ok do
      -- Ask, until cancel is hit, or everything is ok.
      
      if sub_path ~= "" then
        propose = sub_path .. "/" .. func_id
      else
        propose = func_id
      end
        
      retval, sub_path, func_id = getSaveParams(propose);
      
      if not retval then
        -- Cancel hit, quit
        return
      end
      
      if func_id ~= "" then
      
        export_folder    = reaper.GetResourcePath() .. "/" .. user_lib_path .. "/" .. sub_path;
        export_file_name = export_folder .. "/" .. func_id .. ".txt" ;
      
        if file_exists(export_file_name) then
          ow = reaper.ShowMessageBox("\nA file already exists for the same path : \n\n" .. "<RESOURCE>/" .. user_lib_path .. "/" .. sub_path .. "/" .. func_id .. ".txt\n\nOverwrite?","Warning!", 4);
          if ow == 6 then -- yes
            things_are_ok = true;
          end
        else
          -- Test if we can save
          things_are_ok = true;
        end
        
      end
    end
    
    reaper.RecursiveCreateDirectory(export_folder,1);
            
    file = io.open(export_file_name, "w")
    
    if file == nil then
      reaper.ShowMessageBox("\nFailed to save file.\n" ..
            "\n" ..
            "Make sure the target path is accessible (all subfolders should exist) :\n" ..
            "\n" ..
            export_file_name ..
            "\n\n" ..
            "Press OK to open the export folder.","Failed to save file!", 0);
        
    
    else
      -- appends a word test to the last line of the file
      file:write("@noindex\n");
      file:write("# MIDI CC Mapper X Function exported from REAPER\n\n");
      
      for k,v in pairs(data) do
        file:write( string.format("%f\n", v) );
      end
      
      -- closes the open file
      file:close()
    
      reaper.ShowMessageBox("\nYour function was exported successfully!\n\n" ..
        "" ..
        "To make it available in Reaper, please follow the README.md file.\n\n" ..
        ""..
        "Press OK to open the export folder.","Success!", 0);
    
      open_file_manager_on_path(export_folder .. "/");
      
    end
    
end

cmd_start = nil;
local function second_step_retrieve_cmd_result()
  
  local res = reaper.gmem_read(2);
    
  if res == 3 then
    
    local si = 0;
    data = {};
    while(si < 128) do
      data[si+1] = reaper.gmem_read(10+si);
      si = si + 1;
    end
  
    return finish_after_cmd(data);
  elseif res == 4 then
    reaper.ShowMessageBox("\nNo control selected in MIDI CC Mapper X or selected control is not enabled.\n\n",
        "Midi CC Mapper X : Failed", 0);
    return;
  end
    
  local elapsed = reaper.time_precise() - cmd_start
  
  if elapsed >= 1 then
    reaper.ShowMessageBox("\nLooks like the script could not communicate with any open instances of MIDI CC Mapper X. Make sure one (and only one) instance is currently displayed.\n\n",
     "Midi CC Mapper X : Failed", 0);
  else
    reaper.defer(second_step_retrieve_cmd_result)
  end
    
end
 
local function first_step_explain()

   reaper.ShowMessageBox("\nYou're about to export the currently displayed curve/function from the MIDI CC Mapper X plugin.\n\n" ..
      "" .. 
      "This will create a function file in your\n\n"..
      "" ..
      "<RESOURCE>/" .. user_lib_path .. "\n\n" ..
      "" ..
      "folder that you will have to reference from a file called 'user_lib.txt'.\n\n" .. 
      "A README.md file explaining how to proceed in details is located in that folder, which will be opened after save.\n\n",
      "Midi CC Mapper X : Info", 0);

    reaper.gmem_attach('MIDICCMapperX');
    reaper.gmem_write(1,1);  -- CMD 1 in CMD address
    reaper.gmem_write(2,1);  -- CMD READY in CMD status
    
    cmd_start = reaper.time_precise();
    second_step_retrieve_cmd_result();
end


first_step_explain();

