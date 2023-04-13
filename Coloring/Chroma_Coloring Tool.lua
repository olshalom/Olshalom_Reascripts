-- @description Chroma - Coloring Tool
-- @author olshalom, vitalker
-- @version 0.5
  
  

  -- CONSOLE OUTPUT --
  
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
  local floor = math.floor
  local SetTrackColor = reaper.SetTrackColor
  local ColorToNative = reaper.ColorToNative
  local CountTrackMediaItems = reaper.CountTrackMediaItems 
  local Undo_CanUndo2 = reaper.Undo_CanUndo2
  local ImGui_ColorEditFlags_DisplayHSV = reaper.ImGui_ColorEditFlags_DisplayHSV
  local defer = reaper.defer
  local insert = table.insert
  local UpdateArrange = reaper.UpdateArrange
  local Undo_EndBlock2 = reaper.Undo_EndBlock2
  local Undo_BeginBlock2 = reaper.Undo_BeginBlock2
  local GetDisplayedMediaItemColor = reaper.GetDisplayedMediaItemColor
  
  
  
  -- ImGui
  
  local ImGui_ColorConvertHSVtoRGB = reaper.ImGui_ColorConvertHSVtoRGB
  local ImGui_ColorConvertRGBtoHSV = reaper.ImGui_ColorConvertRGBtoHSV
  local ImGui_ColorConvertNative = reaper.ImGui_ColorConvertNative
  local ImGui_ColorConvertDouble4ToU32 = reaper.ImGui_ColorConvertDouble4ToU32
  local ImGui_GetWindowSize = reaper.ImGui_GetWindowSize
  local ImGui_PushStyleVar = reaper.ImGui_PushStyleVar
  local ImGui_PushStyleColor = reaper.ImGui_PushStyleColor
  local ImGui_StyleVar_FrameRounding = reaper.ImGui_StyleVar_FrameRounding
  local ImGui_StyleVar_GrabRounding = reaper.ImGui_StyleVar_GrabRounding
  local ImGui_StyleVar_PopupRounding = reaper.ImGui_StyleVar_PopupRounding
  local ImGui_StyleVar_ItemSpacing = reaper.ImGui_StyleVar_ItemSpacing
  local ImGui_StyleVar_FrameBorderSize = reaper.ImGui_StyleVar_FrameBorderSize
  local ImGui_Col_Border = reaper.ImGui_Col_Border
  local ImGui_BeginMenuBar = reaper.ImGui_BeginMenuBar
  local ImGui_BeginMenu = reaper.ImGui_BeginMenu
  local ImGui_AlignTextToFramePadding = reaper.ImGui_AlignTextToFramePadding
  local ImGui_Text = reaper.ImGui_Text
  local ImGui_PushItemWidth = reaper.ImGui_PushItemWidth
  local ImGui_Col_BorderShadow = reaper.ImGui_Col_BorderShadow
  local ImGui_BeginCombo = reaper.ImGui_BeginCombo
  local ImGui_Selectable = reaper.ImGui_Selectable
  local ImGui_SetItemDefaultFocus = reaper.ImGui_SetItemDefaultFocus
  local ImGui_SameLine = reaper.ImGui_SameLine
  local ImGui_EndCombo = reaper.ImGui_EndCombo
  local ImGui_PopStyleColor = reaper.ImGui_PopStyleColor
  local ImGui_RadioButtonEx = reaper.ImGui_RadioButtonEx
  local ImGui_Viewport_GetCenter = reaper.ImGui_Viewport_GetCenter
  local ImGui_GetWindowViewport = reaper.ImGui_GetWindowViewport
  local ImGui_OpenPopup = reaper.ImGui_OpenPopup
  local ImGui_EndMenu = reaper.ImGui_EndMenu
  local ImGui_EndMenuBar = reaper.ImGui_EndMenuBar
  local ImGui_SetNextWindowPos = reaper.ImGui_SetNextWindowPos
  local ImGui_Button = reaper.ImGui_Button
  local ImGui_BeginPopupModal = reaper.ImGui_BeginPopupModal
  local ImGui_Separator = reaper.ImGui_Separator
  local ImGui_SeparatorText = reaper.ImGui_SeparatorText
  local ImGui_Checkbox = reaper.ImGui_Checkbox
  local ImGui_CloseCurrentPopup = reaper.ImGui_CloseCurrentPopup
  local ImGui_EndPopup = reaper.ImGui_EndPopup
  local ImGui_ColorConvertU32ToDouble4 = reaper.ImGui_ColorConvertU32ToDouble4
  local ImGui_OpenPopupOnItemClick = reaper.ImGui_OpenPopupOnItemClick
  local ImGui_WindowFlags_MenuBar = reaper.ImGui_WindowFlags_MenuBar
  local ImGui_Dummy = reaper.ImGui_Dummy 
  local ImGui_MenuItem = reaper.ImGui_MenuItem
  local ImGui_SliderDouble = reaper.ImGui_SliderDouble
  local ImGui_SliderDouble2 = reaper.ImGui_SliderDouble2
  local ImGui_SliderFlags_None = reaper.ImGui_SliderFlags_None
  local ImGui_Col_Text = reaper.ImGui_Col_Text
  local ImGui_GetWindowWidth = reaper.ImGui_GetWindowWidth
  local ImGui_CloseCurrentPopup = reaper.ImGui_CloseCurrentPopup
  local ImGui_PopStyleVar = reaper.ImGui_PopStyleVar
  local ImGui_PushID = reaper.ImGui_PushID
  local ImGui_GetCursorPosY = reaper.ImGui_GetCursorPosY
  local ImGui_SetCursorPosY = reaper.ImGui_SetCursorPosY
  local ImGui_ColorEditFlags_NoPicker = reaper.ImGui_ColorEditFlags_NoPicker
  local ImGui_ColorEditFlags_NoTooltip = reaper.ImGui_ColorEditFlags_NoTooltip
  local ImGui_ColorEditFlags_NoBorder = reaper.ImGui_ColorEditFlags_NoBorder
  local ImGui_ColorButton = reaper.ImGui_ColorButton
  local ImGui_BeginDragDropTarget = reaper.ImGui_BeginDragDropTarget
  local ImGui_AcceptDragDropPayloadRGBA = reaper.ImGui_AcceptDragDropPayloadRGBA
  local ImGui_EndDragDropTarget = reaper.ImGui_EndDragDropTarget
  local ImGui_PopID = reaper.ImGui_PopID
  local ImGui_StyleVar_SeparatorTextBorderSize = reaper.ImGui_StyleVar_SeparatorTextBorderSize
  local ImGui_PopupFlags_MouseButtonLeft = reaper.ImGui_PopupFlags_MouseButtonLeft
  local ImGui_BeginPopup = reaper.ImGui_BeginPopup
  local ImGui_ColorPicker4 = reaper.ImGui_ColorPicker4
  local ImGui_ColorEditFlags_NoSmallPreview = reaper.ImGui_ColorEditFlags_NoSmallPreview
  local ImGui_ColorEditFlags_NoDragDrop = reaper.ImGui_ColorEditFlags_NoDragDrop
  local ImGui_ColorEditFlags_NoInputs = reaper.ImGui_ColorEditFlags_NoInputs
  local ImGui_Col_TitleBgActive = reaper.ImGui_Col_TitleBgActive
  local ImGui_Col_FrameBg = reaper.ImGui_Col_FrameBg
  local ImGui_Col_SliderGrab = reaper.ImGui_Col_SliderGrab
  local ImGui_Col_CheckMark = reaper.ImGui_Col_CheckMark
  local ImGui_StyleVar_WindowRounding = reaper.ImGui_StyleVar_WindowRounding
  local ImGui_StyleVar_WindowTitleAlign = reaper.ImGui_StyleVar_WindowTitleAlign
  local ImGui_PushFont = reaper.ImGui_PushFont
  local ImGui_WindowFlags_None = reaper.ImGui_WindowFlags_None
  local ImGui_SetNextWindowSize = reaper.ImGui_SetNextWindowSize
  local ImGui_Cond_FirstUseEver = reaper.ImGui_Cond_FirstUseEver
  local ImGui_Begin = reaper.ImGui_Begin
  local ImGui_End = reaper.ImGui_End
  local ImGui_PopFont = reaper.ImGui_PopFont
  local ImGui_IsKeyDown = reaper.ImGui_IsKeyDown
  local ImGui_Mod_Shortcut = reaper.ImGui_Mod_Shortcut
  local ImGui_Col_Button = reaper.ImGui_Col_Button
  local ImGui_Col_ButtonHovered = reaper.ImGui_Col_ButtonHovered
  local ImGui_Col_ButtonActive = reaper.ImGui_Col_ButtonActive
  local ImGui_PopFont = reaper.ImGui_PopFont
  
  
  
  -- PREDEFINE TABLES AS LOCAL --
  
  local sel_color = {} 
  local move_tbl = {tke = {}, trk_ip = {}}
  local col_tbl = nil
  local tr_clr = {}
  local pal_tbl = nil
  local cust_tbl = nil
  local sel_tbl = {it = {}, tke = {}, tr = {}}
  local custom_palette = {} 
 
  
  local function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
  end

  
  
  -- PREDEFINE VALUES --

  local test_item2        -- used again: line 874   
  local Item2             -- used again: line 723   
  local track2            -- used again: line 724   
  local test_track2       -- used again: line 888   
  local sel_tracks2 = 0   -- used again: line 930   
  local sel_items_sw      -- used again: line 943   
  local it_cnt_sw = nil
  local init_state = GetProjectStateChangeCount(0)
  local combo_items = { '   Track color', ' Custom color' }
  local tr_txt = '--' -- REST
  local tr_txt_h = 0.555 -- REST
  
  
  
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
    return ImGui_ColorConvertDouble4ToU32(r, g, b, a or 1.0)
  end
  
  
  --[[
  local function RgbaToArgb(rgba)
  
    return (rgba >> 8 & 0x00FFFFFF) | (rgba << 24 & 0xFF000000)
  end
  
  
  
  local function ArgbToRgba(argb)
  
    return (argb << 8 & 0xFFFFFF00) | (argb >> 24 & 0xFF)
  end
  ]]
  
  
  
  local function rgbToHsl(r, g, b)
  
    local max, min = math.max(r, g, b), math.min(r, g, b)
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
  
    local r, g, b =ImGui_ColorConvertHSVtoRGB(h, s, v)
    return ImGui_ColorConvertDouble4ToU32(r, g, b, a or 1.0)
  end
  
  
  --[[
  local function IntToRgba(Int_color)
  
    local r, g, b = ColorFromNative(Int_color)
    return ImGui_ColorConvertDouble4ToU32(r/255, g/255, b/255, a or 1.0)
  end
  ]]


  -- LOADING SETTINGS --
  
  if reaper.HasExtState("shiny_colorpalette", "selected_mode") then
    selected_mode       = tonumber(reaper.GetExtState("shiny_colorpalette", "selected_mode"))
  else selected_mode = 0 end
  
  if reaper.HasExtState("shiny_colorpalette", "colorspace") then -- REST --
    colorspace          = tonumber(reaper.GetExtState("shiny_colorpalette", "colorspace"))
  else colorspace = 0 end
  
  if reaper.HasExtState("shiny_colorpalette", "automode_id") then
    automode_id         = tonumber(reaper.GetExtState("shiny_colorpalette", "automode_id"))
  else automode_id = 1 end

  if reaper.HasExtState("shiny_colorpalette", "saturation") then
    saturation          = tonumber(reaper.GetExtState("shiny_colorpalette", "saturation"))
  else saturation = 0.8 end
  
  --custom_palette = {}
  if reaper.HasExtState("shiny_colorpalette", "custom_palette") then
    for i in string.gmatch(reaper.GetExtState("shiny_colorpalette", "custom_palette"), "-?%d+,?") do
      insert(custom_palette, tonumber(string.match(i, "-?%d+"))) --REST
    end
  else
    for m = 0, 23 do
      insert(custom_palette, HSL(m / 24+0.69, 0.1, 0.2, 1))
    end
  end
  
  if reaper.HasExtState("shiny_colorpalette", "lightness") then
    lightness           = tonumber(reaper.GetExtState("shiny_colorpalette", "lightness"))
  else lightness = 0.65 end
  
  if reaper.HasExtState("shiny_colorpalette", "darkness") then
    darkness            = tonumber(reaper.GetExtState("shiny_colorpalette", "darkness"))
  else darkness = 0.2 end
  
  if reaper.HasExtState("shiny_colorpalette", "rgba") then
    rgba                 = tonumber(reaper.GetExtState("shiny_colorpalette", "rgba"))
  else rgba = 630132991 end
  
  if reaper.HasExtState("shiny_colorpalette", "dont_ask") then
    if reaper.GetExtState("shiny_colorpalette", "dont_ask") == "false" then dont_ask = false end
    if reaper.GetExtState("shiny_colorpalette", "dont_ask") == "true" then dont_ask = true end
  else dont_ask = false end
  
  if reaper.HasExtState("shiny_colorpalette", "random_custom") then
    if reaper.GetExtState("shiny_colorpalette", "random_custom") == "false" then random_custom = false end
    if reaper.GetExtState("shiny_colorpalette", "random_custom") == "true" then random_custom = true end
  else random_custom = false end
  
  if reaper.HasExtState("shiny_colorpalette", "random_main") then
    if reaper.GetExtState("shiny_colorpalette", "random_main") == "false" then random_main = false end
    if reaper.GetExtState("shiny_colorpalette", "random_main") == "true" then random_main = true end
  else random_main = false end
  
  

  --[[
  retval2, tcptint = reaper.BR_Win32_GetPrivateProfileString("REAPER", "tinttcp", "", reaper.get_ini_file())
  tinttcp = tonumber(tcptint)
  tcp_value = 1920
  color_mode = false
  if tinttcp > tcp_value then
  color_mode = true
  end
  CurSetting = reaper.SNM_GetIntConfigVar( "tinttcp", -666 )
  ]]
  

