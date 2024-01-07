-- @description Chroma - Coloring Tool
-- @author olshalom, vitalker
-- @version 0.8.1
-- @changelog
--   0.8.1
--   NEW features:
--     > Save/Load Main Palette Presets
--     > Improved saving of "Last unsaved" presets (backup)
--  
--   Appearance:
--     > Redesigned Menubar
--
--
--   0.8.0
--   Bug fixes:
--     > Tooltip bug fix for Palette Menu (p=2746078)
--
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
--     > Shift + Command/Control: Gradient Shortcut for automatically make a gradient for selected items/tracks (in two steps)
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
  
  
  
  local OS = reaper.GetOS()
  local sys_offset 
  if OS:find("OSX") or OS:find("macOS") then
    sys_offset = 0
  else 
    sys_offset = 30
  end
  
  
  
  local function OpenURL(url)
    if type(url)~="string" then return false end
    if OS=="OSX32" or OS=="OSX64" or OS=="macOS-arm64" then
      os.execute("open ".. url)
    elseif OS=="Other" then
      os.execute("xdg-open "..url)
    else
      os.execute("start ".. url)
    end
    return true
  end
  
  

  local script_name = 'Chroma - Coloring Tool'
  if not reaper.APIExists('ImGui_CreateContext') then
    reaper.ShowMessageBox('Install\nReaImGui: ReaScript binding for Dear ImGui\nto make the script work', script_name, 0)
    if reaper.APIExists('ReaPack_BrowsePackages') then
      reaper.ReaPack_BrowsePackages('ReaImGui: ReaScript binding for Dear ImGui')
      return
    else
      OpenURL('https://forum.cockos.com/showthread.php?t=250419')
      return
    end
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
  local time_precise = reaper.time_precise            
  local CountMediaItems = reaper.CountMediaItems      
  local GetMediaItem = reaper.GetMediaItem            
  local GetMediaItemNumTakes = reaper.GetMediaItemNumTakes

  local insert = table.insert
  local floor = math.floor
  local max = math.max
  local min = math.min


  -- ImGui
  
  local ImGui = {}
  
  ImGui.ColorEditFlags_DisplayHSV = reaper.ImGui_ColorEditFlags_DisplayHSV
  ImGui.ColorConvertHSVtoRGB = reaper.ImGui_ColorConvertHSVtoRGB
  ImGui.ColorConvertRGBtoHSV = reaper.ImGui_ColorConvertRGBtoHSV
  ImGui.ColorConvertNative = reaper.ImGui_ColorConvertNative
  ImGui.ColorConvertDouble4ToU32 = reaper.ImGui_ColorConvertDouble4ToU32
  ImGui.GetWindowSize = reaper.ImGui_GetWindowSize
  ImGui.PushStyleVar = reaper.ImGui_PushStyleVar
  ImGui.PushStyleColor = reaper.ImGui_PushStyleColor
  ImGui.StyleVar_FrameRounding = reaper.ImGui_StyleVar_FrameRounding
  ImGui.StyleVar_GrabRounding = reaper.ImGui_StyleVar_GrabRounding
  ImGui.StyleVar_PopupRounding = reaper.ImGui_StyleVar_PopupRounding
  ImGui.StyleVar_ItemSpacing = reaper.ImGui_StyleVar_ItemSpacing
  ImGui.StyleVar_FrameBorderSize = reaper.ImGui_StyleVar_FrameBorderSize
  ImGui.Col_Border = reaper.ImGui_Col_Border
  ImGui.BeginMenuBar = reaper.ImGui_BeginMenuBar
  ImGui.BeginMenu = reaper.ImGui_BeginMenu
  ImGui.AlignTextToFramePadding = reaper.ImGui_AlignTextToFramePadding
  ImGui.Text = reaper.ImGui_Text
  ImGui.PushItemWidth = reaper.ImGui_PushItemWidth
  ImGui.Col_BorderShadow = reaper.ImGui_Col_BorderShadow
  ImGui.BeginCombo = reaper.ImGui_BeginCombo
  ImGui.Selectable = reaper.ImGui_Selectable
  ImGui.SetItemDefaultFocus = reaper.ImGui_SetItemDefaultFocus
  ImGui.SameLine = reaper.ImGui_SameLine
  ImGui.EndCombo = reaper.ImGui_EndCombo
  ImGui.PopStyleColor = reaper.ImGui_PopStyleColor
  ImGui.RadioButtonEx = reaper.ImGui_RadioButtonEx
  ImGui_Viewport_GetCenter = reaper.ImGui_Viewport_GetCenter
  ImGui.GetWindowViewport = reaper.ImGui_GetWindowViewport
  ImGui.OpenPopup = reaper.ImGui_OpenPopup
  ImGui.EndMenu = reaper.ImGui_EndMenu
  ImGui.EndMenuBar = reaper.ImGui_EndMenuBar
  ImGui.SetNextWindowPos = reaper.ImGui_SetNextWindowPos
  ImGui.Button = reaper.ImGui_Button
  ImGui.BeginPopupModal = reaper.ImGui_BeginPopupModal
  ImGui.Separator = reaper.ImGui_Separator
  ImGui.SeparatorText = reaper.ImGui_SeparatorText
  ImGui.Checkbox = reaper.ImGui_Checkbox
  ImGui.CloseCurrentPopup = reaper.ImGui_CloseCurrentPopup
  ImGui.EndPopup = reaper.ImGui_EndPopup
  ImGui.ColorConvertU32ToDouble4 = reaper.ImGui_ColorConvertU32ToDouble4
  ImGui.OpenPopupOnItemClick = reaper.ImGui_OpenPopupOnItemClick
  ImGui.WindowFlags_MenuBar = reaper.ImGui_WindowFlags_MenuBar
  ImGui.Dummy = reaper.ImGui_Dummy 
  ImGui.SliderDouble = reaper.ImGui_SliderDouble
  ImGui.SliderDouble2 = reaper.ImGui_SliderDouble2
  ImGui.SliderFlags_None = reaper.ImGui_SliderFlags_None
  ImGui.Col_Text = reaper.ImGui_Col_Text
  ImGui.PopStyleVar = reaper.ImGui_PopStyleVar
  ImGui.PushID = reaper.ImGui_PushID
  ImGui.GetCursorPosY = reaper.ImGui_GetCursorPosY
  ImGui.SetCursorPosY = reaper.ImGui_SetCursorPosY
  ImGui.ColorEditFlags_NoPicker = reaper.ImGui_ColorEditFlags_NoPicker
  ImGui.ColorEditFlags_NoTooltip = reaper.ImGui_ColorEditFlags_NoTooltip
  ImGui.ColorEditFlags_NoBorder = reaper.ImGui_ColorEditFlags_NoBorder
  ImGui.ColorButton = reaper.ImGui_ColorButton
  ImGui.BeginDragDropTarget = reaper.ImGui_BeginDragDropTarget
  ImGui.AcceptDragDropPayloadRGBA = reaper.ImGui_AcceptDragDropPayloadRGBA
  ImGui.EndDragDropTarget = reaper.ImGui_EndDragDropTarget
  ImGui.PopID = reaper.ImGui_PopID
  ImGui.StyleVar_SeparatorTextBorderSize = reaper.ImGui_StyleVar_SeparatorTextBorderSize
  ImGui.PopupFlags_MouseButtonLeft = reaper.ImGui_PopupFlags_MouseButtonLeft
  ImGui.BeginPopup = reaper.ImGui_BeginPopup
  ImGui.ColorPicker4 = reaper.ImGui_ColorPicker4
  ImGui.ColorEditFlags_NoSmallPreview = reaper.ImGui_ColorEditFlags_NoSmallPreview
  ImGui.ColorEditFlags_NoDragDrop = reaper.ImGui_ColorEditFlags_NoDragDrop
  ImGui.ColorEditFlags_NoInputs = reaper.ImGui_ColorEditFlags_NoInputs
  ImGui.Col_TitleBgActive = reaper.ImGui_Col_TitleBgActive
  ImGui.Col_FrameBg = reaper.ImGui_Col_FrameBg
  ImGui.Col_SliderGrab = reaper.ImGui_Col_SliderGrab
  ImGui.Col_CheckMark = reaper.ImGui_Col_CheckMark
  ImGui.StyleVar_WindowRounding = reaper.ImGui_StyleVar_WindowRounding
  ImGui.StyleVar_WindowTitleAlign = reaper.ImGui_StyleVar_WindowTitleAlign
  ImGui.PushFont = reaper.ImGui_PushFont
  ImGui.WindowFlags_None = reaper.ImGui_WindowFlags_None
  ImGui.SetNextWindowSize = reaper.ImGui_SetNextWindowSize
  ImGui.Cond_FirstUseEver = reaper.ImGui_Cond_FirstUseEver
  ImGui.Begin = reaper.ImGui_Begin
  ImGui.End = reaper.ImGui_End
  ImGui.PopFont = reaper.ImGui_PopFont
  ImGui.IsKeyDown = reaper.ImGui_IsKeyDown
  ImGui.Mod_Shortcut = reaper.ImGui_Mod_Shortcut
  ImGui.Col_Button = reaper.ImGui_Col_Button
  ImGui.Col_ButtonHovered = reaper.ImGui_Col_ButtonHovered
  ImGui.Col_ButtonActive = reaper.ImGui_Col_ButtonActive
  ImGui.GetWindowPos = reaper.ImGui_GetWindowPos
  ImGui.SmallButton = reaper.ImGui_SmallButton
  ImGui.Col_FrameBgHovered = reaper.ImGui_Col_FrameBgHovered
  ImGui.BeginGroup = reaper.ImGui_BeginGroup
  ImGui.EndPopup = reaper.ImGui_EndPopup
  ImGui.Mod_Shift = reaper.ImGui_Mod_Shift                      
  ImGui.Attach = reaper.ImGui_Attach                            
  ImGui.CreateContext = reaper.ImGui_CreateContext              
  ImGui.CreateFont = reaper.ImGui_CreateFont                    
  ImGui.GetWindowDrawList = reaper.ImGui_GetWindowDrawList      
  ImGui.IsItemClicked = reaper.ImGui_IsItemClicked              
  ImGui.MouseButton_Left = reaper.ImGui_MouseButton_Left        
  ImGui.SetNextItemOpen = reaper.ImGui_SetNextItemOpen          
  ImGui.Cond_Once = reaper.ImGui_Cond_Once                      
  ImGui.TreeNode = reaper.ImGui_TreeNode                        
  ImGui.TreePop = reaper.ImGui_TreePop                          
  ImGui.IsItemToggledOpen = reaper.ImGui_IsItemToggledOpen      
  ImGui.StyleVar_SeparatorTextAlign = reaper.ImGui_StyleVar_SeparatorTextAlign      
  ImGui.Cond_Appearing = reaper.ImGui_Cond_Appearing                                
  ImGui.WindowFlags_AlwaysAutoResize = reaper.ImGui_WindowFlags_AlwaysAutoResize    
  ImGui.WindowFlags_NoCollapse = reaper.ImGui_WindowFlags_NoCollapse                
  ImGui.WindowFlags_NoDocking = reaper.ImGui_WindowFlags_NoDocking                  
  ImGui.SelectableFlags_None = reaper.ImGui_SelectableFlags_None                    
  ImGui.MouseButton_Right = reaper.ImGui_MouseButton_Right                          
  ImGui.EndGroup = reaper.ImGui_EndGroup                                            
  ImGui.ColorEditFlags_NoSidePreview = reaper.ImGui_ColorEditFlags_NoSidePreview    
  ImGui.Mod_None = reaper.ImGui_Mod_None                                            
  ImGui.GetContentRegionAvail = reaper.ImGui_GetContentRegionAvail                  
  ImGui.GetWindowDpiScale = reaper.ImGui_GetWindowDpiScale                          
  ImGui.IsKeyPressed = reaper.ImGui_IsKeyPressed                                    
  ImGui.Key_Escape = reaper.ImGui_Key_Escape                                        
  ImGui.Key_Z = reaper.ImGui_Key_Z                                                  
  
  
  
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
  local user_palette = {}
  local auto_pal 
  local auto_custom
  local auto_palette
  local sel_tab
  local userpalette = {}
  local user_mainpalette = {}
  local user_main_settings = {}
  
 

  -- PREDEFINE VALUES AS LOCAL--

  local sel_items = 0
  local sel_tracks = 0 
  local itemcolor  
  local test_take
  local test_track
  local test_item
  local test_item_sw
  local item_sw
  local track_sw
  local test_track_sw
  local sel_tracks2 = 0      
  local sel_items_sw
  local it_cnt_sw 
  local combo_items = { '   Track color', ' Custom color' }
  local tr_txt = '##No_selection' 
  local tr_txt_h = 0.555
  local automode_id
  local colorspace
  local colorspace_sw
  local dont_ask
  local items_mode
  local lightness
  local darkness
  local random_custom
  local random_main
  local retval
  local saturation
  local rgba
  local selected_mode
  local old_project
  local widgetscolorsrgba
  local track_number_sw
  local auto_trk
  local current_item = 1
  local cur_state3
  local tr_cnt_sw
  local stored_val            
  local state2                
  local check_one             
  local found                 
  local button_text1           
  local button_text2          
  local button_text3           
  local button_text4          
  local button_text5          
  local gap                   
  local custom_color          
  local last_touched_color    
  local ref_col               
  local tree_node_open        
  local remainder             
  local show_action_buttons   
  local show_custompalette         
  local show_edit             
  local show_lasttouched      
  local show_mainpalette
  local hovered_preset = ' '
  local hovered_main_preset = ' '
  local sys_offset
  local draw_thickness
  local set_pos
  local sat_true
  local contrast_true
  local current_main_item
  local combo_preview_value
  local not_inst
  local stop
  local stop2
  local main_combo_preview_value
  local differs
  local differs2
  local differs3
  local yes_undo
  local _

  -- CONSOLE OUTPUT --
  
  local function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
  end
 
 
 
  if not reaper.APIExists('SNM_GetIntConfigVar') then
    not_inst = true
  end
  
  
  
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
  
  
  
  local function HSL(h, s, l, a)
  
    local r, g, b = hslToRgb(h, s, l)
    return ImGui.ColorConvertDouble4ToU32(r, g, b, a or 1.0)
  end
  
  

  local function rgbToHsl(r, g, b)

    local max, min = max(r, g, b), min(r, g, b)
    local b = max + min
    local h = b / 2
    if max == min then return 0, 0, h end
    local s, l = h, h
    local d = max - min
    local s = l > .5 and d / (2 - b) or d / b
    if max == r then h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    return h * .16667, s, l
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
    if reaper.GetExtState(script_name, "tree_node_open_save") == "false" then tree_node_open = false end
    if reaper.GetExtState(script_name, "tree_node_open_save") == "true" then tree_node_open = true end
  else tree_node_open = false end
  
  if reaper.HasExtState(script_name, "tree_node_open_save2") then
    if reaper.GetExtState(script_name, "tree_node_open_save2") == "false" then tree_node_open2 = false end
    if reaper.GetExtState(script_name, "tree_node_open_save2") == "true" then tree_node_open2 = true end
  else tree_node_open2 = false end
  
  if reaper.HasExtState(script_name, "user_palette") then
    local serialized2 = reaper.GetExtState(script_name, "user_palette")
    user_palette = stringToTable(serialized2) 
  else
    insert(user_palette, '*Last unsaved*')
    reaper.SetExtState(script_name , 'userpalette.*Last unsaved*',  table.concat(custom_palette,","),true)
  end

  if reaper.HasExtState(script_name, "current_item") then
    current_item = tonumber(reaper.GetExtState(script_name, "current_item"))
  else current_item = 1 end
  
  if reaper.HasExtState(script_name, "user_mainpalette") then
    local serialized2 = reaper.GetExtState(script_name, "user_mainpalette")
    user_mainpalette = stringToTable(serialized2) 
  else
    insert(user_mainpalette, '*Last unsaved*')
    user_main_settings = {}
    user_main_settings[1] = colorspace
    user_main_settings[2] = saturation
    user_main_settings[3] = lightness
    user_main_settings[4] = darkness
    local serialized = serializeTable(user_mainpalette)
    reaper.SetExtState(script_name , 'user_mainpalette', serialized, true )
    reaper.SetExtState(script_name , 'usermainpalette.*Last unsaved*',  table.concat(user_main_settings,","),true)
  end
  
  if reaper.HasExtState(script_name, "current_main_item") then
    current_main_item = tonumber(reaper.GetExtState(script_name, "current_main_item"))
    if current_main_item == nil then current_main_item = 1 end
  else current_main_item = 1 end
  
  if reaper.HasExtState(script_name, "stop") then
    if reaper.GetExtState(script_name, "stop") == "false" then stop = false end
    if reaper.GetExtState(script_name, "stop") == "true" then
      stop = true 
      new_combo_preview_value = user_palette[current_item]..' (modified)'
    end
  else stop = false end
  
  if reaper.HasExtState(script_name, "stop2") then
    if reaper.GetExtState(script_name, "stop2") == "false" then stop2 = false end
    if reaper.GetExtState(script_name, "stop2") == "true" then 
      stop2 = true 
      main_combo_preview_value = user_mainpalette[current_main_item]..' (modified)'
    end
  else stop2 = false end
  


  -- IMGUI CONTEXT --
  
  local ctx = ImGui.CreateContext(script_name) 
  local sans_serif = ImGui.CreateFont('sans-serif', 15)
  local buttons_font, font_size 
  local want_font_size = 15 
  ImGui.Attach(ctx, sans_serif)
  local openSettingWnd = false
  
  
  
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
      generated_color, differs, differs2, stop = nil, current_item, 1, nil
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
    end
    generated_color, differs, differs2, stop = nil, current_item, 1, nil
    cust_tbl = nil
    return custom_palette
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
    end
    generated_color, differs, differs2, stop = nil, current_item, 1, nil
    cust_tbl = nil
    return custom_palette
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
    end
    generated_color, differs, differs2, stop = nil, current_item, 1, nil
    cust_tbl = nil
    return custom_palette
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
    end
    generated_color, differs, differs2, stop = nil, current_item, 1, nil
    cust_tbl = nil
    return custom_palette
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

    if sel_items > 0 and (test_take2 ~= test_take or sel_items ~= it_cnt_sw or test_item_sw ~= test_item) then
      items_mode = 1
      sel_color = {}
      sel_tbl = {it = {}, tke = {}, tr = {}, it_tr = {}}
      move_tbl = {it = {}, trk_ip = {}}
      local index, tr_index, it_index, sel_index, tr_ip, same_col  = 0, 0, 0, 0

      for i=0, sel_items -1 do
        local itemcolor
        local different
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
              if different or not tr_ip then
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
          sel_index, itemcolor_sw = sel_index+1, itemcolor
          sel_color[sel_index] = IntToRgba(itemcolor)
        end
      end
      test_track_sw, itemtrack2, test_take2, test_item_sw, itemcolor_sw = nil, nil, test_take, test_item, nil   
      it_cnt_sw = sel_items
      col_found = nil
      track_sw = test_track_it
      
    elseif sel_tracks > 0 and (test_track_sw ~= test_track or sel_tracks2 ~= sel_tracks) and items_mode == 0 then 
      sel_color = {}
      for i=0, sel_tracks -1 do
        test_track_sw, sel_tracks2 = test_track, sel_tracks
        local track = GetSelectedTrack(0,i)
        sel_tbl.tr[i+1] = track
        sel_color[i+1] = IntToRgba(GetTrackColor(track)) 
      end
    end
    return sel_color, move_tbl
  end
  
  
  
  -- FUNCTIONS FOR VARIOUS COLORING --
  --________________________________--
  
  
  -- caching trackcolors -- (could be extended and refined with a function written by justin)
  local function generate_trackcolor_table(tr_cnt)
    
    col_tbl = {it={}, tr={}, tr_int={}}
    local index=0
    for i=0, tr_cnt -1 do
      index = index+1
      local trackcolor = GetTrackColor(GetTrack(0,i))
      col_tbl.tr[index] = IntToRgba(trackcolor)
      col_tbl.it[index] = background_color_native(trackcolor)
      col_tbl.tr_int[index] = trackcolor
    end 
    return col_tbl
  end
  
  
  
  -- COLOR ITEMS TO TRACK COLOR IN SHINYCOLORS MODE WHEN MOVING --
  
  local function automatic_item_coloring(init_state) -- moving items

    local local_ip
    if test_item and sel_items < 60001 then
      local track1 = GetMediaItemTrack(test_item)
      if item_sw == test_item and track_sw ~= track1 then
        PreventUIRefresh(1)
        for x=1, #move_tbl.it do
          if move_tbl.trk_ip[x] == move_tbl.trk_ip[x-1] then
            SetMediaItemInfo_Value(move_tbl.it[x],"I_CUSTOMCOLOR", col_tbl.it[local_ip])
          else
            local_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(move_tbl.it[x]), "IP_TRACKNUMBER")
            SetMediaItemInfo_Value(move_tbl.it[x], "I_CUSTOMCOLOR", col_tbl.it[local_ip])
          end
        end
        it_cnt_sw = nil
        cur_state3, track_sw = cur_state2, track1
        UpdateArrange()
        PreventUIRefresh(-1)
        
      else
        if not track_sw then
          track_sw = track1
        end
        item_sw = test_item             
      end
      
    elseif test_item and sel_items > 60000 then   -- change colors after undopoint
      local local_ip
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
  end
  
  -- COLOR TAKES IN SHINYCOLORS MODE --
  
  local function reselect_take(init_state)
  
    local takelane_mode = reaper.SNM_GetIntConfigVar("projtakelane", 1)
    
    if (takelane_mode == 1 or takelane_mode == 3) and takelane_mode ~= takelane_mode2 then
      PreventUIRefresh(1)
      local item_count = CountMediaItems(0)
      for i = 0, CountMediaItems(0) -1 do
        local item = GetMediaItem(0, i)
        local tke_num = GetMediaItemNumTakes(item)
        if tke_num > 1 then
          local back2 = ImGui.ColorConvertNative(HSV(1, 0, 0.7, 1.0) >> 8)|0x1000000
          SetMediaItemInfo_Value(item ,"I_CUSTOMCOLOR", back2) 
        end
      end
      PreventUIRefresh(-1)
      UpdateArrange()
      takelane_mode2 = takelane_mode
    elseif (takelane_mode == 0 or takelane_mode == 2) and takelane_mode ~= takelane_mode2 then
      PreventUIRefresh(1)
      for i = 0, CountMediaItems(0) -1 do
        local item = GetMediaItem(0, i)
        local tke_num = GetMediaItemNumTakes(item)
        if tke_num > 1 then
          local take = GetActiveTake(item)
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
      PreventUIRefresh(-1)
      UpdateArrange()
      takelane_mode2 = takelane_mode
    end
    
    if (takelane_mode == 0 or takelane_mode == 2)
      and (Undo_CanUndo2(0)=='Change active take'
        or Undo_CanUndo2(0)=='Previous take'
          or Undo_CanUndo2(0)=='Next take')
            and init_state ~= cur_state then
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
      
  local function Color_new_items_automatically(init_state)
    
    if ((Undo_CanUndo2(0)=='Insert new MIDI item'
        or Undo_CanUndo2(0)=='Insert media items'
          or Undo_CanUndo2(0)=='Recorded media'
            or Undo_CanUndo2(0)=='Insert empty item')
              and (not cur_state4 or cur_state4<init_state)) 
                and automode_id == 1 then
      PreventUIRefresh(1) 
      cur_state4 = init_state
      for i=0, sel_items -1 do
        local tr_ip = GetMediaTrackInfo_Value(sel_tbl.it_tr[i+1], "IP_TRACKNUMBER")
        SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", col_tbl.it[tr_ip] )
      end
      UpdateArrange()
      PreventUIRefresh(-1) 
    end
  end



  -- COLOR SELECTED ITEMS TO TRACK COLOR --

  local function Reset_to_default_color() 
  
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
  
  local function coloring(tbl_tr, tbl_it, clr_key) 
    
    PreventUIRefresh(1) 
    if items_mode == 1 then
      if ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) 
          and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) then
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
      if ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) 
          and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) then
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
    end
    UpdateArrange()
    PreventUIRefresh(-1)
  end
  

  
  -- COLORING FOR CUSTOM COLOR AND LAST TOUCHED -- 
  
  local function coloring_cust_col(in_color) 
  
    PreventUIRefresh(1) 
    if in_color then
      local color = ImGui.ColorConvertNative(in_color >>8)|0x1000000
      local background_color = Background_color_rgba(in_color)
      if items_mode == 1 then
        if ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) 
            and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) then
          
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

        if ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut())
            and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) then
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
        local value_r, value_g, value_b = floor(0.5+firstcolor_r*255+r_step*i), floor(0.5+firstcolor_g*255+g_step*i), floor(0.5+firstcolor_b*255+b_step*i) 
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
        local value_r, value_g, value_b = floor(0.5+firstcolor_r*255+r_step*i), floor(0.5+firstcolor_g*255+g_step*i), floor(0.5+firstcolor_b*255+b_step*i)
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

  
  
  -- Thanks Embass for this function! --
   
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
  
  
 
  -- COLOR CHILDS TO PARENTCOLOR -- Thanks to ChMaha for this function
   
  local function color_childs_to_parentcolor(tr_cnt)
  
    PreventUIRefresh(1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    for i=0, sel_tracks -1 do
      track = GetSelectedTrack(0,i)
      trackcolor = GetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR")
      ip = GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
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
    local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b, 1.0)
    local s=s/3.7
    local v=v+0.5
    if v > 0.88 then v = 0.88 end
    local background_color = ImGui.ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end
  
  
  
  -- PREPARE BACKGROUND COLOR FOR SHINYCOLORS MODE INTEGER --
  
  function background_color_native(color)
  
    local r, g, b = ColorFromNative(color)
    local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b, 1.0)
    local s=s/3.7
    local v=v+0.5
    if v > 0.88 then v = 0.88 end
    local background_color = ImGui.ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end
  
  
  
   -- PREPARE BACKGROUND COLOR FOR SHINYCOLORS MODE R, G, B --
  
  function Background_color_R_G_B(r,g,b)
  
    local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b, 1.0)
    local s=s/3.7
    local v=v+0.5
    if v > 0.88 then v = 0.88 end
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
  
  function shuffle (arr)
  
    for i = 1, #arr - 1 do
      local j = math.random(i, #arr)
      arr[i], arr[j] = arr[j], arr[i]
    end
  end
  
  
  
  function shuffled_numbers (n)
  
    local numbers = {}
    for i = 1, n do
      numbers[i] = i
    end
    shuffle(numbers)
    return numbers
  end
  
  
  
  -- COLOR MULTIPLE TRACKS TO PALETTE COLORS--
  
  local function Color_multiple_tracks_to_palette_colors(sel_tracks)
    
    PreventUIRefresh(1) 
    local numbers = shuffled_numbers (120)
    local first_color = sel_color[1]
    color_state = 0
    for p=1, #main_palette do
      if first_color==main_palette[p] then
        color_state = 1
        for i=1, sel_tracks -1 do
          if random_main then value = numbers[i%120+1] else value = (i+p-1)%120+1 end
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
  
  
  
  local function Color_multiple_items_to_palette_colors(sel_items)
    
    PreventUIRefresh(1) 
    local numbers = shuffled_numbers (120)
    local first_color = sel_color[1] -- 
    color_state = 0
    for p=1, #main_palette do
      if first_color==main_palette[p] then
        color_state = 1
        for i=1, sel_items -1 do
          if random_main then value = numbers[i%120+1] else value = (i+p-1)%120+1 end
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
  
  local function Color_multiple_tracks_to_custom_palette(sel_tracks)
  
    PreventUIRefresh(1) 
    local numbers = shuffled_numbers (24)
    local first_color = sel_color[1]
    color_state = 0
    for r=1, #custom_palette do
      if first_color == custom_palette[r] then
        color_state = 1
        for i=1, sel_tracks -1 do
          if random_custom then value = numbers[i%24+1] else value = (i+r-1)%24+1 end
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
  

  
  local function Color_multiple_items_to_custom_palette(sel_items)
  
    PreventUIRefresh(1) 

    local numbers = shuffled_numbers (24)
    local first_color = (sel_color[1])
    color_state = 0
    for r=1, #custom_palette do
      if first_color==custom_palette[r] then
        color_state = 1
        for i=1, sel_items -1 do
          if random_custom then value = numbers[i%24+1] else value = (i+r-1)%24+1 end
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
    
  local function Color_new_tracks_automatically(init_state, tr_cnt)

    local state = init_state
    if not track_number_sw then track_number_sw = tr_cnt end
    if track_number_sw < tr_cnt and test_track then
      Undo_BeginBlock2(0)
      for i = 0, sel_tracks-1 do
        local track = GetSelectedTrack(0, i)  
        state = state+1
        if stored_val and state2 == state then
          SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", auto_pal.tr[stored_val%remainder+1])
          stored_val, state2 = stored_val+1, state +1

        else
          local prev_tr_ip = GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')-1
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
        end
      end
      state2 = state2 +1
      track_number_sw, sel_tracks2, col_tbl, found = tr_cnt, nil, nil, nil
      Undo_EndBlock2(0, "CHROMA: Automatically color new tracks", 1)
      
    elseif track_number_sw > tr_cnt then
      track_number_sw, found, col_tbl = tr_cnt, nil, nil 
    end
  end

  
  
  -- BUTTON TEMPLATE 1 --
  
  local function button_color(h, s, v, a, name, size_w, size_h, small, round)
  
    local n = 0
    local state
    ImGui.PushStyleColor(ctx, ImGui.Col_Button(), HSV(h, 0, 0.3, a/3)) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered(), HSV(h, s, v, a/2)) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive(), HSV(h, s, v, a)) n=n+1
    if not small then state = ImGui.Button(ctx, name, size_w, size_h)
    else state = ImGui.SmallButton(ctx, name) end
    ImGui.PopStyleColor(ctx, n)
  
    local draw_list = ImGui.GetWindowDrawList(ctx)
    local text_min_x, text_min_y = reaper.ImGui_GetItemRectMin(ctx)
    local text_max_x, text_max_y = reaper.ImGui_GetItemRectMax(ctx)
    if not reaper.ImGui_IsItemHovered(ctx) then
      reaper.ImGui_DrawList_AddRect(draw_list, text_min_x, text_min_y, text_max_x, text_max_y, HSV(h, s, v, a), round)
    elseif reaper.ImGui_IsItemHovered(ctx) then
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
    if b_h < 0.5 then bs_h = b_h + 0.5 else bs_h = b_h - 0.5 end
    
    ImGui.PushStyleColor(ctx, ImGui.Col_Button(), HSV(h, s, v-0.2, a)) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered(), HSV(h, s, v, a)) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive(), HSV(h, s, v+0.2, a)) n=n+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding(),rounding) m=m+1
    if border == true then 
      ImGui.PushStyleColor(ctx, ImGui.Col_Border(), HSV(b_h, b_s, b_v, b_a))n=n+1
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize(), b_thickness) m=m+1 
      ImGui.PushStyleColor(ctx, ImGui.Col_BorderShadow(), HSV(bs_h, b_s, b_v-0.25, b_a))n=n+1
    end
    state = ImGui.Button(ctx, name, size_w, size_h)
    ImGui.PopStyleColor(ctx, n)
    ImGui.PopStyleVar(ctx, m)
    return state
  end
  
  function get_last_context()
    local left_click = r.JS_Mouse_GetState(1)
    local right_click = r.JS_Mouse_GetState(2)
    if (left_click == 1 and last_left_click ~= 1) or (right_click == 2 and last_right_click ~= 2) then
      local window, segment, details = r.BR_GetMouseCursorContext()
      if window ~= 'unknown' then
        manager_focus = 0
        if window == 'tcp' or window == 'mcp' then
          target_button = last_track_state
        elseif window == 'arrange' then
          target_button = last_item_state
        elseif window == 'ruler' then
          if segment == 'marker_lane' then
            target_button = 6
            last_marker_state = 6
          elseif segment == 'region_lane' then
            target_button = 7
            last_marker_state = 7
          else
            target_button = last_marker_state
          end
        end
      else
        -- If unknown, get focus hwnd and parent
        local hwnd_focus = r.JS_Window_GetFocus()
        if hwnd_focus then
          local hwnd_focus_parent = r.JS_Window_GetParent(hwnd_focus)
          if hwnd_focus_parent then
            local hwnd_focus_parent_title = r.JS_Window_GetTitle(hwnd_focus_parent)
            if hwnd_focus_parent_title == trackmanager_title then
              hwnd_tracks = hwnd_focus_parent
              manager_focus, target_button = 2,2
            elseif hwnd_focus_parent_title == regionmanager_title then
              hwnd_regions = hwnd_focus_parent
              manager_focus, target_button = 1,8
            end
          end
        end
      end
    end
    last_left_click = left_click
    last_right_click = right_click
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
  
  

  local function shortcut_gradient(color_input)
  
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Left()) and not check_one then
        
      if not stop_gradient and sel_tracks > 0 then
      first_color = color_input
      sel_tab = {tr = {}}
      for i = 1, sel_tracks do
        sel_tab.tr[i] = sel_tbl.tr[i]
        if i > 1 then SetTrackSelected(sel_tab.tr[i], false) end
      end
      stop_gradient = true
            
      elseif stop_coloring and not check_one then
        SetTrackSelected(sel_tab.tr[1], false)
        SetTrackSelected(sel_tab.tr[#sel_tab.tr], true)
        check_one = true
        last_color = color_input
      end
      if not stop_coloring then
        stop_coloring = true
      end
      
    elseif check_two then
      test_track = sel_tab.tr[1]
      for i = 1, #sel_tab.tr  do
        SetTrackSelected(sel_tab.tr[i], true)
        sel_tbl.tr[i] = sel_tab.tr[i]
      end
      Color_selected_tracks_with_gradient(#sel_tab.tr, test_track, first_color, last_color) 
      sel_tab, stop_gradient, stop_coloring, check_one, check_two, col_tbl = nil -- all variables should get nil
    end
  end



  local function shortcut_gradient_items(color_input)
  
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Left()) and not check_one then

      if not stop_gradient and sel_items > 0 then
        first_color = color_input
        sel_tab = {it = {}, tke = {}} 
        for i = 1, sel_items  do
          sel_tab.it[i] = sel_tbl.it[i]
          sel_tab.tke[i] = sel_tbl.tke[i]
          if i > 1 then SetMediaItemSelected(sel_tab.it[i], false) end
        end
        stop_gradient = true
        
      elseif stop_coloring and not check_one then
        SetMediaItemSelected(sel_tab.it[1], false)
        SetMediaItemSelected(sel_tab.it[#sel_tab.it], true)
        check_one = true
        last_color = color_input
      end
      if not stop_coloring then
        stop_coloring = true
      end
      
    elseif check_two then
      test_item = sel_tab.it[1]
      for i = 1, #sel_tab.it  do
        SetMediaItemSelected(sel_tab.it[i], true)
        sel_tbl.it[i] = sel_tab.it[i]
        sel_tbl.tke[i] = sel_tab.tke[i] 
      end
      Color_selected_items_with_gradient(#sel_tab.it, test_item, first_color, last_color)
      sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil -- all variables should get nil
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
    differs, differs2, stop = current_item, 1, nil
  end

  
  -- USER CUSTOM PALETTE BUTTON FUNCTIONS --
  
  local function SaveCustomPaletteButton()
  
    local retval, retvals_csv = reaper.GetUserInputs('Set a new preset name', 1, 'Enter name:, extrawidth=300', user_palette[current_item]) 
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
            reaper.SetExtState(script_name , 'user_palette', serialized, true )
            reaper.SetExtState(script_name , 'userpalette.'..tostring(retvals_csv),  table.concat(custom_palette,","),true)
            current_item, stop, differs = index, false, index
          end
        end
      end
  
      if not preset_found then 
        differs2 = nil 
        user_palette[index] = retvals_csv
        --if index == 2 then user_palette[1] = '*Last unsaved*' end
        local serialized = serializeTable(user_palette)
        reaper.SetExtState(script_name , 'user_palette', serialized, true )
        reaper.SetExtState(script_name , 'userpalette.'..tostring(retvals_csv),  table.concat(custom_palette,","),true)
        current_item = index
      end
      stop, new_combo_preview_value, combo_preview_value = false, nil, nil
    end
  end
  
  
  
  local function DeleteCustomPalettePreset()
  
    if #user_palette > 1 and current_item > 1 then
      if new_combo_preview_value then
        reaper.SetExtState(script_name, 'userpalette.*Last unsaved*', table.concat(custom_palette,","),true)
      end
      reaper.DeleteExtState( script_name, 'userpalette.'..tostring(user_palette[current_item]), true )
      table.remove(user_palette, current_item)
      local serialized = serializeTable(user_palette)
      reaper.SetExtState(script_name , 'user_palette', serialized, true )
      if current_item > #user_palette then current_item = current_item - 1 end
      custom_palette = {} 
      if reaper.HasExtState(script_name, 'userpalette.'..tostring(user_palette[current_item])) then
        for i in string.gmatch(reaper.GetExtState(script_name, 'userpalette.'..tostring(user_palette[current_item])), "[^,]+") do
          insert(custom_palette, tonumber(string.match(i, "[^,]+")))
        end
      end
      new_combo_preview_value, combo_preview_value, differs, stop = nil, nil, current_item, false
      cust_tbl = nil
    end
  end
        
       
        
  local function CustomPaletteUserPreset()
    --Placeholder -- maybe put the relating content here for organization
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
    
    local retval_main, retvals_csv_main = reaper.GetUserInputs('Set a new mainpreset name', 1, 'Enter name:, extrawidth=300', user_mainpalette[current_main_item]) 
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
            reaper.SetExtState(script_name , 'user_mainpalette', serialized, true )
            reaper.SetExtState(script_name , 'usermainpalette.'..tostring(retvals_csv_main),  table.concat(user_main_settings,","),true)
            current_main_item, stop2, differs3 = index, false, index
          end
        end
      end
  
      if not preset_found then 
        differs4 = nil 
        user_mainpalette[index] = retvals_csv_main
        --if index == 2 then user_mainpalette[1] = '*Last unsaved*' end
        local serialized = serializeTable(user_mainpalette)
        reaper.SetExtState(script_name , 'user_mainpalette', serialized, true )
        reaper.SetExtState(script_name , 'usermainpalette.'..tostring(retvals_csv_main),  table.concat(user_main_settings,","),true)
        current_main_item = index
      end
      main_new_combo_preview_value, main_combo_preview_value, stop2 = nil, nil, false
    end
  end
  
  
  
  local function DeleteMainPalettePreset()
    if #user_mainpalette > 1 and current_main_item > 1 then
      reaper.DeleteExtState( script_name, 'usermainpalette.'..tostring(user_mainpalette[current_main_item]), true )
      table.remove(user_mainpalette, current_main_item)
      local serialized = serializeTable(user_mainpalette)
      reaper.SetExtState(script_name , 'user_mainpalette', serialized, true )
      if current_main_item > #user_mainpalette then current_main_item = current_main_item - 1 end
  
      user_main_settings = {} 
      if reaper.HasExtState(script_name, 'usermainpalette.'..tostring(user_mainpalette[current_main_item])) then
        for i in string.gmatch(reaper.GetExtState(script_name, 'usermainpalette.'..tostring(user_mainpalette[current_main_item])), "[^,]+") do
          insert(user_main_settings, tonumber(string.match(i, "[^,]+")))
        end
        colorspace =user_main_settings[1] 
        saturation = user_main_settings[2] 
        lightness = user_main_settings[3] 
        darkness = user_main_settings[4]
      end
      differs3, stop2, main_new_combo_preview_value, main_combo_preview_value = current_main_item, false, nil, nil
    end
  end
    
        
        
  local function MainPaletteUserPreset()
    --Placeholder -- maybe put the relating content here for organization 
  end
  
  
  
  -- PALETTE MENU WINDOW --
  
  local function PaletteMenu(p_y, p_x, w)
  
    local set_x
    local set_h 
    ImGui.SetNextWindowSize(ctx, 236, 740, ImGui.Cond_Appearing()) 
    local set_y = p_y +30
    if set_y < 0 then
      set_y = p_y + h 
    end
    if  p_x -300 < 0 then set_x = p_x + w +30 else set_x = p_x -300 end
    
    if not set_pos then
      ImGui.SetNextWindowPos(ctx, set_x, set_y, ImGui.Cond_Appearing())
    end
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 5)
    visible, openSettingWnd = ImGui.Begin(ctx, 'Palette Menu', true, ImGui.WindowFlags_NoCollapse() | ImGui.WindowFlags_NoDocking()) 
    if visible then
    
      -- GENERATE CUSTOM PALETTES -- 
      
      local space_btwn = 8
      
      ImGui.Dummy(ctx, 0, 2)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffe8acff)
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

      if not stop and not combo_preview_value then
        combo_preview_value = user_palette[current_item]
      elseif not combo_preview_value then
        combo_preview_value = new_combo_preview_value
      end
        
      ImGui.PushItemWidth(ctx, 220)
      local combo = ImGui.BeginCombo(ctx, '##6', combo_preview_value, 0) 
      if combo then 
        for i,v in ipairs(user_palette) do
          local is_selected = current_item == i
          if ImGui.Selectable(ctx, user_palette[i], is_selected, ImGui.SelectableFlags_None(),  300.0,  0.0) then
            current_item = i
            if new_combo_preview_value and current_item ~= 1 then
              reaper.SetExtState(script_name, 'userpalette.*Last unsaved*', table.concat(custom_palette,","),true)
            end
            
            custom_palette = {} 
            if reaper.HasExtState(script_name, 'userpalette.'..tostring(user_palette[i])) then
              for i in string.gmatch(reaper.GetExtState(script_name, 'userpalette.'..tostring(user_palette[i])), "[^,]+") do
                insert(custom_palette, tonumber(string.match(i, "[^,]+")))
              end
            end
            stop, new_combo_preview_value, combo_preview_value = false, nil, nil
            cust_tbl = nil
          end
          
          if reaper.ImGui_IsItemHovered(ctx) then
            hovered_preset = v
          end
          -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
          if is_selected then
            ImGui.SetItemDefaultFocus(ctx)
          end
        end
        ImGui.EndCombo(ctx)
      end
      
      if reaper.ImGui_IsWindowHovered(ctx, reaper.ImGui_FocusedFlags_ChildWindows()) then
        local x, y = reaper.GetMousePosition()
        if reaper.ImGui_IsItemHovered(ctx) or combo then
          if combo and hovered_preset ~= ' ' and x > 0 then 
            for p, c in utf8.codes(hovered_preset) do 
              if c > 255 or string.len(hovered_preset) > 30 then 
                reaper.TrackCtl_SetToolTip( hovered_preset, x, y+sys_offset, 0 )
                break
              else
                reaper.TrackCtl_SetToolTip( '', 0, 0, 0 )
              end
            end
          elseif x > 0 then
            for p, c in utf8.codes(user_palette[current_item]) do 
              if c > 255 or string.len(user_palette[current_item]) > 30 then 
                reaper.TrackCtl_SetToolTip( user_palette[current_item], x, y+sys_offset, 0 )
                break
              end
            end
          end
        else
          reaper.TrackCtl_SetToolTip( '', 0, 0, 0 )
        end
      end

      if differs and not stop and differs2 == 1 then
        new_combo_preview_value = user_palette[current_item]..' (modified)'
        stop, differs2, combo_preview_value = true, nil, nil
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
      
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffe8acff)
      button_action(0, 0, 0, 0,'MAIN PALETTE:##set', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      ImGui.PopStyleColor(ctx, 1)
      ImGui.Dummy(ctx, 0, space_btwn)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 2)
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
      
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 0)
      button_action(0, 0, 0, 0,'saturation##set', 220, 19, true, 0, 0, 0, 0, 0, 0) 
      ImGui.PopStyleVar(ctx, 1)
      ImGui.PushItemWidth(ctx, 220)
      sat_true, saturation = ImGui.SliderDouble(ctx, '##1', saturation, 0.3, 1.0, '%.3f', ImGui.SliderFlags_None())
      
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 0)
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
      
      if not stop2 and not main_combo_preview_value then
        main_combo_preview_value = user_mainpalette[current_main_item]
      elseif not main_combo_preview_value then
        main_combo_preview_value = main_new_combo_preview_value
       
      end
        
      ImGui.PushItemWidth(ctx, 220)
      local main_combo = ImGui.BeginCombo(ctx, '##7', main_combo_preview_value, 0) 
      if main_combo then 
        for i,v in ipairs(user_mainpalette) do
          local is_selected = current_main_item == i
          if ImGui.Selectable(ctx, user_mainpalette[i], is_selected, ImGui.SelectableFlags_None(),  300.0,  0.0) then
            current_main_item = i
            if main_new_combo_preview_value and current_main_item ~= 1 then
              reaper.SetExtState(script_name, 'usermainpalette.*Last unsaved*', table.concat(user_main_settings,","),true)
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
            main_new_combo_preview_value, main_combo_preview_value, differs3, stop2 = nil, nil, 1, false
          end
           
          if reaper.ImGui_IsItemHovered(ctx) then
            hovered_main_preset = v
          end

          -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
          if is_selected then
            ImGui.SetItemDefaultFocus(ctx)
          end
        end
        ImGui.EndCombo(ctx)
      end
      
      if reaper.ImGui_IsWindowHovered(ctx, reaper.ImGui_FocusedFlags_ChildWindows()) then
        local x, y = reaper.GetMousePosition()
        if reaper.ImGui_IsItemHovered(ctx) or main_combo then
          if main_combo and hovered_main_preset ~= ' ' and x > 0 then 
            for p, c in utf8.codes(hovered_main_preset) do 
              if c > 255 or string.len(hovered_main_preset) > 30 then 
                reaper.TrackCtl_SetToolTip( hovered_main_preset, x, y+sys_offset, 0 )
                break
              end
            end
          elseif x > 0 then
            for p, c in utf8.codes(user_mainpalette[current_main_item]) do 
              if c > 255 or string.len(user_mainpalette[current_main_item]) > 30 then 
                reaper.TrackCtl_SetToolTip( user_mainpalette[current_main_item], x, y+sys_offset, 0 )
                break
              end
            end
          end
        end
      end
      
      if sat_true or contrast_true or colorspace ~= colorspace_sw and current_main_item > 1 and not stop2 then
        main_new_combo_preview_value = user_mainpalette[current_main_item]..' (modified)'
        stop2, main_combo_preview_value = true, nil
      end

      ImGui.Dummy(ctx, 0, space_btwn)
      _, random_main = ImGui.Checkbox(ctx, "Random coloring via button##2", random_main)
      if button_color(0.14, 0.9, 0.7, 1, 'Reset Main Palette', 220, 19, false, 3)  then 
        saturation = 0.8; lightness =0.65; darkness =0.20; dont_ask = false; colorspace = 0
        sat_true = true
      end
      
      ImGui.Separator(ctx)
      ImGui.End(ctx)
      set_pos = {ImGui.GetWindowPos(ctx)}
    end
    ImGui.PopStyleVar(ctx)
  end

  local function SettingsPopUp()
    
    ImGui.Dummy(ctx, 0, 0)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffe8acff)
    
    if tree_node_open then
      ImGui.SetNextItemOpen(ctx, true, ImGui.Cond_Once())
    end
    
    local tree_node_open = ImGui.TreeNode(ctx, 'SECTIONS (show/hide)')
      
    if tree_node_open then -- first treenode --
    
      tree_node_open_save = true
      -- HIDING SECTIONS --
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffffffff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 6)
      _, show_custompalette  = ImGui.Checkbox(ctx, 'Show Custom Palette', show_custompalette)
      _, show_edit           = ImGui.Checkbox(ctx, 'Show Edit custom color', show_edit)
      _, show_lasttouched    = ImGui.Checkbox(ctx, 'Show Last touched', show_lasttouched)
      _, show_mainpalette    = ImGui.Checkbox(ctx, 'Show Main Palette', show_mainpalette)
      ImGui.PopStyleVar(ctx, 1)
      _, show_action_buttons = ImGui.Checkbox(ctx, 'Show Action buttons', show_action_buttons) 
      ImGui.PopStyleColor(ctx,1)
    end
  
    if tree_node_open then
      ImGui.TreePop(ctx)
    end
  
    if tree_node_open_save then
      local was_toggled = ImGui.IsItemToggledOpen(ctx)
      if was_toggled then
        tree_node_open_save = false
      end
    end
    
    ImGui.Dummy(ctx, 0, 0)
    
    if tree_node_open2 then
      ImGui.SetNextItemOpen(ctx, true, ImGui.Cond_Once()) --ImGui.Cond_Once()
    end
    
    local tree_node_open2 = ImGui.TreeNode(ctx, 'ADVANCED SETTINGS       ') -- second treenode --
    
    if tree_node_open2 then
      -- SEPERATOR --
      tree_node_open_save2 = true
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffe8acff)
    
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize(),3) 
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign(), 0.5, 0.5)
      ImGui.SeparatorText(ctx, '  Coloring Mode  ')
      ImGui.PopStyleVar(ctx, 2)
    
      ImGui.PopStyleColor(ctx,1)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffffffff)
    
      -- MODE SELECTION --
    
      ImGui.AlignTextToFramePadding(ctx)
      ImGui.Text(ctx, 'Mode:')
      ImGui.SameLine(ctx, 0, 7)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 6)
  
      _, selected_mode = ImGui.RadioButtonEx(ctx, 'Normal', selected_mode, 0); ImGui.SameLine(ctx, 0 , 25)
      if ImGui.RadioButtonEx(ctx, 'ShinyColors (experimental)   ', selected_mode, 1) then
        if not dont_ask then
          ImGui.OpenPopup(ctx, 'ShinyColors Mode')
        else
          selected_mode = 1
        end
      end
    
    
    
      -- SHINYCOLORS MODE POPUP --
  
      -- Always center this window when appearing
      local center = {ImGui_Viewport_GetCenter(ImGui.GetWindowViewport(ctx))}
      ImGui.SetNextWindowPos(ctx, center[1], center[2], ImGui.Cond_Appearing(), 0.5, 0.5)
      if ImGui.BeginPopupModal(ctx, 'ShinyColors Mode', nil, ImGui.WindowFlags_AlwaysAutoResize()) then
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
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffe8acff)
      
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize(),3) 
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign(), 0.5, 0.5)
      ImGui.SeparatorText(ctx, '  Auto Coloring  ')
      ImGui.PopStyleVar(ctx, 2)
      ImGui.PopStyleColor(ctx,1)
      
     
      
      -- CHECKBOX FOR AUTO TRACK COLORING --
      
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 6)
      _, auto_trk = ImGui.Checkbox(ctx, "Autocolor new tracks", auto_trk)
      
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
      
      ImGui.PushStyleColor(ctx, ImGui.Col_Border(), HSV(0.3, 0.1, 0.5, 1))
      ImGui.PushStyleColor(ctx, ImGui.Col_FrameBg (), HSV(0.65, 0.4, 0.2, 1))
      ImGui.PushStyleColor(ctx, ImGui.Col_FrameBgHovered(), HSV(0.65, 0.2, 0.4, 1))
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
  
    if tree_node_open2 then
      ImGui.TreePop(ctx)
    end
    
    if tree_node_open_save2 then
      local was_toggled2 = ImGui.IsItemToggledOpen(ctx)
      if was_toggled2 then
        tree_node_open_save2 = false
      end
    end
    ImGui.PopStyleColor(ctx)
    ImGui.Dummy(ctx, 0, 0) 
  end
  
  
      
