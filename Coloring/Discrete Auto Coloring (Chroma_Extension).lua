--  @description Discrete Auto Coloring (Chroma_Exntension)
--  @author olshalom, vitalker
--  @version 0.7.1
--  @date 25.09.20
--  @changelog
--    0.7
--      Bugfixes:
--      - if autocoloring for tracks is activated, check if a track has already a color
--      - fix autocoloring for new added/recorded items in ShinyColorsMode

--    0.6
--      Update:
--      - update to latest auto coloring functions

--    0.5
--      Bug fixes: 
--        > fixed bug with draw new item in ShinyColorsMode

--    0.4
--      Bug fixes: 
--        > fixed crash when item not valid
--        > recolor items only in ShinyColorsMode 

--    0.3
--      > Updated and adjusted to behave similar to CHROMA 0.9.0

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


  
local script_name = 'Chroma - Coloring Tool'
  
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


-- GET HANDLES OF WINDOWS AND INTERCEPT --
local main = reaper.GetMainHwnd()
local ruler_win = reaper.JS_Window_FindChildByID(main, 0x3ED)
local arrange = reaper.JS_Window_FindChildByID(main, 0x3E8)
local seen_msgs = {}


function hslToRgb(h, s, l)
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    function hue2rgb(p, q, t)
      if t < 0   then t = t + 1 end
      if t > 1   then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end
    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q
    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end
  return r, g, b
end


local function HSL(h, s, l, a)
  local r, g, b = hslToRgb(h, s, l)
  return ImGui.ColorConvertDouble4ToU32(r, g, b, a or 1.0)
end


function rgbToHsl(r, g, b)
  --r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l
  l = (max + min) / 2
  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, l
end
  

local function HSV(h, s, v, a)
  local r, g, b = reaper.ImGui_ColorConvertHSVtoRGB(h, s, v)
  return ImGui.ColorConvertDouble4ToU32(r, g, b, a or 1.0)
end


local function IntToRgba(Int_color)
  local r, g, b = ColorFromNative(Int_color)
  return ImGui.ColorConvertDouble4ToU32(r/255, g/255, b/255, a or 1.0)
end


function loadsetting(str3, alt)
  local function toboolean(str2) return str2 == "true" end
  local var
  if reaper.HasExtState(script_name, str3) then
    var = toboolean(reaper.GetExtState(script_name, str3))
  else
    var = alt
  end
  return var
end


function loadsetting2(str4, alt2)
  local var2
  if reaper.HasExtState(script_name, str4) then
    var2 = tonumber(reaper.GetExtState(script_name, str4))
  else 
    var2 = alt2
  end
  return var2
end


-- PREDEFINE TABLES AS LOCAL --

local sel_color = {} 
local move_tbl = {it = {}, trk_ip = {}}
local col_tbl = nil
local pal_tbl = nil
local cust_tbl = nil
local sel_tbl = {it = {}, tke = {}, tr = {}, it_tr = {}}
local custom_palette = {}
local main_palette 
local auto_pal 
local auto_custom
local auto_palette
local sel_tab
local auto_track = {auto_pal, auto_palette, auto_retval, auto_custom = loadsetting("auto_custom", false), auto_stable = loadsetting("auto_stable", false)}
local mouse_item = {mod_flag_t ={}}


-- PREDEFINE VALUES AS LOCAL--
local items_mode, item_sw, takecolor2, projfn2
local remainder, init_state_saved, mouse_over
local old_project, track_number_stop, tr_cnt_sw
local takelane_mode2, sel_tracks2 
local test_take, test_take2, test_track_it, test_item_sw, test_track_sw, sel_items, sel_items_sw, it_cnt_sw, track_sw2


-- LOADING SETTINGS --
local selected_mode       = loadsetting2("selected_mode", 0)
local automode_id         = loadsetting2("automode_id", 1)
local colorspace          = loadsetting2("colorspace", 0)
local lightness           = loadsetting2("lightness", 0.65)
local darkness            = loadsetting2("darkness", 0.2)
local saturation          = loadsetting2("saturation", 0.8)
local rgba                = loadsetting2("rgba", 630132991)
local rgba3               = loadsetting2("rgba3", 630132991)
local auto_trk            = loadsetting("auto_trk", true)


if reaper.HasExtState(script_name, "custom_palette") then
  for i in string.gmatch(reaper.GetExtState(script_name, "custom_palette"), "[^,]+") do 
    insert(custom_palette, tonumber(string.match(i, "[^,]+"))) 
  end
