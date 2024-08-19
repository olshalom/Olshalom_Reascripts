--  @description Discrete Auto Coloring (Chroma_Exntension)
--  @author olshalom, vitalker
--  @version 0.2
--
--  @changelog
--    0.2
--      Bug fixes: 
--        > fix table creation on startup

--    0.1
--      NEW features:
--        > initial release

--      Mouse modifiers:
--     
--      Appearance:
--
--      Performance:
--
--      Bug fixes:


--[[

    To use the full potentual of ShinyColors Mode, make sure the Custom color under REAPER Preferences are set correctly,
    or the current used theme provides the value of 50 for tinttcp inside its rtconfig.txt file! More Info: ---------
  
  ]]

  
  local script_name = 'Chroma - Coloring Tool'
  --local OS = reaper.GetOS()
  
  

  -- CONSOLE OUTPUT --
  
  local function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
  end


  do
    local err
    local check = {
        { 'BR_PositionAtMouseCursor',
          'SWS Extension required.',
          'Please install SWS Extension as well.',
          'SWS/S&M extension',
          'https://www.sws-extension.org'
        }
      }
      
    local function OutputMB(chk_tbl, int2)
      local userinput = reaper.MB(chk_tbl[int2][2]..'\n\n'..chk_tbl[int2][3]..'\n\nDo you want to install??', script_name, 4)
      if userinput == 6 then
        if reaper.APIExists('ReaPack_BrowsePackages') then
          reaper.ReaPack_BrowsePackages(chk_tbl[int2][4])
          return
        else
          OpenURL(chk_tbl[int2][5])
          return
        end
      else
        return
      end
    end
    
    local function CheckForApi(tbl_chk, int)
      if not reaper.APIExists(tbl_chk[int][1]) then
        OutputMB(tbl_chk, int)
        err = true
        return
      end
    end
    
    for i = 1, #check-1 do
      err = CheckForApi(check, i)
    end
    if err then return end
  end
  
  
  
  -- PREDEFINE FUNCTIONS AS LOCAL --
  
  local reaper = reaper
  local GetSelectedTrack = reaper.GetSelectedTrack
  local GetSelectedMediaItem = reaper.GetSelectedMediaItem
  local GetMediaTrackInfo_Value = reaper.GetMediaTrackInfo_Value
  local GetMediaItemInfo_Value = reaper.GetMediaItemInfo_Value
  local GetMediaItemTake_Track = reaper.GetMediaItemTake_Track
  local GetMediaItemTakeInfo_Value = reaper.GetMediaItemTakeInfo_Value
  local GetMediaItemTrack = reaper.GetMediaItemTrack
  local SetMediaItemTakeInfo_Value = reaper.SetMediaItemTakeInfo_Value
  local GetActiveTake = reaper.GetActiveTake
  local ColorFromNative = reaper.ColorFromNative
  local CountSelectedTracks = reaper.CountSelectedTracks
  local CountSelectedMediaItems = reaper.CountSelectedMediaItems
  local SetMediaItemInfo_Value = reaper.SetMediaItemInfo_Value
  local SetMediaTrackInfo_Value = reaper.SetMediaTrackInfo_Value
  local CountTracks = reaper.CountTracks
  local GetTrack = reaper.GetTrack
  local GetTrackColor = reaper.GetTrackColor
  local GetProjectStateChangeCount = reaper.GetProjectStateChangeCount
  local GetTrackNumMediaItems = reaper.GetTrackNumMediaItems
  local GetTrackMediaItem = reaper.GetTrackMediaItem
  local SetTrackColor = reaper.SetTrackColor
  local ColorToNative = reaper.ColorToNative
  local CountTrackMediaItems = reaper.CountTrackMediaItems 
  local defer = reaper.defer
  local UpdateArrange = reaper.UpdateArrange
  local Undo_EndBlock2 = reaper.Undo_EndBlock2
  local Undo_BeginBlock2 = reaper.Undo_BeginBlock2
  local GetDisplayedMediaItemColor = reaper.GetDisplayedMediaItemColor
  local EnumProjects = reaper.EnumProjects
  local PreventUIRefresh = reaper.PreventUIRefresh
  local Main_OnCommandEx = reaper.Main_OnCommandEx
  local GetCursorContext2 = reaper.GetCursorContext2  
  local CountMediaItems = reaper.CountMediaItems      
  local GetMediaItem = reaper.GetMediaItem            
  local GetMediaItemNumTakes = reaper.GetMediaItemNumTakes
  local GetMousePosition = reaper.GetMousePosition
  local GetItemFromPoint = reaper.GetItemFromPoint
  local insert = table.insert
  local Undo_CanUndo2 = reaper.Undo_CanUndo2
  local SetExtState =reaper.SetExtState
  
  local ImGui = {
    ColorConvertDouble4ToU32 = reaper.ImGui_ColorConvertDouble4ToU32,
    ColorConvertNative = reaper.ImGui_ColorConvertNative
    }


  
  -- PREDEFINE TABLES AS LOCAL --
  
  local sel_color = {} 
  local move_tbl = {it = {}, trk_ip = {}}
  local col_tbl = nil
  local tr_clr = {} 
  local pal_tbl = nil
  local cust_tbl = nil
  local sel_tbl = {it = {}, tke = {}, tr = {}, it_tr = {}}
  local custom_palette = {}
  local main_palette 
  local auto_pal 
  local auto_custom
  local auto_palette
  local sel_tab
  local userpalette = {}
  

  
  -- PREDEFINE VALUES AS LOCAL--

  local test_take
  local test_take2
  local test_item_sw
  local test_track_sw
  local sel_tracks2 = 0      
  local sel_items_sw
  local it_cnt_sw 
  local track_sw2
  local automode_id
  local colorspace
  local colorspace_sw
  local items_mode 
  local lightness
  local darkness
  local retval
  local saturation
  local selected_mode
  local old_project
  local track_number_stop
  local auto_trk
  local tr_cnt_sw
  local remainder             
  local takelane_mode2
  local cur_state4
  local projfn2
  
  
  local function SetButtonState(set)
    local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
    reaper.SetToggleCommandState(sec, cmd, set or 0)
    reaper.RefreshToolbar2(sec, cmd)
  end
  


  local function HSL(h, s, l, a)
    local function hslToRgb(h, s, l)
      if s == 0 then return l, l, l end
      local function to(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < .16667 then return p + (q - p) * 6 * t end
        if t < .5 then return q end
        if t < .66667 then return p + (q - p) * (.66667 - t) * 6 end
        return p
      end
      local q = l < .5 and l * (1 + s) or l + s - l * s
      local p = 2 * l - q
      return to(p, q, h + .33334), to(p, q, h), to(p, q, h - .33334)
    end
    
    local r, g, b = hslToRgb(h, s, l)
    return ImGui.ColorConvertDouble4ToU32(r, g, b, a or 1.0)
  end
  
  
  
  local function HSV(h, s, v, a)
  
    local r, g, b = reaper.ImGui_ColorConvertHSVtoRGB(h, s, v)
    return ImGui.ColorConvertDouble4ToU32(r, g, b, a or 1.0)
  end
  
  
  
  local function IntToRgba(Int_color)
  
    local r, g, b = ColorFromNative(Int_color)
    return ImGui.ColorConvertDouble4ToU32(r/255, g/255, b/255, a or 1.0)
  end
  


  -- LOADING SETTINGS --
  
  if reaper.HasExtState(script_name, "selected_mode") then
    selected_mode       = tonumber(reaper.GetExtState(script_name, "selected_mode"))
  else selected_mode = 0 end
  
  if reaper.HasExtState(script_name, "colorspace") then 
    colorspace          = tonumber(reaper.GetExtState(script_name, "colorspace"))
  else colorspace = 0 end
  
  if reaper.HasExtState(script_name, "automode_id") then
    automode_id         = tonumber(reaper.GetExtState(script_name, "automode_id"))
  else automode_id = 1 end

  if reaper.HasExtState(script_name, "saturation") then
    saturation          = tonumber(reaper.GetExtState(script_name, "saturation"))
  else saturation = 0.8 end
  
  if reaper.HasExtState(script_name, "custom_palette") then
    for i in string.gmatch(reaper.GetExtState(script_name, "custom_palette"), "[^,]+") do 
      insert(custom_palette, tonumber(string.match(i, "[^,]+"))) 
    end
  else
    for m = 0, 23 do
      insert(custom_palette, HSL(m / 24+0.69, 0.1, 0.2, 1))
    end
  end
  
  if reaper.HasExtState(script_name, "lightness") then
    lightness           = tonumber(reaper.GetExtState(script_name, "lightness"))
  else lightness = 0.65 end
  
  if reaper.HasExtState(script_name, "darkness") then
    darkness            = tonumber(reaper.GetExtState(script_name, "darkness"))
  else darkness = 0.2 end
  
  if reaper.HasExtState(script_name, "auto_trk") then
    if reaper.GetExtState(script_name, "auto_trk") == "false" then auto_trk = false end
    if reaper.GetExtState(script_name, "auto_trk") == "true" then auto_trk = true end
  else auto_trk = false end
  
  if reaper.HasExtState(script_name, "auto_custom") then
    if reaper.GetExtState(script_name, "auto_custom") == "false" then auto_custom = false end
    if reaper.GetExtState(script_name, "auto_custom") == "true" then auto_custom = true end
  else auto_custom = false end
  
  -- HIGHLIGHTING ITEMS OR TRACK COLORS -- 
  
  local function get_sel_items_or_tracks_colors(sel_items, sel_tracks, test_item, test_take, test_track)
      
    if sel_items > 0 and (test_take2 ~= test_take or sel_items ~= it_cnt_sw or test_item_sw ~= test_item) then
      --palette_high = {main = {}, cust = {}}
      sel_color = {}
      sel_tbl = {it = {}, tke = {}, tr = {}, it_tr = {}}
      move_tbl = {it = {}, trk_ip = {}}
      local index, tr_index, it_index, sel_index, trk_ip, same_col  = 0, 0, 0, 0
      for i=0, sel_items -1 do
        local itemcolor, different
        index = index+1
        local item = GetSelectedMediaItem(0,i) 
        sel_tbl.it[index] = item
        local take = GetActiveTake(item)
        sel_tbl.tke[index] = take
        local itemtrack = GetMediaItemTrack(item)
        sel_tbl.it_tr[index] = itemtrack
        if itemtrack ~= itemtrack2 then
          tr_index, itemtrack2, different = tr_index+1, itemtrack, 1
          sel_tbl.tr[tr_index] = itemtrack
        end

        if selected_mode == 1 then
          if take then 
            itemcolor = GetMediaItemTakeInfo_Value(take,"I_CUSTOMCOLOR")
            if itemcolor == 0 then
              it_index = it_index +1
              if different or not trk_ip then
                trk_ip = GetMediaTrackInfo_Value(itemtrack, "IP_TRACKNUMBER")  
                itemcolor = col_tbl.tr_int[trk_ip]
              else
                itemcolor = nil
              end
              move_tbl.trk_ip[it_index] = trk_ip 
              move_tbl.it[it_index] = item  
            end
          else
            itemcolor = GetMediaItemInfo_Value(item,"I_CUSTOMCOLOR")
            if itemcolor ~= same_col then
              same_col = false
            end
            if itemcolor == same_col then
              it_index, itemcolor = it_index +1, nil
              move_tbl.trk_ip[it_index] = trk_ip
              move_tbl.it[it_index] = item
            elseif different or not same_col then
              trk_ip = GetMediaTrackInfo_Value(itemtrack, "IP_TRACKNUMBER")
              if itemcolor == col_tbl.it[trk_ip] then
                same_col, it_index = itemcolor, it_index +1
                itemcolor = col_tbl.tr_int[trk_ip]
                move_tbl.trk_ip[it_index] = trk_ip
                move_tbl.it[it_index] = item
              else
                for i=1, #pal_tbl.it do
                  if pal_tbl.it[i] == itemcolor then
                    itemcolor = pal_tbl.tr[i]
                    col_found = true
                    break
                  end
                end
                if not col_found then
                  for i=1, #cust_tbl.it do
                    if cust_tbl.it[i] == itemcolor then
                      itemcolor = cust_tbl.tr[i]
                      break
                    end
                  end
                end
              end
            end
          end
        else
          itemcolor = GetDisplayedMediaItemColor(item)
        end
        if itemcolor ~= itemcolor_sw and itemcolor ~= nil then
          itemcolor = IntToRgba(itemcolor)
          for i = 1, #main_palette do
            if itemcolor == main_palette[i] then
              --palette_high.main[i] = 1
              break
            end
          end
          for i = 1, #custom_palette do
            if itemcolor == custom_palette[i] then
              --palette_high.cust[i] = 1 
              break
            end
          end
          sel_index, itemcolor_sw = sel_index+1, itemcolor
          sel_color[sel_index] = itemcolor
        end
      end
      test_track_sw, itemtrack2, test_take2, test_item_sw, itemcolor_sw = nil, nil, test_take, test_item, nil   
      it_cnt_sw, col_found  = sel_items, nil
      
    elseif sel_tracks > 0 and (test_track_sw ~= test_track or sel_tracks2 ~= sel_tracks) and items_mode == 0 then 
      --palette_high = {main = {}, cust = {}}
      sel_color = {}
      for i=0, sel_tracks -1 do
        test_track_sw, sel_tracks2 = test_track, sel_tracks
        local track = GetSelectedTrack(0,i)
        sel_tbl.tr[i+1] = track
        local trackcolor = IntToRgba(GetTrackColor(track)) 
        sel_color[i+1] = trackcolor
        for i =1, #main_palette do
          if trackcolor == main_palette[i] then
            --palette_high.main[i] = 1
          end
        end
        for i =1, #custom_palette do
          if trackcolor == custom_palette[i] then
            --palette_high.cust[i] = 1
          end
        end
      end
    end
    return sel_color, move_tbl
  end
  
  
  
  -- FUNCTIONS FOR VARIOUS COLORING --
  --________________________________--
  
  
  -- caching trackcolors -- (could be extended and refined with a function written by justin by first check of already cached. Maybe faster)
  local function generate_trackcolor_table(tr_cnt)
    
    col_tbl = {it={}, tr={}, tr_int={}, ptr={}, ip={}}
    local index=0
    for i=0, tr_cnt -1 do
      index = index+1
      local track = GetTrack(0,i)
      local trackcolor = GetTrackColor(track)
      col_tbl.tr[index] = IntToRgba(trackcolor)
      col_tbl.it[index] = background_color_native(trackcolor)
      col_tbl.tr_int[index] = trackcolor
      col_tbl.ptr[index] = track
      col_tbl.ip[index] = GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')
    end
    return col_tbl
  end
  

  
  -- COLOR ITEMS TO TRACK COLOR IN SHINYCOLORS MODE WHEN MOVING --
  
  function automatic_item_coloring() 

    local local_ip, cur_state3
    return function(func_mode, track_sw, track1, init_state)
      if func_mode == 1 then
        
        PreventUIRefresh(1)
        for x=1, #move_tbl.it do
          if move_tbl.trk_ip[x] == move_tbl.trk_ip[x-1] then
            SetMediaItemInfo_Value(move_tbl.it[x],"I_CUSTOMCOLOR", col_tbl.it[local_ip])
          else
            local_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(move_tbl.it[x]), "IP_TRACKNUMBER")
            SetMediaItemInfo_Value(move_tbl.it[x], "I_CUSTOMCOLOR", col_tbl.it[local_ip])
          end
        end
        local track_sw = track1
        UpdateArrange()
        PreventUIRefresh(-1)
      elseif func_mode == 2 then   -- if more than 60.000 items are selected, change colors after undopoint
        if not cur_state3 then cur_state3 = init_state end
        if (Undo_CanUndo2(0)=='Move media items')
              and init_state ~= cur_state3 then
          PreventUIRefresh(1) 
          for x=1, #move_tbl.it do
            if move_tbl.trk_ip[x] == move_tbl.trk_ip[x-1] then
              SetMediaItemInfo_Value(move_tbl.it[x] ,"I_CUSTOMCOLOR", col_tbl.it[local_ip])
            else
              local_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(move_tbl.it[x]), "IP_TRACKNUMBER")
              SetMediaItemInfo_Value(move_tbl.it[x], "I_CUSTOMCOLOR", col_tbl.it[local_ip])
            end
          end
          cur_state3 = init_state
          UpdateArrange()
          PreventUIRefresh(-1)
        end
      end  
      return track_sw
    end
  end
  
  
  
  -- COLOR TAKES IN SHINYCOLORS MODE --
  
  local function reselect_take(init_state, sel_items, item_track)
  
    local takelane_mode = reaper.SNM_GetIntConfigVar("projtakelane", 1)
    
    if takelane_mode ~= takelane_mode2 then
      if (takelane_mode == 1 or takelane_mode == 3) then
        PreventUIRefresh(1)
        local item_count = CountMediaItems(0)
        for i = 0, CountMediaItems(0) -1 do
          local item = GetMediaItem(0, i)
          local tke_num = GetMediaItemNumTakes(item)
          if tke_num > 1 then
            for j = 0, tke_num -1 do
              local take = reaper.GetTake(item, j)
              if take then
                local takecolor = reaper.GetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR")
                if takecolor2 then
                  if takecolor ~= takecolor2 then
                    local back2 = ImGui.ColorConvertNative(HSV(1, 0, 0.7, 1.0) >> 8)|0x1000000
                    SetMediaItemInfo_Value(item ,"I_CUSTOMCOLOR", back2) 
                  end
                else
                  takecolor2 = takecolor
                end
              end
            end
          end
        end
        PreventUIRefresh(-1)
        UpdateArrange()
        takelane_mode2 = takelane_mode
      elseif (takelane_mode == 0 or takelane_mode == 2) then
        PreventUIRefresh(1)
        for i = 0, CountMediaItems(0) -1 do
          local item = GetMediaItem(0, i)
          local tke_num = GetMediaItemNumTakes(item)
          if tke_num > 1 then
            local take = GetActiveTake(item)
            if take then
              local takecolor = GetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR")
              if takecolor == 0 then 
                local trk_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(item), "IP_TRACKNUMBER")
                SetMediaItemInfo_Value(item ,"I_CUSTOMCOLOR", col_tbl.it[trk_ip])
              else
                local back = background_color_native(takecolor)
                SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", back) 
              end
            end
          end
        end
        PreventUIRefresh(-1)
        UpdateArrange()
        takelane_mode2 = takelane_mode
      end
    end
    
    if init_state ~= cur_state 
      and (takelane_mode == 0 or takelane_mode == 2) 
        and (Undo_CanUndo2(0)=='Change active take'
          or Undo_CanUndo2(0)=='Previous take'
            or Undo_CanUndo2(0)=='Next take') then
      PreventUIRefresh(1)
      for i=0, sel_items -1 do 
        local takecolor = GetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR")
        if takecolor == 0 then 
          local trk_ip = GetMediaTrackInfo_Value(sel_tbl.it_tr[i+1], "IP_TRACKNUMBER")
          SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", col_tbl.it[trk_ip])
        else
          local back = background_color_native(takecolor)
          SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", back) 
        end
      end
      cur_state = init_state
      PreventUIRefresh(-1)
      UpdateArrange()
    end
  end
  

   
  -- COLOR NEW ITEMS AUTOMATICALLY --
      
  local function Color_new_items_automatically(init_state, sel_items) 
  
    if automode_id == 1 and (not cur_state4 or cur_state4<init_state) then
      
      if (Undo_CanUndo2(0)=='Insert new MIDI item'
        or Undo_CanUndo2(0)=='Insert media items'
          or Undo_CanUndo2(0)=='Recorded media'
            or Undo_CanUndo2(0)=='Insert empty item') then
        PreventUIRefresh(1) 
        
        for i=0, sel_items -1 do
          local item = GetSelectedMediaItem(0, i)
          local tr_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(item), "IP_TRACKNUMBER")
          SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", col_tbl.it[tr_ip] )
        end
        
        UpdateArrange()
        PreventUIRefresh(-1) 
      elseif Undo_CanUndo2(0)=='Add media item via pencil' then
        local x, y = reaper.GetMousePosition()
        local item = reaper.GetItemFromPoint(x-10, y,1)
        if item then
          PreventUIRefresh(1) 
          local tr_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(item), "IP_TRACKNUMBER")
          SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", col_tbl.it[tr_ip] )
          UpdateArrange()
          PreventUIRefresh(-1) 
          
        end
      end
      cur_state4 = init_state
    end
  end
  

  
  -- PREPARE BACKGROUND COLOR FOR SHINYCOLORS MODE RGBA (DOUBLE4) --
  
  function Background_color_rgba(color)
    
    local r, g, b, a = reaper.ImGui_ColorConvertU32ToDouble4(color)
    local h, s, v = reaper.ImGui_ColorConvertRGBtoHSV(r, g, b)
    local s=s/3.7
    local v=v+((0.92-v)/1.3)
    if v > 0.99 then v = 0.99 end
    local background_color = ImGui.ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end
  
  
  
  -- PREPARE BACKGROUND COLOR FOR SHINYCOLORS MODE INTEGER --
  
  function background_color_native(color)
  
    local r, g, b = ColorFromNative(color)
    local h, s, v = reaper.ImGui_ColorConvertRGBtoHSV(r/255, g/255, b/255)
    local s=s/3.7
    local v=v+((0.92-v)/1.3)
    if v > 0.99 then v = 0.99 end
    local background_color = ImGui.ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end 
  
  
  
  function Color_items_to_track_color_in_shiny_mode(track, background_color)

    for j=0, GetTrackNumMediaItems(track) -1 do
      local trackitem = GetTrackMediaItem(track, j)
      local take = GetActiveTake(trackitem) 
      if take then
        local tracktakecolor = GetMediaItemTakeInfo_Value(take,"I_CUSTOMCOLOR")
        if tracktakecolor == 0 then
          SetMediaItemInfo_Value(trackitem,"I_CUSTOMCOLOR", background_color)
        end
      else
        local trackitemcolor = GetMediaItemInfo_Value(trackitem,"I_CUSTOMCOLOR")
        trackip = GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
        if trackitemcolor == col_tbl.it[trackip] then
          SetMediaItemInfo_Value(trackitem,"I_CUSTOMCOLOR", background_color)
        end
      end
    end
  end
  
  
  
  -- FOR AUTOCOLORING TO PALETTES
  
  function shuffled_numbers (n)
    
    function shuffle (arr)
      for i = 1, #arr - 1 do
        local j = math.random(i, #arr)
        arr[i], arr[j] = arr[j], arr[i]
      end
    end

    local numbers = {}
    for i = 1, n do
      numbers[i] = i
    end
    shuffle(numbers)
    return numbers
  end
  
  
  
  -- COLOR NEW TRACKS AUTOMATICALLY --
 
  local function Color_new_tracks_automatically(sel_tracks, test_track, state, tr_cnt) 
    
    local track_number_sw, stored_val, found, track, tr_ip, prev_tr_ip, state2
    return function()
        Undo_BeginBlock2(0)
        for i = 0, sel_tracks-1 do
          track = GetSelectedTrack(0, i) 
          state = state+1
          if stored_val and state2 == state then
            SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_pal.tr[stored_val%remainder+1])
            stored_val, state2 = stored_val+1, state +1
          else
            tr_ip = GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')
            if track ~= col_tbl.ptr[tr_ip] then
              prev_tr_ip = tr_ip-1
              if prev_tr_ip > 0 then
                for o=1, #auto_palette do
                  if auto_palette[o]==col_tbl.tr[prev_tr_ip] then
                    SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_pal.tr[o%remainder+1])
                    found, stored_val, state2 = true, o+1, state +1
                    break
                  end
                end
                if not found then 
                  SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_pal.tr[1])
                  stored_val, state2 = 1, state +1
                end
              else
                SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_pal.tr[1])
                stored_val, state2  = 1, state +1
              end 
            else
              state2 = 1 -- it just needs a value...
            end
          end
        end
        state2 = state2 +1
        track_number_sw, sel_tracks2, col_tbl, found = tr_cnt, nil, nil, nil
        Undo_EndBlock2(0, "CHROMA: Automatically color new tracks", 1)
      return track_number_sw, found
    end
  end
  
  

  -- PALETTE FUNCTION --

  local function Palette()
  
    local main_palette = {}
    if colorspace == 1 then colormode = HSV else colormode = HSL end
    local darkness_offset = 0.0 -- not in use
    local index = 1
    for n = 0, 23 do
      main_palette[index] =  colormode(n / 24+0.69, saturation, lightness, 1)
       index = index+1
    end
    for n = 0, 23 do
      main_palette[index] = colormode(n / 24+0.69, saturation, 0.75 - ((1-lightness)/4*3)+(darkness/4), 1)
      index = index+1
    end
    for n = 0, 23 do
      main_palette[index] = colormode(n / 24+0.69, saturation, 0.5 - ((1-lightness)/2)+(darkness/2), 1)
      index = index+1
    end
    for n = 0, 23 do
      main_palette[index] = colormode(n / 24+0.69, saturation, 0.25 - ((1-lightness)/4)+(darkness/4*3)+darkness_offset/4*3, 1)
      index = index+1
    end
    for n = 0, 23 do
      main_palette[index] = colormode(n / 24+0.69, saturation, darkness+darkness_offset, 1)
      index = index+1
    end
    return main_palette
  end
  
 
 
  -- for simply recall pregenerated colors --
  
  function generate_palette_color_table()
  
    pal_tbl = {tr={}, it={}}
    for i=1, #main_palette do
      pal_tbl.tr[i] = ImGui.ColorConvertNative(main_palette[i] >>8)|0x1000000
      pal_tbl.it[i] = Background_color_rgba(main_palette[i])
    end 
    return pal_tbl
  end
  
  
  
  -- for simply recall pregenerated colors --
  
  function generate_custom_color_table()
  
    cust_tbl = {tr={}, it={}}
    for y=1, #custom_palette do
      cust_tbl.tr[y] = ImGui.ColorConvertNative(custom_palette[y] >>8)|0x1000000
      cust_tbl.it[y] = Background_color_rgba(custom_palette[y])
    end 
    return cust_tbl
  end
  
  
  
  -- MAKE ANONYMOUS FUNCTIONS LOCAL --
  
  local AutoItem = automatic_item_coloring()
  
  
      
