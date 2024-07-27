--  @description Chroma - Coloring Tool
--  @author olshalom, vitalker
--  @version 0.8.6
--
--  @changelog
--    0.8.6
--      NEW features:
--        > Marker and region coloring
--        > Region/Marker Manager support
--        > "Static context mode" via hold of ctrl/cmd and clicking selection indicator
--        > Refinement of "Color tracks/items to Main/Custom palette functions" when only one is selected
--        > Redisgned selection system under the hood for integrading marker/region coloring 
--        > Autocolor new items drawn via pencil in ShinyColors Mode
--        > Use REAPER theme background color (Experimental)
--        > ReaImGui 0.9.2 needed, please update if your current version of ReaImGui is older
--
--      Mouse modifiers:
--        > Shift + Command/Control: all Markers and Region in time selection get same color
--        > Shift: color Markers or Regions in time selection to same color dependent on focus in the selection indicator
--     
--      Appearance:
--        > Refinement of mainwindow frameborders
--        > Refinement of Selection indicator
--        > Redesign ShinyColors Mode indicator
--
--      Performance:
--        > Optimize idle state
--        > Overall optimizations for ShinyColors Mode
--        > Improved Gradient Coloring with shortcut and high count of selected tracks/items
--
--      Bug fixes:
--        > Updating trackcolor table on change of custom palette for automatic track coloring

--   0.8.5
--   Bug fixes:
--     > Fix second issue with empty items in shinycolors mode
--
--   0.8.4
--   Bug fixes:
--     > Fix issue with empty items in shinycolors mode
--
--   0.8.3
--   Bug fixes:
--     > check for ReaImGui Version compatibility
--   0.8.2
--   Bug fixes:
--     > issue with opening Palette Menu
--
--   0.8.1
--   NEW features:
--     > Save/Load Main Palette Presets
--     > Improved saving of "Last unsaved" presets (backup)
--  
--   Appearance:
--     > Redesigned Menubar

--   0.8.0
--   Bug fixes:
--     > Tooltip bug fix for Palette Menu (p=2746078)

--   0.7.9
--   NEW features:
--     > Save/Load Custom Palettes
--     > Show/Hide Sections
--     > Checkbox for Auto track coloring to custom palette
--     > Added current/original to color picker for custom color palette
--     > Added current/original to color picker for edit custom color 
--     > Clicking the selection indicator allows to switch between tracks/items if both are selected
--     > Clicking the selection indicator doesn't unselect tracks/items anymore
--     > Selection and Indicator is TCP/Arrange Window context-aware
--     > Automatically color multiple added tracks
--     > Refined Action "Color items/tracks to main palette" (dependent on selection indicator)
--     > Refined Action "Color items/tracks to custom palette" (dependent on selection indicator)
--     > Refined Action "Color items/tracks to gradient" (dependent on selection indicator)
--    
--   Mouse modifiers:
--     > Shift + Command/Control: Gradient Shortcut for au tomatically make a gradient for selected items/tracks (in two steps)
--     > Shift: Color selected items/tracks to Main/Custom Palette Shortcut for Color Buttons 
--     > Command/Control + RightClick Custom Color Button: get selected color to custom palette 
--     > Right click selection indicator unselect all items/tracks 
--     
--   Appearance:
--     > Redesigning Settings menu
--     > Redesigning shinycolors mode popup
--     > Dynamic action buttons font size
--     > Show shorter names for action buttons when the size is small enough 
--
--   Bug fixes:
--     > Highlighting for empty items in shinycolors mode
--     > fixing update arrange in automatic item coloring for shinycolors mode (performance improvement)
--     > Performance boost for Highlighting Colors
--     > Many many more improvements