else
  for m = 0, 23 do
    insert(custom_palette, HSL(m / 24+0.69, 0.1, 0.2, 1))
  end
end


-- GET ITEM OR TRACK COLORS FOR HIGHLIGHTING AND COLORING (CACHE) -- 

local function get_sel_items_or_tracks_colors(sel_items, sel_tracks, test_item, test_take, test_track)
  if sel_items > 0 and (test_take2 ~= test_take or sel_items ~= it_cnt_sw or test_item_sw ~= test_item) then
    sel_color = {}
    sel_tbl = {it = {}, tke = {}, tr = {}, it_tr = {}}
    move_tbl = {it = {}, trk_ip = {}}
    local index, tr_index, it_index, sel_index, trk_ip, same_col  = 0, 0, 0, 0
    for i=0, sel_items -1 do
      local itemcolor, different
      index = index+1
      local item = GetSelectedMediaItem(0,i) 
      if item then
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
      end
      if itemcolor ~= itemcolor_sw and itemcolor ~= nil then
        itemcolor = IntToRgba(itemcolor)
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
    end
  end
  return sel_color, move_tbl
end



-- FUNCTIONS FOR VARIOUS COLORING --
--________________________________--


-- caching trackcolors -- (could be extended and refined with a function written by justin by first check if already cached. Maybe faster)
local function generate_trackcolor_table(tr_cnt)
col_tbl = {it={}, tr={}, tr_int={}, ptr={}, ip={}}
local index=0
for i=0, tr_cnt -1 do
  index = index+1
  local track = GetTrack(0,i)
  local trackcolor = GetTrackColor(track)
  col_tbl.tr[index], col_tbl.it[index] = IntToRgba(trackcolor), background_color_native(trackcolor)
  col_tbl.tr_int[index], col_tbl.ptr[index], col_tbl.ip[index] = trackcolor, track, GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')
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
local function Color_new_items_automatically(init_state, sel_items, go, test_item) 
  if go and selected_mode == 1 and automode_id == 1 and test_item ~= test_item_sw then
    if (Undo_CanUndo2(0)=='Insert new MIDI item'
      or Undo_CanUndo2(0)=='Insert media items'
        or Undo_CanUndo2(0)=='Recorded media'
          or Undo_CanUndo2(0)=='Insert empty item'
            or Undo_CanUndo2(0)=='Insert click source') then
      PreventUIRefresh(1) 
      for i=0, sel_items -1 do
        local item = GetSelectedMediaItem(0, i)
        local tr_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(item), "IP_TRACKNUMBER")
        SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", col_tbl.it[tr_ip] )
      end
      UpdateArrange()
      PreventUIRefresh(-1) 
    end
  elseif go and automode_id == 2 then
    if (Undo_CanUndo2(0)=='Insert media items'
        or Undo_CanUndo2(0)=='Recorded media') then
      PreventUIRefresh(1) 
      for i=0, sel_items -1 do
        local item = GetSelectedMediaItem(0, i)
        SetMediaItemTakeInfo_Value(GetActiveTake(item), "I_CUSTOMCOLOR", ImGui.ColorConvertNative(rgba >>8)|0x1000000)
        if selected_mode == 1 then
          SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", Background_color_rgba(rgba))
        end
      end
      UpdateArrange()
      PreventUIRefresh(-1)
    end
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
local function Color_new_tracks_automatically() 
local track_number_sw, stored_val, found, track, tr_ip, prev_tr_ip, state2
return function(sel_tracks, test_track, state, tr_cnt)
  local track = GetTrack(0, tr_cnt-1) 
  if track and track ~= col_tbl.ptr[#col_tbl.ptr] and test_track ~= track and reaper.GetTrackColor(track) == 0 then
    for i = 0, tr_cnt-track_number_stop-1 do
      local track = GetTrack(0, tr_cnt-(tr_cnt-track_number_stop)+i)
      state = state+1
      if stored_val and state2 == state then -- if already a new track was created and the color of it is known
        SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_track.auto_pal.tr[stored_val%remainder+1])
        stored_val, state2 = stored_val+1, state +1
      else
        for q=1, #auto_track.auto_palette do
          if auto_track.auto_palette[q]==col_tbl.tr[#col_tbl.tr] then
            SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_track.auto_pal.tr[(q+i)%remainder+1])
            state2 = state +2
            found, stored_val, state2 = true, q+1, state +1
            break
          end
        end
        if not found then
          SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_track.auto_pal.tr[1])
          stored_val, state2 = 1, state +1
        end
      end
    end
    state2 = state2 +1
    track_number_sw, sel_tracks2, col_tbl, found = tr_cnt, true
  elseif sel_tracks > 0 then
    Undo_BeginBlock2(0)
    for i = 0, sel_tracks-1 do
      track = GetSelectedTrack(0, i) 
      local trk_color = reaper.GetTrackColor(track)
      if trk_color == 0 then
        state = state+1
        if stored_val and state2 == state then -- if already a new track was created and the color of it is known
          SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_track.auto_pal.tr[stored_val%remainder+1])
          if selected_mode == 1 and reaper.GetTrackMediaItem(track, 0) then
            Color_items_to_track_color_in_shiny_mode(track, auto_track.auto_pal.it[stored_val%remainder+1])
          end
          stored_val, state2 = stored_val+1, state +1
        else
          tr_ip = GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')
          if track ~= col_tbl.ptr[tr_ip] then
            prev_tr_ip = tr_ip-1
            if prev_tr_ip > 0 then
              for o=1, #auto_track.auto_palette do
                if auto_track.auto_palette[o]==col_tbl.tr[prev_tr_ip] then
                  SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_track.auto_pal.tr[o%remainder+1])
                  if selected_mode == 1 and reaper.GetTrackMediaItem(track, 0) then
                    Color_items_to_track_color_in_shiny_mode(track, auto_track.auto_pal.it[o%remainder+1])
                  end
                  found, stored_val, state2 = true, o+1, state +1
                  break
                end
              end
              if not found then 
                SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_track.auto_pal.tr[1])
                if selected_mode == 1 and reaper.GetTrackMediaItem(track, 0) then
                  Color_items_to_track_color_in_shiny_mode(track, auto_track.auto_pal.tr[1])
                end
                
                stored_val, state2 = 1, state +1
              end
            else
              SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_track.auto_pal.tr[1])
              if selected_mode == 1 and reaper.GetTrackMediaItem(track, 0) then
                Color_items_to_track_color_in_shiny_mode(track, auto_track.auto_pal.tr[1])
              end
              stored_val, state2  = 1, state +1
            end
          else
            state2 = 1 -- it just needs a value...
          end
        end
      end
    end
    if state2 then
      state2 = state2 +1
    end
    track_number_sw, sel_tracks2, col_tbl, found = tr_cnt, nil, nil, nil
    Undo_EndBlock2(0, "CHROMA: Automatically color new tracks", 1+4)
  end
  return track_number_sw