--[[_______________________________________________________________________________
    _______________________________________________________________________________]]
  
  
  
  local function CollapsedPalette(init_state)
  
    -- CHECK FOR PROJECT TAP CHANGE --
    local cur_project, projfn = reaper.EnumProjects( -1 )
    
    if cur_project ~= old_project or projfn ~= projfn2 then
      old_project, projfn2, track_number_stop = cur_project, projfn, tr_cnt
      track_number_sw, col_tbl, cur_state4, it_cnt_sw, items_mode, test_track_sw = nil
    end
    
    if not main_palette then
      main_palette = Palette()
      pal_tbl = generate_palette_color_table()
    end
    
    if not cust_tbl then
      cust_tbl = generate_custom_color_table()
    end
  
    -- DEFINE "GLOBAL" VARIABLES --
    
    local sel_tracks = CountSelectedTracks(0)
    local test_track = GetSelectedTrack(0, 0)
    
    local tr_cnt = CountTracks(0)
    if auto_trk then
      if auto_custom then
        if not auto_pal then 
          auto_pal = cust_tbl
          remainder = 24
          auto_palette = custom_palette
        end
      else
        if not auto_pal then
          auto_pal = pal_tbl
          remainder = 120
          auto_palette = main_palette
        end
      end
      if not track_number_stop then track_number_stop = tr_cnt end
      if tr_cnt > track_number_stop and test_track then
        local Color_new_tracks = Color_new_tracks_automatically(sel_tracks, test_track, init_state, tr_cnt)
        track_number_stop = Color_new_tracks()
      elseif tr_cnt < track_number_stop then
        track_number_stop, col_tbl = tr_cnt, nil
      end
    end
    if not col_tbl 
      or ((Undo_CanUndo2(0)=='Change track order')
          or  tr_cnt ~= tr_cnt_sw) then
      generate_trackcolor_table(tr_cnt)
      tr_cnt_sw = tr_cnt
    end  
    
    -- CALLING FUNCTIONS --

    if selected_mode == 1 then
      local sel_items = CountSelectedMediaItems(0)
      if (sel_tracks == 0 or GetCursorContext2(true) ~= 0) and sel_items > 0 then 
        test_item = GetSelectedMediaItem(0, 0) 
        test_take = GetActiveTake(test_item)
        items_mode = 1
      elseif sel_tracks > 0 then
        items_mode, test_item_sw, test_item = 0, nil
      else 
        sel_color = {}
        items_mode, test_track_sw, test_item_sw, test_item = 2, nil
      end
      get_sel_items_or_tracks_colors(sel_items, sel_tracks,test_item, test_take, test_track)
      Color_new_items_automatically(init_state, sel_items)
      if test_item and sel_items > 0 and sel_items < 60001 then
        local item_track = GetMediaItemTrack(test_item)
        if item_sw == test_item and track_sw2 ~= item_track then
          local Func_mode = 1
          AutoItem(Func_mode, track_sw2, item_track)
          track_sw2, item_sw, it_cnt_sw = item_track, test_item, nil
        else
          track_sw2, item_sw = item_track, test_item
        end
      elseif test_item and sel_items > 60000 then
        local Func_mode = 2
        AutoItem(Func_mode, track_sw2, item_track, init_state)
      end
      reselect_take(init_state, sel_items, item_track) 
    end
    
    if ((Undo_CanUndo2(0)=='Insert media items'
      or Undo_CanUndo2(0)=='Recorded media')
        and (not cur_state or cur_state<init_state))
          and automode_id == 2  then
      cur_state = GetProjectStateChangeCount(0)
      coloring_cust_col(sel_items, sel_tracks, in_color) 
    end
  end
  


  -- LOOP -- MAIN FUNCTION --

  local function loop()

    local init_state = GetProjectStateChangeCount(0)
    CollapsedPalette(init_state)
    defer(loop)
  end
  
  
  local start_script
  -- EXECUTE --
  
  if auto_trk == false and selected_mode == 0 then
    start_script = reaper.MB("No AutoColor option configured yet. \n\nThis script is meant\nas an extension of the\n\n'CHROMA - Coloring Tool' script\n\nto run all Auto Coloring features in a discrete state.\n\nFor full support, please run the Coloring Tool, set all colors in the two available palettes and the automatic coloring options under Settings/Advanced Settings/Autocoloring according to your needs.\n\n Do you want to continue with 'Automatically color new tracks' engaged?", "CHROMA - Discrete Autocoloring", 4)
    if start_script == 6 then
      auto_trk = true 
      SetExtState(script_name ,'auto_trk', tostring(auto_trk),true)
    end
  end
  
  if selected_mode == 1 or auto_trk == true then
    SetButtonState(1)
    reaper.set_action_options(1)
    defer(loop)
    reaper.atexit(SetButtonState)
  else
    return
  end