--[[

    To use the full potentual of ShinyColors Mode, make sure the Custom color under REAPER Preferences are set correctly,
    or the current used theme provides the value of 50 for tinttcp inside its rtconfig.txt file! More Info: ---------
  
  ]]

  
  local script_name = 'Chroma - Coloring Tool'
  local OS = reaper.GetOS()
  local sys_os
  local sys_offset 
  local sys_scale
  if OS:find("OSX") or OS:find("macOS") then
    sys_os = 1
    sys_offset = 0
  else 
    sys_os = 0
    sys_offset = 30
  end
  -- GFX FONT  --
  gfx.r, gfx.g, gfx.b = 1, 1, 1
  gfx.set(100,1,1,1)
  
  

  -- CONSOLE OUTPUT --
  
  local function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
  end

  local function OpenURL(url)
    if type(url)~="string" then return false end
    if OS=="OSX32" or OS=="OSX64" or OS=="macOS-arm64" then
      os.execute("open ".. url)
    elseif OS=="Other" then
      os.execute("xdg-open s"..url)
    else
      os.execute("start ".. url)
    end
    return true
  end
  
  local ImGui

  do
    local err
    local check = {
        { 'ImGui_CreateContext',
          'requires ReaImGui:\nReaScript binding for Dear ImGui.',
          'Please install this Extension to use the Script.',
          'ReaImGui: ReaScript binding for Dear ImGui',
          'https://forum.cockos.com/showthread.php?t=250419'
        },
        { 'BR_PositionAtMouseCursor',
          'SWS Extension required.',
          'Please install SWS Extension as well.',
          'SWS/S&M extension',
          'https://www.sws-extension.org'
        },
        { 'JS_Mouse_GetState',
          'JS_ReaScriptAPI required.',
          'Please install JS_ReaScriptAPI as well.',
          'js_ReaScriptAPI: API functions for ReaScripts',
          'https://forum.cockos.com/showthread.php?t=212174'
        },
        { 'ImGui_CreateContext',
          'Version of ReaImGui Extension is to old.',
          'Please install the latest Version to use the Script.',
          'ReaImGui: ReaScript binding for Dear ImGui',
          'https://forum.cockos.com/showthread.php?t=250419'
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
    
    local imgui_ok
    if not reaper.ImGui_GetBuiltinPath then
      imgui_ok = false
    else
      package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua'
      imgui_ok, ImGui = pcall(function() return require 'imgui' '0.9.2' end)
      if not imgui_ok then
        check[4][2] = ImGui
      end
    end
    if not imgui_ok then
      OutputMB(check, 4)
      err = true
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
  local Undo_CanUndo2 = reaper.Undo_CanUndo2
  local defer = reaper.defer
  local UpdateArrange = reaper.UpdateArrange
  local Undo_EndBlock2 = reaper.Undo_EndBlock2
  local Undo_BeginBlock2 = reaper.Undo_BeginBlock2
  local GetDisplayedMediaItemColor = reaper.GetDisplayedMediaItemColor
  local EnumProjects = reaper.EnumProjects
  local SetMediaItemSelected = reaper.SetMediaItemSelected
  local SetTrackSelected = reaper.SetTrackSelected
  local PreventUIRefresh = reaper.PreventUIRefresh
  local Main_OnCommandEx = reaper.Main_OnCommandEx
  local GetTrackDepth = reaper.GetTrackDepth      
  local GetCursorContext2 = reaper.GetCursorContext2  
  local Undo_DoUndo2 = reaper.Undo_DoUndo2            
  local CountMediaItems = reaper.CountMediaItems      
  local GetMediaItem = reaper.GetMediaItem            
  local GetMediaItemNumTakes = reaper.GetMediaItemNumTakes
  local SetCursorContext =reaper.SetCursorContext
  local GetCursorPositionEx = reaper.GetCursorPositionEx
  local GetMousePosition = reaper.GetMousePosition
  local GetItemFromPoint = reaper.GetItemFromPoint
  local Undo_CanRedo2 = reaper.Undo_CanRedo2
  local SetExtState = reaper.SetExtState

  local insert = table.insert
  local max = math.max
  local min = math.min


  
  -- PREDEFINE TABLES AS LOCAL --
  
  local sel_color = {} 
  local move_tbl = {it = {}, trk_ip = {}}
  local col_tbl = nil
  local tr_clr = {} 
  local pal_tbl = nil
  local cust_tbl = nil
  local sel_tbl = {it = {}, tke = {}, tr = {}, it_tr = {}}
  local custom_palette = {}
  local main_palette = {}
  local palette_high = {main = {}, cust = {}}
  local user_palette = {}
  local auto_pal 
  local auto_custom
  local auto_palette
  local sel_tab
  local userpalette = {}
  local user_mainpalette = {}
  local user_main_settings = {}
  local rv_markers = {} 
  local sel_markers = { retval={}, number={}, m_type={} }
  local combo_items = { '   Track color', ' Custom color' }
  
  
  -- CONTROL VARIABLES -- run out of local variables
  
  local pre_cntrl = {
    current_item = 1,
    hovered_preset = ' ',
    combo_preview_value,
    current_main_item, 
    hovered_main_preset = ' ',
    main_combo_preview_value,
    stop,
    stop2,
    differs,
    differs2,
    differs3,
    new_combo_preview_value,
    main_new_combo_preview_value
    }
    
  local set_cntrl = {
    tree_node_open,
    tree_node_open_save,
    tree_node_open2,
    tree_node_open_save2,
    tree_node_open2,
    tree_node_open_save2,
    tree_node_open3,
    tree_node_open_save3
    }

  
  -- PREDEFINE VALUES AS LOCAL--

  local test_take
  local test_take2
  local test_track_it
  local test_item_sw
  local test_track_sw
  local sel_tracks2 = 0      
  local sel_items_sw
  local it_cnt_sw 
  local track_sw2
  local tr_txt = '##No_selection' 
  local tr_txt_h = 0.555
  local tr_txt_hb
  local automode_id
  local colorspace
  local colorspace_sw
  local dont_ask      --!! put it into table
  local items_mode 
  local lightness
  local darkness
  local random_custom --!! put it into table
  local random_main   --!! put it into table
  local retval
  local saturation
  local rgba
  local selected_mode
  local old_project
  local widgetscolorsrgba
  local track_number_stop
  local auto_trk
  local tr_cnt_sw
  local check_one             
  local button_text1           
  local button_text2          
  local button_text3           
  local button_text4          
  local button_text5          
  local gap                   
  local custom_color          
  local last_touched_color    
  local ref_col               
  local remainder             
  local show_action_buttons   
  local show_custompalette         
  local show_edit             
  local show_lasttouched      
  local show_mainpalette
  local draw_thickness
  local set_pos
  local sat_true
  local contrast_true
  local yes_undo
  local takelane_mode2
  local check_mark 
  local static_mode = 0
  local sel_mk 
  local can_re = ""
  local cur_state4

  
  
  -- Thanks to Sexan for the next two functions -- 
  
  function stringToTable(str)
  
    local f, err = load("return "..str)
    return f ~= nil and f() or nil
  end
  

  
  local function serializeTable(val, name, depth)

    depth = depth or 0
    local tmp = string.rep(" ", depth)
    if name then
        if type(name) == "number" and math.floor(name) == name then
            name = "[" .. name .. "]"
        elseif not string.match(name, '^[a-zA-z_][a-zA-Z0-9_]*$') then
            name = string.gsub(name, "'", "\\'")
            name = "['" .. name .. "']"
        end
        tmp = tmp .. name .. " = "
    end
    if type(val) == "table" then
        tmp = tmp .. "{"                                                      
        for k, v in pairs(val) do
            tmp = tmp .. serializeTable(v, k, depth + 1) .. "," 
        end
        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end
    return tmp
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
  
    local r, g, b = ImGui.ColorConvertHSVtoRGB(h, s, v)
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
  
  if reaper.HasExtState(script_name, "rgba") then
    rgba                 = tonumber(reaper.GetExtState(script_name, "rgba"))
  else rgba = 630132991 end
  
  if reaper.HasExtState(script_name, "dont_ask") then
    if reaper.GetExtState(script_name, "dont_ask") == "false" then dont_ask = false end
    if reaper.GetExtState(script_name, "dont_ask") == "true" then dont_ask = true end
  else dont_ask = false end
  
  if reaper.HasExtState(script_name, "random_custom") then
    if reaper.GetExtState(script_name, "random_custom") == "false" then random_custom = false end
    if reaper.GetExtState(script_name, "random_custom") == "true" then random_custom = true end
  else random_custom = false end
  
  if reaper.HasExtState(script_name, "random_main") then
    if reaper.GetExtState(script_name, "random_main") == "false" then random_main = false end
    if reaper.GetExtState(script_name, "random_main") == "true" then random_main = true end
  else random_main = false end
  
  if reaper.HasExtState(script_name, "auto_trk") then
    if reaper.GetExtState(script_name, "auto_trk") == "false" then auto_trk = false end
    if reaper.GetExtState(script_name, "auto_trk") == "true" then auto_trk = true end
  else auto_trk = true end
  
  if reaper.HasExtState(script_name, "show_custompalette") then
    if reaper.GetExtState(script_name, "show_custompalette") == "false" then show_custompalette = false end
    if reaper.GetExtState(script_name, "show_custompalette") == "true" then show_custompalette = true end
  else show_custompalette = true end
  
  if reaper.HasExtState(script_name, "show_edit") then
    if reaper.GetExtState(script_name, "show_edit") == "false" then show_edit = false end
    if reaper.GetExtState(script_name, "show_edit") == "true" then show_edit = true end
  else show_edit = true end
  
  if reaper.HasExtState(script_name, "show_lasttouched") then
    if reaper.GetExtState(script_name, "show_lasttouched") == "false" then show_lasttouched = false end
    if reaper.GetExtState(script_name, "show_lasttouched") == "true" then show_lasttouched = true end
  else show_lasttouched = true end
  
  if reaper.HasExtState(script_name, "show_mainpalette") then
    if reaper.GetExtState(script_name, "show_mainpalette") == "false" then show_mainpalette = false end
    if reaper.GetExtState(script_name, "show_mainpalette") == "true" then show_mainpalette = true end
  else show_mainpalette = true end
  
  if reaper.HasExtState(script_name, "show_action_buttons") then
    if reaper.GetExtState(script_name, "show_action_buttons") == "false" then show_action_buttons = false end
    if reaper.GetExtState(script_name, "show_action_buttons") == "true" then show_action_buttons = true end
  else show_action_buttons = true end
  
  if reaper.HasExtState(script_name, "auto_custom") then
    if reaper.GetExtState(script_name, "auto_custom") == "false" then auto_custom = false end
    if reaper.GetExtState(script_name, "auto_custom") == "true" then auto_custom = true end
  else auto_custom = false end
  
  if reaper.HasExtState(script_name, "tree_node_open_save") then
    if reaper.GetExtState(script_name, "tree_node_open_save") == "false" then set_cntrl.tree_node_open = false end
    if reaper.GetExtState(script_name, "tree_node_open_save") == "true" then set_cntrl.tree_node_open = true end
  else set_cntrl.tree_node_open = false end
  
  if reaper.HasExtState(script_name, "tree_node_open_save2") then
    if reaper.GetExtState(script_name, "tree_node_open_save2") == "false" then set_cntrl.tree_node_open2 = false end
    if reaper.GetExtState(script_name, "tree_node_open_save2") == "true" then set_cntrl.tree_node_open2 = true end
  else set_cntrl.tree_node_open2 = false end
  
  if reaper.HasExtState(script_name, "tree_node_open_save3") then
    if reaper.GetExtState(script_name, "tree_node_open_save3") == "false" then set_cntrl.tree_node_open3 = false end
    if reaper.GetExtState(script_name, "tree_node_open_save3") == "true" then set_cntrl.tree_node_open3 = true end
  else set_cntrl.tree_node_open3 = false end
  
  if reaper.HasExtState(script_name, "user_palette") then
    local serialized2 = reaper.GetExtState(script_name, "user_palette")
    user_palette = stringToTable(serialized2) 
  else
    insert(user_palette, '*Last unsaved*')
    SetExtState(script_name , 'userpalette.*Last unsaved*',  table.concat(custom_palette,","),true)
  end

  if reaper.HasExtState(script_name, "current_item") then
    pre_cntrl.current_item = tonumber(reaper.GetExtState(script_name, "current_item"))
  else pre_cntrl.current_item = 1 end
  
  if reaper.HasExtState(script_name, "user_mainpalette") then
    local serialized2 = reaper.GetExtState(script_name, "user_mainpalette")
    user_mainpalette = stringToTable(serialized2) 
  else
    insert(user_mainpalette, '*Last unsaved*')
    user_main_settings = {colorspace, saturation, lightness, darkness}
    local serialized = serializeTable(user_mainpalette)
    SetExtState(script_name , 'user_mainpalette', serialized, true )
    SetExtState(script_name , 'usermainpalette.*Last unsaved*',  table.concat(user_main_settings,","),true)
  end
  
  if reaper.HasExtState(script_name, "current_main_item") then
    pre_cntrl.current_main_item = tonumber(reaper.GetExtState(script_name, "current_main_item"))
    if pre_cntrl.current_main_item == nil then pre_cntrl.current_main_item = 1 end
  else pre_cntrl.current_main_item = 1 end
  
  if reaper.HasExtState(script_name, "stop") then
    if reaper.GetExtState(script_name, "stop") == "false" then pre_cntrl.stop = false end
    if reaper.GetExtState(script_name, "stop") == "true" then
      pre_cntrl.stop = true 
      pre_cntrl.new_combo_preview_value = user_palette[pre_cntrl.current_item]..' (modified)'
    end
  else pre_cntrl.stop = false end
  
  if reaper.HasExtState(script_name, "stop2") then
    if reaper.GetExtState(script_name, "stop2") == "false" then stop2 = false end
    if reaper.GetExtState(script_name, "stop2") == "true" then 
      pre_cntrl.stop2 = true 
      pre_cntrl.main_combo_preview_value = user_mainpalette[pre_cntrl.current_main_item]..' (modified)'
    end
  else pre_cntrl.stop2 = false end
  
  if reaper.HasExtState(script_name, "background_color_mode") then
    if reaper.GetExtState(script_name, "background_color_mode") == "false" then set_cntrl.background_color_mode = false end
    if reaper.GetExtState(script_name, "background_color_mode") == "true" then set_cntrl.background_color_mode = true end
  else set_cntrl.background_color_mode = false end
  


  -- IMGUI CONTEXT --
  
  local ctx = ImGui.CreateContext(script_name) 
  local sans_serif = ImGui.CreateFont('sans-serif', 15)
  local buttons_font, font_size 
  local want_font_size = 15 
  ImGui.Attach(ctx, sans_serif)
  local openSettingWnd = false
  
  
  
  -- GET RULER WINDOW --
  
  local main = reaper.GetMainHwnd()
  local ruler_win = reaper.JS_Window_FindChildByID(main, 0x3ED)
  local arrange = reaper.JS_Window_FindChildByID(main, 0x3E8)
  local TCPDisplay = reaper.JS_Window_FindEx(main, main, "REAPERTCPDisplay", "" )
  local seen_msgs = {}
  local msgs = 'WM_LBUTTONDOWN'
  
  reaper.JS_WindowMessage_Intercept(ruler_win, msgs, true)
  reaper.JS_WindowMessage_Intercept(arrange, msgs, true)
  reaper.JS_WindowMessage_Intercept(TCPDisplay, msgs, true)


  
  -- CUMSTOM PALETTES FOR GENERATOR --
  
  local function custom_palette_analogous()
  
    for m, d in ipairs(main_palette)do
      if custom_palette[1] == d then
        generated_color = d
        custom_palette = {}
        custom_palette[1] = d
        custom_palette[2] = Generate_color(m, 1) 
        custom_palette[3] = Generate_color(m, 2)
        custom_palette[4] = Generate_color(m, 22) 
        custom_palette[5] = Generate_color(m, 23)
        custom_palette[6] = Generate_color(m-24, 0)        
        custom_palette[7] = Generate_color(m-24, 1)        
        custom_palette[8] = Generate_color(m-24, 2)        
        custom_palette[9] = Generate_color(m-24, 22)
        custom_palette[10] = Generate_color(m+24, 23)
        custom_palette[11] = Generate_color(m+24, 0)
        custom_palette[12] = Generate_color(m+24, 1)
        custom_palette[13] = Generate_color(m+24, 2)   
        custom_palette[14] = Generate_color(m+24, 22)
        custom_palette[15] = Generate_color(m+24, 23)
        custom_palette[16] = Generate_color(m-48, 0)
        custom_palette[17] = Generate_color(m-48, 1)
        custom_palette[18] = Generate_color(m-48, 2) 
        custom_palette[19] = Generate_color(m-48, 22)
        custom_palette[20] = Generate_color(m-48, 23)
        custom_palette[21] = Generate_color(m+48, 0)
        custom_palette[22] = Generate_color(m+48, 1) 
        custom_palette[23] = Generate_color(m+48, 2) 
        custom_palette[24] = Generate_color(m+48, 22) 
      end
    end
    if not generated_color then 
      reaper.ShowMessageBox("Drag a color from the MAIN Palette to the first CUSTOM Palette color box.", "Important info", 0 )
    else
      generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
      cust_tbl = nil
      return custom_palette
    end
  end
  
  
  
  local function custom_palette_triadic()
  
    for m, d in ipairs(main_palette)do
      if custom_palette[1] == d then
        generated_color = d
        custom_palette = {}
        custom_palette[1] = d
        custom_palette[2] = Generate_gradient_color(m, 0, m-24, 8, 75)
        custom_palette[3] = Generate_gradient_color(m-24, 0, m-48, 8, 25) 
        custom_palette[4] = Generate_color(m, 8) 
        custom_palette[5] = Generate_color(m, 16)
        custom_palette[6] = Generate_gradient_color(m-48, 16, m-24, 0, 75)
        custom_palette[7] = Generate_gradient_color(m-48, 16, m+24, 0, 25)
        custom_palette[8] = Generate_color(m-24, 0)
        custom_palette[9] = Generate_gradient_color(m+24, 0, m-48, 8, 75)
        custom_palette[10] = Generate_gradient_color(m-24, 0, m-24, 8, 25) 
        custom_palette[11] = Generate_color(m+24, 8)
        custom_palette[12] = Generate_color(m-24, 16) 
        custom_palette[13] = Generate_gradient_color(m+24, 16, m+24, 0, 75) 
        custom_palette[14] = Generate_gradient_color(m-24, 16, m-24, 0, 25)
        custom_palette[15] = Generate_color(m+24, 0)
        custom_palette[16] = Generate_gradient_color(m-24, 0, m, 8, 75)
        custom_palette[17] = Generate_gradient_color(m-24, 0, m-24, 8, 25) 
        custom_palette[18] = Generate_color(m-24, 8)
        custom_palette[19] = Generate_color(m+24, 16) 
        custom_palette[20] = Generate_gradient_color(m-24, 16, m-24, 0, 75)
        custom_palette[21] = Generate_gradient_color(m, 16, m, 0, 25)
        custom_palette[22] = Generate_color(m-48, 0) 
        custom_palette[23] = Generate_gradient_color(m, 0, m+24, 8, 75) 
        custom_palette[24] = Generate_gradient_color(m, 0, m, 8, 25) 
      end
    end
    if not generated_color then 
      reaper.ShowMessageBox("Drag a color from the MAIN Palette to the first CUSTOM Palette color box.", "Important info", 0 )
    else
      generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
      cust_tbl = nil
      return custom_palette
    end
  end
  
  
  
  local function custom_palette_complementary()
  
    for m, d in ipairs(main_palette)do
      if custom_palette[1] == d then
        generated_color = d
        custom_palette = {}
        custom_palette[1] = d
        custom_palette[2] = Generate_gradient_color(m-24, 0, m-48, 12, 75)
        custom_palette[3] = Generate_gradient_color(m+24, 0, m+24, 12, 25)
        custom_palette[4] = Generate_color(m-24, 12)  
        custom_palette[5] = Generate_gradient_color(m-48, 0, m-48, 12, 50) 
        custom_palette[6] = Generate_color(m-24, 0)  
        custom_palette[7] = Generate_gradient_color(m, 0, m-48, 12, 75)
        custom_palette[8] = Generate_gradient_color(m-24, 0, m-48, 12, 25)
        custom_palette[9] = Generate_color(m+24, 12)
        custom_palette[10] = Generate_gradient_color(m+48, 0, m, 12, 50)
        custom_palette[11] = Generate_color(m+24, 0) 
        custom_palette[12] = Generate_gradient_color(m-48, 0, m+24, 12, 75) 
        custom_palette[13] = Generate_gradient_color(m, 0, m-48, 12, 25) 
        custom_palette[14] = Generate_color(m+48, 12) 
        custom_palette[15] = Generate_gradient_color(m-24, 0, m-48, 12, 50)
        custom_palette[16] = Generate_color(m+48, 0) 
        custom_palette[17] = Generate_gradient_color(m-24, 0, m-24, 12, 75)
        custom_palette[18] = Generate_gradient_color(m+24, 0, m, 12, 25)
        custom_palette[19] = Generate_color(m-48, 12)  
        custom_palette[20] = Generate_gradient_color(m, 0, m-24, 12, 50) 
        custom_palette[21] = Generate_color(m-48, 0) 
        custom_palette[22] = Generate_gradient_color(m+48, 0, m-48, 12, 75)
        custom_palette[23] = Generate_gradient_color(m-48, 0, m+24, 12, 25)
        custom_palette[24] = Generate_color(m, 12)
      end
    end
    if not generated_color then 
      reaper.ShowMessageBox("Drag a color from the MAIN Palette to the first CUSTOM Palette color box.", "Important info", 0 )
    else
      generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
      cust_tbl = nil
      return custom_palette
    end
  end
  
  
  
  local function custom_palette_split_complementary()
  
    for m, d in ipairs(main_palette)do
      if custom_palette[1] == d then
        generated_color = d
        custom_palette = {}
        custom_palette[1] = d
        custom_palette[2] = Generate_gradient_color(m, 0, m-24, 10, 75)
        custom_palette[3] = Generate_gradient_color(m-24, 0, m-48, 10, 25) 
        custom_palette[4] = Generate_color(m, 10) 
        custom_palette[5] = Generate_color(m, 14)
        custom_palette[6] = Generate_gradient_color(m-48, 14, m-24, 0, 75)
        custom_palette[7] = Generate_gradient_color(m-48, 14, m+24, 0, 25)
        custom_palette[8] = Generate_color(m-24, 0)
        custom_palette[9] = Generate_gradient_color(m+24, 0, m-48, 10, 75)
        custom_palette[10] = Generate_gradient_color(m-24, 0, m-24, 10, 25) 
        custom_palette[11] = Generate_color(m+24, 10)
        custom_palette[12] = Generate_color(m-24, 14) 
        custom_palette[13] = Generate_gradient_color(m+24, 14, m+24, 0, 75) 
        custom_palette[14] = Generate_gradient_color(m-24, 14, m-24, 0, 25)
        custom_palette[15] = Generate_color(m+24, 0)
        custom_palette[16] = Generate_gradient_color(m-24, 0, m, 10, 75)
        custom_palette[17] = Generate_gradient_color(m-24, 0, m-24, 10, 25) 
        custom_palette[18] = Generate_color(m-24, 10)
        custom_palette[19] = Generate_color(m+24, 14) 
        custom_palette[20] = Generate_gradient_color(m-24, 14, m-24, 0, 75)
        custom_palette[21] = Generate_gradient_color(m, 14, m, 0, 25)
        custom_palette[22] = Generate_color(m-48, 0) 
        custom_palette[23] = Generate_gradient_color(m, 0, m+24, 10, 75) 
        custom_palette[24] = Generate_gradient_color(m, 0, m, 10, 25) 
      end
    end
    if not generated_color then 
      reaper.ShowMessageBox("Drag a color from the MAIN Palette to the first CUSTOM Palette color box.", "Important info", 0 )
    else
      generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_pal = nil, pre_cntrl.current_item, 1, nil, auto_pal
      cust_tbl = nil
      return custom_palette
    end
  end
  
  
  
  local function custom_palette_double_split_complementary()
  
    for m, d in ipairs(main_palette)do
      if custom_palette[1] == d then
        generated_color = d
        custom_palette = {}
        custom_palette[1] = d
        custom_palette[2] = Generate_color(m, 22)
        custom_palette[3] = Generate_gradient_color(m, 22, m, 14, 50) 
        custom_palette[4] = Generate_color(m, 14)
        custom_palette[5] = Generate_color(m, 10) 
        custom_palette[6] = Generate_gradient_color(m, 10, m, 2, 50)
        custom_palette[7] = Generate_color(m, 2) 
        custom_palette[8] = Generate_color(m-24, 0)
        custom_palette[9] = Generate_color(m-24, 22)
        custom_palette[10] = Generate_gradient_color(m, -2, m-24, 14, 50)
        custom_palette[11] = Generate_color(m-24, 14)
        custom_palette[12] = Generate_color(m-24, 10) 
        custom_palette[13] = Generate_gradient_color(m-24, 10, m-24, 2, 50)
        custom_palette[14] = Generate_color(m-24, 2)
        custom_palette[15] = Generate_color(m+48, 0) 
        custom_palette[16] = Generate_color(m+24, 22)
        custom_palette[17] = Generate_gradient_color(m+24, 22, m+24, 14, 50)
        custom_palette[18] = Generate_color(m+24, 14)
        custom_palette[19] = Generate_color(m+24, 10)
        custom_palette[20] = Generate_gradient_color(m+24, 10, m+24, 2, 50)
        custom_palette[21] = Generate_color(m+24, 2)
        custom_palette[22] = Generate_color(m+24, 0)
        custom_palette[23] = Generate_color(m-48, 22)
        custom_palette[24] = Generate_gradient_color(m-48, 22, m, 14, 50)
      end
    end
    if not generated_color then 
      reaper.ShowMessageBox("Drag a color from the MAIN Palette to the first CUSTOM Palette color box.", "Important info", 0 )
    else
      generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
      cust_tbl = nil
      return custom_palette
    end
  end
  
 
  
  -- GENERATE GRADIENT COLOR -- 
  
  function Generate_gradient_color(m, x, m2, y, percent)
    
    if m <= 0 then m = m+96 elseif m > 120 then m = m-96 else m = m end             
    local num = ((m-1)//24)*24+((m+x-1)%24)+1                                             
    if m2 <= 0 then m2 = m2+96 elseif m2 > 120 then m2 = m2-96 else m = m end      
    local num2 = ((m2-1)//24)*24+((m2+y-1)%24)+1                                          
    local first_color = main_palette[num]
    local second_color = main_palette[num2]
    local r1, g1, b1, a1 = ImGui.ColorConvertU32ToDouble4(first_color)
    local r2, g2, b2, a2 = ImGui.ColorConvertU32ToDouble4(second_color)
    local compliment_percent = 100-percent
    local perc_r = (r1/100*percent)+(r2/100*compliment_percent)
    local perc_g = (g1/100*percent)+(g2/100*compliment_percent)
    local perc_b = (b1/100*percent)+(b2/100*compliment_percent)
    local new_color = ImGui.ColorConvertDouble4ToU32(perc_r, perc_g, perc_b, 1.0)
    return new_color
  end
  
  
  
  -- GENERATE COLOR -- 
  
  function Generate_color(m, x)
    
    if m <= 0 then m = m+96 elseif m > 120 then m = m-96 else m = m end         
    local num3 = ((m-1)//24)*24+((m+x-1)%24)+1                                        
    local main_color = main_palette[num3]
    return main_color
  end

  
  
  -- HIGHLIGHTING ITEMS OR TRACK COLORS -- 
  
  local function get_sel_items_or_tracks_colors(sel_items, sel_tracks, test_item, test_take, test_track)
    
    if items_mode == 3 and sel_markers and check_mark == true then
      
      sel_color = {}
      palette_high = {main = {}, cust = {}}
      for j = 1, #sel_markers.retval do
        local markercolor = IntToRgba(rv_markers.color[sel_markers.retval[j]])
        sel_color[j] = markercolor
        for i = 1, #main_palette do
          if markercolor == main_palette[i] then
            palette_high.main[i] = 1 
            break
          end
        end
        for i = 1, #custom_palette do
          if markercolor == custom_palette[i] then
            palette_high.cust[i] = 1 
            break
          end
        end
      end
      check_mark = false
      
    elseif sel_items > 0 and (test_take2 ~= test_take or sel_items ~= it_cnt_sw or test_item_sw ~= test_item) 
      and (static_mode == 0 or static_mode == 2) then
      palette_high = {main = {}, cust = {}}
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
              palette_high.main[i] = 1
              break
            end
          end
          for i = 1, #custom_palette do
            if itemcolor == custom_palette[i] then
              palette_high.cust[i] = 1 
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
      palette_high = {main = {}, cust = {}}
      sel_color = {}
      for i=0, sel_tracks -1 do
        test_track_sw, sel_tracks2 = test_track, sel_tracks
        local track = GetSelectedTrack(0,i)
        sel_tbl.tr[i+1] = track
        local trackcolor = IntToRgba(GetTrackColor(track)) 
        sel_color[i+1] = trackcolor
        for i =1, #main_palette do
          if trackcolor == main_palette[i] then
            palette_high.main[i] = 1
          end
        end
        for i =1, #custom_palette do
          if trackcolor == custom_palette[i] then
            palette_high.cust[i] = 1
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
  
  local function reselect_take(init_state)
  
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



  -- COLOR SELECTED ITEMS TO TRACK COLOR --

  local function Reset_to_default_color(sel_items, sel_tracks) 
  
    Undo_BeginBlock2(0) 
    PreventUIRefresh(1) 
    if items_mode == 1 then
      local track_ip
      for i=0, sel_items -1 do
        if sel_tbl.tke[i+1] then
          SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", 0)
        end
        if selected_mode == 1 then
          if sel_tbl.it_tr[i+1] ~= sel_tbl.it_tr[i] then
            track_ip = GetMediaTrackInfo_Value(sel_tbl.it_tr[i+1], "IP_TRACKNUMBER")
          end
          SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", col_tbl.it[track_ip])
        else
          SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", 0)
        end
      end
      sel_tracks2, it_cnt_sw = nil, nil
    else 
      if selected_mode == 1 then
        for i=0, sel_tracks -1 do
          track = GetSelectedTrack(0, i)
          SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", 0)
          trackcolor = GetTrackColor(track)
          Color_items_to_track_color_in_shiny_mode(track, trackcolor)
        end
      else
        Main_OnCommandEx(40359, 0, 0)
      end
      sel_tracks2 = nil
      col_tbl = nil
    end
    PreventUIRefresh(-1)
    UpdateArrange()
    Undo_EndBlock2(0, "CHROMA: Set selected to default color", 1+4)
  end
  

  
  -- COLORING FOR MAIN AND CUSTOM PALETTE WIDGETS --
  
  local function coloring(sel_items, sel_tracks, tbl_tr, tbl_it, clr_key) 
    
    PreventUIRefresh(1) 
    if items_mode == 1 then
      if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) 
            and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
        for j = 0, #sel_tbl.tr -1 do
          SetMediaTrackInfo_Value(sel_tbl.tr[j+1],"I_CUSTOMCOLOR", tbl_tr[clr_key])
          if selected_mode == 1 then
            Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[j+1], tbl_it[clr_key])
          end
        end
        for i = 0, sel_items - 1 do
          if selected_mode == 1 then
            SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", tbl_it[clr_key])
            if sel_tbl.tke[i+1] then 
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", 0)
            end
          else
            if sel_tbl.tke[i+1] then 
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", 0) 
            else
              SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", 0)
            end
          end
        end  
        col_tbl = nil          
      else 
        for i = 0, sel_items - 1 do
          if selected_mode == 1 then 
            SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", tbl_it[clr_key])
            if sel_tbl.tke[i+1] then 
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", tbl_tr[clr_key])
            end
          else
            if sel_tbl.tke[i+1] then 
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", tbl_tr[clr_key]) 
            else
              SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", tbl_tr[clr_key])
            end
          end
        end
      end

    elseif items_mode == 0 then
      if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) 
          and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
        for i = 0, sel_tracks -1 do
          SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", tbl_tr[clr_key])
          local cnt_items = CountTrackMediaItems(sel_tbl.tr[i+1])
          if cnt_items > 0 then
            for j = 0, cnt_items -1 do
              local new_item = GetTrackMediaItem(sel_tbl.tr[i+1], j)
              local new_take = GetActiveTake(new_item)
              if new_take then 
                SetMediaItemTakeInfo_Value(new_take,"I_CUSTOMCOLOR", 0) 
              end 
              if selected_mode == 1 then
                SetMediaItemInfo_Value(new_item,"I_CUSTOMCOLOR", tbl_it[clr_key])
              else
                SetMediaItemInfo_Value(new_item,"I_CUSTOMCOLOR", 0)
              end
            end
          end
        end
      else
        for i = 0, sel_tracks -1 do
          SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", tbl_tr[clr_key])
          if selected_mode == 1 then
            Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i+1], tbl_it[clr_key]) 
          end
        end
      end

    elseif items_mode == 3 then
      if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) 
          and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
        local start, fin = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
        if sel_mk == 1 then
          for i = 0, #rv_markers.pos -1 do
            if rv_markers.pos[i] >= start and rv_markers.pos[i] <= fin and rv_markers.isrgn[i] == false then
              reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], tbl_tr[clr_key], 0)
              rv_markers.color[i] = tbl_tr[clr_key]
            end
          end
        
        elseif sel_mk == 2 then
          for i = 0, #rv_markers.pos -1 do
            if rv_markers.pos[i] >= start and rv_markers.pos[i] <= fin and rv_markers.isrgn[i] == true then
              reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], tbl_tr[clr_key], 0)
              rv_markers.color[i] = tbl_tr[clr_key]
            end
          end
        end

      elseif ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) 
          and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
        local start, fin = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
        for i = 0, #rv_markers.pos -1 do
          if rv_markers.pos[i] >= start and rv_markers.pos[i] <= fin then
            reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], tbl_tr[clr_key], 0)
            rv_markers.color[i] = tbl_tr[clr_key]
          end
        end
        
      elseif sel_markers then
        for i = 1, #sel_markers.retval do
          reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[sel_markers.retval[i]], rv_markers.isrgn[sel_markers.retval[i]], rv_markers.pos[sel_markers.retval[i]], rv_markers.rgnend[sel_markers.retval[i]], rv_markers.name[sel_markers.retval[i]], tbl_tr[clr_key], 0)
          rv_markers.color[sel_markers.retval[i]] = tbl_tr[clr_key]
        end
      end
      check_mark = true
    end
    UpdateArrange()
    PreventUIRefresh(-1)
  end
  

  
  -- COLORING FOR CUSTOM COLOR AND LAST TOUCHED -- 
  
  local function coloring_cust_col(sel_items, sel_tracks, in_color) 
  
    PreventUIRefresh(1) 
    if in_color then
      local color = ImGui.ColorConvertNative(in_color >>8)|0x1000000
      local background_color = Background_color_rgba(in_color)
      
      if items_mode == 1 then
        if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) 
            and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
          for j = 0, #sel_tbl.tr -1 do
            SetMediaTrackInfo_Value(sel_tbl.tr[j+1],"I_CUSTOMCOLOR", color)
            if selected_mode == 1 then
              Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[j+1], background_color)
            end
          end
          for i = 0, sel_items -1 do
            if selected_mode == 1 then
              SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", background_color)
              if sel_tbl.tke[i+1] then 
                SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", 0)
              end
            else
              if sel_tbl.tke[i+1] then 
                SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", 0)
              else
                SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", 0)
              end
            end
          end
          col_tbl = nil  
        else
          for i = 0, sel_items -1 do
            if selected_mode == 1 then
              SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", background_color)
              if sel_tbl.tke[i+1] then 
                SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", color)
              end
            else
              if sel_tbl.tke[i+1] then 
                SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", color)
              else
                SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", color)
              end
            end
          end
        end
          
      elseif items_mode == 0 then
        if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl)
            and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
          for i = 0, sel_tracks -1 do
            SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", color)
            local cnt_items = CountTrackMediaItems(sel_tbl.tr[i+1])
            if cnt_items > 0 then
              for j = 0, cnt_items -1 do
                local new_item =  GetTrackMediaItem(sel_tbl.tr[i+1], j)
                local new_take = GetActiveTake(new_item)
                if new_take then 
                  SetMediaItemTakeInfo_Value(new_take,"I_CUSTOMCOLOR", 0) 
                end              
                if selected_mode == 1 then
                  SetMediaItemInfo_Value(new_item,"I_CUSTOMCOLOR", background_color)
                else
                  SetMediaItemInfo_Value(new_item,"I_CUSTOMCOLOR", 0)
                end
              end
            end
          end
        else
          for i = 0, sel_tracks -1 do
            local track = GetSelectedTrack(0,i)
            SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", color)
            if selected_mode == 1 then
              Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i+1], background_color) 
            end
          end
        end
        
      elseif items_mode == 3 then
        if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) 
            and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
          local start, fin = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
          if sel_mk == 1 then
            for i = 0, #rv_markers.pos -1 do
              if rv_markers.pos[i] >= start and rv_markers.pos[i] <= fin and rv_markers.isrgn[i] == false then
                reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], color, 0)
                rv_markers.color[i] = color
                --sel_marker = i
              end
            end
          elseif sel_mk == 2 then
            for i = 0, #rv_markers.pos -1 do
              if rv_markers.pos[i] >= start and rv_markers.pos[i] <= fin and rv_markers.isrgn[i] == true then
                reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], color, 0)
                rv_markers.color[i] = color
              end
            end
          end

        elseif ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) 
            and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
          local start, fin = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
          for i = 0, #rv_markers.pos -1 do
            if rv_markers.pos[i] >= start and rv_markers.pos[i] <= fin then
              reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], color, 0)
              rv_markers.color[i] = color
            end
          end

        elseif sel_markers then
          for i = 1, #sel_markers.retval do
            reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[sel_markers.retval[i]], rv_markers.isrgn[sel_markers.retval[i]], rv_markers.pos[sel_markers.retval[i]], rv_markers.rgnend[sel_markers.retval[i]], rv_markers.name[sel_markers.retval[i]], color, 0)
            rv_markers.color[sel_markers.retval[i]] = color
          end
        end
        check_mark = true
      end
    end
    UpdateArrange()
    PreventUIRefresh(-1)
  end
  


  local function Color_selected_tracks_with_gradient(sel_tracks, test_track, first_color, last_color) 
    
    if sel_tracks > 1 then 
      if first_color == 255 and last_color == 255 then
        first_color = main_palette[1] 
        last_color = main_palette[16] 
        SetTrackColor(sel_tbl.tr[1], pal_tbl.tr[1]) 
      elseif first_color == 255 then 
        local r, g, b, a = ImGui.ColorConvertU32ToDouble4(last_color) 
        local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b) 
        if h+0.667 > 1 then h2 = h+0.667-1 else h2= h+0.667 end 
        first_color = HSV(h2, s, v, a) 
      elseif last_color == 255 or first_color ~= 255 and last_color == first_color then 
        local r, g, b, a = ImGui.ColorConvertU32ToDouble4(first_color) 
        local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b) 
        if h+0.667 > 1 then h2 = h+0.667-1 else h2= h+0.667 end 
        last_color = HSV(h2, s, v, a) 
      end 
      PreventUIRefresh(1)  
      Undo_BeginBlock2(0) 
      local r2, g2, b2, _ = ImGui.ColorConvertU32ToDouble4(last_color) 
      local firstcolor_r, firstcolor_g, firstcolor_b, _ = ImGui.ColorConvertU32ToDouble4(first_color) 
      local r_step = (r2*255-firstcolor_r*255)/(sel_tracks-1) 
      local g_step = (g2*255-firstcolor_g*255)/(sel_tracks-1) 
      local b_step = (b2*255-firstcolor_b*255)/(sel_tracks-1)
      
      for i=1,sel_tracks-1 do 
        local value_r, value_g, value_b = (0.5+firstcolor_r*255+r_step*i)//1, (0.5+firstcolor_g*255+g_step*i)//1, (0.5+firstcolor_b*255+b_step*i)//1 
        SetTrackColor(sel_tbl.tr[i+1], ColorToNative(value_r, value_g, value_b)) 
        if selected_mode == 1 then 
          Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i+1], Background_color_R_G_B(value_r, value_g, value_b)) 
        end 
      end
      Undo_EndBlock2(0, "CHROMA: Color selected tracks with gradient colors", 1) 
      PreventUIRefresh(-1)  
    else 
      reaper.MB( "Select at least 3 tracks", "Can't create gradient colors", 0 ) 
    end 
  end


  
  local function Color_selected_items_with_gradient(sel_items, test_item, first_color, last_color)
  
    if sel_items > 1 then 
      if first_color == 255 and last_color == 255 then
        first_color = main_palette[1] 
        last_color = main_palette[16] 
        SetTrackColor(sel_tbl.tr[1], pal_tbl.tr[1]) 
      elseif first_color == 255 then 
        local r, g, b, a = ImGui.ColorConvertU32ToDouble4(last_color) 
        local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b) 
        if h+0.667 > 1 then h2 = h+0.667-1 else h2= h+0.667 end 
        first_color = HSV(h2, s, v, a) 
      elseif last_color == 255 or first_color ~= 255 and last_color == first_color then 
        local r, g, b, a = ImGui.ColorConvertU32ToDouble4(first_color) 
        local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b) 
        if h+0.667 > 1 then h2 = h+0.667-1 else h2= h+0.667 end 
        last_color = HSV(h2, s, v, a) 
      end
      Undo_BeginBlock2(0)
      PreventUIRefresh(1) 
      if first_color == last_color then
        reaper.MB("Last selected item color should be different than first.", "", 0 )
        return
      end
      local r2, g2, b2, _ = ImGui.ColorConvertU32ToDouble4(last_color)
      local firstcolor_r, firstcolor_g, firstcolor_b, _ = ImGui.ColorConvertU32ToDouble4(first_color)
      local r_step = (r2*255-firstcolor_r*255)/(sel_items-1)
      local g_step = (g2*255-firstcolor_g*255)/(sel_items-1)
      local b_step = (b2*255-firstcolor_b*255)/(sel_items-1)
        
      for i=1,sel_items-1 do
        local value_r, value_g, value_b = (0.5+firstcolor_r*255+r_step*i)//1, (0.5+firstcolor_g*255+g_step*i)//1, (0.5+firstcolor_b*255+b_step*i)//1
        if selected_mode == 1 then
          SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", Background_color_R_G_B(value_r, value_g, value_b))
          if sel_tbl.tke[i+1] then
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", ColorToNative(value_r, value_g, value_b)|0x1000000)
          end
        else
          if sel_tbl.tke[i+1] then
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", ColorToNative(value_r, value_g, value_b)|0x1000000)
          else
            SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", ColorToNative(value_r, value_g, value_b)|0x1000000)
          end    
        end
      end
      UpdateArrange()
      Undo_EndBlock2(0, "CHROMA: Color selected items with gradient colors", 4) 
      PreventUIRefresh(-1)
    else
      reaper.MB( "Select at least 3 items", "Can't create gradient colors", 0 )
    end
  end
  
  
 
  -- COLOR CHILDS TO PARENTCOLOR -- Thanks to ChMaha  and BirdBird for this functions
   
  local function color_childs_to_parentcolor(sel_tracks, tr_cnt) 
    
    local function get_child_tracks(folder_track, tr_cnt)
    
      local all_tracks = {}
      if GetMediaTrackInfo_Value(folder_track, "I_FOLDERDEPTH") ~= 1 then
        return all_tracks
      end
      local tracks_count = tr_cnt
      local folder_track_depth = GetTrackDepth(folder_track)  
      local track_index = GetMediaTrackInfo_Value(folder_track, "IP_TRACKNUMBER")
      local tr_index = 0
      for i = track_index, tracks_count - 1 do
        local track = GetTrack(0, i)
        local track_depth = GetTrackDepth(track)
        if track_depth > folder_track_depth then 
          tr_index = tr_index+1
          all_tracks[tr_index] = track
        else
          break
        end
      end
      return all_tracks
    end
  
    PreventUIRefresh(1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    for i=0, sel_tracks -1 do
      local track = GetSelectedTrack(0,i)
      local trackcolor = GetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR")
      local ip = GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
      local child_tracks = get_child_tracks(track, tr_cnt)
      for i = 1, #child_tracks do
        SetTrackColor(child_tracks[i], trackcolor)
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(child_tracks[i], col_tbl.it[ip])
        end
      end
    end
    col_tbl = nil                 
    Undo_EndBlock2(0, "CHROMA: Set children to parent color", 1) 
    PreventUIRefresh(-1) 
  end
  

  
  -- PREPARE BACKGROUND COLOR FOR SHINYCOLORS MODE RGBA (DOUBLE4) --
  
  function Background_color_rgba(color)
    
    local r, g, b, a = ImGui.ColorConvertU32ToDouble4(color)
    local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b)
    local s=s/3.7
    local v=v+((0.92-v)/1.3)
    if v > 0.99 then v = 0.99 end
    local background_color = ImGui.ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end
  
  
  
  -- PREPARE BACKGROUND COLOR FOR SHINYCOLORS MODE INTEGER --
  
  function background_color_native(color)
  
    local r, g, b = ColorFromNative(color)
    local h, s, v = ImGui.ColorConvertRGBtoHSV(r/255, g/255, b/255)
    local s=s/3.7
    local v=v+((0.92-v)/1.3)
    if v > 0.99 then v = 0.99 end
    local background_color = ImGui.ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end 
  
  
  
   -- PREPARE BACKGROUND COLOR FOR SHINYCOLORS MODE R, G, B --
  
  function Background_color_R_G_B(r,g,b)

    local h, s, v = ImGui.ColorConvertRGBtoHSV(r/255, g/255, b/255)
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
  
  
  
  -- COLOR MULTIPLE TRACKS TO PALETTE COLORS--
  
  local function Color_multiple_tracks_to_palette_colors(sel_tracks, first_stay)
    PreventUIRefresh(1) 
    local numbers = shuffled_numbers (120)
    local first_color = sel_color[1]
    local color_state = 0
    local i
    local value
    for p=1, #main_palette do
      if first_color==main_palette[p] then
        color_state = 1
        if first_stay then i = 1 else i = 0 end
        for i=i, sel_tracks -1 do
          if random_main then value = numbers[i%120+1] elseif sel_tracks < 2 then value = (i+p)%120+1 else value = (i+p-1)%120+1 end
          SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", pal_tbl.tr[value])
          if selected_mode == 1 then
            Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i+1], pal_tbl.it[value])
          end
        end
        break
      end
    end
    
    if color_state ~= 1 then
      for i=0, sel_tracks -1 do
        if random_main then value = numbers[i%120+1] else value = i%120+1 end
        SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", pal_tbl.tr[value])
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i+1], pal_tbl.it[value])
        end
      end  
    end
    PreventUIRefresh(-1) 
  end
  
  
  
  local function Color_multiple_items_to_palette_colors(sel_items, first_stay)
    
    PreventUIRefresh(1) 
    local numbers = shuffled_numbers (120)
    local first_color = sel_color[1] -- 
    local color_state = 0
    local i
    local value
    for p=1, #main_palette do
      if first_color==main_palette[p] then
        color_state = 1
        if first_stay then i = 1 else i = 0 end
        for i=i, sel_items -1 do
          if random_main then value = numbers[i%120+1] elseif sel_items < 2 then value = (i+p)%120+1 else value = (i+p-1)%120+1 end
          if selected_mode == 1 then
            if sel_tbl.tke[i+1] then
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", pal_tbl.tr[value])
              SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", pal_tbl.it[value])  
            else
              SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", pal_tbl.it[value])
            end
          else
            if sel_tbl.tke[i+1] then
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", pal_tbl.tr[value])
            else
              SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", pal_tbl.tr[value])
            end
          end
        end
        break 
      end
    end
    
    if color_state ~= 1 then
      for i=0, sel_items -1 do
        if random_main then value = numbers[i%120+1] else value = i%120+1 end
        if selected_mode == 1 then
          if sel_tbl.tke[i+1] then
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", pal_tbl.tr[value])
            SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", pal_tbl.it[value])  
          else
            SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", pal_tbl.it[value])
          end
        else
          if sel_tbl.tke[i+1] then
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", pal_tbl.tr[value])
          else
            SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", pal_tbl.tr[value])
          end
        end
      end  
    end
    UpdateArrange()
    PreventUIRefresh(-1)
  end


    
  -- COLOR MULTIPLE TRACKS TO CUSTOM PALETTE  --
  
  local function Color_multiple_tracks_to_custom_palette(sel_tracks, first_stay)
    
    local numbers = shuffled_numbers (24)
    local first_color = sel_color[1]
    r = nil
    local color_state = 0
    local i
    local value
    PreventUIRefresh(1)
    for r=1, #custom_palette do
      if first_color == custom_palette[r] then
        color_state = 1
        if first_stay then i = 1 else i = 0 end
        for i=i, sel_tracks -1 do
          if random_custom then value = numbers[i%24+1] elseif sel_tracks < 2 then value = (i+r)%24+1 else value = (i+r-1)%24+1 end
          SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", cust_tbl.tr[value])
          if selected_mode == 1 then
            Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i+1], cust_tbl.it[value])
          end
        end
        break
      end
    end
    
    if color_state ~= 1 then
      for i=0, sel_tracks -1 do
        if random_custom then value = numbers[i%24+1] else value = i%24+1 end
        SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", cust_tbl.tr[value])
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i+1], cust_tbl.it[value])
        end
      end  
    end
    PreventUIRefresh(-1) 
  end
  

  
  local function Color_multiple_items_to_custom_palette(sel_items, first_stay)
  
    PreventUIRefresh(1) 

    local numbers = shuffled_numbers (24)
    local first_color = (sel_color[1])
    local color_state = 0
    local i
    local value
    for r=1, #custom_palette do
      if first_color==custom_palette[r] then
        color_state = 1
        if first_stay then i = 1 else i = 0 end
        for i=i, sel_items -1 do
          if random_custom then value = numbers[i%24+1] elseif sel_items < 2 then value = (i+r)%24+1 else value = (i+r-1)%24+1 end
          if selected_mode == 1 then
            if sel_tbl.tke[i+1] then
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", cust_tbl.tr[value])
              SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", cust_tbl.it[value])  
            else
              SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", cust_tbl.it[value])
            end
          else
            if sel_tbl.tke[i+1] then
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", cust_tbl.tr[value])
            else
              SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", cust_tbl.tr[value])
            end
          end
        end
        break
      end
    end
    if color_state ~= 1 then
      for i=0, sel_items -1 do
        if random_custom then value = numbers[i%24+1] else value = i%24+1 end
        if selected_mode == 1 then
          if sel_tbl.tke[i+1] then
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", cust_tbl.tr[value])
            SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", cust_tbl.it[value])  
          else
            SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", cust_tbl.it[value])
          end
        else
          if sel_tbl.tke[i+1] then
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1], "I_CUSTOMCOLOR", cust_tbl.tr[value])
          else
            SetMediaItemInfo_Value(sel_tbl.it[i+1], "I_CUSTOMCOLOR", cust_tbl.tr[value])
          end
        end
      end  
    end
    UpdateArrange()
    PreventUIRefresh(-1)
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

  
  
  -- BUTTON TEMPLATE 1 --
  
  local function button_color(h, s, v, a, name, size_w, size_h, small, round)
  
    local n = 0
    local state
    ImGui.PushStyleColor(ctx, ImGui.Col_Button, HSV(h, 0, 0.3, a/3)) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, HSV(h, s, v, a/2)) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive, HSV(h, s, v, a)) n=n+1
    if not small then state = ImGui.Button(ctx, name, size_w, size_h)
    else state = ImGui.SmallButton(ctx, name) end
    ImGui.PopStyleColor(ctx, n)
  
    local draw_list = ImGui.GetWindowDrawList(ctx)
    local text_min_x, text_min_y = reaper.ImGui_GetItemRectMin(ctx)
    local text_max_x, text_max_y = reaper.ImGui_GetItemRectMax(ctx)
    if not ImGui.IsItemHovered(ctx) then
      reaper.ImGui_DrawList_AddRect(draw_list, text_min_x, text_min_y, text_max_x, text_max_y, HSV(h, s, v, a), round)
    elseif ImGui.IsItemHovered(ctx) then
      reaper.ImGui_DrawList_AddRect(draw_list, text_min_x, text_min_y, text_max_x, text_max_y, HSV(h, s, v, a), round)
    elseif reaper.ImGui_IsItemActive(ctx) then
      reaper.ImGui_DrawList_AddRect(draw_list, text_min_x, text_min_y, text_max_x, text_max_y, HSV(h, s, v, a), round)      
    end
    return state
  end
  
  

  -- BUTTON TEMPLATE 2 --

  local function button_action(h, s, v, a, name, size_w, size_h, border, b_thickness, b_h, b_s, b_v, b_a, rounding) -- b_= border
    
    local n = 0
    local m = 0
    local state
    local bs_h 
    local bs_v
    if b_h < 0.5 then bs_h = b_h + 0.5 else bs_h = b_h - 0.5 end
    if b_v > 0.5 then bs_v = 0.4 else bs_v = b_v end
    
    ImGui.PushStyleColor(ctx, ImGui.Col_Button, HSV(h, s, v-0.2, a)) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, HSV(h, s, v, a)) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive, HSV(h, s, v+0.2, a)) n=n+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding,rounding) m=m+1
    if border == true then 
      ImGui.PushStyleColor(ctx, ImGui.Col_Border, HSV(b_h, b_s, b_v, b_a))n=n+1
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize, b_thickness) m=m+1 
      ImGui.PushStyleColor(ctx, ImGui.Col_BorderShadow, HSV(bs_h, b_s, bs_v-0.25, b_a))n=n+1
    end
    state = ImGui.Button(ctx, name, size_w, size_h)
    ImGui.PopStyleColor(ctx, n)
    ImGui.PopStyleVar(ctx, m)
    return state
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
  
  
  
  function getProjectTabIndex()

    local i, project = 0, EnumProjects(-1, '')
    while true do
      if EnumProjects(i, '') == project then
        return i
      else
       i = i + 1
      end
    end
  end
  
  

  local function shortcut_gradient(sel_tracks, test_track, color_input) 
    
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Left) and not check_one then
        
      if not stop_gradient and sel_tracks > 0 then
        first_color = color_input
        sel_tab = {tr = {}}
        for i = 1, sel_tracks do
          sel_tab.tr[i] = sel_tbl.tr[i]
        end
        reaper.SetOnlyTrackSelected(sel_tab.tr[1])
        stop_gradient = true
      elseif stop_coloring and not check_one then
        reaper.SetOnlyTrackSelected(sel_tab.tr[#sel_tab.tr])
        check_one = true
        last_color = color_input
      end
      if not stop_coloring then
        stop_coloring = true
      end
    elseif check_two then
      test_track = sel_tab.tr[1]
      PreventUIRefresh(1) 
      for i = 1, #sel_tab.tr  do
        SetTrackSelected(sel_tab.tr[i], true)
        sel_tbl.tr[i] = sel_tab.tr[i]
      end
      PreventUIRefresh(-1) 
      Color_selected_tracks_with_gradient(#sel_tab.tr, test_track, first_color, last_color) 
      sel_tab, stop_gradient, stop_coloring, check_one, check_two, col_tbl = nil 
    end
  end



  local function shortcut_gradient_items(sel_items, color_input) 
  
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Left) and not check_one then

      if not stop_gradient and sel_items > 0 then
        first_color = color_input
        sel_tab = {it = {}, tke = {}} 

        PreventUIRefresh(1) 
        for i = 1, sel_items  do
          sel_tab.it[i] = sel_tbl.it[i]
          sel_tab.tke[i] = sel_tbl.tke[i]
          if i > 1 then SetMediaItemSelected(sel_tbl.it[i], false) end
        end
        PreventUIRefresh(-1) 
        last_color = color_input
        stop_gradient = true
      elseif stop_coloring and not check_one then
        local time1 = reaper.time_precise()
        PreventUIRefresh(1) 
        SetMediaItemSelected(sel_tab.it[1], false)
        SetMediaItemSelected(sel_tab.it[#sel_tab.it], true)
        PreventUIRefresh(-1) 
        check_one = true
        last_color = color_input
      end
      if not stop_coloring then
        stop_coloring = true
      end
      
    elseif check_two then
      test_item = sel_tab.it[1]
      PreventUIRefresh(1) 
      for i = 1, #sel_tab.it  do
        SetMediaItemSelected(sel_tab.it[i], true) 
        sel_tbl.it[i] = sel_tab.it[i]
        sel_tbl.tke[i] = sel_tab.tke[i] 
      end
      PreventUIRefresh(-1) 
      Color_selected_items_with_gradient(#sel_tab.it, test_item, first_color, last_color)
      sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil 
    end
  end

  
  
  function item_track_color_to_custom_palette(m)
  
    local sel_colorcnt
    local calc
    if #sel_color > 24 then sel_colorcnt = 24 else sel_colorcnt = #sel_color end
    for i = 1, sel_colorcnt do
      if (m+i-1)%24 == 0 then calc = 24 else calc = (m+i-1)%24 end
      custom_palette[calc] = sel_color[i]
    end
    cust_tbl = nil
    pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop = pre_cntrl.current_item, 1, nil
  end

  
  
  -- USER CUSTOM PALETTE BUTTON FUNCTIONS --
  
  local function SaveCustomPaletteButton()
  
    local retval, retvals_csv = reaper.GetUserInputs('Set a new preset name', 1, 'Enter name:, extrawidth=300', user_palette[pre_cntrl.current_item]) 
    if retval and retvals_csv ~= '' and retvals_csv ~= '*Last unsaved*' then
      local index = #user_palette+1
      local preset_found
      for i = 1, #user_palette do
        if string.gsub(retvals_csv, '^%s*(.-)%s*$', '%1') == string.gsub(user_palette[i], '^%s*(.-)%s*$', '%1') then
          preset_found = 1 
          restore = reaper.ShowMessageBox('Do you want to overwrite the preset?', 'PRESET ALREADY EXISTS', 1)
          if restore == 1 then
            index = i
            user_palette[index] = retvals_csv
            local serialized = serializeTable(user_palette)
            SetExtState(script_name , 'user_palette', serialized, true )
            SetExtState(script_name , 'userpalette.'..tostring(retvals_csv),  table.concat(custom_palette,","),true)
            pre_cntrl.current_item, pre_cntrl.stop, pre_cntrl.differs = index, false, index
          end
        end
      end
  
      if not preset_found then 
        pre_cntrl.differs2 = nil 
        user_palette[index] = retvals_csv
        local serialized = serializeTable(user_palette)
        SetExtState(script_name , 'user_palette', serialized, true )
        SetExtState(script_name , 'userpalette.'..tostring(retvals_csv),  table.concat(custom_palette,","),true)
        pre_cntrl.current_item = index
      end
      pre_cntrl.stop, pre_cntrl.new_combo_preview_value, pre_cntrl.combo_preview_value = false, nil, nil
    end
  end
  
  
  
  local function DeleteCustomPalettePreset()
  
    if #user_palette > 1 and pre_cntrl.current_item > 1 then
      if pre_cntrl.new_combo_preview_value then
        SetExtState(script_name, 'userpalette.*Last unsaved*', table.concat(custom_palette,","),true)
      end
      reaper.DeleteExtState( script_name, 'userpalette.'..tostring(user_palette[pre_cntrl.current_item]), true )
      table.remove(user_palette, pre_cntrl.current_item)
      local serialized = serializeTable(user_palette)
      SetExtState(script_name , 'user_palette', serialized, true )
      if pre_cntrl.current_item > #user_palette then pre_cntrl.current_item = pre_cntrl.current_item - 1 end
      custom_palette = {} 
      if reaper.HasExtState(script_name, 'userpalette.'..tostring(user_palette[pre_cntrl.current_item])) then
        for i in string.gmatch(reaper.GetExtState(script_name, 'userpalette.'..tostring(user_palette[pre_cntrl.current_item])), "[^,]+") do
          insert(custom_palette, tonumber(string.match(i, "[^,]+")))
        end
      end
      pre_cntrl.new_combo_preview_valuenew_combo_preview_value, pre_cntrl.combo_preview_value, pre_cntrl.differs, pre_cntrl.stop = nil, nil, pre_cntrl.current_item, false
      cust_tbl = nil
    end
  end
  

  
  -- USER MAIN PALETTE BUTTON FUNCTIONS --

  local function generate_user_main_settings()

    user_main_settings = {}
    user_main_settings[1] = colorspace
    user_main_settings[2] = saturation
    user_main_settings[3] = lightness
    user_main_settings[4] = darkness
    return user_main_settings
  end
  
  
  
  local function SaveMainPalettePreset()
      
    local retval_main, retvals_csv_main = reaper.GetUserInputs('Set a new mainpreset name', 1, 'Enter name:, extrawidth=300', user_mainpalette[pre_cntrl.current_main_item]) 
    if retval_main and retvals_csv_main ~= '' and retvals_csv ~= '*Last unsaved*' then
      local index = #user_mainpalette+1
      local preset_found
      for i = 1, #user_mainpalette do
        if string.gsub(retvals_csv_main, '^%s*(.-)%s*$', '%1') == string.gsub(user_mainpalette[i], '^%s*(.-)%s*$', '%1') then
          preset_found = 1 
          restore = reaper.ShowMessageBox('Do you want to overwrite the preset?', 'PRESET ALREADY EXISTS', 1)
          if restore == 1 then
            index = i
            user_mainpalette[index] = retvals_csv_main
            local serialized = serializeTable(user_mainpalette)
            SetExtState(script_name , 'user_mainpalette', serialized, true )
            SetExtState(script_name , 'usermainpalette.'..tostring(retvals_csv_main),  table.concat(user_main_settings,","),true)
            pre_cntrl.current_main_item, pre_cntrl.stop2, pre_cntrl.differs3 = index, false, index
          end
        end
      end
  
      if not preset_found then 
        differs4 = nil 
        user_mainpalette[index] = retvals_csv_main
        local serialized = serializeTable(user_mainpalette)
        SetExtState(script_name , 'user_mainpalette', serialized, true )
        SetExtState(script_name , 'usermainpalette.'..tostring(retvals_csv_main),  table.concat(user_main_settings,","),true)
        pre_cntrl.current_main_item = index
      end
      pre_cntrl.main_new_combo_preview_value, pre_cntrl.main_combo_preview_value, pre_cntrl.stop2 = nil, nil, false
    end
  end
  
  
  
  local function DeleteMainPalettePreset()
  
    if #user_mainpalette > 1 and pre_cntrl.current_main_item > 1 then
      reaper.DeleteExtState( script_name, 'usermainpalette.'..tostring(user_mainpalette[pre_cntrl.current_main_item]), true )
      table.remove(user_mainpalette, pre_cntrl.current_main_item)
      local serialized = serializeTable(user_mainpalette)
      SetExtState(script_name , 'user_mainpalette', serialized, true )
      if pre_cntrl.current_main_item > #user_mainpalette then pre_cntrl.current_main_item = pre_cntrl.current_main_item - 1 end
      user_main_settings = {} 
      if reaper.HasExtState(script_name, 'usermainpalette.'..tostring(user_mainpalette[pre_cntrl.current_main_item])) then
        for i in string.gmatch(reaper.GetExtState(script_name, 'usermainpalette.'..tostring(user_mainpalette[pre_cntrl.current_main_item])), "[^,]+") do
          insert(user_main_settings, tonumber(string.match(i, "[^,]+")))
        end
        colorspace =user_main_settings[1] 
        saturation = user_main_settings[2] 
        lightness = user_main_settings[3] 
        darkness = user_main_settings[4]
      end
      pre_cntrl.differs3, pre_cntrl.stop2, pre_cntrl.main_new_combo_preview_value, pre_cntrl.main_combo_preview_value = pre_cntrl.current_main_item, false, nil, nil
    end
  end
  
  
  
  -- PALETTE MENU WINDOW --
  
  local function PaletteMenu(p_y, p_x, w, h)
  
    local set_x
    local set_h 
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowPadding, 8, 0) 
    ImGui.SetNextWindowSize(ctx, 236, 740, ImGui.Cond_Appearing) 
    local set_y = p_y +30
    if set_y < 0 then
      set_y = p_y + h 
    end
    if  p_x -300 < 0 then set_x = p_x + w +30 else set_x = p_x -300 end
    
    if not set_pos then
      ImGui.SetNextWindowPos(ctx, set_x, set_y, ImGui.Cond_Appearing)
    end
    
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 5)
    visible, openSettingWnd = ImGui.Begin(ctx, 'Palette Menu', true, ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoDocking) 
    if visible then
    
      -- GENERATE CUSTOM PALETTES -- 
      
      local space_btwn = 8
      ImGui.Dummy(ctx, 0, 2)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      button_action(0, 0, 0, 0,'CUSTOM PALETTE:##set', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      ImGui.PopStyleColor(ctx, 1)
      
      ImGui.Dummy(ctx, 0, space_btwn)
      button_action(0, 0, 0, 0,'Generate Custom Palette:', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      
      if button_action(0.555, 0.59, 0.6, 1, 'analogous', 220, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then 
        custom_palette_analogous()
      end
      
      if button_action(0.555, 0.59, 0.6, 1, 'triadic', 220, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then 
        custom_palette_triadic()
      end
      
      if button_action(0.555, 0.59, 0.6, 1, 'complementary', 220, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then 
        custom_palette_complementary()
      end
          
      if button_action(0.555, 0.59, 0.6, 1, 'split complementary', 220, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then 
        custom_palette_split_complementary()
      end
          
      if button_action(0.555, 0.59, 0.6, 1, 'double split complementary', 220, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then 
        custom_palette_double_split_complementary()
      end
      
      ImGui.Dummy(ctx, 0, space_btwn)
      button_action(0, 0, 0, 0,'Custom Presets:', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      
     
      -- SAVING USER CUSTOM PALETTE PRESETS --
      
      -- SAVE BUTTON --
      if button_action(0.555, 0.59, 0.6, 1, 'Save', 90, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
        SaveCustomPaletteButton()
      end
        
      -- DELETE BUTTON --
      ImGui.SameLine(ctx, 0,38)
      if button_action(0.555, 0.59, 0.6, 1, 'Delete', 90, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
        DeleteCustomPalettePreset()
      end
      
      -- USER PALETTE MENU COMBO BOX --
      if not pre_cntrl.stop and not pre_cntrl.combo_preview_value then
        pre_cntrl.combo_preview_value = user_palette[pre_cntrl.current_item]
      elseif not pre_cntrl.combo_preview_value then
        pre_cntrl.combo_preview_value = pre_cntrl.new_combo_preview_value
      end
        
      ImGui.PushItemWidth(ctx, 220)
      local combo = ImGui.BeginCombo(ctx, '##6', pre_cntrl.combo_preview_value, 0) 
      if combo then 
        for i,v in ipairs(user_palette) do
          local is_selected = pre_cntrl.current_item == i
          if ImGui.Selectable(ctx, user_palette[i], is_selected, ImGui.SelectableFlags_None,  300.0,  0.0) then
            pre_cntrl.current_item = i
            if pre_cntrl.new_combo_preview_value and pre_cntrl.current_item ~= 1 then
              SetExtState(script_name, 'userpalette.*Last unsaved*', table.concat(custom_palette,","),true)
            end
            
            custom_palette = {} 
            if reaper.HasExtState(script_name, 'userpalette.'..tostring(user_palette[i])) then
              for i in string.gmatch(reaper.GetExtState(script_name, 'userpalette.'..tostring(user_palette[i])), "[^,]+") do
                insert(custom_palette, tonumber(string.match(i, "[^,]+")))
              end
            end
            pre_cntrl.stop, pre_cntrl.new_combo_preview_value, pre_cntrl.combo_preview_value = false, nil, nil
            cust_tbl = nil
          end
          
          if ImGui.IsItemHovered(ctx) then
            pre_cntrl.hovered_preset = v
          end
          -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
          if is_selected then
            ImGui.SetItemDefaultFocus(ctx)
          end
        end
        ImGui.EndCombo(ctx)
      end
      
      if ImGui.IsWindowHovered(ctx, ImGui.FocusedFlags_ChildWindows) then
        local x, y = reaper.GetMousePosition()
        if ImGui.IsItemHovered(ctx) or combo then
          if combo and pre_cntrl.hovered_preset ~= ' ' and x > 0 then 
            for p, c in utf8.codes(pre_cntrl.hovered_preset) do 
              if c > 255 or string.len(pre_cntrl.hovered_preset) > 30 then 
                reaper.TrackCtl_SetToolTip( pre_cntrl.hovered_preset, x, y+sys_offset, 0 )
                break
              else
                reaper.TrackCtl_SetToolTip( '', 0, 0, 0 )
              end
            end
          elseif x > 0 then
            for p, c in utf8.codes(user_palette[pre_cntrl.current_item]) do 
              if c > 255 or string.len(user_palette[pre_cntrl.current_item]) > 30 then 
                reaper.TrackCtl_SetToolTip( user_palette[pre_cntrl.current_item], x, y+sys_offset, 0 )
                break
              end
            end
          end
        else
          reaper.TrackCtl_SetToolTip( '', 0, 0, 0 )
        end
      end

      if pre_cntrl.differs and not pre_cntrl.stop and pre_cntrl.differs2 == 1 then
        pre_cntrl.new_combo_preview_value = user_palette[pre_cntrl.current_item]..' (modified)'
        pre_cntrl.stop, pre_cntrl.differs2, pre_cntrl.combo_preview_value = true, nil, nil
      end
      
      ImGui.Dummy(ctx, 0, space_btwn)
      _, random_custom = ImGui.Checkbox(ctx, "Random coloring via button##1", random_custom)
      
      if button_color(0.14, 0.9, 0.7, 1, 'Reset Custom Palette', 220, 19, false, 3)  then 
        custom_palette = {}
        cust_tbl = nil
        for m = 0, 23 do
          insert(custom_palette, HSL(m / 24+0.69, 0.1, 0.2, 1))
        end
      end
      
      ImGui.Separator(ctx)
      ImGui.Dummy(ctx, 0, space_btwn)
      
      
      -- MAIN PALETTE SETTINGS --
  
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      button_action(0, 0, 0, 0,'MAIN PALETTE:##set', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      ImGui.PopStyleColor(ctx, 1)
      ImGui.Dummy(ctx, 0, space_btwn)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 2)
      ImGui.AlignTextToFramePadding(ctx)
      ImGui.Text(ctx, 'Color model:')
      ImGui.SameLine(ctx, 0, 10) 
      
      if ImGui.RadioButtonEx(ctx, ' HSL', colorspace, 0) then
        colorspace = 0; lightness =0.7; darkness =0.20;
      end
            
      ImGui.SameLine(ctx, 0, 5) 
            
      if ImGui.RadioButtonEx(ctx, ' HSV', colorspace, 1) then
        colorspace = 1; lightness =1; darkness =0.3
      end
      ImGui.PopStyleVar(ctx, 1)
      local lightness_range
      if colorspace == 1 then lightness_range = 1 else lightness_range = 0.8 end
      
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 0)
      button_action(0, 0, 0, 0,'saturation##set', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      ImGui.PopStyleVar(ctx, 1)
      ImGui.PushItemWidth(ctx, 220)
      sat_true, saturation = ImGui.SliderDouble(ctx, '##1', saturation, 0.3, 1.0, '%.3f', ImGui.SliderFlags_None)
      
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 0)
      button_action(0, 0, 0, 0,'darkness - lightness', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      ImGui.PopStyleVar(ctx, 1)
      contrast_true ,darkness, lightness = ImGui.SliderDouble2(ctx, '##2', darkness, lightness, 0.12, lightness_range)
      

      
      -- USER MAIN PALETTE PRESET --
      
      -- SAVE BUTTON --
      ImGui.Dummy(ctx, 0, space_btwn)
      button_action(0, 0, 0, 0,'Main Presets:', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      
      if button_action(0.555, 0.59, 0.6, 1, 'Save##2', 90, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
        SaveMainPalettePreset()
      end
        
      -- DELETE BUTTON --
      ImGui.SameLine(ctx, 0,38)
      if button_action(0.555, 0.59, 0.6, 1, 'Delete##2', 90, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
        DeleteMainPalettePreset()
      end
      
      -- USER MAIN PALETTE MENU --
      if not pre_cntrl.stop2 and not pre_cntrl.main_combo_preview_value then
        pre_cntrl.main_combo_preview_value = user_mainpalette[pre_cntrl.current_main_item]
      elseif not pre_cntrl.main_combo_preview_value then
        pre_cntrl.main_combo_preview_value = pre_cntrl.main_new_combo_preview_value
      end
        
      ImGui.PushItemWidth(ctx, 220)
      local main_combo = ImGui.BeginCombo(ctx, '##7', pre_cntrl.main_combo_preview_value, 0) 
      if main_combo then 
        for i,v in ipairs(user_mainpalette) do
          local is_selected = pre_cntrl.current_main_item == i
          if ImGui.Selectable(ctx, user_mainpalette[i], is_selected, ImGui.SelectableFlags_None,  300.0,  0.0) then
            pre_cntrl.current_main_item = i
            if pre_cntrl.main_new_combo_preview_value and pre_cntrl.current_main_item ~= 1 then
              SetExtState(script_name, 'usermainpalette.*Last unsaved*', table.concat(user_main_settings,","),true)
            end
            
            user_main_settings = {} 
            if reaper.HasExtState(script_name, 'usermainpalette.'..tostring(user_mainpalette[i])) then
              for i in string.gmatch(reaper.GetExtState(script_name, 'usermainpalette.'..tostring(user_mainpalette[i])), "[^,]+") do
                insert(user_main_settings, tonumber(string.match(i, "[^,]+")))
              end
              colorspace =user_main_settings[1] 
              saturation = user_main_settings[2] 
              lightness = user_main_settings[3] 
              darkness = user_main_settings[4]
            end
            pre_cntrl.main_new_combo_preview_value, pre_cntrl.main_combo_preview_value, pre_cntrl.differs3, pre_cntrl.stop2 = nil, nil, 1, false
          end
           
          if ImGui.IsItemHovered(ctx) then
            pre_cntrl.hovered_main_preset = v
          end
          -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
          if is_selected then
            ImGui.SetItemDefaultFocus(ctx)
          end
        end
        ImGui.EndCombo(ctx)
      end
      
      if ImGui.IsWindowHovered(ctx, ImGui.FocusedFlags_ChildWindows) then
        local x, y = reaper.GetMousePosition()
        if ImGui.IsItemHovered(ctx) or main_combo then
          if main_combo and pre_cntrl.hovered_main_preset ~= ' ' and x > 0 then 
            for p, c in utf8.codes(pre_cntrl.hovered_main_preset) do 
              if c > 255 or string.len(pre_cntrl.hovered_main_preset) > 30 then 
                reaper.TrackCtl_SetToolTip( pre_cntrl.hovered_main_preset, x, y+sys_offset, 0 )
                break
              end
            end
          elseif x > 0 then
            for p, c in utf8.codes(user_mainpalette[pre_cntrl.current_main_item]) do 
              if c > 255 or string.len(user_mainpalette[pre_cntrl.current_main_item]) > 30 then 
                reaper.TrackCtl_SetToolTip( user_mainpalette[pre_cntrl.current_main_item], x, y+sys_offset, 0 )
                break
              end
            end
          end
        end
      end
      
      if sat_true or contrast_true or colorspace ~= colorspace_sw and pre_cntrl.current_main_item > 1 and not pre_cntrl.stop2 then
        pre_cntrl.main_new_combo_preview_value = user_mainpalette[pre_cntrl.current_main_item]..' (modified)'
        pre_cntrl.stop2, pre_cntrl.main_combo_preview_value = true, nil
      end

      ImGui.Dummy(ctx, 0, space_btwn)
      _, random_main = ImGui.Checkbox(ctx, "Random coloring via button##2", random_main)
      if button_color(0.14, 0.9, 0.7, 1, 'Reset Main Palette', 220, 19, false, 3)  then 
        saturation = 0.8; lightness =0.65; darkness =0.20; dont_ask = false; colorspace = 0
        sat_true = true
      end
      ImGui.PopStyleVar(ctx, 1)
      ImGui.Separator(ctx)
      ImGui.End(ctx)
      set_pos = {ImGui.GetWindowPos(ctx)}
    end
    ImGui.PopStyleVar(ctx)
  end
  
  

  local function SettingsPopUp()
    
    ImGui.Dummy(ctx, 0, 0)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    
    if set_cntrl.tree_node_open then
      ImGui.SetNextItemOpen(ctx, true, ImGui.Cond_Once)
    end
    set_cntrl.tree_node_open = ImGui.TreeNode(ctx, 'SECTIONS (show/hide)')
    if set_cntrl.tree_node_open then -- first treenode --
      set_cntrl.tree_node_open_save = true
      -- HIDING SECTIONS --
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
      _, show_custompalette  = ImGui.Checkbox(ctx, 'Show Custom Palette', show_custompalette)
      _, show_edit           = ImGui.Checkbox(ctx, 'Show Edit custom color', show_edit)
      _, show_lasttouched    = ImGui.Checkbox(ctx, 'Show Last touched', show_lasttouched)
      _, show_mainpalette    = ImGui.Checkbox(ctx, 'Show Main Palette', show_mainpalette)
      ImGui.PopStyleVar(ctx, 1)
      _, show_action_buttons = ImGui.Checkbox(ctx, 'Show Action buttons', show_action_buttons) 
      ImGui.PopStyleColor(ctx,1)
    end
    if set_cntrl.tree_node_open then
      ImGui.TreePop(ctx)
    end
    if set_cntrl.tree_node_open_save then
      local was_toggled = ImGui.IsItemToggledOpen(ctx)
      if was_toggled then
        set_cntrl.tree_node_open_save = false
      end
    end
    ImGui.Dummy(ctx, 0, 0)
    

    -- APEEARANCE SETTINGS SECTION --
    if set_cntrl.tree_node_open3 then
      ImGui.SetNextItemOpen(ctx, true, ImGui.Cond_Once)
    end
    set_cntrl.tree_node_open3 = ImGui.TreeNode(ctx, 'APPEARANCE (Experimental!)')
    if set_cntrl.tree_node_open3 then -- first treenode --
      set_cntrl.tree_node_open_save3 = true
      -- APPEARANCE --
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
      ImGui.PopStyleVar(ctx, 1)
      _, set_cntrl.background_color_mode  = ImGui.Checkbox(ctx, 'Use REAPER theme background color', set_cntrl.background_color_mode) 
      ImGui.PopStyleColor(ctx,1)
    end
    if set_cntrl.tree_node_open3 then
      ImGui.TreePop(ctx)
    end
    if set_cntrl.tree_node_open_save3 then
      local was_toggled = ImGui.IsItemToggledOpen(ctx)
      if was_toggled then
        tree_node_open_save = false
      end
    end
    ImGui.Dummy(ctx, 0, 0)
    
    -- ADVANCED SETTINGS
    if set_cntrl.tree_node_open2 then
      ImGui.SetNextItemOpen(ctx, true, ImGui.Cond_Once) 
    end
    set_cntrl.tree_node_open2 = ImGui.TreeNode(ctx, 'ADVANCED SETTINGS       ') -- second treenode --
    
    if set_cntrl.tree_node_open2 then
      -- SEPERATOR --
      set_cntrl.tree_node_open_save2 = true
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize,3) 
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign, 0.5, 0.5)
      ImGui.SeparatorText(ctx, '  Coloring Mode  ')
      ImGui.PopStyleVar(ctx, 2)
      ImGui.PopStyleColor(ctx,1)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
    
      -- MODE SELECTION --
      ImGui.AlignTextToFramePadding(ctx)
      ImGui.Text(ctx, 'Mode:')
      ImGui.SameLine(ctx, 0, 7)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
      _, selected_mode = ImGui.RadioButtonEx(ctx, 'Normal', selected_mode, 0); ImGui.SameLine(ctx, 0 , 25)
      if ImGui.RadioButtonEx(ctx, 'ShinyColors (experimental)   ', selected_mode, 1) then
        if not dont_ask then
          ImGui.OpenPopup(ctx, 'ShinyColors Mode')
        else
          selected_mode = 1
        end
      end
    
    
      -- SHINYCOLORS MODE POPUP --
      local center = {reaper.ImGui_Viewport_GetCenter(ImGui.GetWindowViewport(ctx))}
      ImGui.SetNextWindowPos(ctx, center[1], center[2], ImGui.Cond_Appearing, 0.5, 0.5)
      if ImGui.BeginPopupModal(ctx, 'ShinyColors Mode', nil, ImGui.WindowFlags_AlwaysAutoResize) then
        ImGui.Text(ctx, 'To use the full potential of ShinyColors Mode,\nmake sure Custom colors settings are set correctly under:\n\n"REAPER/ Preferences/ Appearance/",\n\nor that the currently used theme has a value of 50 for "tinttcp"\ninside its rtconfig.txt file!')
        ImGui.Dummy(ctx, 0, 0)
        ImGui.AlignTextToFramePadding(ctx)
        ImGui.Text(ctx, 'More info:')
        ImGui.SameLine(ctx, 0, 20)
        if button_action(0.555, 0.59, 0.6, 1, 'Open PDF in browser', 200, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
          OpenURL('https://drive.google.com/file/d/1fnRfPrMjsfWTdJtjSAny39dWvJTOyni1/view?usp=share_link')
        end
        ImGui.Dummy(ctx, 0, 0)
        ImGui.Separator(ctx)
        ImGui.Dummy(ctx, 0, 10)
        ImGui.AlignTextToFramePadding(ctx)
        ImGui.Text(ctx, 'Continue with ShinyColors Mode?')
      
        if button_action(0.555, 0.59, 0.6, 1, 'OK', 90, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
          ImGui.CloseCurrentPopup(ctx); selected_mode = 1
        end
        ImGui.SetItemDefaultFocus(ctx)
        ImGui.SameLine(ctx, 0, 20)
      
        if button_action(0.555, 0.59, 0.6, 1, 'Cancel', 90, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
          ImGui.CloseCurrentPopup(ctx); selected_mode = 0
        end
        ImGui.SameLine(ctx, 0, 20)
        _, dont_ask = ImGui.Checkbox(ctx, " Don't ask me next time", dont_ask)
        ImGui.Dummy(ctx, 0, 10)
        ImGui.EndPopup(ctx)
      end -- end of popup
  
      ImGui.AlignTextToFramePadding(ctx)
      ImGui.Text(ctx, 'How to use ShinyColors Mode:')
      ImGui.SameLine(ctx, 0, 10)
      if ImGui.Button(ctx, 'PDF', 60, 20) then
        OpenURL('https://drive.google.com/file/d/1fnRfPrMjsfWTdJtjSAny39dWvJTOyni1/view?usp=share_link')
      end
      ImGui.Dummy(ctx, 0, 0)
      ImGui.PopStyleVar(ctx, 1)
      
      
      -- SEPERATOR --
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize,3) 
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign, 0.5, 0.5)
      ImGui.SeparatorText(ctx, '  Auto Coloring  ')
      ImGui.PopStyleVar(ctx, 2)
      ImGui.PopStyleColor(ctx,1)
      
      
      -- CHECKBOX FOR AUTO TRACK COLORING --
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
      _, auto_trk = ImGui.Checkbox(ctx, "Autocolor new tracks", auto_trk)
      local yes
      if auto_trk then 
        ImGui.Dummy(ctx, 0, 0) 
        ImGui.SameLine(ctx, 0.0, 20)
        yes, auto_custom = ImGui.Checkbox(ctx, "Autocolor new tracks to custom palette", auto_custom)
      end
  
      if yes then auto_pal = nil end
      
      ImGui.Dummy(ctx, 0, 10)
      ImGui.AlignTextToFramePadding(ctx)
      ImGui.Text(ctx, 'Color new items to:')
      ImGui.PushItemWidth(ctx, 130)
      ImGui.SameLine(ctx, 0.0, 6)
      local auto_coloring_preview_value = combo_items[automode_id]
      ImGui.PushStyleColor(ctx, ImGui.Col_Border, HSV(0.3, 0.1, 0.5, 1))
      ImGui.PushStyleColor(ctx, ImGui.Col_FrameBg , HSV(0.65, 0.4, 0.2, 1))
      ImGui.PushStyleColor(ctx, ImGui.Col_FrameBgHovered, HSV(0.65, 0.2, 0.4, 1))
      
      if ImGui.BeginCombo(ctx, '##5', auto_coloring_preview_value, 0) then
        for i=1, #combo_items do
          local is_selected = automode_id == i
          if ImGui.Selectable(ctx, combo_items[i], is_selected) then
            automode_id = i
          end
          -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
          if is_selected then
            ImGui.SetItemDefaultFocus(ctx)
          end
        end
        ImGui.EndCombo(ctx)
      end
      ImGui.Dummy(ctx, 0, 0)
      ImGui.PopStyleColor(ctx, 3)
      ImGui.PopStyleVar(ctx, 1)
      ImGui.PopStyleColor(ctx)
    end
    
    if set_cntrl.tree_node_open2 then
      ImGui.TreePop(ctx)
    end
    if set_cntrl.tree_node_open_save2 then
      local was_toggled2 = ImGui.IsItemToggledOpen(ctx)
      if was_toggled2 then
        set_cntrl.tree_node_open_save2 = false
      end
    end
    ImGui.PopStyleColor(ctx)
    ImGui.Dummy(ctx, 0, 0) 
  end
  
  
  
  -- OWN VERSION OF "GET RULER MOUSE CONTEXT" --
  
  local function GetRulerMouseContext(mouse_pos, scale, UI_scale)
    
    local height_key, top_offs, lane_count, mark_mode, tempo_mode, time_mode, sec_offset, time_offs, mark_key, reg_key, timeline
    local region_h, marker_h, mouse_section, mouse_section_lane, marker_lane_ytop, marker_lane_yheight, marker_lane_ystart
    local pattern = 17
    local timeline_mode = reaper.SNM_GetIntConfigVar("projtimemode", 1)
    if timeline_mode < 9 and timeline_mode ~= 1 and timeline_mode ~= 7 or timeline_mode == 256 then
      sec_offset = 0
    else
      sec_offset = 9
    end
    
    local _, _, height = reaper.JS_Window_GetClientSize(ruler_win) 
    local rulerlayout = reaper.SNM_GetIntConfigVar("rulerlayout", 1)
    if rulerlayout%4 >= 2 then mark_mode = false else mark_mode = true end
    if rulerlayout%8 >= 4 then tempo_mode = 1 else tempo_mode = 0 end
    if rulerlayout%32 >= 24 then time_mode, time_offs = 1, 14 else time_mode, time_offs = 0, 0 end
    
    if sys_os == 1 then
      --height_key = 103*UI_scale//1
      top_offs = 3
      pattern = pattern*UI_scale//1
      sec_offset = sec_offset*UI_scale//1
      top_offs = 3*UI_scale//1
      time_offs = time_offs*UI_scale//1
      timeline = 29*UI_scale//1
      height_key = pattern*4+top_offs*2+timeline+((1*UI_scale+.5)//1)
    else
    --[[ -- LEFT HERE FOR REFERENCE INFORMATION
      if      scale == 1    then height_key = 104
      elseif  scale == 1.25 then height_key = 127
      elseif  scale == 1.5  then height_key = 152
      elseif  scale == 1.75 then height_key = 177
      elseif  scale == 2    then height_key = 208
      end
    --]]
      pattern = pattern*scale*UI_scale//1
      sec_offset = sec_offset*scale*UI_scale//1
      top_offs = 3*scale*UI_scale//1
      time_offs = time_offs*scale*UI_scale//1
      timeline = 29*scale*UI_scale//1
      height_key = pattern*4+top_offs*2+timeline+((1*UI_scale+.5)//1)
    end
    
    if height < height_key+sec_offset-time_offs then
      region_h, region_h_lanes = height/5.6, 1
      marker_h, marker_h_lanes = height/5.6+height/5.6, 1
      lane_count, reg_key, mark_key = 2, 1, 1
    elseif height >= height_key+sec_offset-time_offs then
      lane_count = (height-height_key-sec_offset+time_offs)//pattern+3-tempo_mode
      if rulerlayout%2 == 0 then 
        if mark_mode == true then
          reg_key, mark_key = lane_count//2+(lane_count%2), lane_count//2
          region_h, marker_h = top_offs+pattern*reg_key, top_offs+pattern*mark_key
        else
          mark_key, region_h = 1, top_offs+pattern*(lane_count-1)
          reg_key, marker_h = lane_count - mark_key, top_offs+pattern + region_h
        end
      else
        region_h, reg_key = top_offs+pattern, 1
        if mark_mode == true then
          marker_h, mark_key = top_offs+pattern*(lane_count-1), lane_count-reg_key
        else
          marker_h, mark_key = top_offs+pattern, 1 
        end
      end
    end
  
    if mouse_pos < region_h then 
      mouse_section = "region_lane"
      mouse_section_lane = (mouse_pos/(region_h/reg_key))//1+1
    elseif mouse_pos < top_offs*2+pattern*lane_count then 
      mouse_section = "marker_lane"
      mouse_section_lane = ((mouse_pos-region_h)/(marker_h/mark_key))//1+1
    else
      mouse_section = "timeline"
    end

    return mouse_section, mouse_section_lane, reg_key, mark_key
  end
  
  
  
  local function GetSelectedMarkers(sel_ruler, mouse_lane, region_lanes, marker_lanes, rvs, test_item, sel_items)
  
    if (sel_ruler == 'marker_lane' or sel_ruler == 'region_lane') and (static_mode == 0 or static_mode == 3)  then 
      local sel_key_m, sel_key_r
      items_mode, sel_mk, check_mark = 3, 1, false
      local retval, _, _ = reaper.CountProjectMarkers(0)
      local title = reaper.JS_Localize("Region/Marker Manager", "common")
      local manager = reaper.JS_Window_Find(title, true)
      if not manager then
        reaper.Main_OnCommand(40326, 0) -- View: Show region/marker manager window
        manager = reaper.JS_Window_Find(title, true)
        closeonexit = true
      end 
      local container = reaper.JS_Window_FindChildByID(manager, 1071)
      local sel_count, sel_indexes = reaper.JS_ListView_ListAllSelItems(container)
      
      rv_markers = {retval={},isrgn={},pos={},rgnend={},name={},markrgnindexnumber={},color={},length={},lane={}}
      sel_markers = { retval={}, number={}, m_type={} }
      
      i = 0
      for index in string.gmatch(sel_indexes, '[^,]+') do 
        i = i+1
        local marker = reaper.JS_ListView_GetItemText(container, tonumber(index), 1)
        local marker2 = marker:gsub("%D+", "")
        local sel_key = marker:gsub("%A+", "")
        if sel_key == "M" then
          sel_key_m = true
        elseif sel_key == "R" then
          sel_key_r = true
        end
        sel_markers.number[i] = tonumber(marker2)
        sel_markers.m_type[i] = sel_key
        check_mark = true
      end
  
      for i = 0, retval-1 do 
        rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
          for j = 1, #sel_markers.number do
            if sel_markers.m_type[j] == "M" and rv_markers.isrgn[i] == false and rv_markers.markrgnindexnumber[i] == sel_markers.number[j] then
              sel_markers.retval[j] = rv_markers.retval[i]-1
            elseif sel_markers.m_type[j] == "R" and rv_markers.isrgn[i] == true and rv_markers.markrgnindexnumber[i] == sel_markers.number[j] then
              sel_markers.retval[j] = rv_markers.retval[i]-1
            end
          end
      end
      if closeonexit == true then
        reaper.JS_Window_Destroy(manager)
        closeonexit = false
      end
      
      if check_mark == true then
        if sel_key_m == true and sel_key_r == true then
          tr_txt = 'Mrk+Rgn'
        elseif sel_key_m == true then
          tr_txt = 'Markers'
          sel_mk = 1
        elseif sel_key_r == true then
          tr_txt = 'Regions'
          sel_mk = 2
        end
        tr_txt_h = 0.663
      elseif check_mark == false and static_mode == 0 then
        tr_txt = '##No_selection'
        check_mark = true
      end
      
    elseif static_mode == 0 then
      if sel_items > 0 then
        items_mode = 1
        rv_markers = {}
      else
        items_mode = 0
        rv_markers = {}
      end
    end
    seen_msgs[1] = rvs
    test_item = nil
  end
  
  
  local function GetSelectedMarkers2(container2) 
    local sel_key_m, sel_key_r
    items_mode, sel_mk, check_mark = 3, 1, false
    local retval, _, _ = reaper.CountProjectMarkers(0)
    if (static_mode == 0 or static_mode == 3) then
      local sel_count, sel_indexes = reaper.JS_ListView_ListAllSelItems(container2)
          
      rv_markers = {retval={},isrgn={},pos={},rgnend={},name={},markrgnindexnumber={},color={},length={},lane={}}
      sel_markers = { retval={}, number={}, m_type={} }
          
      i = 0
      for index in string.gmatch(sel_indexes, '[^,]+') do 
        i = i+1
        local marker = reaper.JS_ListView_GetItemText(container2, tonumber(index), 1)
        local marker2 = marker:gsub("%D+", "")
        local sel_key = marker:gsub("%A+", "")
        if sel_key == "M" then
          sel_key_m = true
        elseif sel_key == "R" then
          sel_key_r = true
        end
        sel_markers.number[i] = tonumber(marker2)
        sel_markers.m_type[i] = sel_key
        check_mark = true
      end
  
      for i = 0, retval-1 do 
        rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
          for j = 1, #sel_markers.number do
            if sel_markers.m_type[j] == "M" and rv_markers.isrgn[i] == false and rv_markers.markrgnindexnumber[i] == sel_markers.number[j] then
              sel_markers.retval[j] = rv_markers.retval[i]-1
            elseif sel_markers.m_type[j] == "R" and rv_markers.isrgn[i] == true and rv_markers.markrgnindexnumber[i] == sel_markers.number[j] then
              sel_markers.retval[j] = rv_markers.retval[i]-1
            end
          end
      end
      
      if check_mark == true then
        if sel_key_m == true and sel_key_r == true then
          tr_txt = 'Mrk+Rgn'
        elseif sel_key_m == true then
          --tr_txt = 'Markers'
          tr_txt = 'Manager'
        elseif sel_key_r == true then
          --tr_txt = 'Regions'
          tr_txt = 'Manager'
        end
        tr_txt_h = 0.663
      elseif check_mark == false and static_mode == 0 then
        tr_txt = '##No_selection'
        check_mark = true
      end
    
    elseif static_mode == 0 then
      if sel_items > 0 then
        items_mode = 1
        rv_markers = {}
      else
        items_mode = 0
        rv_markers = {}
      end
    end
    --seen_msgs[1] = rvs
    test_item = nil
  end
    
    
  
  local function GetMarkerUnderMouse(sel_ruler, mouse_lane, region_lanes, marker_lanes, sys_scale, ui_scale, sel_items)
    if sel_ruler == 'marker_lane' and (static_mode == 0 or static_mode == 3)  then 
      items_mode, sel_mk = 3, 1

      local same_pos_index, marker_lane, lanes = 1, 0, marker_lanes
      local last_marker, length_offset
      local retval, _, _ = reaper.CountProjectMarkers(0)
      local mouse_cursor = reaper.BR_PositionAtMouseCursor(true)
      local zoom = reaper.GetHZoomLevel()
      local rounding1 = 1/zoom*((1*sys_scale+.5)//1)
      
      rv_markers = {retval={},isrgn={},pos={},rgnend={},name={},markrgnindexnumber={},color={},length={},lane={}} 
      local same_pos_t = {pos={}, num={}}

      if marker_lanes > 1 then -- more than 1 lane seen!! 
      
        -- GET TIMELINE FONT FROM COLORTHEME_FILE OR INI
        local path_mode, tl_font
        local inipath = reaper.get_ini_file()
        local _, lasttheme = reaper.BR_Win32_GetPrivateProfileString("reaper", "lastthemefn5", "Error", inipath)
        if lasttheme == "*unsaved*" then
          _, tl_font = reaper.BR_Win32_GetPrivateProfileString("reaper", "tl_font", "Error", inipath)
          pathmode = 1
        else 
          local theme = reaper.GetLastColorThemeFile()
          pathmode = 0
          _, tl_font = reaper.BR_Win32_GetPrivateProfileString("reaper", "tl_font", "Error", theme)
          if tl_font == "Error" then 
            local ext = theme:find("(.-)%Zip") 
            if not ext then
              theme = theme.."Zip"
            end
            local zip, _ = reaper.JS_Zip_Open(theme, 'r', 6)
            local _, ent_str = reaper.JS_Zip_ListAllEntries(zip)
            local file_name
            for name in ent_str:gmatch("[^\0]+")do
              local file = name:match("(.-)%.ReaperTheme$")
              if file then
                file_name = name
                break
              end
            end
            reaper.JS_Zip_Entry_OpenByName(zip, file_name)
            local _, contents = reaper.JS_Zip_Entry_ExtractToMemory(zip)
            tl_font = string.match(tostring(contents), "tl_font=(%x*)")
            reaper.JS_Zip_Entry_Close(zip)
            reaper.JS_Zip_Close(theme)
          end
        end
        
        tl_font = tl_font:gsub(('[A-F0-9]'):rep(2), function(byte)
          return string.char(tonumber(byte, 16))
        end)
        local height, width, escapement, orientation, weight, italic, underline, strike_out,
        charset, out_precision, clip_precision, quality, pitch_and_family, facename =
          ('iiiiibbbbbbbbc32'):unpack(tl_font)

        local font_size, font_size_t, nativedraw, osx_display, bm, bmDC, font, button_t, bk_mode
        
        if sys_os ==1 then
          bk_mode = 1
          nativedraw = reaper.SNM_GetIntConfigVar('nativedrawtext', -1)
          if nativedraw == -1 then
            nativedraw = reaper.SNM_GetIntConfigVar('nativedrawtext2', -1)
          end
          nativedraw = tonumber(nativedraw)
          osx_display = reaper.SNM_GetIntConfigVar("osxdisplayoptions", 666)
          
          button_t = {(13*ui_scale)//1,(21*ui_scale)//1,(3*ui_scale)//1}
          if osx_display >= 34 then 
            font_size = math.ceil((math.floor(height*ui_scale))*0.777)
          else
            font_size = math.ceil((math.floor(height*sys_scale*ui_scale))*0.777)
          end
          if font_size == 24 and tonumber(ui_scale) > 1.548 and tonumber(ui_scale) < 1.55 then font_size = 25 end -- what a shame... --
          length_offset = (4*ui_scale)//1

        else
          bk_mode, nativedraw = 2, 1
          button_t = {(((13*sys_scale)//1*ui_scale)//1),(((21*sys_scale)//1*ui_scale)//1),((3*sys_scale*ui_scale)//1)}
          font_size = math.floor((math.ceil(height*sys_scale*ui_scale))*0.777)
          length_offset = (4*sys_scale//1*ui_scale)//1
          
          local alt_face = {"Script", "Modern", "Roman", "Marlett", "8514oem", "Terminal", "Webdings" , "Wingdings"}
          local face = string.match(facename, "%w*")
          for i = 1, #alt_face do
            if alt_face[i] == face then
              nativedraw = 0
              break
            end
          end
        end
        
        local function scale(x)
          local value = (x*sys_scale+0.5)//1
          return value
        end
         
        if nativedraw == 1 then 
          -- CREATE GDI FONT AND SYSTEM BITMAP --
          local w = scale(2500)
          local sample_h = 1
          bm = reaper.JS_LICE_CreateBitmap(true, w, sample_h)
          bmDC = reaper.JS_LICE_GetDC(bm)
          font = reaper.JS_GDI_CreateFont(font_size, weight, 0, italic, underline, false, facename)
          reaper.JS_GDI_SetTextColor(bmDC, 0xFFFF0000)
          reaper.JS_GDI_SetTextBkColor(bmDC, 0xFFFF0000) 
          reaper.JS_GDI_SetTextBkMode(bmDC, bk_mode)
          reaper.JS_GDI_SelectObject(bmDC, font)
        else 
          -- GFX TEXT MEASUREMENT --
          flags = ''
          if weight > 649 then flags = 'b' end
          if italic == -1 then flags = flags..'i' end
          if underline == -1 then flags = flags..'u' end
          
          function fontflags(str) 
            local v = 0
            for a = 1, str:len() do 
              v = v * 256 + string.byte(str, a) 
            end 
            return v 
          end
          
          gfx.setfont(1, facename, font_size, fontflags(flags))
        end
        
        local function SearchForEndOfMarker(bmp, target, pixel_i)
            local step = 0
            local text_length
            while not text_length do
                pixel_i = pixel_i + step
                local found_color = reaper.JS_LICE_GetPixel(bmp,  pixel_i, 0)
                if found_color ~= target then
                  text_length = pixel_i
                  break
                else
                  step = 1
                end
                if pixel_i > 10000 then
                    Msg("MARKER NOT FOUND")
                    break
                end -- prevent infinite loop
            end
            return text_length
        end
        
        local shortest_t = {pos={}, value={}, key={}, lane={}}
        
        for i = 0, retval -1 do 
          rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
          if rv_markers.isrgn[i] == false then
            local marker_gui_w, button
            if rv_markers.markrgnindexnumber[i] > 9 then
              marker_gui_w = button_t[2]
              button = button_t[2]+button_t[3]
            else
              marker_gui_w = button_t[1]
              button = button_t[1]+button_t[3]
            end
            local rounding2 = (1/zoom*marker_gui_w*1000+.5)//1/1000
            
            -- STORE ALL MARKERS AT MOUSE POSITION IN TABLE --
            if rv_markers.pos[i]-rounding1 < mouse_cursor
                and rv_markers.pos[i]+rounding2 > mouse_cursor then
              tr_txt = 'Marker'
              tr_txt_h = 0.663
              check_mark = true
              same_pos_t.pos[same_pos_index] = rv_markers.retval[i]
              same_pos_t.num[same_pos_index] = i
              same_pos_index = same_pos_index+1
            end
            
            -- CALCULATE MARKER LENGTH --
            if nativedraw == 1 then
              local str_length = string.len(rv_markers.name[i])
              reaper.JS_LICE_Clear(bm, 0xFF000000)
              reaper.JS_GDI_DrawText(bmDC, rv_markers.name[i], str_length, 0, 0, 3500, 1000, "LEFT")
              if sys_os == 1 then target_color = 0xFFFF0000 else target_color = 0xFF0000 end
              Text_length = SearchForEndOfMarker(bm, target_color, 0)
            else
              Text_length, _ = gfx.measurestr(rv_markers.name[i])
            end
            
            local marker_length = Text_length+(button)+length_offset
            rv_markers.length[i] = marker_length
            local numofoverlap = 1
            
            -- CALCULATE MARKER LANE --
            if last_marker then
              local shortest_index, marker_lane, short, shortest, shortest_key = 0, 0
              for k = 1, #shortest_t.lane  do
                local Key1 = (rv_markers.pos[shortest_t.key[k]]+rv_markers.length[shortest_t.key[k]]/zoom)
                local Key2 = rv_markers.pos[i]
                if numofoverlap < marker_lanes then
                  if (rv_markers.pos[shortest_t.key[k]] <= rv_markers.pos[i]) and Key1 >= Key2 then
                    numofoverlap = numofoverlap +1
                    local short = rv_markers.length[shortest_t.key[k]]/zoom+rv_markers.pos[shortest_t.key[k]]-rv_markers.pos[i]
                    if shortest_t.lane[k] == marker_lane then
                      marker_lane = (shortest_t.lane[k] +1)%lanes
                    end
                    if shortest then
                      if short < shortest then
                        shortest, shortest_key = short, k
                      end
                    else
                      shortest, shortest_key = short, k
                    end
                    
                  else
                    if shortest_t.lane[k] == marker_lane then
                      marker_lane = (shortest_t.lane[k])
                    end
                  end
                else
                  local short = rv_markers.length[shortest_t.key[k]]/zoom+rv_markers.pos[shortest_t.key[k]]-rv_markers.pos[i]
                  if rv_markers.pos[shortest_t.key[k]] <= rv_markers.pos[i] and Key1 >= Key2 then
                    if shortest then
                      if short < shortest then
                        shortest, shortest_key  = short, k
                        marker_lane = rv_markers.lane[shortest_t.key[k]]
                      else
                        marker_lane = rv_markers.lane[shortest_t.key[shortest_key]]
                      end
                    else
                      shortest, shortest_key = short, k
                      marker_lane = rv_markers.lane[shortest_t.key[k]]
                    end
                  else
                    if shortest then
                      if shortest > 0 then
                        shortest, shortest_key = short, k
                        marker_lane = rv_markers.lane[shortest_t.key[k]]
                      end
                    else
                      shortest, shortest_key = short, k
                      marker_lane = rv_markers.lane[shortest_t.key[k]]
                    end
                  end
                end
              end
              rv_markers.lane[i] = marker_lane
              shortest_index = marker_lane
              shortest_t.pos = rv_markers.pos[i]
              shortest_t.key[shortest_index+1] = i
              shortest_t.lane[shortest_index+1] = marker_lane
            else
              rv_markers.lane[i] = 0
              shortest_index = 0
              shortest_t.key[shortest_index+1] = i
              shortest_t.pos = rv_markers.pos[i]
              shortest_t.lane[shortest_index+1] = 0
            end
            last_marker = i
          end
        end
        
        -- RESET JS_GDI AND LICE
        reaper.JS_GDI_ReleaseDC( bmDC, bm )
        reaper.JS_GDI_DeleteObject(font)
        reaper.JS_LICE_DestroyBitmap(bm)
        
      else -- if only one lane is seen
        for i = 0, retval -1 do 
          rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
          if rv_markers.isrgn[i] == false then
            local marker_gui_w
            local button
            if rv_markers.markrgnindexnumber[i] > 9 then
              marker_gui_w = (21*sys_scale+.5)//1
            else
              marker_gui_w = (13*sys_scale+.5)//1
            end
            local rounding2 = (1/zoom*marker_gui_w*1000+.5)//1/1000
            
            -- STORE ALL MARKERS AT MOUSE POSITION IN TABLE --
            if rv_markers.pos[i]-rounding1 < mouse_cursor
                and rv_markers.pos[i]+rounding2 > mouse_cursor then
              tr_txt = 'Marker'
              tr_txt_h = 0.663
              check_mark = true
              same_pos_t.pos[same_pos_index] = rv_markers.retval[i]
              same_pos_t.num[same_pos_index] = i
              same_pos_index = same_pos_index+1
            end
          end
        end
      end
      
      sel_markers = { retval={}, number={}, m_type={} }
      
      if marker_lanes > 1 then
        if #same_pos_t.pos > 1 then
          for i=1, #same_pos_t.pos do
            if rv_markers.lane[same_pos_t.num[i]] == mouse_lane-1 then
              sel_markers.retval[1] = same_pos_t.num[i]
              break
            end  
          end
        else
          if rv_markers.lane[same_pos_t.num[1]] == mouse_lane-1 then
            sel_markers.retval[1] = same_pos_t.num[1]
          end
        end
      else
        sel_markers.retval[1] = same_pos_t.num[1]
      end
      
      if check_mark == false and static_mode == 0 then
        tr_txt = '##No_selection'
      end
        
        
    elseif sel_ruler == 'region_lane' and (static_mode == 0 or static_mode == 4) then
      items_mode, sel_mk = 3, 2
      local same_pos_index, marker_lane, lanes = 1, 0, region_lanes
      local last_marker, shortest
      local retval, _, _ = reaper.CountProjectMarkers(0)
      local mouse_cursor = reaper.BR_PositionAtMouseCursor(true)
      rv_markers = {retval={},isrgn={},pos={},rgnend={},name={},markrgnindexnumber={},color={},length={},lane={}} -- Why isn't this local??
      local same_pos_t = {pos={}, num={}}
      local shortest_t = {pos={}, value={}, key={}, lane={}}
      
      for i = 0, retval -1 do 
        rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
        if rv_markers.isrgn[i] == true then
          
          -- STORE ALL MARKERS AT MOUSE POSITION IN TABLE --
          if rv_markers.pos[i] <= mouse_cursor
              and rv_markers.rgnend[i] >= mouse_cursor then
            tr_txt = 'Region'
            tr_txt_h = 0.663
            check_mark = true
            same_pos_t.pos[same_pos_index] = rv_markers.retval[i]
            same_pos_t.num[same_pos_index] = i
            same_pos_index = same_pos_index+1
          end
            
          local marker_length = rv_markers.rgnend[i] - rv_markers.pos[i]
          rv_markers.length[i] = marker_length
          local numofoverlap = 1
          
          -- CALCULATE MARKER LANE --
          if last_marker then
            local shortest_index, marker_lane, short, shortest, shortest_key = 0, 0
            for k = 1, #shortest_t.lane  do
              local Key1 = (rv_markers.pos[shortest_t.key[k]]+rv_markers.length[shortest_t.key[k]])
              local Key2 = rv_markers.pos[i]
              
              if numofoverlap < region_lanes then
                if (rv_markers.pos[shortest_t.key[k]] <= rv_markers.pos[i]) and Key1 >= Key2 then
                  numofoverlap = numofoverlap +1
                  local short = rv_markers.length[shortest_t.key[k]]+rv_markers.pos[shortest_t.key[k]]-rv_markers.pos[i]
                  if shortest_t.lane[k] == marker_lane then
                    marker_lane = (shortest_t.lane[k] +1)%lanes
                  end
                  if shortest then
                    if short < shortest then
                      shortest, shortest_key = short, k
                    end
                  else
                    shortest, shortest_key = short, k
                  end
                else
                  if shortest_t.lane[k] == marker_lane then
                    marker_lane = (shortest_t.lane[k])
                  end
                end
              else
                local short = rv_markers.length[shortest_t.key[k]]+rv_markers.pos[shortest_t.key[k]]-rv_markers.pos[i]
                if rv_markers.pos[shortest_t.key[k]] <= rv_markers.pos[i] and Key1 >= Key2 then
                  if shortest then
                    
                    if short < shortest then
                      shortest, shortest_key = short, k
                      marker_lane = rv_markers.lane[shortest_t.key[k]]
                    else
                      marker_lane = rv_markers.lane[shortest_t.key[shortest_key]]
                    end
                  else
                    shortest, shortest_key = short, k
                    marker_lane = rv_markers.lane[shortest_t.key[k]]
                  end
                else
                  if shortest then
                    if shortest > 0 then
                      shortest, shortest_key = short, k
                      marker_lane = rv_markers.lane[shortest_t.key[k]]
                    end
                  else
                    shortest, shortest_key = short, k
                    marker_lane = rv_markers.lane[shortest_t.key[k]]
                  end
                end
              end
            end
            rv_markers.lane[i] = marker_lane
            shortest_index = marker_lane
            shortest_t.pos = rv_markers.pos[i]
            shortest_t.key[shortest_index+1] = i
            shortest_t.lane[shortest_index+1] = marker_lane
          else
            rv_markers.lane[i] = 0
            shortest_index = 0
            shortest_t.key[shortest_index+1] = i
            shortest_t.pos = rv_markers.pos[i]
            shortest_t.lane[shortest_index+1] = 0
          end
          last_marker = i
        end
      end
      
      sel_markers = { retval={}, number={}, m_type={} }
      
      if marker_lanes > 1 then
        if #same_pos_t.pos > 1 then
          for i=1, #same_pos_t.pos do
            if rv_markers.lane[same_pos_t.num[i]] == mouse_lane-1 then
              sel_markers.retval[1] = same_pos_t.num[i]
              --break -- don't break for regions 
            end  
          end
        else
          if rv_markers.lane[same_pos_t.num[1]] == mouse_lane-1 then
            sel_markers.retval[1] = same_pos_t.num[1]
          end
        end
      else
        sel_markers.retval[1] = same_pos_t.num[#same_pos_t.num]
      end
      if check_mark == false and static_mode == 0 then
        tr_txt = '##No_selection'
      end 
      
    elseif static_mode == 0 then
      if sel_items > 0 then
        items_mode = 1
        rv_markers = {}
      else
        items_mode = 0
        rv_markers = {}
      end
    end
  end
  
  
  
  local function IsManagerWindowClicked()
    local state_count, focused_hWnd, focused_hWnd_sw, parent_hWnd, is_focused_sw, list_item_sw, parent_hWnd_sw, list_hWnd
    local inputbox_hWnd, region_manager_state, state_count_sw, list_item, list_item_sw, had_mouse_input, time
    local mouseclick = false
    --local time = reaper.time_precise()
    local time = 0
    local title = reaper.JS_Localize("Region/Marker Manager", "common")
    
    return function()
      focused_hWnd = reaper.JS_Window_GetFocus()
      state_count = reaper.GetProjectStateChangeCount(0)
      if focused_hWnd and focused_hWnd ~= focused_hWnd_sw then 
        parent_hWnd = reaper.JS_Window_Find(title, 0)
        is_focused_sw, list_item_sw = 1, nil
        if parent_hWnd and parent_hWnd_sw ~= parent_hWnd then
          
          is_focused_sw, list_item_sw = 1, nil
          list_hWnd = reaper.JS_Window_FindChildByID(parent_hWnd, 0x42f)
          inputbox_hWnd = reaper.JS_Window_FindChildByID(parent_hWnd, 0x3EF)
          is_focused_sw, parent_hWnd_sw, region_manager_state, list_item_sw  = 1, parent_hWnd, true, nil
        elseif region_manager_state == true and parent_hWnd == nil then 
          is_focused_sw, focused_hWnd_sw, parent_hWnd_sw, region_manager_state = 0, nil, nil, false
          
        end
        focused_hWnd_sw = focused_hWnd
      end
      
      if focused_hWnd and (list_hWnd == focused_hWnd or parent_hWnd == focused_hWnd or inputbox_hWnd == focused_hWnd) then -- only if list is focused
        if is_focused_sw == 1 or state_count ~= state_count_sw  then
          list_item, _ = reaper.JS_ListView_GetFocusedItem(list_hWnd)
          if list_item ~= list_item_sw then
            had_mouse_input = list_item -- make function output whatever you want
            time = reaper.time_precise() -- make function output whatever you want
            mouseclick = true
            list_item_sw = list_item
          end
          state_count_sw = state_count
        else
          mouseclick = false
        end
        is_focused_sw = 0
      else
        had_mouse_input = nil
      end
      return mouseclick, time, had_mouse_input, list_hWnd
    end
  end 
  
  
  -- MAKE ANONYMOUS FUNCTIONS LOCAL --
  
  local IsManagerWindow = IsManagerWindowClicked()
  local AutoItem = automatic_item_coloring()
  
  
      
--[[_______________________________________________________________________________
    _______________________________________________________________________________]]
  


  -- THE COLORPALETTE GUI--

  local function ColorPalette(init_state, pad) 

    local ImGui_scale = reaper.ImGui_GetWindowDpiScale(ctx)
    if ImGui_scale ~= ImGui_scale2 then
      sys_scale, ImGui_scale2 = ImGui_scale, ImGui_scale2
    end
      
    local p_x, p_y = ImGui.GetWindowPos(ctx)
    local w, h = ImGui.GetWindowSize(ctx)
    local size = ((w-2*23-32)/24)
    local width2 = w-pad*2
    
    
   
    -- DEFINE "GLOBAL" VARIABLES --

    local sel_items = CountSelectedMediaItems(0)
    local test_item = GetSelectedMediaItem(0, 0) 
    local sel_tracks = CountSelectedTracks(0) 
    local test_track = GetSelectedTrack(0, 0) 
    local tr_cnt = CountTracks(0)
    
    
    -- CHECK FOR PROJECT TAP CHANGE --
    local cur_project = getProjectTabIndex()
    
    if cur_project ~= old_project then
      old_project, track_number_sw, col_tbl, cur_state4 = cur_project, nil
      track_number_stop = tr_cnt
    end
    
    
    -- CHECK FOR WINDOW --
    
    local rvs = {reaper.JS_WindowMessage_Peek(ruler_win, msgs)} -- multiple values are required, so must be a table
    local rvs2 = select(3, reaper.JS_WindowMessage_Peek(arrange, msgs))
    local rvs3 = select(3, reaper.JS_WindowMessage_Peek(TCPDisplay, msgs))
    local rvs4 = select(2, IsManagerWindow())
  
    
    -- AUTO TRACK COLORING --
    
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
    
    -- SAVE ALL TRACKS AND THEIR COLORS TO A TABLE --
    
    if not col_tbl 
      or ((Undo_CanUndo2(0)=='Change track order')
          or  tr_cnt ~= tr_cnt_sw) then
      generate_trackcolor_table(tr_cnt)
      tr_cnt_sw = tr_cnt 
    end
    
    
    local var = 0 
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, 5); var=var+1 -- for settings menu sliders
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_GrabRounding, 2); var=var+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_PopupRounding, 2); var=var+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 16); var=var+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize,1) var=var+1
    
    local col = 0
    ImGui.PushStyleColor(ctx, ImGui.Col_Border,0x303030ff) col= col+1
    ImGui.PushStyleColor(ctx, ImGui.Col_BorderShadow, 0x10101050) col= col+1
  
    
    -- PALETTE MENU, SETTINGS POPUP AND INDICATOR --
    
    if ImGui.BeginPopupContextItem(ctx, '##Settings3') then
      SettingsPopUp()
      ImGui.EndPopup(ctx)
    end -- Settings Menu
        
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 9); var=var+1 
    ImGui.Dummy(ctx, 0, 0)
    
    -- PALETTE MENU --
    if button_action(0.555, 0.59, 0.6, 1, 'Palette Menu', 140, 22, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then 
      openSettingWnd = true
    end
    if openSettingWnd then
      PaletteMenu(p_y, p_x, w, h)
    end
    
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6); var=var+1
    ImGui.SameLine(ctx, 0, 5)
    
    -- THE NEW SETTINGS BUTTON --
    if button_action(0.555, 0.59, 0.6, 1, '##Settings2', 36, 22, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then 
      ImGui.OpenPopup(ctx, '##Settings3')
    end

    -- DRAWING --
    local pos = {ImGui.GetCursorScreenPos(ctx)}
    local center = {pos[1]+154, pos[2]-22}
    local draw_list = ImGui.GetWindowDrawList(ctx)
    local draw_color = 0xffe8acff
    if ImGui.IsItemHovered(ctx) then
      local draw_thickness = 1.8
    else
      local draw_thickness = 1.6
    end
    ImGui.DrawList_AddLine(draw_list, center[1], center[2], center[1]+3, center[2], draw_color, draw_thickness)
    ImGui.DrawList_AddLine(draw_list, center[1]+7, center[2], center[1]+18, center[2], draw_color, draw_thickness)
    ImGui.DrawList_AddLine(draw_list, center[1], center[2]+6, center[1]+10, center[2]+6, draw_color, draw_thickness)
    ImGui.DrawList_AddLine(draw_list, center[1]+14, center[2]+6, center[1]+18, center[2]+6, draw_color, draw_thickness)
    ImGui.DrawList_AddCircle(draw_list, center[1]+6, center[2], 3, draw_color,  0, draw_thickness)
    ImGui.DrawList_AddCircle(draw_list, center[1]+12, center[2]+6, 3, draw_color,  0, draw_thickness)
    
    -- OPEN SETTINGS POPUP VIA RIGHT CLICK --
    if ImGui.IsMouseClicked(ctx, ImGui.MouseButton_Right, false) and ImGui.IsWindowHovered(ctx) and not ImGui.IsAnyItemHovered(ctx) then
      ImGui.OpenPopup(ctx, '##Settings3')
    end
    
    -- SELECTION INDICATOR TEXT AND COLOR --
    if items_mode == 0 then 
      tr_txt = 'Tracks'
      --tr_txt_h = 0.555
      tr_txt_h = 0.610
    elseif items_mode == 1 then 
      tr_txt = 'Items'
      tr_txt_h = 0.610
    elseif items_mode == 2 then 
      tr_txt = '##No_selection'
    end
    
    if items_mode == 3 then
      tr_txt_hb = 0.091
    else
      tr_txt_hb = 0.555
    end
      
    ImGui.SameLine(ctx, -1, width2-82)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) col=col+1

    -- SELECTION INDICATOR --
    if button_action(tr_txt_h, 0.5, 0.4, 1, tr_txt, 100, 22, true, 4, tr_txt_hb, 0.2, 0.3, 0.55, 3) then
      if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) 
          and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
          if static_mode == 0 and items_mode ~= 2 then 
            if items_mode == 0 then
              static_mode = 1
            elseif items_mode == 1 then
              static_mode = 2
            elseif items_mode == 3 and sel_mk == 1 then
              static_mode = 3
            elseif items_mode == 3 and sel_mk == 2 then
              static_mode = 3
            end
          else
            static_mode = 0 
            if items_mode == 1 or items_mode == 3 then
              seen_msgs[3] = rvs3
            end
          end
      elseif items_mode == 0 and sel_items>0 then
        items_mode = 1
        test_item_sw = nil
        test_take2 = nil
        static_mode = 0
        SetCursorContext(1) 
      elseif items_mode == 1 and sel_tracks>0 then 
        items_mode = 0 
        sel_tracks2 = nil
        static_mode = 0
        SetCursorContext(0) 
      elseif items_mode == 3 then
        static_mode = 0
        if sel_items>0 then 
          items_mode = 1
        else
          items_mode = 0
        end
      elseif items_mode == 0 and static_mode == 1 then
        static_mode = 0
      end
    end
    
    if not ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) and ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right)then
      Main_OnCommandEx(40769, 0, 0) -- Unselect (clear selection of) all tracks/items/envelope points
    end
    
    
    -- STATIC DRAWING --
    
    if  static_mode ~= 0 then
      local text_min_x, text_min_y = reaper.ImGui_GetItemRectMin(ctx)
      local text_max_x, text_max_y = reaper.ImGui_GetItemRectMax(ctx)
      ImGui.DrawList_AddLine(draw_list, text_min_x+4, text_min_y+8, text_min_x+4,text_min_y+4, HSV(0.555, 0.7, 1, 1), 1)
      ImGui.DrawList_AddLine(draw_list, text_min_x+4, text_min_y+4, text_min_x+8,text_min_y+4, HSV(0.555, 0.7, 1, 1), 1)
      ImGui.DrawList_AddLine(draw_list, text_min_x+4, text_max_y-5, text_min_x+8,text_max_y-5, HSV(0.555, 0.7, 1, 1), 1)
      ImGui.DrawList_AddLine(draw_list, text_min_x+4, text_max_y-5, text_min_x+4,text_max_y-9, HSV(0.555, 0.7, 1, 1), 1)
      ImGui.DrawList_AddLine(draw_list, text_max_x-5, text_min_y+4, text_max_x-9,text_min_y+4, HSV(0.555, 0.7, 1, 1), 1)
      ImGui.DrawList_AddLine(draw_list, text_max_x-5, text_min_y+4, text_max_x-5,text_min_y+8, HSV(0.555, 0.7, 1, 1), 1)
      ImGui.DrawList_AddLine(draw_list, text_max_x-5, text_max_y-5, text_max_x-9,text_max_y-5, HSV(0.555, 0.7, 1, 1), 1)
      ImGui.DrawList_AddLine(draw_list, text_max_x-5, text_max_y-5, text_max_x-5,text_max_y-9, HSV(0.555, 0.7, 1, 1), 1)
    end
    

    -- GREEN DOT --
    
    if selected_mode == 1 then
      ImGui.PushStyleColor(ctx, ImGui.Col_Border, HSV(0.555, 0.1, 0.39, 1)); col=col+1
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize,2); var=var+1
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_FramePadding, 0, 0); var=var+1
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6); var=var+1
      ImGui.SameLine(ctx, -3, width2-106)
      ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx) + 3)
      ImGui.RadioButtonEx(ctx, '##', selected_mode, 1)
      local circle_min_x, circle_min_y = reaper.ImGui_GetItemRectMin(ctx)
      local circle = {circle_min_x, circle_min_y}
      ImGui.DrawList_AddCircle(draw_list, circle[1]+7, circle[2]+7, 2, HSV(0.255, 0.1, 1, 1),  0)
      ImGui.DrawList_AddCircle(draw_list, circle[1]+8, circle[2]+8, 6, HSV(0.255, 0.5, 1, 0.08),  0, 6)
      ImGui.DrawList_AddCircle(draw_list, circle[1]+8, circle[2]+8, 9, HSV(0.255, 0.5, 1, 0.06),  0, 2)
    end
    
    ImGui.Dummy(ctx, 0, 1) -- gap between next row (main palette)
    ImGui.PopStyleVar(ctx, var) -- for upper part
    ImGui.PopStyleColor(ctx, col) -- for upper part
  
  
    -- -- GENERATING TABLES -- --

    if not main_palette or pre_cntrl.differs3 or sat_true or contrast_true
        or colorspace ~= colorspace_sw then
      main_palette = Palette()
      pal_tbl = generate_palette_color_table()
      colorspace_sw = colorspace 
      user_main_settings = generate_user_main_settings()
    end
    
    if not cust_tbl then
      cust_tbl = generate_custom_color_table()
    end
    
    
    -- WHEN MARKERS OR REGIONS MOVED --
    if items_mode == 3
      and (not cur_state5 or cur_state5 < init_state)
        and (Undo_CanUndo2(0)=='Move marker'
          or Undo_CanUndo2(0)=='Reorder region') then
      seen_msgs[1] = nil
      cur_state5 = init_state
    end 
    
  
    -- SWITCHING BETWEEN MODES ALONG WITH MARKERS AND REGIONS --

    -- MOUSE CLICK RULER --
    if rvs[3] ~= (seen_msgs[1] or 0)  then
      local _, ui_scale = reaper.get_config_var_string("uiscale")
      local sel_ruler, mouse_lane, region_lanes, marker_lanes  = GetRulerMouseContext(rvs[7], sys_scale, ui_scale)
      local version = tonumber(reaper.GetAppVersion():match('^[%d%.]+'))
      if version > 7.15 then
        GetSelectedMarkers(sel_ruler, mouse_lane, region_lanes, marker_lanes, rvs[3], test_item, sel_items)
      else
        GetMarkerUnderMouse(sel_ruler, mouse_lane, region_lanes, marker_lanes, sys_scale, ui_scale, sel_items)
        seen_msgs[1] = rvs[3]
        test_item = nil
      end 
        
    -- MOUSE CLICK MANAGER --
    elseif rvs4 ~= (seen_msgs[4] or 0) and (static_mode == 0 or static_mode == 3) then
      local win = select(4, IsManagerWindow())
      GetSelectedMarkers2(win)
      seen_msgs[4] = rvs4
      test_item = nil

    -- MOUSE CLICK ARRANGE --
    elseif rvs2 ~= (seen_msgs[2] or 0) and (static_mode == 0 or static_mode == 2) then
      if sel_items > 0 then
        test_take = GetActiveTake(test_item)
        test_track_it = GetMediaItemTrack(test_item)
        if (static_mode == 0 or static_mode == 2) then
          items_mode = 1
        end
      elseif sel_tracks > 0 then
        if static_mode == 0 then
          items_mode = 0
        end
      else
        if static_mode == 0 then
          items_mode = 2
        end
        sel_color = {}
      end
      seen_msgs[2] = rvs2
      
    -- MOUSE CLICK TCP --
    elseif rvs3 ~= (seen_msgs[3] or 0) and (static_mode == 0 or static_mode == 1)  then
      items_mode = 0
      seen_msgs[3] = rvs3
    end
    
    -- NON CLICKING CONDITIONS --
    if sel_tracks == 0 and sel_items == 0 and items_mode ~= 3 and static_mode == 0 then
      sel_color = {}
      palette_high = {main = {}, cust = {}}
      items_mode = 2
    elseif items_mode == nil and sel_items > 0 and static_mode == 0 then
      items_mode = 1
    elseif items_mode == nil and sel_tracks > 0 and sel_items == 0 and static_mode == 0 then
      items_mode = 0
    end
    
    
    -- CALLING FUNCTIONS -- 
    
    get_sel_items_or_tracks_colors(sel_items, sel_tracks, test_item, test_take, test_track) 
    do
      if selected_mode == 1 then
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
  
      if init_state ~= yes_undo and Undo_CanRedo2(0) and Undo_CanRedo2(0) ~= can_re and string.match(Undo_CanRedo2(0), "CHROMA:") then 
        yes_undo, it_cnt_sw, test_track_sw, col_tbl = init_state, nil
        can_re = Undo_CanRedo2(0) 
      end 
    end
   

    -- -- ==== MIDDLE PART ==== -- --
    
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding,2)    -- general rounding for color widgets
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 0)  -- first seperator upper space
    
    -- CUSTOM COLOR PALETTE --
    
    if show_custompalette then

      for m=1, #custom_palette do
        ImGui.PushID(ctx, m)
        if ((m - 1) % 24) ~= 0 then
          ImGui.SameLine(ctx, 0.0, 2)
        else 
          retval = ImGui.GetCursorPosY(ctx)
          ImGui.SetCursorPosY(ctx, retval -2)
        end
        local highlight2 = false
        local palette_button_flags2 =
                      ImGui.ColorEditFlags_NoPicker |
                      ImGui.ColorEditFlags_NoTooltip
        if palette_high.cust[m] == 1 then
          ImGui.PushStyleColor(ctx, ImGui.Col_Border,0xffffffff)
          ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize,2)
          highlight2 = true
        end
        if highlight2 == false then
          palette_button_flags2 = palette_button_flags2 | ImGui.ColorEditFlags_NoBorder
        end
        
        if ImGui.ColorButton(ctx, '##palette2', custom_palette[m], palette_button_flags2, size, size) then
          if custom_palette[m] ~= HSL((m-1) / 24+0.69, 0.1, 0.2, 1) then
            widgetscolorsrgba = custom_palette[m] -- needed for highlighting
            Undo_BeginBlock2(0) 
            coloring(sel_items, sel_tracks, cust_tbl.tr, cust_tbl.it, m) 
            sel_color[1] = custom_palette[m]

            if ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) and not ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) then
              if items_mode == 0 then
                first_stay = true
                Color_multiple_tracks_to_custom_palette(sel_tracks, first_stay) 
                first_stay = false
                col_tbl, sel_tracks2 = nil, nil
                Undo_EndBlock2(0, "CHROMA: Color multiple tracks to custom palette", 1+4)
              elseif items_mode == 1 then
                first_stay = true
                Color_multiple_items_to_custom_palette(sel_items, first_stay)
                first_stay = false
                it_cnt_sw = nil
                Undo_EndBlock2(0, "CHROMA: Color multiple items to custom palette", 4)
              end
            else
              if items_mode == 0 then
                col_tbl, sel_tracks2 = nil, nil
              elseif items_mode == 1 then
                it_cnt_sw = nil 
              end
              local undo_flag
              if items_mode == 3 then undo_flag = 8 else undo_flag = 1+4 end
              Undo_EndBlock2( 0, "CHROMA: Apply palette color", undo_flag) 
            end

            if check_one then
              if items_mode == 0 and selected_mode == 1 then
                generate_trackcolor_table(tr_cnt)
                tr_cnt_sw = tr_cnt 
              end
              check_two = true
              it_cnt_sw = sel_items
            end
          else
            ImGui.OpenPopupOnItemClick(ctx, 'Choose color', ImGui.PopupFlags_MouseButtonLeft)
             backup_color = rgba
          end
        end

        if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) and ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) then
          item_track_color_to_custom_palette(m)
        elseif ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
          if items_mode == 0 then
            shortcut_gradient(sel_tracks, test_track, custom_palette[m]) 
          elseif items_mode == 1 then
            it_cnt_sw = sel_items
            shortcut_gradient_items(sel_items, custom_palette[m]) 
          end

        elseif sel_tab and ImGui.Mod_None then
          sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil -- all variables should get nil
          if items_mode == 0 then
            col_tbl = nil
          end
        end
        
        local open_popup = ImGui.BeginPopup(ctx, 'Choose color')
        if not open_popup then
          ref_col = rgba
        else
          ref_col = ref_col
        end
        if open_popup then
          got_color, rgba = ImGui.ColorPicker4(ctx, '##Current', rgba, ImGui.ColorEditFlags_NoSidePreview | ImGui.ColorEditFlags_NoSmallPreview, ref_col)
          ImGui.SameLine(ctx, 255)
          ImGui.BeginGroup(ctx) -- Lock X position
          ImGui.Text(ctx, 'Current')
          ImGui.ColorButton(ctx, '##current2', rgba, ImGui.ColorEditFlags_NoPicker, 60, 40)
          ImGui.Dummy(ctx, 0, 1)
          ImGui.Text(ctx, 'Previous')
          if ImGui.ColorButton(ctx, '##previous', backup_color, ImGui.ColorEditFlags_NoPicker, 60, 40) then
            rgba = backup_color
          end
          
          if got_color then
            custom_color, widgetscolorsrgba, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_pal  = rgba, rgba, pre_cntrl.current_item, 1, false, nil
            custom_palette[m] = rgba 
            cust_tbl = nil 
          end
          ImGui.EndGroup(ctx) 
          ImGui.EndPopup(ctx)
        end
        
        if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and not ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) then
          custom_palette[m] = HSL((m-1) / 24+0.69, 0.1, 0.2, 1)
        end
        
        if highlight2 == true then
          ImGui.PopStyleColor(ctx,1)
          ImGui.PopStyleVar(ctx,1)
        end
         
        -- Allow user to drop colors into each palette entry. Note that ColorButton() is already a
        -- drag source by default, unless specifying the ImGuiColorEditFlags_NoDragDrop flag.
        if ImGui.BeginDragDropTarget(ctx) then
          local rv,drop_color = ImGui.AcceptDragDropPayloadRGBA(ctx)
          if rv then
            custom_palette[m] = drop_color 
            pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_pal = pre_cntrl.current_item, 1, false, nil
            cust_tbl = nil
          end
          ImGui.EndDragDropTarget(ctx)
        end
        ImGui.PopID(ctx)
      end
      
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize,3) 
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign, 1, 0.5)
      ImGui.SeparatorText(ctx, '  Custom Palette  ')
      ImGui.PopStyleVar(ctx, 2)
      ImGui.PopStyleColor(ctx,1)
    end

    ImGui.PopStyleVar(ctx,1)
    
    
    -- CUSTOM COLOR WIDGET --

    if show_edit then
      -- BORDERCOLOR FOR "EDIT CUSTOM COLOR" AND COLORPICKER --
      local rc, gc, bc, ac = ImGui.ColorConvertU32ToDouble4(rgba)
      local hc, sc, vc = ImGui.ColorConvertRGBtoHSV(rc, gc, bc)
      
      if button_color(hc, sc, vc, 1, 'Edit custom color', 146, 21, false, 2) then
        ImGui.OpenPopupOnItemClick(ctx, 'Choose color', ImGui.PopupFlags_MouseButtonLeft)
        backup_color2 = rgba
      end
      
      local open_popup = ImGui.BeginPopup(ctx, 'Choose color')
      if not open_popup then
        ref_col = rgba
      else
        ref_col = ref_col
      end
      if open_popup then
        got_color, rgba = ImGui.ColorPicker4(ctx, '##Current3', rgba, ImGui.ColorEditFlags_NoSidePreview | ImGui.ColorEditFlags_NoSmallPreview, ref_col)
        ImGui.SameLine(ctx, 255)
        ImGui.BeginGroup(ctx) -- Lock X position
        ImGui.Text(ctx, 'Current')
        ImGui.ColorButton(ctx, '##current3', rgba, ImGui.ColorEditFlags_NoPicker, 60, 40)
        ImGui.Dummy(ctx, 0, 1)
        ImGui.Text(ctx, 'Previous')
        if ImGui.ColorButton(ctx, '##previous2', backup_color2, ImGui.ColorEditFlags_NoPicker, 60, 40) then
          rgba = backup_color2
        end
        if got_color then
          custom_color, widgetscolorsrgba = rgba, rgba 
        end
        ImGui.EndGroup(ctx)
        ImGui.EndPopup(ctx)
      end
      ImGui.SameLine(ctx, -1, 159) -- overlapping items
      
      
  
      -- APPLY CUSTOM COLOR --
      
      if ImGui.ColorButton(ctx, 'Apply custom color##3', rgba, ImGui.ColorEditFlags_NoBorder, 21, 21)
        or ((Undo_CanUndo2(0)=='Insert media items'
          or Undo_CanUndo2(0)=='Recorded media')
            and (not cur_state or cur_state < init_state))
              and automode_id == 2  then
        local cur_state = init_state
        Undo_BeginBlock2(0)
        coloring_cust_col(sel_items, sel_tracks, rgba) 
        widgetscolorsrgba = rgba 

        if items_mode == 0 then
          col_tbl, sel_tracks2 = nil, nil
        elseif items_mode == 1 then
          it_cnt_sw = nil 
        end
        local undo_flag
        if items_mode == 3 then undo_flag = 8 else undo_flag = 1+4 end
        Undo_EndBlock2(0, "CHROMA: Apply custom color", undo_flag)

        if check_one then
          if items_mode == 0 and selected_mode == 1 then
            generate_trackcolor_table(tr_cnt)
            tr_cnt_sw = tr_cnt 
          end
          check_two = true
        end
      end
      ImGui.SameLine(ctx, 0.0, 17)
    end
    custom_color = rgba

    if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
      if items_mode == 0 then
        shortcut_gradient(sel_tracks, test_track, rgba) 
      elseif items_mode == 1 then
        shortcut_gradient_items(rgba)
      end
      
    elseif sel_tab and ImGui.Mod_None then
      sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil 
      if items_mode == 0 then
        col_tbl = nil
      end
    end
    
    -- Drag and Drop --
    if ImGui.BeginDragDropTarget(ctx) then
      local rv,drop_color = ImGui.AcceptDragDropPayloadRGBA(ctx)
      if rv then
        rgba = drop_color
      end
      ImGui.EndDragDropTarget(ctx)
    end
    
    local custom_color_flags =  
                   ImGui.ColorEditFlags_DisplayHSV
                  |ImGui.ColorEditFlags_NoSmallPreview
                  |ImGui.ColorEditFlags_NoBorder
                  |ImGui.ColorEditFlags_NoInputs
                  
    if widgetscolorsrgba then
      last_touched_color = widgetscolorsrgba
    else
      last_touched_color = custom_color
    end
    
   
    -- LAST TOUCHED --
    
    if show_lasttouched then
      ImGui.AlignTextToFramePadding(ctx)
      ImGui.Text(ctx,'Last touched:')
      ImGui.SameLine(ctx, 0.0, 4)
      if ImGui.ColorButton(ctx, 'Apply last color##6', last_touched_color, custom_color_flags, 21, 21) then
        Undo_BeginBlock2(0)
        coloring_cust_col(sel_items, sel_tracks, last_touched_color) 
        if items_mode == 0 then
          col_tbl, sel_tracks2 = nil, nil
        elseif items_mode == 1 then
          it_cnt_sw = nil 
        end
        local undo_flag
        if items_mode == 3 then undo_flag = 8 else undo_flag = 1+4 end
        Undo_EndBlock2(0, "CHROMA: Apply last touched color", undo_flag)
        if check_one then
          if items_mode == 0 and selected_mode == 1 then
            generate_trackcolor_table(tr_cnt)
            tr_cnt_sw = tr_cnt 
          end
          check_two = true
        end
      end
      if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
        if items_mode == 0 then
          shortcut_gradient(sel_tracks, test_track, last_touched_color) 
        elseif items_mode == 1 then
          shortcut_gradient_items(last_touched_color)
        end
      elseif sel_tab and ImGui.Mod_None then
        sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil 
        if items_mode == 0 then
          col_tbl = nil
        end
      end
    else
      ImGui.Dummy(ctx,0,0)
    end
    if show_edit == true or show_lasttouched == true then
      gap = -7 
    else gap = -3
    end
    
    if show_mainpalette then
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, gap)
      ImGui.Dummy(ctx,0,0)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 4)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize,3)
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign, 1, 0.5)
      ImGui.SeparatorText(ctx, '  Main Palette  ')
      ImGui.PopStyleVar(ctx,4) 
      ImGui.PopStyleColor(ctx, 1) 
    
      
      -- MAIN COLOR PALETTE --

      for n=1, #main_palette do
        ImGui.PushID(ctx, n)
        if ((n - 1) % 24) ~= 0 then
          ImGui.SameLine(ctx, 0.0, 2)
        else
          retval = ImGui.GetCursorPosY(ctx)
          ImGui.SetCursorPosY(ctx, retval -2)
        end
        local highlight = false
        local palette_button_flags =
                    ImGui.ColorEditFlags_NoPicker |
                    ImGui.ColorEditFlags_NoTooltip
        if palette_high.main[n] == 1 then
          ImGui.PushStyleColor(ctx, ImGui.Col_Border,0xffffffff)
          ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize,2)
          highlight = true
        end
        if highlight == false then
          palette_button_flags = palette_button_flags | ImGui.ColorEditFlags_NoBorder
        end
        
      -- MAIN PALETTE BUTTONS --
        
        if ImGui.ColorButton(ctx, '##palette', main_palette[n], palette_button_flags, size, size) then
          widgetscolorsrgba = main_palette[n] 
          Undo_BeginBlock2(0) 
          coloring(sel_items, sel_tracks, pal_tbl.tr, pal_tbl.it, n) 
          sel_color[1] = main_palette[n]
          if ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) and not ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) then
            if items_mode == 0 then
              first_stay = true
              Color_multiple_tracks_to_palette_colors(sel_tracks, first_stay) 
              first_stay = false
              col_tbl, sel_tracks2 = nil, nil
              Undo_EndBlock2(0, "CHROMA: Color multiple tracks to custom palette", 1+4)
            elseif items_mode == 1 then
              first_stay = true
              Color_multiple_items_to_palette_colors(sel_items, first_stay)
              first_stay = false
              it_cnt_sw = nil 
              Undo_EndBlock2(0, "CHROMA: Color multiple items to custom palette", 4)
            end
          else
            if items_mode == 0 then
              col_tbl, sel_tracks2 = nil, nil
            elseif items_mode == 1 then
              it_cnt_sw = nil 
            end
            local undo_flag
            if items_mode == 3 then undo_flag = 8 else undo_flag = 1+4 end
            Undo_EndBlock2(0, "CHROMA: Apply main_palette color", undo_flag)
          end
          -- 3rd cycle
          if check_one then
            if items_mode == 0 and selected_mode == 1 then
              generate_trackcolor_table(tr_cnt)                           
              tr_cnt_sw = tr_cnt                                    
            end
            check_two = true
          end
        end
        if ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift) then
          if items_mode == 0 then
            shortcut_gradient(sel_tracks, test_track, main_palette[n]) 
          elseif items_mode == 1 then
            shortcut_gradient_items(sel_items, main_palette[n]) 
          end
        elseif sel_tab and ImGui.Mod_None then
          sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil 
          if items_mode == 0 then
            col_tbl = nil
          end
        end
        if highlight == true then
          ImGui.PopStyleColor(ctx,1)
          ImGui.PopStyleVar(ctx,1)
        end
        ImGui.PopID(ctx)
      end
    end
    
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize,3) 
    ImGui.Dummy(ctx, 0, 12)
    ImGui.PopStyleVar(ctx,2) -- Item spacing and ?
    
    
    ---- -----
    ---- -----
      
    -- TRIGGER ACTIONS/FUNCTIONS VIA BUTTONS --
      
    if show_action_buttons then
      
      local bttn_h = 0.644
      local bttn_s = 0.45
      local bttn_v = 0.83
    
      local br_h = 0.558
      local br_s = 0.45
      local br_v = 0.33
    
      -- button calculations ..
      local divider = 14
      local bttn_gap = width2/(divider*5-1)
      local bttn_width = (width2/(divider*5-1))*(divider-1)
      local bttn_height = bttn_width/5*2
      
      ImGui.PushFont(ctx, buttons_font)
      
      if w >= 370+80/math.log(sys_scale+0.4) then 
        
        button_text2 = 'Color children\n     to parent'
        if items_mode == 1 then
          button_text1 = 'Set items to\ndefault color'
          button_text3 = 'Color items\n to gradient'
          button_text4 = 'Color items to\n main palette'
          button_text5 = 'Color items to\ncustom palette'
        else
          button_text1 = 'Set tracks to\ndefault color'
          button_text3 = ' Color tracks\n  to gradient'
          button_text4 = ' Color tracks to\n  main palette'
          button_text5 = 'Color tracks to\ncustom palette'
        end
      else
        button_text1 = 'Def. color' 
        button_text2 = 'Children'
        button_text3 = 'To gradient'
        button_text4 = 'To main'
        button_text5 = 'To custom'
      end
      
      ImGui.PushStyleColor(ctx, ImGui.Col_Text,0xffffffff) 

      if button_action(bttn_h, bttn_s, bttn_v, 1,  button_text1, bttn_width, bttn_height, true, 5,  br_h, br_s, br_v, 0.55, 5) then
        Reset_to_default_color(sel_items, sel_tracks) 
      end
      
      ImGui.SameLine(ctx, 0.0, bttn_gap)
      if button_action(bttn_h, bttn_s, bttn_v, 1, button_text2, bttn_width, bttn_height, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
        color_childs_to_parentcolor(sel_tracks, tr_cnt) 
      end
      
      ImGui.SameLine(ctx, 0.0, bttn_gap)
      if button_action(bttn_h, bttn_s, bttn_v, 1, button_text3, bttn_width, bttn_height, true, 5,  br_h, br_s, br_v, 0.55, 5) then
        if items_mode == 0 then
          local first_color = sel_color[1]
          local last_color = sel_color[#sel_color]
          Color_selected_tracks_with_gradient(sel_tracks, test_track, first_color, last_color)
          col_tbl, sel_tracks2 = nil, nil
        elseif items_mode == 1 then
          local first_color = sel_color[1]
          local last_color = sel_color[#sel_color]
          Color_selected_items_with_gradient(sel_items, test_item, first_color, last_color)
          it_cnt_sw = nil 
        end
      end
      
      ImGui.SameLine(ctx, 0.0, bttn_gap)
      if button_action(bttn_h, bttn_s, bttn_v, 1, button_text4, bttn_width, bttn_height, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
        Undo_BeginBlock2(0) 
        if items_mode == 0 then
          Color_multiple_tracks_to_palette_colors(sel_tracks) 
          col_tbl, sel_tracks2 = nil, nil
          Undo_EndBlock2(0, "CHROMA: Color multiple tracks to palette colors", 1+4)
        elseif items_mode == 1 then
          Color_multiple_items_to_palette_colors(sel_items)
          it_cnt_sw = nil 
          Undo_EndBlock2(0, "CHROMA: Color multiple items to palette colors", 4)
        end
      end
      
      ImGui.SameLine(ctx, 0.0, bttn_gap)
      if button_action(bttn_h, bttn_s, bttn_v, 1, button_text5, bttn_width, bttn_height, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
        Undo_BeginBlock2(0) 
        if items_mode == 0 then
          Color_multiple_tracks_to_custom_palette(sel_tracks)
          col_tbl, sel_tracks2 = nil, nil
          Undo_EndBlock2(0, "CHROMA: Color multiple tracks to custom palette", 1+4)
        elseif items_mode == 1 then
          Color_multiple_items_to_custom_palette(sel_items)
          it_cnt_sw = nil
          Undo_EndBlock2(0, "CHROMA: Color multiple items to custom palette", 4)
        end
      end
      ImGui.PopStyleColor(ctx)
      ImGui.PopFont(ctx) 
    end
  end -- END OF GUI
    
  -----------------------------------
  -----------------------------------
  
  
  
  local function CollapsedPalette(init_state)
  
    -- CHECK FOR PROJECT TAP CHANGE --
    local cur_project = getProjectTabIndex()
    
    if cur_project ~= old_project then
      old_project, track_number_sw, col_tbl, cur_state4 = cur_project, nil
    end
  
    -- DEFINE "GLOBAL" VARIABLES --
    
    local sel_items = CountSelectedMediaItems(0)
    local sel_tracks = CountSelectedTracks(0)
    local test_track = GetSelectedTrack(0, 0)
    if (sel_tracks == 0 or GetCursorContext2(true) ~= 0) and sel_items > 0 then 
      test_item = GetSelectedMediaItem(0, 0) 
      test_take = GetActiveTake(test_item)
      test_track_it = GetMediaItemTrack(test_item)
      items_mode = 1
    elseif sel_tracks > 0 then
      items_mode, test_item_sw, test_item = 0, nil
    else 
      sel_color = {}
      items_mode, test_track_sw, test_item_sw, test_item = 2, nil
    end
    
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
    
    if not main_palette then
      main_palette = Palette()
      pal_tbl = generate_palette_color_table()
    end
    
    if not cust_tbl then
      cust_tbl = generate_custom_color_table()
    end
    
    -- CALLING FUNCTIONS --
    
    get_sel_items_or_tracks_colors(sel_items, sel_tracks,test_item, test_take, test_track)
    
    if selected_mode == 1 then
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
  
  
  
  local function save_current_settings()
  
    SetExtState(script_name ,'selected_mode',   tostring(selected_mode),true)
    SetExtState(script_name ,'colorspace',      tostring(colorspace),true)
    SetExtState(script_name ,'dont_ask',        tostring(dont_ask),true)
    SetExtState(script_name ,'automode_id',     tostring(automode_id),true)
    SetExtState(script_name ,'saturation',      tostring(saturation),true)
    SetExtState(script_name ,'lightness',       tostring(lightness),true)
    SetExtState(script_name ,'darkness',        tostring(darkness),true)
    SetExtState(script_name ,'rgba',            tostring(rgba),true)
    SetExtState(script_name ,'custom_palette',  table.concat(custom_palette,","),true)
    SetExtState(script_name ,'random_custom',   tostring(random_custom),true)
    SetExtState(script_name ,'random_main',     tostring(random_main),true)
    SetExtState(script_name ,'auto_trk',        tostring(auto_trk),true)
    SetExtState(script_name ,'show_custompalette',   tostring(show_custompalette),true)
    SetExtState(script_name ,'show_edit',            tostring(show_edit),true)
    SetExtState(script_name ,'show_lasttouched',     tostring(show_lasttouched),true)
    SetExtState(script_name ,'show_mainpalette',     tostring(show_mainpalette),true)
    SetExtState(script_name ,'show_action_buttons',  tostring(show_action_buttons),true)
    SetExtState(script_name ,'current_item',         tostring(pre_cntrl.current_item),true)
    SetExtState(script_name ,'current_main_item',    tostring(pre_cntrl.current_main_item),true)
    SetExtState(script_name ,'auto_custom',          tostring(auto_custom),true)
    SetExtState(script_name ,'tree_node_open_save',  tostring(set_cntrl.tree_node_open_save),true)
    SetExtState(script_name ,'tree_node_open_save2', tostring(set_cntrl.tree_node_open_save2),true)
    SetExtState(script_name ,'tree_node_open_save3', tostring(set_cntrl.tree_node_open_save3),true)
    SetExtState(script_name ,'stop',                 tostring(pre_cntrl.stop),true)
    SetExtState(script_name ,'stop2',                tostring(pre_cntrl.stop2),true)
    SetExtState(script_name ,'background_color_mode',tostring(set_cntrl.background_color_mode),true)
  end
  
 

  -- PUSH STYLE COLOR AND VAR COUNTING --

  local function push_style_color()

    local n = 0
    ImGui.PushStyleColor(ctx, ImGui.Col_TitleBgActive, 0x1b3542ff) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_FrameBg , 0x1b3542ff) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_SliderGrab, 0x47aaaaff) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_CheckMark, 0x9eff59ff) n=n+1
    
    if set_cntrl.background_color_mode then
      local theme_color = reaper.ImGui_ColorConvertNative(reaper.GetThemeColor('col_main_bg2', -1))
      local theme_color = (theme_color << 8) | 0xFF 
      ImGui.PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), theme_color) n=n+1
    end
    return n
  end



  local function push_style_var(pad) 

    local m = 0
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding,12) m=m+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowPadding, pad, 6) m=m+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowTitleAlign,0.5, 0.5) m=m+1
    return m
  end



  -- LOOP -- MAIN FUNCTION --

  local function loop()

    if want_font_size ~= font_size then
      if buttons_font then reaper.ImGui_Detach(ctx, buttons_font) end
      buttons_font = ImGui.CreateFont('sans-serif', want_font_size)
      font_size = want_font_size
      ImGui.Attach(ctx, buttons_font)
    end
    
    ImGui.PushFont(ctx, sans_serif)
    local pad = 16 -- window padding (border)
    local window_flags = ImGui.WindowFlags_None 
    local style_color_n = push_style_color()
    local style_var_m = push_style_var(pad)
    ImGui.SetNextWindowSize(ctx, 641, 377, ImGui.Cond_FirstUseEver)
    local visible, open = ImGui.Begin(ctx, 'Chroma - Coloring Tool', true, window_flags)
    local init_state = GetProjectStateChangeCount(0)
    if visible then
      want_font_size = max(ImGui.GetContentRegionAvail(ctx)//40, (18-math.exp(reaper.ImGui_GetWindowDpiScale(ctx)))//1) 
      ColorPalette(init_state, pad) 
      ImGui.End(ctx)
    else
      CollapsedPalette(init_state)
    end
    ImGui.PopFont(ctx)
    ImGui.PopStyleColor(ctx, style_color_n)
    ImGui.PopStyleVar(ctx, style_var_m)
    if ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) then open = false end -- Escape Key
    if ImGui.IsKeyPressed(ctx, ImGui.Mod_Ctrl) and ImGui.IsKeyPressed(ctx, ImGui.Key_Z) then reaper.Undo_DoUndo2( 0 ) end
    if open then
      defer(loop)
    end
  end
  
  
  -- EXECUTE --

  defer(loop)
  
  reaper.atexit(save_current_settings)

  reaper.atexit(function()
    reaper.JS_WindowMessage_Release(ruler_win, msgs)
    reaper.JS_WindowMessage_Release(arrange, msgs)
    reaper.JS_WindowMessage_Release(TCPDisplay, msgs)
    reaper.JS_WindowMessage_Release(RegionManager, msgs2)
  end)