end
end



-- PALETTE FUNCTION --

local function Palette()
local main_palette = {}
if colorspace == 1 then colormode = HSV else colormode = HSL end
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
  main_palette[index] = colormode(n / 24+0.69, saturation, 0.25 - ((1-lightness)/4)+(darkness/4*3), 1)
  index = index+1
end
for n = 0, 23 do
  main_palette[index] = colormode(n / 24+0.69, saturation, darkness, 1)
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


function CheckForMod()
  local mod_actions = {'1 m','2 m', '3 m', '4 m', '5 m', '6 m', '16 m', '17 m', '18 m', '23 m', '24 m'}
  local index, mod = 0
  for i = 0 , 7 do
    local action = reaper.GetMouseModifier('MM_CTX_TRACK',i )
    for z = 1, 11 do
      if mod_actions[z] == action then
        if i == 1 then mod = 8
        elseif i == 2 then mod = 4
        elseif i == 3 then mod = 12
        elseif i == 4 then mod = 16
        elseif i == 5 then mod = 24
        elseif i == 6 then mod = 20
        elseif i == 7 then mod = 28 end
        index = index +1 
        mouse_item.mod_flag_t[index] = mod
      end
    end
  end
end

CheckForMod()

function DrawnItem(m1, m2, m3)
  local modifier = reaper.JS_Mouse_GetState(29)
  if m1 ~= (seen_msgs[6] or 0)  and modifier&28 ~= 0  then
    if not mouse_item.pressed then
      for i = 1, #mouse_item.mod_flag_t do
        if modifier&28 == mouse_item.mod_flag_t[i] then
          mouse_item.pressed = true
          mouse_item.pos = {reaper.GetMousePosition()}
          mouse_item.found = false
          mouse_item.stop = false
        break
        end
      end
    end
    mouse_item.pos2 = {reaper.GetMousePosition()}
    if m3 ~= (seen_msgs[7] or 0)  and modifier&28 ~= 0  then
      seen_msgs[6] = m1
      seen_msgs[7] = m3
      mouse_item.pressed, mouse_item.pos, mouse_item.pos2, mouse_item.stop, mouse_item.found,  mouse_item.item = nil
    elseif m2 ~= (seen_msgs[5] or 0) then
      seen_msgs[6] = m1
      seen_msgs[5] = m2
      mouse_item.stop = true
    end
  elseif m2 ~= (seen_msgs[5] or 0) then
    seen_msgs[6] = m1
    seen_msgs[5] = m2
    mouse_item.pressed, mouse_item.pos, mouse_item.pos2, mouse_item.stop, mouse_item.found,  mouse_item.item = nil
  elseif (mouse_item.stop or modifier&28 == 0) then
    mouse_item.pressed, mouse_item.pos, mouse_item.pos2, mouse_item.stop, mouse_item.found,  mouse_item.item = nil
  end
  if mouse_item.pressed and not mouse_item.found then
    if mouse_item.pos[1] ~= mouse_item.pos2[1] then
      local offset = mouse_item.pos2[1] - mouse_item.pos[1]
      local step = offset >= 0 and 1 or -1 
      for i = 1, math.abs(offset) do
        local x = mouse_item.pos[1] + (i * step)
        mouse_item.item = reaper.GetItemFromPoint(x, mouse_item.pos[2], 0)
        if mouse_item.item then
          break
        end
      end
      if mouse_item.item then
        PreventUIRefresh(1) 
        if automode_id == 1 then
          local tr_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(mouse_item.item), "IP_TRACKNUMBER")
          SetMediaItemInfo_Value(mouse_item.item, "I_CUSTOMCOLOR", col_tbl.it[tr_ip] )
        else
          SetMediaItemTakeInfo_Value(GetActiveTake(mouse_item.item), "I_CUSTOMCOLOR", ImGui.ColorConvertNative(rgba >>8)|0x1000000)
          if selected_mode == 1 then
            SetMediaItemInfo_Value(mouse_item.item, "I_CUSTOMCOLOR", Background_color_rgba(rgba))
          end
        end
        reaper.UpdateItemInProject(mouse_item.item)
        PreventUIRefresh(-1) 
        mouse_item.found = true
        mouse_item.stop = true
        mouse_item.pos, mouse_item.pos2, mouse_item.item = nil
      end
    end
  end