--[[_______________________________________________________________________________
    _______________________________________________________________________________]]
  



  -- THE COLORPALETTE GUI--

  local function ColorPalette(init_state)

    local p_x, p_y = ImGui.GetWindowPos(ctx)
    local w, h = ImGui.GetWindowSize(ctx)
    local size = (w-2*24)/25

    
    -- SAVE ALL TRACKS AND ITS COLORS TO A TABLE --
    
    local tr_cnt = CountTracks(0)
    if not col_tbl 
      or ((Undo_CanUndo2(0)=='Change track order')
          or  tr_cnt ~= tr_cnt_sw) then
      generate_trackcolor_table(tr_cnt)
      tr_cnt_sw = tr_cnt 
    end
    
    local var = 0 
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding(), 5); var=var+1 -- for settings menu sliders
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_GrabRounding(), 2); var=var+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_PopupRounding(), 2); var=var+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 16); var=var+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize(),1) var=var+1
    
    local col = 0
    ImGui.PushStyleColor(ctx, ImGui.Col_Border(),0x303030ff) col= col+1
    ImGui.PushStyleColor(ctx, ImGui.Col_BorderShadow(), 0x10101050) col= col+1
  
    
    -- MENUBAR AND SETTINGS POPUP --
      
    --ImGui.BeginMenuBar(ctx) -- left here for ancient
    --if ImGui.BeginMenu(ctx, 'Settings') then -- left here for ancient

    if reaper.ImGui_BeginPopupContextItem(ctx, '##Settings3') then
      SettingsPopUp()
      ImGui.EndPopup(ctx)
    end -- Settings Menu
    
    --ImGui.EndMenuBar(ctx) - -- left here for ancient

    
    -- PALETTE MENU --
        
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 9); var=var+1 

    ImGui.Dummy(ctx, 0, 0) 
    if button_action(0.555, 0.59, 0.6, 1, 'Palette Menu', 140, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
      openSettingWnd = true
    end
    
    if openSettingWnd then
      PaletteMenu(p_y, p_x, w)
    end
    
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 6); var=var+1
    -- THE NEW SETTINGS BUTTON --

    local pos = {reaper.ImGui_GetCursorScreenPos(ctx)}
    
    ImGui.SameLine(ctx, 0, 5)
    if button_action(0.555, 0.59, 0.6, 1, '##Settings2', 36, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then
      ImGui.OpenPopup(ctx, '##Settings3')
    end
    
    local center = {pos[1]+154, pos[2]-22}
    
    
    -- DRAWING --
    
    local draw_list = reaper.ImGui_GetWindowDrawList(ctx)
  
    local draw_color = 0xffe8acff
    --local draw_color = 0xffffffff
    if reaper.ImGui_IsItemHovered(ctx) then
      draw_thickness = 1.8
    else
      draw_thickness = 1.6
    end
    
    reaper.ImGui_DrawList_AddLine(draw_list, center[1], center[2], center[1]+3, center[2], draw_color, draw_thickness)
    reaper.ImGui_DrawList_AddLine(draw_list, center[1]+7, center[2], center[1]+18, center[2], draw_color, draw_thickness)
    reaper.ImGui_DrawList_AddLine(draw_list, center[1], center[2]+6, center[1]+10, center[2]+6, draw_color, draw_thickness)
    reaper.ImGui_DrawList_AddLine(draw_list, center[1]+14, center[2]+6, center[1]+18, center[2]+6, draw_color, draw_thickness)
    reaper.ImGui_DrawList_AddCircle(draw_list, center[1]+6, center[2], 3, draw_color,  0, draw_thickness)
    reaper.ImGui_DrawList_AddCircle(draw_list, center[1]+12, center[2]+6, 3, draw_color,  0, draw_thickness)
    
    -- Open settings popup via right click --

    if reaper.ImGui_IsMouseClicked(ctx, ImGui.MouseButton_Right(), false) and reaper.ImGui_IsWindowHovered(ctx) and not reaper.ImGui_IsAnyItemHovered(ctx) then
      ImGui.OpenPopup(ctx, '##Settings3')
    end

    
    -- UPPER RIGHT CORNER --
    
    -- MODE ELEMENT POSITION --
    
    local width2 = size*24+2*23
    ImGui.SameLine(ctx, 155, width2-140-88)
    
    
    
    -- SHINY MODE INDICATOR --
    
    if selected_mode == 1 then
      ImGui.SameLine(ctx, 155, width2-262-88)
      button_action(0, 0, 0, 0,'ShinyColors:', 90, 21, true, 0, 0, 0, 0, 0, 0) 
      ImGui.SameLine(ctx, 0, 3)
      ImGui.RadioButtonEx(ctx, '##', selected_mode, 1)
      ImGui.SameLine(ctx, 0, 6)
    else
      ImGui.SameLine(ctx, 155, width2-140-88)
    end
    
    
    --ImGui.SameLine(ctx, 0, 3)
    
    -- SELECTION INDICATOR --

    if items_mode == 0 then 
      tr_txt = 'Tracks'
      tr_txt_h = 0.555
    elseif items_mode == 1 then 
      tr_txt = 'Items'
      tr_txt_h = 0.15
    elseif items_mode == 2 then 
      tr_txt = '##No_selection'
    end
    
    ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffe8acff) col=col+1

    if button_action(tr_txt_h, 0.5, 0.4, 1, tr_txt, 80, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 3) then
      if items_mode == 0 and sel_items>0 then 
        items_mode = 1
        test_item_sw = nil
        test_take2 = nil
        reaper.SetCursorContext(1) 
      elseif items_mode == 1 and sel_tracks>0 then 
        items_mode = 0 
        sel_tracks2 = nil
        reaper.SetCursorContext(0) 
      end
    end

    if not ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) and ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right())then
      reaper.Main_OnCommand(40769, 0) -- Unselect (clear selection of) all tracks/items/envelope points
    end
    
    -- FRAME FOR SELECTION INDICATOR
    
    if selected_mode == 1 then
      local draw_list = ImGui.GetWindowDrawList(ctx)
      local text_min_x, text_min_y = reaper.ImGui_GetItemRectMin(ctx)
      local text_max_x, text_max_y = reaper.ImGui_GetItemRectMax(ctx)
      --reaper.ImGui_DrawList_AddRect(draw_list, text_min_x-3, text_min_y-3, text_max_x+3, text_max_y+3, HSV(0.3, 1, 1, 0.3), 3, DrawFlags_None, 3)
      reaper.ImGui_DrawList_AddRect(draw_list, text_min_x-3, text_min_y-3, text_max_x+3, text_max_y+3, HSV(0.3, 0, 0.3, 0.3), 3, DrawFlags_None, 3)
    end
    
    

    ImGui.Dummy(ctx, 0, 1)
    ImGui.PopStyleVar(ctx, var) -- for upper part
    ImGui.PopStyleColor(ctx, col) -- for upper part
  
  
  
    -- -- GENERATING TABLES -- --

    if not main_palette or differs3 or sat_true or contrast_true
        or colorspace ~= colorspace_sw then
      main_palette = Palette()
      pal_tbl = generate_palette_color_table()
      colorspace_sw = colorspace 
      user_main_settings = generate_user_main_settings()
    end
    
    if not cust_tbl then
      cust_tbl = generate_custom_color_table()
    end
    

    
    -- DEFINE "GLOBAL" VARIABLES
    
    sel_items = CountSelectedMediaItems(0)
    sel_tracks = CountSelectedTracks(0)
    test_track = GetSelectedTrack(0, 0)
 
    if (sel_tracks == 0 or GetCursorContext2(true) ~= 0) and sel_items > 0 then 
      test_item = GetSelectedMediaItem(0, 0) 
      test_take = GetActiveTake(test_item)
      test_track_it = GetMediaItemTrack(test_item)

    elseif sel_tracks > 0 then
      items_mode = 0
      test_item_sw = nil
      test_item = nil
    else 
      test_item = nil
      sel_color = {}
      items_mode, test_track_sw, test_item_sw = 2, nil, nil
    end
    
    
    
    -- CALLING FUNCTIONS -- 

    get_sel_items_or_tracks_colors(sel_items, sel_tracks, test_item, test_take, test_track)
    
    if selected_mode == 1 then
      Color_new_items_automatically(init_state)
      automatic_item_coloring(init_state)
      if not not_inst then
        reselect_take(init_state)
      end
    end

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
      Color_new_tracks_automatically(init_state, tr_cnt)
    end

    if reaper.Undo_CanRedo2(0) and string.match(reaper.Undo_CanRedo2(0), "CHROMA:") and init_state ~= yes_undo then 
      it_cnt_sw, test_track_sw, col_tbl = nil
      yes_undo = init_state
    end 
    
    
     
    ---- ---- MIDDLE PART ---- ----
    
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding(),2)    -- general rounding for color widgets
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 0)  -- first seperator upper space
    
    
    -- CUSTOM COLOR PALETTE --
    
    if show_custompalette then

      local dist_index = 0
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
                      ImGui.ColorEditFlags_NoPicker() |
                      ImGui.ColorEditFlags_NoTooltip()
        for l=1, #sel_color do
          if sel_color[l]==custom_palette[m] then
              ImGui.PushStyleColor(ctx, ImGui.Col_Border(),0xffffffff)
              ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize(),2)
              highlight2 = true
            break
          end
        end
        if highlight2 == false then
          palette_button_flags2 = palette_button_flags2 | ImGui.ColorEditFlags_NoBorder()
        end
        
        if ImGui.ColorButton(ctx, '##palette2', custom_palette[m], palette_button_flags2, size, size) then
          if custom_palette[m] ~= HSL((m-1) / 24+0.69, 0.1, 0.2, 1) then
            widgetscolorsrgba = custom_palette[m] -- needed for highlighting
            Undo_BeginBlock2(0)
            coloring(cust_tbl.tr, cust_tbl.it, m)
            sel_color[1] = custom_palette[m]

            if ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) then
              if items_mode == 0 then
                Color_multiple_tracks_to_custom_palette(sel_tracks) 
                col_tbl, sel_tracks2 = nil, nil
                Undo_EndBlock2(0, "CHROMA: Color multiple tracks to custom palette", 1+4)
              elseif items_mode == 1 then
                Color_multiple_items_to_custom_palette(sel_items)
                it_cnt_sw = nil
                Undo_EndBlock2(0, "CHROMA: Color multiple items to custom palette", 4)
              end
            else
              if items_mode == 0 then
                col_tbl, sel_tracks2 = nil, nil
              elseif items_mode == 1 then
                it_cnt_sw = nil 
              end
              Undo_EndBlock2(0, "CHROMA: Apply palette color", 1+4)
            end

            if check_one then
              if items_mode == 0 and selected_mode == 1 then
                generate_trackcolor_table(tr_cnt)
                tr_cnt_sw = tr_cnt 
              end
              check_two = true
            end
          else
            ImGui.OpenPopupOnItemClick(ctx, 'Choose color', ImGui.PopupFlags_MouseButtonLeft())
             backup_color = rgba
          end
        end

        if ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) and ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right()) then
          item_track_color_to_custom_palette(m)
        elseif ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) then
          if items_mode == 0 then
            shortcut_gradient(custom_palette[m])
          elseif items_mode == 1 then
            shortcut_gradient_items(custom_palette[m])
          end

        elseif sel_tab and ImGui.Mod_None() then
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

          got_color, rgba = ImGui.ColorPicker4(ctx, '##Current', rgba, ImGui.ColorEditFlags_NoSidePreview() | ImGui.ColorEditFlags_NoSmallPreview(), ref_col)
          ImGui.SameLine(ctx, 255)
          ImGui.BeginGroup(ctx) -- Lock X position
          ImGui.Text(ctx, 'Current')
          ImGui.ColorButton(ctx, '##current2', rgba, ImGui.ColorEditFlags_NoPicker(), 60, 40)
          ImGui.Dummy(ctx, 0, 1)
          ImGui.Text(ctx, 'Previous')
          if ImGui.ColorButton(ctx, '##previous', backup_color, ImGui.ColorEditFlags_NoPicker(), 60, 40) then
            rgba = backup_color
          end
          
          if got_color then
            custom_color, widgetscolorsrgba, differs, differs2, stop  = rgba, rgba, current_item, 1, false
            custom_palette[m] = rgba 
            cust_tbl = nil 
          end
          ImGui.EndGroup(ctx) 
          ImGui.EndPopup(ctx)
        end
        
        if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right()) and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) then
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
            differs, differs2, stop = current_item, 1, false
            cust_tbl = nil
          end
          ImGui.EndDragDropTarget(ctx)
        end
        ImGui.PopID(ctx)
      end
      
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffe8acff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize(),3) 
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign(), 1, 0.5)
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
      
      if button_color(hc, sc, vc, 1, 'Edit custom color', 150, 21, false, 2) then
        ImGui.OpenPopupOnItemClick(ctx, 'Choose color', ImGui.PopupFlags_MouseButtonLeft())
        backup_color2 = rgba
      end
      
      local open_popup = ImGui.BeginPopup(ctx, 'Choose color')
      if not open_popup then
        ref_col = rgba
      else
        ref_col = ref_col
      end
      if open_popup then
        got_color, rgba = ImGui.ColorPicker4(ctx, '##Current3', rgba, ImGui.ColorEditFlags_NoSidePreview() | ImGui.ColorEditFlags_NoSmallPreview(), ref_col)

        ImGui.SameLine(ctx, 255)
        ImGui.BeginGroup(ctx) -- Lock X position
        ImGui.Text(ctx, 'Current')
        ImGui.ColorButton(ctx, '##current3', rgba, ImGui.ColorEditFlags_NoPicker(), 60, 40)
        ImGui.Dummy(ctx, 0, 1)
        ImGui.Text(ctx, 'Previous')
        if ImGui.ColorButton(ctx, '##previous2', backup_color2, ImGui.ColorEditFlags_NoPicker(), 60, 40) then
          rgba = backup_color2
        end
        if got_color then
          custom_color, widgetscolorsrgba = rgba, rgba 
        end
        
        ImGui.EndGroup(ctx)
        ImGui.EndPopup(ctx)
      end
      ImGui.SameLine(ctx, -1, 156) -- overlapping items
      
      
  
      -- APPLY CUSTOM COLOR --
      
      if ImGui.ColorButton(ctx, 'Apply custom color##3', rgba, ImGui.ColorEditFlags_NoBorder(), 21, 21)
        or ((Undo_CanUndo2(0)=='Insert media items'
          or Undo_CanUndo2(0)=='Recorded media')
            and (not cur_state or cur_state < init_state))
              and automode_id == 2  then
        local cur_state = init_state
        Undo_BeginBlock2(0)
        coloring_cust_col(rgba)
        widgetscolorsrgba = rgba --is it needed anymore? yes, for being last color

        if items_mode == 0 then
          col_tbl, sel_tracks2 = nil, nil
        elseif items_mode == 1 then
          it_cnt_sw = nil 
        end
        Undo_EndBlock2(0, "CHROMA: Apply custom color", 1+4)

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

    if ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) then
      if items_mode == 0 then
        shortcut_gradient(rgba)
      elseif items_mode == 1 then
        shortcut_gradient_items(rgba)
      end
      
    elseif sel_tab and ImGui.Mod_None() then
      sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil -- all variables should get nil
      if items_mode == 0 then
        col_tbl = nil
      end
    end
    
    --Drag and Drop--
    if ImGui.BeginDragDropTarget(ctx) then
      local rv,drop_color = ImGui.AcceptDragDropPayloadRGBA(ctx)
      if rv then
        rgba = drop_color
      end
      ImGui.EndDragDropTarget(ctx)
    end
    
    local custom_color_flags =  
                   ImGui.ColorEditFlags_DisplayHSV()
                  |ImGui.ColorEditFlags_NoSmallPreview()
                  |ImGui.ColorEditFlags_NoBorder()
                  |ImGui.ColorEditFlags_NoInputs()
                  
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
        coloring_cust_col(last_touched_color)

        if items_mode == 0 then
          col_tbl, sel_tracks2 = nil, nil
        elseif items_mode == 1 then
          it_cnt_sw = nil 
        end
        Undo_EndBlock2(0, "CHROMA: Apply last touched color", 1+4)

        if check_one then
          if items_mode == 0 and selected_mode == 1 then
            generate_trackcolor_table(tr_cnt)
            tr_cnt_sw = tr_cnt 
          end
          check_two = true
        end
      end

      if ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) then
        if items_mode == 0 then
          shortcut_gradient(last_touched_color)
        elseif items_mode == 1 then
          shortcut_gradient_items(last_touched_color)
        end
        
      elseif sel_tab and ImGui.Mod_None() then
        sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil -- all variables should get nil
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
    
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, gap)
      ImGui.Dummy(ctx,0,0)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(), 0xffe8acff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing(), 0, 4)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize(),3)
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign(), 0.985, 0.5)
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
          ImGui.ColorEditFlags_NoPicker() |
          ImGui.ColorEditFlags_NoTooltip()
        for k=1, #sel_color do
          if sel_color[k]==main_palette[n] then
              ImGui.PushStyleColor(ctx, ImGui.Col_Border(),0xffffffff)
              ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize(),2)
              highlight = true
            break
          end
        end
        if highlight == false then
          palette_button_flags = palette_button_flags | ImGui.ColorEditFlags_NoBorder()
        end
        
        
  
      -- MAIN PALETTE BUTTONS --
        
        if ImGui.ColorButton(ctx, '##palette', main_palette[n], palette_button_flags, size, size) then
          widgetscolorsrgba = main_palette[n] 
          Undo_BeginBlock2(0) 
          coloring(pal_tbl.tr, pal_tbl.it, n)
          sel_color[1] = main_palette[n]

          if ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) and not ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) then
            if items_mode == 0 then
              Color_multiple_tracks_to_palette_colors(sel_tracks) 
              col_tbl, sel_tracks2 = nil, nil
              Undo_EndBlock2(0, "CHROMA: Color multiple tracks to custom palette", 1+4)
            elseif items_mode == 1 then
              Color_multiple_items_to_palette_colors(sel_items)
              it_cnt_sw = nil 
              Undo_EndBlock2(0, "CHROMA: Color multiple items to custom palette", 4)
            end
          else
            if items_mode == 0 then
              col_tbl, sel_tracks2 = nil, nil
            elseif items_mode == 1 then
              it_cnt_sw = nil 
            end
            Undo_EndBlock2(0, "CHROMA: Apply main_palette color", 1+4)
          end
          
          -- 3rd cycle
          if check_one then
            if items_mode == 0 and selected_mode == 1 then
              generate_trackcolor_table(tr_cnt)                           
              tr_cnt_sw = tr_cnt                                    
            end
            check_two = true
          end
          end_block = true
        end

        if ImGui.IsKeyDown(ctx, ImGui.Mod_Shortcut()) and ImGui.IsKeyDown(ctx, ImGui.Mod_Shift()) then
          if items_mode == 0 then
            shortcut_gradient(main_palette[n])
          elseif items_mode == 1 then
            shortcut_gradient_items(main_palette[n])
          end
          
        elseif sel_tab and ImGui.Mod_None() then
          sel_tab, stop_gradient, stop_coloring, check_one, check_two = nil -- all variables should get nil
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
   
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize(),3) 
    ImGui.Dummy(ctx, 0, 12)
    ImGui.PopStyleVar(ctx,2) -- Item spacing and ?
   
   
    if show_action_buttons then
    
      ---- -----
      ---- -----
      
      -- TRIGGER ACTIONS/FUNCTIONS VIA BUTTONS --
      
      local bttn_h = 0.644
      local bttn_s = 0.45
      local bttn_v = 0.83
    
      local br_h = 0.558
      local br_s = 0.45
      local br_v = 0.31
      
      -- button calculations ..
      local divider = 14
      local bttn_gap = width2/(divider*5-1)
      local bttn_width = (width2/(divider*5-1))*(divider-1)
      local bttn_height = bttn_width/5*2

      
      ImGui.PushFont(ctx, buttons_font)
      
      if w >= 370+80/math.log(ImGui.GetWindowDpiScale(ctx)+0.4) then 
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
      
      ImGui.PushStyleColor(ctx, ImGui.Col_Text(),0xffffffff)

      if button_action(bttn_h, bttn_s, bttn_v, 1,  button_text1, bttn_width, bttn_height, true, 5,  br_h, br_s, br_v, 0.55, 5) then
        Reset_to_default_color()
      end
      
      ImGui.SameLine(ctx, 0.0, bttn_gap)
      
      if button_action(bttn_h, bttn_s, bttn_v, 1, button_text2, bttn_width, bttn_height, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
        color_childs_to_parentcolor(tr_cnt) 
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
  
  
  
  local function save_current_settings()
  
    reaper.SetExtState(script_name ,'selected_mode',   tostring(selected_mode),true)
    reaper.SetExtState(script_name ,'colorspace',      tostring(colorspace),true)
    reaper.SetExtState(script_name ,'dont_ask',        tostring(dont_ask),true)
    reaper.SetExtState(script_name ,'automode_id',     tostring(automode_id),true)
    reaper.SetExtState(script_name ,'saturation',      tostring(saturation),true)
    reaper.SetExtState(script_name ,'lightness',       tostring(lightness),true)
    reaper.SetExtState(script_name ,'darkness',        tostring(darkness),true)
    reaper.SetExtState(script_name ,'rgba',            tostring(rgba),true)
    reaper.SetExtState(script_name ,'custom_palette',  table.concat(custom_palette,","),true)
    reaper.SetExtState(script_name ,'random_custom',   tostring(random_custom),true)
    reaper.SetExtState(script_name ,'random_main',     tostring(random_main),true)
    reaper.SetExtState(script_name ,'auto_trk',        tostring(auto_trk),true)
    reaper.SetExtState(script_name ,'show_custompalette',   tostring(show_custompalette),true)
    reaper.SetExtState(script_name ,'show_edit',            tostring(show_edit),true)
    reaper.SetExtState(script_name ,'show_lasttouched',     tostring(show_lasttouched),true)
    reaper.SetExtState(script_name ,'show_mainpalette',     tostring(show_mainpalette),true)
    reaper.SetExtState(script_name ,'show_action_buttons',  tostring(show_action_buttons),true)
    reaper.SetExtState(script_name ,'current_item',         tostring(current_item),true)
    reaper.SetExtState(script_name ,'current_main_item',    tostring(current_main_item),true)
    reaper.SetExtState(script_name ,'auto_custom',          tostring(auto_custom),true)
    reaper.SetExtState(script_name ,'tree_node_open_save',  tostring(tree_node_open_save),true)
    reaper.SetExtState(script_name ,'tree_node_open_save2', tostring(tree_node_open_save2),true)
    reaper.SetExtState(script_name ,'stop',                 tostring(stop),true)
    reaper.SetExtState(script_name ,'stop2',                tostring(stop2),true)
  end
  
 

  -- PUSH STYLE COLOR AND VAR COUNTING --

  local function push_style_color()

    local n = 0
    ImGui.PushStyleColor(ctx, ImGui.Col_TitleBgActive(), 0x1b3542ff) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_FrameBg (), 0x1b3542ff) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_SliderGrab(), 0x47aaaaff) n=n+1
    ImGui.PushStyleColor(ctx, ImGui.Col_CheckMark(), 0x90ff60ff) n=n+1
    return n
  end



  local function push_style_var()

    local m = 0
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding(),12) m=m+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowTitleAlign(),0.5, 0.5) m=m+1
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
    local window_flags = ImGui.WindowFlags_None() --|  ImGui.WindowFlags_MenuBar()
    local style_color_n = push_style_color()
    local style_var_m = push_style_var()
    ImGui.SetNextWindowSize(ctx, 641, 377, ImGui.Cond_FirstUseEver())
    local visible, open = ImGui.Begin(ctx, 'Chroma - Coloring Tool', true, window_flags)
    local init_state = GetProjectStateChangeCount(0)
    if visible then
    
      want_font_size = max(ImGui.GetContentRegionAvail(ctx)//40, floor(18-math.exp(ImGui.GetWindowDpiScale(ctx)))) 

      -- check for project tap change --
      local cur_project = getProjectTabIndex()

      
      if cur_project ~= old_project then
        track_number_sw = nil
        col_tbl = nil 
        old_project = cur_project
        cur_state4 = nil
      end
      
      ColorPalette(init_state)
      ImGui.End(ctx)
     
    else
      local tr_cnt = CountTracks(0)
      if not col_tbl 
        or ((Undo_CanUndo2(0)=='Change track order')
            or  tr_cnt ~= tr_cnt_sw) then
        generate_trackcolor_table(tr_cnt)
        tr_cnt_sw = tr_cnt
      end  

      -- CALLING FUNCTIONS -- 
  
      -- define kind of "global" variables
      sel_items = CountSelectedMediaItems(0)
      sel_tracks = CountSelectedTracks(0)
      test_track = GetSelectedTrack(0, 0)
     
      if (sel_tracks == 0 or GetCursorContext2(true) ~= 0) and sel_items > 0 then 
        test_item = GetSelectedMediaItem(0, 0) 
        test_take = GetActiveTake(test_item)
        test_track_it = GetMediaItemTrack(test_item)
        
      elseif sel_tracks > 0 then
        items_mode = 0
        test_item_sw = nil
        test_item = nil
      else 
        test_item = nil
        sel_color = {}
        items_mode, test_track_sw, test_item_sw = 2, nil, nil
      end
      
      get_sel_items_or_tracks_colors(sel_items, sel_tracks,test_item, test_take, test_track)
      if selected_mode == 1 then
        automatic_item_coloring(init_state)
        Color_new_items_automatically(init_state)
      end
      Color_new_tracks_automatically(init_state, tr_cnt)
      if ((Undo_CanUndo2(0)=='Insert media items'
        or Undo_CanUndo2(0)=='Recorded media')
          and (not cur_state or cur_state<init_state))
            and automode_id == 2  then
        cur_state = GetProjectStateChangeCount(0)
        coloring_cust_col()
      end
    end
    ImGui.PopFont(ctx)
    ImGui.PopStyleColor(ctx, style_color_n)
    ImGui.PopStyleVar(ctx, style_var_m)

    if ImGui.IsKeyPressed(ctx, ImGui.Key_Escape()) then open = false end -- Escape Key
    if ImGui.IsKeyPressed(ctx, ImGui.Mod_Shortcut()) and ImGui.IsKeyPressed(ctx, ImGui.Key_Z()) then reaper.Undo_DoUndo2( 0 ) end

    if open then
      defer(loop)
    end
  end
  
  
  
  -- EXECUTE --

  defer(loop)
  
  reaper.atexit(save_current_settings)