--REST
--  dofile(reaper.GetResourcePath() ..
--       '/Scripts/ReaTeam Extensions/API/imgui.lua')('0.8')

  local ctx = reaper.ImGui_CreateContext('My script')
  local sans_serif = reaper.ImGui_CreateFont('sans-serif', 15)
  reaper.ImGui_Attach(ctx, sans_serif)
  reaper.ImGui_SetConfigVar(ctx, reaper.ImGui_ConfigVar_InputTrickleEventQueue(), 1)
  
  
  
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
      reaper.ShowMessageBox("Please drag a color to the first custom Palette Color.", "Important info", 0 )
    end
    generated_color = nil
    cust_tbl = nil
    return custom_palette
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
      reaper.ShowMessageBox("Please drag a color to the first custom Palette Color.", "Important info", 0 )
    end
    generated_color = nil
    cust_tbl = nil
    return custom_palette
  end
  
  
  
  -- TEST -- TEST -- TEST -- same principle as above
  
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
      reaper.ShowMessageBox("Please drag a color to the first custom Palette Color.", "Important info", 0 )
    end
    generated_color = nil
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
      reaper.ShowMessageBox("Please drag a color to the first custom Palette Color.", "Important info", 0 )
    end
    generated_color = nil
    cust_tbl = nil
    return custom_palette
  end
  
  
  
  local function custom_palette_double_split_complementary()
  
    for m, d in ipairs(main_palette)do
      if m < 24 then offset = -24 else offset = 0 end
      if m > 96 then offset2 = 24 else offset2 = 0 end
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
      reaper.ShowMessageBox("Please drag a color to the first custom Palette Color.", "Important info", 0 )
    end
    generated_color = nil
    cust_tbl = nil
    return custom_palette
  end
  
 
  
  -- GENERATE GRADIENT COLOR -- 
  
  function Generate_gradient_color(m, x, m2, y, percent)
    
    if m <= 0 then m = m+96 elseif m > 120 then m = m-96 else m = m end             
    num = ((m-1)//24)*24+((m+x-1)%24)+1                                             
    if m2 <= 0 then m2 = m2+96 elseif m2 > 120 then m2 = m2-96 else m = m end      
    num2 = ((m2-1)//24)*24+((m2+y-1)%24)+1                                          
    first_color = main_palette[num]
    second_color = main_palette[num2]
    local r1, g1, b1, a1 = ImGui_ColorConvertU32ToDouble4(first_color)
    local r2, g2, b2, a2 = ImGui_ColorConvertU32ToDouble4(second_color)
    compliment_percent = 100-percent
    perc_r = (r1/100*percent)+(r2/100*compliment_percent)
    perc_g = (g1/100*percent)+(g2/100*compliment_percent)
    perc_b = (b1/100*percent)+(b2/100*compliment_percent)
    new_color = ImGui_ColorConvertDouble4ToU32(perc_r, perc_g, perc_b, 1.0)
    return new_color
  end
  
  
  
  -- GENERATE COLOR -- 
  
  function Generate_color(m, x)
    
    if m <= 0 then m = m+96 elseif m > 120 then m = m-96 else m = m end         
    num3 = ((m-1)//24)*24+((m+x-1)%24)+1                                        
    main_color = main_palette[num3]
    return main_color
  end
  
  
  
  -- Set ToolBar Button ON --
  
  local function ToggleStateButton()
  
    is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
    state = reaper.GetToggleCommandStateEx( sec, cmd )
    
    if state == 0 then
    reaper.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
    reaper.RefreshToolbar2( sec, cmd )
    else reaper.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
     reaper.RefreshToolbar2( sec, cmd )
     end
  end
    
  

  -- AN OTHER MENU --

  --function demoShowExampleMenuFile()

    --local rv

  --  if ImGui_BeginMenu(ctx, 'Options') then
  --    local rv,demomenuenabled = r.ImGui_MenuItem(ctx, 'Enabled', '', demomenuenabled)
  --    if ImGui_BeginChild(ctx, 'child', 0, 60, true) then
  --      for i = 0, 9 do
  --        ImGui_Text(ctx, ('Scrolling Text %d'):format(i))
  --      end
  --      reaper.ImGui_EndChild(ctx)
  --    end
  --    local rv,demomenuf = ImGui_SliderDouble(ctx, 'Value', demomenuf, 0.0, 1.0)
  --    local rv,demomenuf = reaper.ImGui_InputDouble(ctx, 'Input', demomenuf, 0.1)
  --    local rv,demomenun = reaper.ImGui_Combo(ctx, 'Combo', demomenun, 'Yes\0No\0Maybe\0')
  --    ImGui_EndMenu(ctx)
  --  end



    -- Here we demonstrate appending again to the "Options" menu (which we already created above)
    -- Of course in this demo it is a little bit silly that this function calls BeginMenu("Options") twice.
    -- In a real code-base using it would make senses to use this feature from very different code locations.
  --  if ImGui_BeginMenu(ctx, 'Options') then -- <-- Append!
  --    rv,demomenub = r.ImGui_Checkbox(ctx, 'SomeOption', demomenub)
  --    r.ImGui_EndMenu(ctx)
  --  end

  --  if ImGui_BeginMenu(ctx, 'Disabled', false) then -- Disabled
  --    error('never called')
  --  end
  --  if ImGui_MenuItem(ctx, 'Checked', nil, true) then end
  --  if ImGui_MenuItem(ctx, 'Quit', 'Alt+F4') then end
  --end
  
  
  
  -- FUNCTION FOR VARIOUS COLORING --
  
  -- caching trackcolors -- could be extended and refined with a function written by justin --
  function generate_trackcolor_table()
  
    col_tbl = {tke={}, tr={}}
    local index=0
    for i=0, CountTracks(0) -1 do
      index = index+1
      local r, g, b = ColorFromNative(GetMediaTrackInfo_Value(GetTrack(0,i), "I_CUSTOMCOLOR"))
      col_tbl.tr[index] = ImGui_ColorConvertDouble4ToU32(r/255, g/255, b/255, a or 1.0)
      col_tbl.tke[index] = background_color_native(GetTrackColor(GetTrack(0,i)))
    end 
    
    return col_tbl
  end
  
  
  
  -- COLOR ITEMS TO TRACK COLOR IN PT-MODE  --
  
  local function automatic_item_coloring()
    
    if selected_mode == 1 then
      local local_ip
      local Item3 = GetSelectedMediaItem(0, 0)
      local itm_cnt = CountSelectedMediaItems(0)
      if Item3 and itm_cnt < 16001 then
        local track1 = GetMediaItemTrack(Item3)
        if Item2 == Item3 and track2 ~= track1 then
          for x=1, #move_tbl.tke do
            if move_tbl.trk_ip[x] == move_tbl.trk_ip[x-1] then
              SetMediaItemTakeInfo_Value(move_tbl.tke[x],"I_CUSTOMCOLOR", col_tbl.tke[local_ip])
            else
              local_ip = GetMediaTrackInfo_Value(GetMediaItemTake_Track(move_tbl.tke[x]), "IP_TRACKNUMBER")
              SetMediaItemTakeInfo_Value(move_tbl.tke[x],"I_CUSTOMCOLOR", col_tbl.tke[local_ip])
            end
          end
          it_cnt_sw= nil 
          cur_state3 = cur_state2
        end
        Item2 = Item3             -- for comparing and stop in defer
        track2 = track1           -- for comparing and stop in defer
        
      elseif Item3 and itm_cnt > 16000 then   -- change colors after undopoint
        local local_ip
        local cur_state2 = GetProjectStateChangeCount(0)
        if not cur_state3 then local cur_state3=cur_state2 end
        if (Undo_CanUndo2(0)=='Move media items')
              and cur_state2 ~= cur_state3 then
          for x=1, #move_tbl.tke do
            if move_tbl.trk_ip[x] == move_tbl.trk_ip[x-1] then
              SetMediaItemTakeInfo_Value(move_tbl.tke[x] ,"I_CUSTOMCOLOR", col_tbl.tke[local_ip])
            else
              local_ip = GetMediaTrackInfo_Value(GetMediaItemTake_Track(move_tbl.tke[x]), "IP_TRACKNUMBER")
              SetMediaItemTakeInfo_Value(move_tbl.tke[x] ,"I_CUSTOMCOLOR", col_tbl.tke[local_ip])
            end
          end
        end
      end 
    end
    UpdateArrange()
  end
       

   
  -- COLOR NEW ITEMS AUTOMATICALLY --
      
  local function Color_new_items_automatically()
    if ((Undo_CanUndo2(0)=='Insert media items'
      or Undo_CanUndo2(0)=='Recorded media')
        and (not cur_state4 or cur_state4<init_state)) 
          and automode_id == 1 
            and selected_mode == 1 then
      cur_state4 = GetProjectStateChangeCount(0)
      for i=0, CountSelectedMediaItems(0) -1 do
        local item = GetSelectedMediaItem(0,i)
        local tr_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(item), "IP_TRACKNUMBER")
        SetMediaItemTakeInfo_Value(GetActiveTake(item),"I_CUSTOMCOLOR", col_tbl.tke[tr_ip] )
      end
    end
  end
        
        

  -- COLOR SELECTED ITEMS TO TRACK COLOR --

  local function Color_selected_items_to_track_color()
  
    Undo_BeginBlock2(0) 
    for i=0, CountSelectedMediaItems(0) -1 do
      item = GetSelectedMediaItem(0, i)
      SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR", 0)
      it_cnt_sw= nil   -- to get highlighted highlighting
      if selected_mode == 1 then
        local track_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(item), "IP_TRACKNUMBER")
        SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", col_tbl.tke[track_ip])
      else
        SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", 0)
      end
    end
    Undo_EndBlock2(0, "Color selected items to track color", 4)
    --UpdateArrange()
  end
  


  -- HIGHLIGHTING ITEMS OR TRACK COLORS -- 

  local function get_sel_items_or_tracks_colors()

    local sel_items = CountSelectedMediaItems(0)
    local sel_tracks = CountSelectedTracks(0)
    local itemcolor   
    if sel_items > 0 then
      local test_item = GetSelectedMediaItem(0, 0)
      if test_item2 ~= test_item or sel_items ~= it_cnt_sw then
      
        -- set limit of selected items in pt mode --
        if selected_mode == 1 then
          if sel_items > 30000 then
            sel_items = 30000
            reaper.ShowMessageBox('More than 30 000 items are selected! \nFor safe performance, only 30 000 items get recolored when moving.', 'THRESHOLD REACHED', 0)
          end
        end
        
        sel_color = {}                                
        move_tbl = {tke = {}, trk_ip = {}}            
        sel_tbl = {it = {}, tke = {}, tr = {}}        
        items_mode = 1
        local index = 0
        local tr_index = 0
        for i=0, sel_items -1 do
          local item = GetSelectedMediaItem(0,i)
          index = index+1
          sel_tbl.it[index] = item
          sel_tbl.tke[index] = GetActiveTake(item)
          local itemtrack = GetMediaItemTrack(item)
          if itemtrack ~= itemtrack2 then
            tr_index = tr_index+1
            sel_tbl.tr[tr_index] = itemtrack
            itemtrack2 = itemtrack
          end
          if selected_mode == 1 then
            itemcolor = GetMediaItemInfo_Value(item,"I_CUSTOMCOLOR")
            if itemcolor == 0 then
              --get color for highlighting and save infos to table for moving items in pt mode
              itemcolor = GetMediaTrackInfo_Value(itemtrack, "I_CUSTOMCOLOR")
              move_tbl.trk_ip[index] = GetMediaTrackInfo_Value(itemtrack, "IP_TRACKNUMBER")   
              move_tbl.tke[index] = GetActiveTake(item)   
            end
          else
            itemcolor = GetDisplayedMediaItemColor(item)
          end
          if itemcolor ~= itemcolor2 then   
            local r, g, b = ColorFromNative(itemcolor)
            local items_colors = ImGui_ColorConvertDouble4ToU32(r/255, g/255, b/255, a or 1.0)
            insert(sel_color, items_colors) 
            itemcolor2 = itemcolor    
          end
        end
        test_track2 = nil
        itemtrack2 = nil          -- for comparing and stop in defer
        test_item2 = test_item    -- for comparing and stop in defer
        itemcolor2 = nil          -- for comparing and stop in defer
        it_cnt_sw = CountSelectedMediaItems(0) -- for highlighting, selected items_table get resetted
      end
      
    elseif sel_tracks > 0 then
      local test_track = GetSelectedTrack(0, 0)
      if test_track2 ~= test_track or sel_tracks2 ~= sel_tracks then    
        sel_color = {}
        items_mode = 0
        for i=0, sel_tracks -1 do
          local trackcolor = GetMediaTrackInfo_Value(GetSelectedTrack(0,i),"I_CUSTOMCOLOR") 
          local r, g, b = ColorFromNative(trackcolor)
          local tracks_colors = ImGui_ColorConvertDouble4ToU32(r/255, g/255, b/255, a or 1.0)
          insert(sel_color, tracks_colors)
          test_track2 = test_track    -- for comparing and stop in defer
          sel_tracks2 = sel_tracks    -- for comparing and stop in defer
          test_item2 = nil 
        end
      end 
    else
      sel_color = {}
      test_track2 = nil 
      test_item2 = nil
      items_mode = 2 -- REST
    end
    return sel_color, move_tbl --sel_tbl ,still not sure, if returning tables is needed
  end


  
  -- COLORING FOR MAIN AND CUSTOM PALETTE WIDGETS --
  
  local function coloring(tbl_tr, tbl_tk, clr_key) 
   
    local sel_items = CountSelectedMediaItems(0)
    local sel_tracks = CountSelectedTracks(0)
  
    Undo_BeginBlock2(0) 
    if sel_items > 0 then
      for i = 0, sel_items - 1 do
        SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", tbl_tr[clr_key])  
        if selected_mode == 1 then
          SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", tbl_tk[clr_key])  
        elseif selected_mode == 0 then
          SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", tbl_tr[clr_key])  
        end
  
        if ImGui_IsKeyDown(ctx, ImGui_Mod_Shortcut()) then
          SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", 0)
          if selected_mode == 0 then
          SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", 0)
          end
          for j = 0, #sel_tbl.tr -1 do
            SetMediaTrackInfo_Value(sel_tbl.tr[j+1],"I_CUSTOMCOLOR", tbl_tr[clr_key])
            if selected_mode == 1 then
              Color_items_to_track_color_in_pt_mode(sel_tbl.tr[j+1], tbl_tk[clr_key]) 
            end
          end
          col_tbl = nil          
        end
      end
      it_cnt_sw= nil  

    elseif sel_tracks > 0 then
      for i = 0, sel_tracks -1 do
        local track = GetSelectedTrack(0,i)
        SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", tbl_tr[clr_key])
        if selected_mode == 1 then
          Color_items_to_track_color_in_pt_mode(track, tbl_tk[clr_key]) 
        end
        if ImGui_IsKeyDown(ctx, ImGui_Mod_Shortcut()) then
          local cnt_items = reaper.CountTrackMediaItems(track)
          if cnt_items > 0 then
            for i = 0, cnt_items -1 do
              local new_item = GetTrackMediaItem( track, i )
              SetMediaItemInfo_Value(new_item,"I_CUSTOMCOLOR", 0)
              local new_take = GetActiveTake(new_item)
              if selected_mode == 1 then
                SetMediaItemTakeInfo_Value(new_take,"I_CUSTOMCOLOR", tbl_tk[clr_key])
              elseif selected_mode == 0 then
                SetMediaItemTakeInfo_Value(new_take,"I_CUSTOMCOLOR", 0)
              end
            end
          end
        end
        col_tbl = nil                 
        sel_tracks2 = nil   -- to get highlighting
      end
    end      
    Undo_EndBlock2(0, "Apply palette color", 1+4) 
    --UpdateArrange()
  end
  
  
  
  -- COLORING FOR CUSTOM COLOR AND LAST TOUCHED -- 
  
  local function coloring_cust_col(in_color) -- made it to input color
  
    if in_color then
      local color = ImGui_ColorConvertNative(in_color >>8)|0x1000000
      local background_color = Background_color_rgba(in_color)
      local sel_items = CountSelectedMediaItems(0)
      local sel_tracks = CountSelectedTracks(0)
      Undo_BeginBlock2(0) 
      if sel_items > 0 then
        for i = 0, sel_items -1 do
          SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", color)
          if selected_mode == 1 then
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", background_color)
          else--if selected_mode == 0 then
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", color)
          end
          if ImGui_IsKeyDown(ctx, ImGui_Mod_Shortcut()) then
            SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", 0)
            if selected_mode == 0 then
              SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", 0)
            end
            for j = 0, #sel_tbl.tr -1 do
              SetMediaTrackInfo_Value(sel_tbl.tr[j+1],"I_CUSTOMCOLOR", color)
              if selected_mode == 1 then
                Color_items_to_track_color_in_pt_mode(sel_tbl.tr[j+1], background_color) 
              end
            end
          end
        end
        it_cnt_sw = nil     -- to get highlighting
        col_tbl = nil              
          
      elseif sel_tracks > 0 then
        for i = 0, sel_tracks -1 do
          local track = GetSelectedTrack(0,i)
          SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", color)
          if selected_mode == 1 then
            for j=0, GetTrackNumMediaItems(track, 0) -1 do
              local trackitem = GetTrackMediaItem(track, j)
              local trackitemcolor = GetMediaItemInfo_Value(trackitem,"I_CUSTOMCOLOR")
              if trackitemcolor == 0 then
                SetMediaItemTakeInfo_Value(GetActiveTake(trackitem),"I_CUSTOMCOLOR", background_color)
              end
            end
          end
          if ImGui_IsKeyDown(ctx, ImGui_Mod_Shortcut()) then
            local cnt_items = reaper.CountTrackMediaItems(track)
            if cnt_items > 0 then
              for i = 0, cnt_items -1 do
                local new_item =  GetTrackMediaItem( track, i )
                SetMediaItemInfo_Value(new_item,"I_CUSTOMCOLOR", 0)
                local new_take = GetActiveTake(new_item)
                if selected_mode == 1 then
                  SetMediaItemTakeInfo_Value(new_take,"I_CUSTOMCOLOR", background_color)
                else
                  SetMediaItemTakeInfo_Value(new_take,"I_CUSTOMCOLOR", 0)
                end
              end
            end
          end
        end
        sel_tracks2 = nil       -- to get highlighting
        col_tbl = nil           -- regenerate track_table
      end
      Undo_EndBlock2(0, "Apply palette color", 1+4) 
    end
    --UpdateArrange()
  end
  
  
  
  -- BORROWED FROM AMALGAMAS GREAT REANOIR SCRIPT -- 
  
   local function Color_selected_tracks_with_gradient()
  
    local seltracks = CountSelectedTracks(0)
    if seltracks > 0 then
      local first_color = GetMediaTrackInfo_Value(GetSelectedTrack(0, 0), "I_CUSTOMCOLOR")
      if first_color == 0 or nil then
        reaper.MB("Set first selected track to a custom color in order to make a gradient.", "FAILED", 0 )
      else
      
        Undo_BeginBlock2(0)
        local last_color = GetMediaTrackInfo_Value(GetSelectedTrack(0, CountSelectedTracks(0)-1), "I_CUSTOMCOLOR")
        if first_color == last_color then
          reaper.MB("Please make last selected trackcolor different from first.", "FAILED", 0 )
          return end
        local r2, g2, b2 = ColorFromNative(last_color)
        local firstcolor_r, firstcolor_g, firstcolor_b = ColorFromNative(first_color)
        local r_step = (r2-firstcolor_r)/(seltracks-1)
        local g_step = (g2-firstcolor_g)/(seltracks-1)
        local b_step = (b2-firstcolor_b)/(seltracks-1)
        for i=1,seltracks-1 do
          local value_r,value_g,value_b = floor(0.5+firstcolor_r+r_step*i), floor(0.5+firstcolor_g+g_step*i), floor(0.5+firstcolor_b+b_step*i)
          local track = GetSelectedTrack(0, i)
          SetTrackColor(track, ColorToNative(value_r, value_g, value_b))
          if selected_mode == 1 then
            Color_items_to_track_color_in_pt_mode(track, Background_color_R_G_B(value_r,value_g,value_b))
            it_cnt_sw= nil   -- to get highlighting
          end
        end
        Undo_EndBlock2(0, "Color selected tracks with gradient colors", 1+4)
        col_tbl = nil                 
      end
    else
      reaper.MB( "Please select at least 3 tracks", "Cannot create gradient colors", 0 )
    end
  end
  
  
  
  -- Thanks Embass for this function! --
   
  local function get_child_tracks(folder_track)
    local all_tracks = {}
      
    if GetMediaTrackInfo_Value(folder_track, "I_FOLDERDEPTH") ~= 1 then
      return all_tracks
    end
    local tracks_count = CountTracks(0)
    local folder_track_depth = reaper.GetTrackDepth(folder_track)  
    local track_index = GetMediaTrackInfo_Value(folder_track, "IP_TRACKNUMBER")
    for i = track_index, tracks_count - 1 do
      local track = GetTrack(0, i)
      local track_depth = reaper.GetTrackDepth(track)
      if track_depth > folder_track_depth then      
        insert(all_tracks, track)
      else
        break
      end
    end
    return all_tracks
  end
  
  
 
  -- COLOR CHILDS TO PARENTCOLOR --
   
  local function color_childs_to_parentcolor()
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    for i=0, CountSelectedTracks(0) -1 do
      track = GetSelectedTrack(0,i)
      trackcolor = GetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR")
      ip = GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
      local child_tracks = get_child_tracks(track)
      for i = 1, #child_tracks do
        SetTrackColor(child_tracks[i], trackcolor)
        if selected_mode == 1 then
          Color_items_to_track_color_in_pt_mode(child_tracks[i], col_tbl.tke[ip])
        end
      end
    end
    col_tbl = nil                 
    Undo_EndBlock2(0, "Set children to parent color", 1+4)
    
  end
  

  
  -- PREPARE BACKGROUND COLOR FOR PT-MODE RGBA (DOUBLE4) --
  
  function Background_color_rgba(color)
  
    local r, g, b, a = ImGui_ColorConvertU32ToDouble4(color)
    local h, s, v = ImGui_ColorConvertRGBtoHSV(r, g, b, 1.0)
    local s=s/3.7
    local v=v+0.5
    if v>0.88 then v = 0.88 end
    background_color = ImGui_ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end
  
  
  
  -- PREPARE BACKGROUND COLOR FOR PT-MODE INTEGER --
  
  function background_color_native(color)
    
    local r, g, b = ColorFromNative(color)
    local h, s, v = ImGui_ColorConvertRGBtoHSV(r, g, b, 1.0)
    local s=s/3.7
    local v=v+0.5
    if v>0.88 then v = 0.88 end
    background_color = ImGui_ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end
  
  
  
   -- PREPARE BACKGROUND COLOR FOR PT-MODE R, G, B --
  
  function Background_color_R_G_B(r,g,b)
  
    local h, s, v = ImGui_ColorConvertRGBtoHSV(r, g, b, 1.0)
    local s=s/3.7
    local v=v+0.5
    if v>0.88 then v = 0.88 end
    background_color = ImGui_ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end
  
  

  function Color_items_to_track_color_in_pt_mode(track, background_color) 
  
    for j=0, GetTrackNumMediaItems(track, 0) -1 do
      local trackitem = GetTrackMediaItem(track, j)
      local trackitemcolor = GetMediaItemInfo_Value(trackitem,"I_CUSTOMCOLOR")
      if trackitemcolor == 0 then
        SetMediaItemTakeInfo_Value(GetActiveTake(trackitem),"I_CUSTOMCOLOR", background_color)
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
    
  
  
  -- FOR AUTOCOLORING TRACKS TO PALETTES --

  -- COLOR MULTIPLE TRACKS TO PALETTE COLORS--
  
  local function Color_multiple_tracks_to_palette_colors()
  
    local numbers = shuffled_numbers (120)
    local first_ip = GetMediaTrackInfo_Value(GetSelectedTrack(0, 0), "IP_TRACKNUMBER")
    if not first_ip then return end 
    local first_color = (col_tbl.tr[first_ip])
    color_state = 0
    reaper.Undo_BeginBlock2(0)
    for p=1, #main_palette do
      if first_color==main_palette[p] then
        color_state = 1
        for i=0, CountSelectedTracks(0) -1 do
          if random_main then value = numbers[i%120+1]
          else value = (i+p-1)%120+1 end
          track = GetSelectedTrack(0, i)
          SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR",  pal_tbl.tr[value])
          if selected_mode == 1 then
            Color_items_to_track_color_in_pt_mode(track, pal_tbl.tk[value])
          end
        end
      end
    end
    
    if color_state ~= 1 then
      for i=0, CountSelectedTracks(0) -1 do
        track = GetSelectedTrack(0, i)
        if random_main then value = numbers[i%120+1]
        else value = i%120+1 end
        SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", pal_tbl.tr[value])
        if selected_mode == 1 then
          Color_items_to_track_color_in_pt_mode(track, pal_tbl.tk[value])
        end
      end  
    end
    Undo_EndBlock2(0, "Color multiple tracks to palette colors", 1+4)
    col_tbl = nil                 
    sel_tracks2 = nil  
    it_cnt_sw= nil
  end
    
    

  -- COLOR MULTIPLE TRACKS TO CUSTOM PALETTE  --
  
  local function Color_multiple_tracks_to_custom_palette()
  
    local sel_tracks = CountSelectedTracks(0)
    if sel_tracks > 0 then
      local numbers = shuffled_numbers (24)
      local first_ip = GetMediaTrackInfo_Value(GetSelectedTrack(0, 0), "IP_TRACKNUMBER")
      local first_color = (col_tbl.tr[first_ip])
      color_state = 0
      reaper.Undo_BeginBlock2(0)
      for r=1, #custom_palette do
        if first_color==custom_palette[r] then
          color_state = 1
          for i=0, sel_tracks -1 do
            track = GetSelectedTrack(0, i)
            if random_custom then value = numbers[i%24+1]
            else value = (i+r-1)%24+1 end
            SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", cust_tbl.tr[value])
            if selected_mode == 1 then
              Color_items_to_track_color_in_pt_mode(track, cust_tbl.tk[value])
            end
          end
        end
      end
      if color_state ~= 1 then
        for i=0, sel_tracks -1 do
          track = GetSelectedTrack(0, i)
          if random_custom then value = numbers[i%24+1]
          else value = i%24+1 end
          SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", cust_tbl.tr[value])
          if selected_mode == 1 then
            Color_items_to_track_color_in_pt_mode(track, cust_tbl.tk[value])
          end
        end  
      end
      Undo_EndBlock2(0, "Color multiple tracks to custom palette", 1+4)
      col_tbl = nil                 
      sel_tracks2 = nil   -- to get highlighting
      it_cnt_sw= nil
    end
  end

  
  
  -- VODKA --

  -- COLOR NEW TRACKS AUTOMATICALLY --
    
  local function Color_new_tracks_automatically()
  
    local track_number = CountTracks(0)
    local new_track = GetSelectedTrack(0, 0)
    if not track_number2 then track_number2 = 0 end
    if track_number2 < track_number  then
      if new_track then 
        local found = 0
        local new_track = GetSelectedTrack(0, 0) -- TEST --
        if stored_val then
          SetMediaTrackInfo_Value(new_track,"I_CUSTOMCOLOR", pal_tbl.tr[stored_val%120+1])
          stored_val = stored_val+1
          saved_tr_ip = saved_tr_ip +1  -- TEST --
        else
          local prev_tr_ip = GetMediaTrackInfo_Value(new_track, 'IP_TRACKNUMBER')-1
          if prev_tr_ip > 0 then
            for o=1, #main_palette do
              if main_palette[o]==col_tbl.tr[prev_tr_ip] then
                SetMediaTrackInfo_Value(new_track,"I_CUSTOMCOLOR", pal_tbl.tr[o%120+1])
                found = 1 
                stored_val = o+1
              end
            end
            if found ~= 1 then
              SetMediaTrackInfo_Value(new_track,"I_CUSTOMCOLOR", pal_tbl.tr[1])
              stored_val = 1
            end
            saved_tr_ip = prev_tr_ip  -- TEST --
          else
            SetMediaTrackInfo_Value(new_track,"I_CUSTOMCOLOR", pal_tbl.tr[1])
            stored_val = 1
            saved_tr_ip = 0  -- TEST --
          end 
        end
        track_number2 = track_number
        sel_tracks2 = nil  
        col_tbl = nil
        goto continue
      end
      
    -- VODKA --
    
    elseif track_number2 > track_number then
      --and reaper.Undo_CanRedo2('Add new track')  then
      tr_cnt = CountTracks(0)
      if tr_cnt > 0 then
        for i=0, tr_cnt -1 do
          prev_trk = reaper.GetTrack(0, i)
          prev_tr_ip = GetMediaTrackInfo_Value(prev_trk, 'IP_TRACKNUMBER')
          if prev_tr_ip == saved_tr_ip  then
            SetMediaTrackInfo_Value(prev_trk,"I_CUSTOMCOLOR", pal_tbl.tr[stored_val%120-1])
            saved_tr_ip = saved_tr_ip -1
            stored_val = stored_val -1
          end  
        end
        track_number2 = track_number
        sel_tracks2 = nil 
        col_tbl = nil
      else
        stored_val = nil
        track_number2 = 0
      end
    end
    
    ::continue::
  end
  
  
  -- END --
  
  
  
  -- BUTTON TEMPLATE 1 --
  
  local function button_color(h, s, v, a, name, size_w, size_h, small, round)
    local n = 0
    local state
    
    ImGui_PushStyleColor(ctx, ImGui_Col_Button(), HSV(h, 0, 0.3, a/3)) n=n+1
    ImGui_PushStyleColor(ctx, ImGui_Col_ButtonHovered(), HSV(h, s, v, a/2)) n=n+1
    ImGui_PushStyleColor(ctx, ImGui_Col_ButtonActive(), HSV(h, s, v, a)) n=n+1
    if not small then state = ImGui_Button(ctx, name, size_w, size_h)
    else state = reaper.ImGui_SmallButton(ctx, name) end
    ImGui_PopStyleColor(ctx, n)
  
    local draw_list = reaper.ImGui_GetWindowDrawList(ctx)
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
    if b_h < 0.5 then bs_h = b_h + 0.5 else bs_h = b_h - 0.5 end
    
    ImGui_PushStyleColor(ctx, ImGui_Col_Button(), HSV(h, s, v-0.2, a)) n=n+1
    ImGui_PushStyleColor(ctx, ImGui_Col_ButtonHovered(), HSV(h, s, v, a)) n=n+1
    ImGui_PushStyleColor(ctx, ImGui_Col_ButtonActive(), HSV(h, s, v, a)) n=n+1
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_FrameRounding(),rounding) m=m+1
    if border == true then 
      ImGui_PushStyleColor(ctx, ImGui_Col_Border(), HSV(b_h, b_s, b_v, b_a))n=n+1
      ImGui_PushStyleVar(ctx, ImGui_StyleVar_FrameBorderSize(), b_thickness) m=m+1 
      ImGui_PushStyleColor(ctx, ImGui_Col_BorderShadow(), HSV(bs_h, b_s, b_v-0.25, b_a))n=n+1
    end
    state = ImGui_Button(ctx, name, size_w, size_h)
    ImGui_PopStyleColor(ctx, n)
    ImGui_PopStyleVar(ctx, m)
    return state
  end
    


  -- PALETTE FUNCTION --

  local function Palette()

    local main_palette = {}
    if colorspace == 1 then colormode = HSV
    else colormode = HSL end
    
    darkness_offset = 0.0
    
    for n = 0, 23 do
      insert(main_palette, colormode(n / 24+0.69, saturation, lightness, 1))
    end
    for n = 0, 23 do
      insert(main_palette, colormode(n / 24+0.69, saturation, 0.75 - ((1-lightness)/4*3)+(darkness/4), 1))
    end
    for n = 0, 23 do
      insert(main_palette, colormode(n / 24+0.69, saturation, 0.5 - ((1-lightness)/2)+(darkness/2), 1))
    end
    for n = 0, 23 do
      insert(main_palette, colormode(n / 24+0.69, saturation, 0.25 - ((1-lightness)/4)+(darkness/4*3)+darkness_offset/4*3, 1))
    end
    for n = 0, 23 do
      insert(main_palette, colormode(n / 24+0.69, saturation, darkness+darkness_offset, 1))
    end

    return main_palette
  end
  
 
 
  -- for simply recall pregenerated colors --
  
  function generate_palette_color_table()
  
    pal_tbl = {tr={}, tk={}}
    for i=1, #main_palette do
      pal_tbl.tr[i] = ImGui_ColorConvertNative(main_palette[i] >>8)|0x1000000
      pal_tbl.tk[i] = Background_color_rgba(main_palette[i])
    end 
    return pal_tbl
  end
  
  
  
  -- for simply recall pregenerated colors --
  
  function generate_custom_color_table()
  
    cust_tbl = {tr={}, tk={}}
    for y=1, #custom_palette do
      cust_tbl.tr[y] = ImGui_ColorConvertNative(custom_palette[y] >>8)|0x1000000
      cust_tbl.tk[y] = Background_color_rgba(custom_palette[y])
    end 
    return cust_tbl
  end
  
  
  
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

  

  -- THE COLORPALETTE GUI--

  local function ColorPalette()

    local w, h = ImGui_GetWindowSize(ctx)
    local max_button_w = (w-2*24)/25
    if max_button_w *5+90 > h then
      size = (h-2*5-50)/6
    else
      size = max_button_w
    end
    
    
    
    -- SAVE ALL TRACKS AND ITS COLORS TO A TABLE --
    
    local tr_cnt = CountTracks(0)
    local tr_cnt2
    if not col_tbl 
      or ((Undo_CanUndo2(0)=='Change track order')
          or  tr_cnt ~= tr_cnt2) then
      generate_trackcolor_table()
      tr_cnt2 = tr_cnt
    end
    
    
 
    var = 0 
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_FrameRounding(), 6); var=var+1 -- for settings menu sliders
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_GrabRounding(), 2); var=var+1
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_PopupRounding(), 2); var=var+1
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, 16); var=var+1
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_FrameBorderSize(),1) var=var+1
    
    
    
    col = 0
    ImGui_PushStyleColor(ctx, ImGui_Col_Border(),0x303030ff) col= col+1
    ImGui_PushStyleColor(ctx, ImGui_Col_BorderShadow(), 0x10101050) col= col+1
 
    
    
    -- MENUBAR AND SETTINGS POPUP --
    
    ImGui_BeginMenuBar(ctx)
    if ImGui_BeginMenu(ctx, 'Settings') then
    
      
      ImGui_AlignTextToFramePadding(ctx)
      ImGui_Text(ctx, 'Color new items to:')
      ImGui_PushItemWidth(ctx, 130)
      ImGui_SameLine(ctx, 0.0, 6)
      
      local auto_coloring_preview_value = combo_items[automode_id]
      
      ImGui_PushStyleColor(ctx, ImGui_Col_Border(), HSV(0.3, 0.1, 0.5, 1))
      ImGui_PushStyleColor(ctx, ImGui_Col_FrameBg(), HSV(0.65, 0.4, 0.2, 1))
      ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(), HSV(0.65, 0.2, 0.4, 1))
      if ImGui_BeginCombo(ctx, '##5', auto_coloring_preview_value, 0) then
        for i=1, #combo_items do
          local is_selected = automode_id == i
          if ImGui_Selectable(ctx, combo_items[i], is_selected) then
            automode_id = i
          end
      
          -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
          if is_selected then
            ImGui_SetItemDefaultFocus(ctx)
          end
        end
        ImGui_EndCombo(ctx)
      end
      ImGui_PopStyleColor(ctx, 3)

      
      -- MODE SELECTION --
      
      rv, selected_mode = ImGui_RadioButtonEx(ctx, 'Normal Mode', selected_mode, 0); ImGui_SameLine(ctx, 0 , 25)
      if ImGui_RadioButtonEx(ctx, 'ProTools Mode (experimental)', selected_mode, 1) then
        if not dont_ask then
          ImGui_OpenPopup(ctx, 'ProTools Mode')
        else selected_mode = 1
        end
      end
      
      
      -- PT MODE POPUP --
      
      -- Always center this window when appearing
      local center = {ImGui_Viewport_GetCenter(ImGui_GetWindowViewport(ctx))}
      ImGui_SetNextWindowPos(ctx, center[1], center[2], reaper.ImGui_Cond_Appearing(), 0.5, 0.5)
      if ImGui_BeginPopupModal(ctx, 'ProTools Mode', nil, reaper.ImGui_WindowFlags_AlwaysAutoResize()) then
      
        ImGui_Text(ctx, 'To use the full potentual of ProTools mode,\nmake sure the CustomColor-Preferences are set correctly\nor the actual used theme provides the value 1922 or 1923\nfor tinttcp inside its rtconfig-file!\nMore Infos:')
               if ImGui_Button(ctx, 'Open PDF in browser', 200, 20) then
          reaper.CF_ShellExecute('https://drive.google.com/file/d/1cUcvToeOLldaMxPS-RE744aSMtA1PJ2c/view?usp=sharing')
        end
        
        ImGui_Separator(ctx)
        ImGui_Text(ctx, 'Continue with ProTools mode?\n\n')
        rv, dont_ask = ImGui_Checkbox(ctx, " Don't ask me next time", dont_ask)
        
        if ImGui_Button(ctx, 'OK', 120, 0) then ImGui_CloseCurrentPopup(ctx); selected_mode = 1 end
        ImGui_SetItemDefaultFocus(ctx)
        ImGui_SameLine(ctx)
        
        if ImGui_Button(ctx, 'Cancel', 120, 0) then ImGui_CloseCurrentPopup(ctx); selected_mode = 0  end
        ImGui_EndPopup(ctx)
      end
      
      ImGui_EndMenu(ctx)
      
    end -- Settings Menu
    ImGui_EndMenuBar(ctx)
    
    
    -- PALETTE MENU --
        
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, 10); var=var+1 
    
    if button_action(0.555, 0.59, 0.6, 1, 'Palette Menu', 140, 21, true, 4, 0.555, 0.2, 0.3, 0.55, 5) then 
      ImGui_OpenPopup(ctx, 'Palette Menu')
    end
 
    if ImGui_BeginPopupModal(ctx, 'Palette Menu', nil, ImGui_WindowFlags_MenuBar()) then
      if ImGui_BeginMenuBar(ctx) then
        if ImGui_BeginMenu(ctx, 'File') then
          if ImGui_MenuItem(ctx, 'Some menu item') then end
          ImGui_EndMenu(ctx)
        end
        ImGui_EndMenuBar(ctx)
      end
     
      
      -- GENERATE CUSTOM PALETTES -- 
      
      ImGui_AlignTextToFramePadding(ctx)
      ImGui_Text(ctx, 'Generate Custom Palette:')
      
      
      
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
      
      
          
      ImGui_Dummy(ctx, 0, 10)
      rv, random_custom = ImGui_Checkbox(ctx, "Random coloring for Custom Palette", random_custom)
         
      if button_color(0.14, 0.9, 0.7, 1, 'Reset Custom', 160, 19, false, 6)  then
        custom_palette = {}
        for m = 0, 23 do
          insert(custom_palette, HSL(m / 24+0.69, 0.1, 0.2, 1))
        end
      end
      
      ImGui_Dummy(ctx, 0, 10)
      ImGui_Separator(ctx)
      
      
      -- MAIN PALETTE SETTINGS --
      
      ImGui_Text(ctx, 'MAIN PALETTE SETTINGS:')
      ImGui_Dummy(ctx, 0, 10)
      
      if ImGui_RadioButtonEx(ctx, ' HSL', colorspace, 0) then
        colorspace = 0; lightness =0.7; darkness =0.20 
      end
            
      ImGui_SameLine(ctx)
            
      if ImGui_RadioButtonEx(ctx, ' HSV', colorspace, 1) then
        colorspace = 1; lightness =1; darkness =0.3
      end
          
      if colorspace == 1 then lightness_range = 1 else lightness_range = 1-0.2 end
      
      rv, saturation = ImGui_SliderDouble(ctx, ' saturation', saturation, 0.3, 1.0, '%.3f', ImGui_SliderFlags_None())
      rv,darkness, lightness = ImGui_SliderDouble2(ctx, ' darkness - lightness', darkness, lightness, 0.12, lightness_range)
      
      ImGui_Dummy(ctx, 0, 10)
      rv, random_main = ImGui_Checkbox(ctx, "Random coloring for Main Palette ", random_main)
      
      if button_color(0.14, 0.9, 0.7, 1, 'Reset Main', 160, 19, false, 6)  then
        saturation = 0.8; lightness =0.65; darkness =0.20; dont_ask = false; colorspace = 0
      end
            
      --local rv,demomenuf = ImGui_SliderDouble(ctx, 'Value', demomenuf, 0.0, 1.0)
      --local rv,demomenuf = reaper.ImGui_InputDouble(ctx, 'Input', demomenuf, 0.1)
      --local rv,demomenun = reaper.ImGui_Combo(ctx, 'Combo', demomenun, 'Yes\0No\0Maybe\0')
          
      w2 = ImGui_GetWindowWidth(ctx) -104
      if w2 < 0 then element_position2 = 0 else element_position2 = w2 end
          
      ImGui_Dummy(ctx, 0, 10)
      ImGui_SameLine(ctx, 0.0, element_position2)
    
      if ImGui_Button(ctx, 'Close', 80, 0) then
        ImGui_CloseCurrentPopup(ctx)
      end
      ImGui_EndPopup(ctx)
      
    end
    
    
    -- UPPER RIGHT CORNER --
    
    -- MODE ELEMENT POSITION --
    if selected_mode == 1 then
      if w-258 < 0 then element_position = 0 else element_position = w-352 end 
    else
      if w-258 < 0 then element_position = 0 else element_position = w-258 end 
    end
    
    ImGui_SameLine(ctx, 0, element_position)
    
    if selected_mode == 1 then text = 'PT mode:  ' else text = '' end
    ImGui_Text(ctx, text)
    ImGui_SameLine(ctx, 0, 0)
    if selected_mode == 1 then
      ImGui_RadioButtonEx(ctx, '##', selected_mode, 1) 
    end
        
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, 12) var=var+1 --custom palette upper space
    ImGui_SameLine(ctx, 0, 10)
    
    
    if items_mode == 0 then 
      tr_txt = 'Tracks'
      tr_txt_h = 0.555
    elseif items_mode == 1 then 
      tr_txt = 'Items'
      tr_txt_h = 0.15
    elseif items_mode == 2 then 
      tr_txt = '--'
      tr_txt_h = 0.555
    end
    
    ImGui_PushStyleColor(ctx, ImGui_Col_Text(), 0xffe8acff)
    
    if button_action(tr_txt_h, 0.5, 0.4, 1, tr_txt, 80, 19, true, 4, 0.555, 0.2, 0.3, 0.55, 3) then
      -- create table for selected items, would be cool here
      if items_mode == 0 then 
        reaper.Main_OnCommand(40769, 0) 
        items_mode = 2
      elseif items_mode == 1 then 
        reaper.Main_OnCommand(40289, 0)
        if CountSelectedTracks(0)>0 then items_mode = 0 -- REST
        else items_mode = 2 end
      elseif items_mode == 2 then 
        -- reselect items from saved selected items table, would be cool here
      end
    end
    
    ImGui_PopStyleColor(ctx)
    


    -- Can get deleted
    --[[
    if items_mode == 1 then
      ImGui_PushStyleColor(ctx, ImGui_Col_Text(), 0xffe8acff)
      if button_action(0.555, 0.59, 0.2, 1, 'Items', 80, 19, true, 4, 0.555, 0.2, 0.3, 0.55, 3) then
        -- create table for selected items, would be cool here
        reaper.Main_OnCommand(40289, 0)
        items_mode = 0
      end
      ImGui_PopStyleColor(ctx)
    elseif items_mode == 0 then
      if button_action(0.555, 0.59, 0.2, 1, 'Tracks' , 80, 19, true, 4, 0.555, 0.2, 0.3, 0.55, 3) then
        reaper.Main_OnCommand(40769, 0) 
        items_mode = 2
      end
    else
      if button_action(0.555, 0.59, 0.2, 1, '--' , 80, 19, true, 4, 0.555, 0.2, 0.3, 0.55, 3) then
        -- reselect items from saved selected items table, would be cool here
      end
    end
    ]]
    
    ImGui_PopStyleVar(ctx, var) -- for upper part
    ImGui_PopStyleColor(ctx, col) -- for upper part


    -- -- GENERATING TABLES -- --
    
    if not main_palette
      or saturation ~= saturation2
        or darkness ~= darkness2
          or lightness ~= lightness2
            or colorspace ~= colorspace2 then
      main_palette = Palette()
      pal_tbl = generate_palette_color_table()
    end
    
    if not cust_tbl then
      cust_tbl = generate_custom_color_table()
    end
  
  
    -- CALLING FUNCTIONS -- 
    local sel_colors = get_sel_items_or_tracks_colors()
    
    Color_new_items_automatically()   
    automatic_item_coloring() 
    
    
    -- for function below --
    --if Undo_CanUndo2(0)~='Add new track' then
      --stored_val = nil
    --end
     
    Color_new_tracks_automatically()
    
    
    
   
    
    ---- ---- MIDDLE PART ---- ----
    
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_FrameRounding(),2)    -- general rounding for color widgets
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, 0) --first seperator upper space
    
    -- CUSTOM COLOR PALETTE --
    
    local distinct_col2 = {}
    for m=1, #custom_palette do
      ImGui_PushID(ctx, m)
      if ((m - 1) % 24) ~= 0 then
        ImGui_SameLine(ctx, 0.0, 2)
      else retval = ImGui_GetCursorPosY(ctx)
        ImGui_SetCursorPosY(ctx, retval -2)
      end
      
      local highlight2 = false
      local palette_button_flags2 =
                    ImGui_ColorEditFlags_NoPicker() |
                    ImGui_ColorEditFlags_NoTooltip()
      for l=1, #sel_colors do
        if sel_colors[l]==custom_palette[m] then
          if #distinct_col2 == 0 or sel_colors[l] ~= distinct_col2[#distinct_col2] then
            insert(distinct_col2, sel_colors[l])
            ImGui_PushStyleColor(ctx, ImGui_Col_Border(),0xffffffff)
            ImGui_PushStyleVar(ctx, ImGui_StyleVar_FrameBorderSize(),2)
            highlight2 = true
          end
        end
      end
      if highlight2 == false then
        palette_button_flags2 = palette_button_flags2 | ImGui_ColorEditFlags_NoBorder()
      end
      if ImGui_ColorButton(ctx, '##palette2', custom_palette[m],  palette_button_flags2, size, size) then
        widgetscolorsrgba = (custom_palette[m]) -- is it needed anymore? Yes for highlighting
        coloring(cust_tbl.tr, cust_tbl.tk, m)
      end
      
      if highlight2 == true then
        ImGui_PopStyleColor(ctx,1)
        ImGui_PopStyleVar(ctx,1)
      end
       
      -- Allow user to drop colors into each palette entry. Note that ColorButton() is already a
      -- drag source by default, unless specifying the ImGuiColorEditFlags_NoDragDrop flag.
      if ImGui_BeginDragDropTarget(ctx) then
        local rv,drop_color = ImGui_AcceptDragDropPayloadRGBA(ctx)
        if rv then
          custom_palette[m] = drop_color 
          cust_tbl = nil
        end
        ImGui_EndDragDropTarget(ctx)
      end
      ImGui_PopID(ctx)
    end
    
    ImGui_PopStyleVar(ctx,1)
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, -2)
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_SeparatorTextBorderSize(),3) 
    ImGui_SeparatorText(ctx, '')
    ImGui_PopStyleVar(ctx,2)


    -- CUSTOM COLOR WIDGET --
    
    -- BORDERCOLORING FOR "EDIT CUSTOM COLOR" AND COLORPICKER --
    rc, gc, bc, ac =ImGui_ColorConvertU32ToDouble4(rgba)
    hc, sc, vc = ImGui_ColorConvertRGBtoHSV(rc, gc, bc)
    
    if button_color(hc, sc, vc, 1, 'Edit custom color', 150, 21, false, 2) then
      ImGui_OpenPopupOnItemClick(ctx, 'Choose color', ImGui_PopupFlags_MouseButtonLeft())
    end
    
    local open_popup = ImGui_BeginPopup(ctx, 'Choose color')
    if not open_popup then
      ref_col = rgba
    else
      ref_col = ref_col
    end
    if open_popup then
      got_color, rgba = ImGui_ColorPicker4(ctx, 'Current', rgba, 0, ref_col)
      if got_color then
        custom_color = rgba
        widgetscolorsrgba = rgba 
      end
      ImGui_EndPopup(ctx)
    end
    
    ImGui_SameLine(ctx, -1, 156) -- overlapping items
    
    
    -- APPLY CUSTOM COLOR --
    
    if ImGui_ColorButton(ctx, 'Apply custom color##3', rgba, ImGui_ColorEditFlags_NoBorder(), 21, 21)
      or ((Undo_CanUndo2(0)=='Insert media items'
        or Undo_CanUndo2(0)=='Recorded media')
          and (not cur_state or cur_state<init_state))
            and automode_id == 2  then
      cur_state = GetProjectStateChangeCount(0)
      coloring_cust_col(rgba)
      widgetscolorsrgba = rgba --is it needed anymore? yes, for being last color
    end
    custom_color = rgba
    
    --Drag and Drop--
    if ImGui_BeginDragDropTarget(ctx) then
      local rv,drop_color = ImGui_AcceptDragDropPayloadRGBA(ctx)
      if rv then
        rgba = drop_color 
      end
      reaper.ImGui_EndDragDropTarget(ctx)
    end
    
    local custom_color_flags =  
                   ImGui_ColorEditFlags_DisplayHSV()
                  |ImGui_ColorEditFlags_NoSmallPreview()
                  |ImGui_ColorEditFlags_NoBorder()
                  |ImGui_ColorEditFlags_NoDragDrop()
                  |ImGui_ColorEditFlags_NoInputs()
    
    if widgetscolorsrgba then
      last_color = widgetscolorsrgba
    else
      last_color = custom_color
    end
   
    
    -- LAST TOUCHED --
    
    --ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, -3)
    ImGui_SameLine(ctx, 0.0, 17)
    ImGui_AlignTextToFramePadding(ctx)
    --ImGui_PopStyleVar(ctx,1)
    ImGui_Text(ctx, 'Last touched:')
    ImGui_SameLine(ctx, 0.0, 6)
    
    if ImGui_ColorButton(ctx, 'Apply last color##6', last_color, custom_color_flags, 21, 21) then
      coloring_cust_col(last_color)
    end
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, -7)
    ImGui_Dummy(ctx,0,0)
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, 3)
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_SeparatorTextBorderSize(),3) 
    ImGui_SeparatorText(ctx, '')
    ImGui_PopStyleVar(ctx,3)

     
    -- MAIN COLOR PALETTE --

    local distinct_col = {}
    for n=1, #main_palette do
      ImGui_PushID(ctx, n)
      if ((n - 1) % 24) ~= 0 then
        ImGui_SameLine(ctx, 0.0, 2)
      else retval = ImGui_GetCursorPosY(ctx)
        ImGui_SetCursorPosY(ctx, retval -2)
      end
      local highlight = false
      local palette_button_flags =
        ImGui_ColorEditFlags_NoPicker() |
        ImGui_ColorEditFlags_NoTooltip()
      for k=1, #sel_colors do
        if sel_colors[k]==main_palette[n] then
          if #distinct_col == 0 or sel_colors[k] ~= distinct_col[#distinct_col] then 
            insert(distinct_col, sel_colors[k])
            ImGui_PushStyleColor(ctx, ImGui_Col_Border(),0xffffffff)
            ImGui_PushStyleVar(ctx, ImGui_StyleVar_FrameBorderSize(),2)
            highlight = true
          end
        end
      end
      if highlight == false then
        palette_button_flags = palette_button_flags | ImGui_ColorEditFlags_NoBorder()
      end

    -- MAIN PALETTE BUTTONS --
      
      if ImGui_ColorButton(ctx, '##palette', main_palette[n], palette_button_flags, size, size) then
        widgetscolorsrgba = (main_palette[n]) -- is it needed anymore? Yes, for highlighting!!
        coloring(pal_tbl.tr, pal_tbl.tk, n)
      end
      
      if highlight == true then
        ImGui_PopStyleColor(ctx,1)
        ImGui_PopStyleVar(ctx,1)
      end
      
      ImGui_PopID(ctx)
    end


    -- AUTO-COLOR NEW ITEMS -- COMBO BOX --

   -- ImGui_PushStyleVar(ctx, ImGui_StyleVar_ItemSpacing(), 0, 10)
   
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_SeparatorTextBorderSize(),3) 
    --ImGui_SeparatorText(ctx, '')
    ImGui_Dummy(ctx, 0, 12)
    --ImGui_PopStyleVar(ctx,1) -- Item spacing and ?
    ImGui_PopStyleVar(ctx,2) -- Item spacing and ?
   
    
    --ImGui_AlignTextToFramePadding(ctx)
    
    ---- -----
    ---- -----
    
    
    -- TRIGGER ACTIONS/FUNCTIONS VIA BUTTONS --
    
    --[[
    if button_action(0.65, 0.5, 0.65, 1, '  Color selected\n   items to track', 120, 41, true, 5,  0.691, 0.62, 0.84, 0.55, 5) then
      Color_selected_items_to_track_color()
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.001, 0.5, 0.65, 1, '    Set children\n   to same color', 120, 41, true, 5,  0.983, 0.62, 0.84, 0.55, 5) then
      color_childs_to_parentcolor() 
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.17, 0.5, 0.65, 1, ' Color tracks\n  to gradient', 120, 41, true, 5,  0.14, 0.62, 0.84, 0.55, 5) then
      Color_selected_tracks_with_gradient()
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.37, 0.5, 0.65, 1, 'Color tracks to\n  main palette', 120, 41, true, 5,  0.3, 0.62, 0.84, 0.55, 5) then
      Color_multiple_tracks_to_palette_colors() 
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.605, 0.5, 0.65, 1, '  Color tracks to\n  custom palette ', 120, 41, true, 5,  0.563, 0.62, 0.84, 0.55, 5) then
      Color_multiple_tracks_to_custom_palette() 
    end

    
    ]]
    
    bttn_h = 0.644
    bttn_s = 0.45
    bttn_v = 0.96
    
    --br_h = 0.558
    --br_s = 0.59
    --br_v = 0.35
    
    br_h = 0.558
    br_s = 0.4
    br_v = 0.4

    
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),0xffffffff)
    
    
    if button_action(bttn_h, bttn_s, bttn_v, 1, ' Color selected\n  items to track', 120, 41, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
      Color_selected_items_to_track_color()
    end
    --reaper.ImGui_PopStyleColor(ctx)

    
    --reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),0x9a0035ff)
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(bttn_h, bttn_s, bttn_v, 1, '   Set children\n to same color', 120, 41, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
      color_childs_to_parentcolor() 
    end
    --reaper.ImGui_PopStyleColor(ctx)
    
   -- reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),0x35009aff)
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(bttn_h, bttn_s, bttn_v, 1, ' Color tracks\n  to gradient', 120, 41, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
      Color_selected_tracks_with_gradient()
    end
   -- reaper.ImGui_PopStyleColor(ctx)
    
   -- reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),0x35009aff)
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(bttn_h, bttn_s, bttn_v, 1, 'Color tracks to\n  main palette', 120, 41, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
      Color_multiple_tracks_to_palette_colors() 
    end
    --reaper.ImGui_  PopStyleColor(ctx)
    
    --reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),0x35009aff)
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(bttn_h, bttn_s, bttn_v, 1, '  Color tracks to\n  custom palette ', 120, 41, true, 5,  br_h, br_s, br_v, 0.55, 5) then 
      Color_multiple_tracks_to_custom_palette()
    end
    

    reaper.ImGui_PopStyleColor(ctx)
  
    --[[
    
    if button_action(0.65, 0.41, 0.88, 1, '  Color selected\n   items to track', 120, 41, true, 5,  0.691, 0.82, 0.76, 0.55, 5) then 
      Color_selected_items_to_track_color()
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.063, 0.41, 0.88, 1, '    Set children\n   to same color', 120, 41, true, 5,  0.983, 0.76, 0.53, 0.55, 5) then 
    color_childs_to_parentcolor()
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.15, 0.5, 0.73, 1, ' Color tracks\n  to gradient', 120, 41, true, 3.5,  0.15, 0.41, 0.88, 0.55, 5) then
      Color_selected_tracks_with_gradient()
    end
  
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.483, 0.3, 0.53, 1, 'Color tracks to\n  main palette', 120, 41, true, 5,  0.441, 0.76, 0.56, 0.55, 5) then
      Color_multiple_tracks_to_palette_colors() 
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.605, 0.5, 0.53, 1, '  Color tracks to\n  custom palette ', 120, 41, true, 5,  0.563, 0.62, 0.84, 0.55, 5) then
      Color_multiple_tracks_to_custom_palette() 
    end
    
    
    --[[
  
    -- OLD BUTTONS
    if button_action(0.555, 0.59, 0.37, 1, '  Color selected\n   items to track', 120, 41, true, 5,  0.511, 0.59, 0.40, 0.55, 5) then 
      Color_selected_items_to_track_color()
    end
      
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.555, 0.59, 0.37, 1, '    Set children\n   to same color', 120, 41, true, 5,  0.511, 0.59, 0.40, 0.55, 5) then 
      color_childs_to_parentcolor()
    end
      
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.555, 0, 0.37, 1, ' Color tracks\n  to gradient', 120, 41, true, 5, 0.511, 0.1, 0.32, 0.55, 5) then
      Color_selected_tracks_with_gradient()
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.555, 0.59, 0.37, 1, 'Autocolor\n   tracks', 120, 41, true, 5, 0.555, 0.2, 0.3, 0.55, 5) then
      Color_multiple_tracks_to_palette_colors() 
    end
    
    ImGui_SameLine(ctx, 0.0, 12)
    if button_action(0.555, 0.59, 0.37, 1, '  Autocolor to \ncustom palette ', 120, 41, true, 5, 0.555, 0.2, 0.3, 0.55, 5) then
      Color_multiple_tracks_to_custom_palette() 
    end
      
      ]]
      
  end -- END OF GUI
    
  -----------------------------------
  -----------------------------------
  
  
  
  local function save_current_settings()
  
    reaper.SetExtState("shiny_colorpalette" ,'selected_mode',   tostring(selected_mode),true)
    reaper.SetExtState("shiny_colorpalette" ,'colorspace',      tostring(colorspace),true)
    reaper.SetExtState("shiny_colorpalette" ,'dont_ask',        tostring(dont_ask),true)
    reaper.SetExtState("shiny_colorpalette" ,'automode_id',     tostring(automode_id),true)
    reaper.SetExtState("shiny_colorpalette" ,'saturation',      tostring(saturation),true)
    reaper.SetExtState("shiny_colorpalette" ,'lightness',       tostring(lightness),true)
    reaper.SetExtState("shiny_colorpalette" ,'darkness',        tostring(darkness),true)
    reaper.SetExtState("shiny_colorpalette" ,'rgba',            tostring(rgba),true)
    reaper.SetExtState("shiny_colorpalette" ,'custom_palette',  table.concat(custom_palette,","),true)
    reaper.SetExtState("shiny_colorpalette" ,'random_custom',   tostring(random_custom),true)
    reaper.SetExtState("shiny_colorpalette" ,'random_main',     tostring(random_main),true)
    
  end
  


  -- PUSH STYLE COLOR AND VAR COUNTING --

  local function push_style_color()

    local n = 0
    ImGui_PushStyleColor(ctx, ImGui_Col_TitleBgActive(), 0x1b3542ff) n=n+1
    ImGui_PushStyleColor(ctx, ImGui_Col_FrameBg(), 0x1b3542ff) n=n+1
    ImGui_PushStyleColor(ctx, ImGui_Col_SliderGrab(), 0x47aaaaff) n=n+1
    --ImGui_PushStyleColor(ctx, ImGui_Col_CheckMark(), 0xffa436ff) n=n+1
    ImGui_PushStyleColor(ctx, ImGui_Col_CheckMark(), 0x90ff60ff) n=n+1
    return n
  end



  local function push_style_var()

    local m = 0
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_WindowRounding(),12) m=m+1
    ImGui_PushStyleVar(ctx, ImGui_StyleVar_WindowTitleAlign(),0.5, 0.5) m=m+1
    return m
  end



  -- LOOP -- MAIN FUNCTION --

  local function loop()
    
    ImGui_PushFont(ctx, sans_serif)
    local window_flags = ImGui_WindowFlags_None() |  ImGui_WindowFlags_MenuBar()
    local style_color_n = push_style_color()
    local style_var_m = push_style_var()
    ImGui_SetNextWindowSize(ctx, 400, 140, ImGui_Cond_FirstUseEver())
    visible, open = ImGui_Begin(ctx, 'Chroma - Coloring Tool', true, window_flags)
    
    if visible then
      init_state = GetProjectStateChangeCount(0)
      ColorPalette()
      ImGui_End(ctx)
     
    else
      if ((Undo_CanUndo2(0)=='Insert media items'
              or Undo_CanUndo2(0)=='Recorded media')
                and (not cur_state or cur_state<init_state))
                  and automode_id == 2  then
            cur_state = GetProjectStateChangeCount(0)
        coloring_cust_col()
      else
        local tr_cnt = CountTracks(0)
        local tr_cnt2
        if not col_tbl 
          or ((Undo_CanUndo2(0)=='Change track order')
              or  tr_cnt ~= tr_cnt2) then
          generate_trackcolor_table()
          tr_cnt2 = tr_cnt
        end
        get_sel_items_or_tracks_colors()
        automatic_item_coloring()
        Color_new_items_automatically()
        Color_new_tracks_automatically()
      end   
    end
    ImGui_PopFont(ctx)
    ImGui_PopStyleColor(ctx, style_color_n)
    ImGui_PopStyleVar(ctx, style_var_m)

    if open then
      defer(loop)
    end
  end
  
  -- EXECUTE --

  --ToggleStateButton()
  
  defer(loop)
  --automatic_item_coloring()
  
  reaper.atexit(save_current_settings)