end


-- MAKE ANONYMOUS FUNCTIONS LOCAL --

local AutoItem = automatic_item_coloring()
local Color_new_tracks = Color_new_tracks_automatically() 

    
--[[_______________________________________________________________________________
  _______________________________________________________________________________]]



local function CollapsedPalette(init_state)
  -- CHECK FOR PROJECT TAP CHANGE --
  local cur_project, projfn = reaper.EnumProjects( -1 )
  if cur_project ~= old_project or projfn ~= projfn2 then
    old_project, projfn2, track_number_stop = cur_project, projfn, tr_cnt
    track_number_sw, col_tbl, cur_state4, it_cnt_sw, items_mode, test_track_sw = nil
  end

  local rvs6 = select(3, reaper.JS_WindowMessage_Peek(ruler_win, 'WM_LBUTTONUP'))
  local rvs2 = select(3, reaper.JS_WindowMessage_Peek(arrange, 'WM_LBUTTONDOWN'))
  local rvs5 = select(3, reaper.JS_WindowMessage_Peek(arrange, 'WM_LBUTTONUP'))

  -- DEFINE "GLOBAL" VARIABLES --
  if go then
    sel_items = CountSelectedMediaItems(0)
  end
  local test_item = GetSelectedMediaItem(0, 0) 
  local sel_tracks = CountSelectedTracks(0)
  local test_track = GetSelectedTrack(0, 0)
  local tr_cnt = CountTracks(0)
  
  
  -- AUTO TRACK COLORING AND TABLE PATCH DEPENDENT ON SETTINGS --
  if auto_trk then
    if not track_number_stop then track_number_stop = tr_cnt end
    if tr_cnt > track_number_stop then
      if not auto_track.auto_pal then
        if auto_track.auto_custom then
          auto_track.auto_pal = cust_tbl
          auto_track.auto_palette = custom_palette
          remainder = 24
        elseif auto_track.auto_stable then
          auto_track.auto_pal = {tr ={ImGui.ColorConvertNative(rgba3 >>8)|0x1000000}, it ={Background_color_rgba(rgba3)}}
          auto_track.auto_palette = {rgba3}
          remainder = 1
        elseif not auto_track.auto_custom then
          auto_track.auto_pal = pal_tbl
          auto_track.auto_palette = main_palette
          remainder = 120
        end
      end
      track_number_stop = Color_new_tracks(sel_tracks, test_track, init_state, tr_cnt)
    elseif tr_cnt < track_number_stop then
      track_number_stop, col_tbl = tr_cnt, nil
    end
  end
  
  -- SAVE ALL TRACKS AND THEIR COLORS TO A TABLE --
  if not col_tbl 
    or ((Undo_CanUndo2(0)=='Change track order')
        or  tr_cnt ~= tr_cnt_sw) then
    generate_trackcolor_table(tr_cnt)
    tr_cnt_sw = tr_cnt
  end  
  
  -- UNDO after adding tracks --
  if reaper.Undo_CanRedo2(0) =='CHROMA: Automatically color new tracks' then
    reaper.Undo_DoUndo2(0)
  end
  
  if not main_palette then
    main_palette = Palette()
    pal_tbl = generate_palette_color_table()
  end
  
  if not cust_tbl then
    cust_tbl = generate_custom_color_table()
  end
  
  if rvs2 ~= (seen_msgs[2] or 0) then
    if sel_items > 0 then
      it_cnt_sw = nil
      if test_item then
        test_take = GetActiveTake(test_item)
        test_track_it = GetMediaItemTrack(test_item)
        test_track_sw = nil
      end
      items_mode = 1
    elseif sel_tracks > 0 then
      items_mode, test_item = 0, nil
    else
      items_mode = 2
      sel_color = {}
    end
    seen_msgs[2] = rvs2
  -- MOUSE CLICK TCP --
  elseif rvs3 ~= (seen_msgs[3] or 0) and (static_mode == 0 or static_mode == 1) then
    items_mode = 0
    seen_msgs[3] = rvs3
  end
  
  -- CHECK FOR CURRENT DRAWN ITEM IN SHINY MODE OR WHEN SET NEW ITEMS TO CUSTOM COLOR IS SET --
  if selected_mode == 1 or automode_id == 2 then
    DrawnItem(rvs2, rvs5, rvs6)
  end
 --
  
  -- CALLING FUNCTIONS --
  Color_new_items_automatically(init_state, sel_items, go, test_item)
  get_sel_items_or_tracks_colors(sel_items, sel_tracks,test_item, test_take, test_track)
  
  if selected_mode == 1 then
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
end



-- LOOP -- MAIN FUNCTION --
local function loop()
  local init_state = GetProjectStateChangeCount(0)
  if init_state ~= init_state_saved then
    go = true
    init_state_saved = init_state
  else
    go = false
  end
  CollapsedPalette(init_state)
  defer(loop)
end


--local start_script

-- EXECUTE --
if auto_trk == false and selected_mode == 0 then
  local start_script = reaper.MB("No AutoColor option configured yet. \n\nThis script is meant\nas an extension of the\n\n'CHROMA - Coloring Tool' script\n\nto run all Auto Coloring features in a discrete state.\n\nFor full support, please run the Coloring Tool, set all colors in the two available palettes and the automatic coloring options under Settings/Advanced Settings/Autocoloring according to your needs.\n\n Do you want to continue with 'Automatically color new tracks' engaged?", "CHROMA - Discrete Autocoloring", 4)
  if start_script == 6 then
    auto_trk = true 
    SetExtState(script_name ,'auto_trk', tostring(auto_trk),true)
  end
end




if selected_mode == 1 or auto_trk == true then
  reaper.JS_WindowMessage_Intercept(ruler_win, 'WM_LBUTTONUP', true)
  reaper.JS_WindowMessage_Intercept(arrange, 'WM_LBUTTONDOWN', true)
  reaper.JS_WindowMessage_Intercept(arrange, 'WM_LBUTTONUP', true)
  reaper.set_action_options(1|4)
  defer(loop)
  reaper.atexit(function()
    reaper.set_action_options(8)
    reaper.JS_WindowMessage_Release(ruler_win, 'WM_LBUTTONUP')
    reaper.JS_WindowMessage_Release(arrange, 'WM_LBUTTONDOWN')
    reaper.JS_WindowMessage_Release(arrange, 'WM_LBUTTONUP')
  end)
else
  return
end