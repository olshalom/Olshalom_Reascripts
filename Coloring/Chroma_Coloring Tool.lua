--  @description Chroma - Coloring Tool
--  @author olshalom, vitalker
--  @version 0.9.0.1
--  @date 25.03.18
--  @changelog
--    0.9.0.1
--    Improvements:
--        > Rightclick Menu for Luminance Adjuster (Adjuster Settings)
--
--    0.9.0
--    NEW features:
--        > Quit after coloring
--        > Luminace Adjuster (enable via: Settings/SECTIONS/)
--        > color folder's tracks to gradient shade function:
--          > added to rightclick menu of "gradient action button"
--          > accessible via holding SHIFT+CNTRL for Windows and SHIFT+CMD for Mac by pressing "gradient action button"
--          > added to rightclick menu of any color button to set folder parent color followed by gradient shade for children
--    Improvements:
--        > redesigned "Info" buttons
--        > save setting changes instantly to ExtState

--    0.8.9.1
--        > fix untick "color new tracks to defined color"
--    0.8.9
--    NEW features:
--        > color elements to gradient shade function (dependent on main palette settings)
--        > rightclick menu for "color element to gradient" action button
--        > add setting for color new tracks to defined color
--        > added "color markers/regions in time selection" function
--        > access setting "random coloring for multiple elements" via rightclick action button popup
--        > added action "set custom palette button" to rightclick menu
--        > Added Guidance accessible via Info buttons
--    Improvements:
--        > change action buttons text for markers and regions independently
--        > scale rightclick menus along parent window
--        > color added click source in shiny colors mode
--        > better function to color background of current drawn item in shiny colors mode

--    0.8.8.5
--    Improvements:
--        > more precise height calculation for resizing window when show/hide sections
--        > improve color children to parent in rightclick menu
--    Bug fixes:
--        > fix multiple elements coloring function 
--        > some more little fixes...
--    0.8.8.4
--    Bug fixes:
--        > fix loading fonts for windows
--
--    0.8.8.3
--    Improvements:
--        > support duplicate tracks with item content in shinycolors mode
--        > refine coloring children to parent in actionmenu
--
--    Bug fixes:
--        > fix preview color for EditCustomColor ColorPicker Popup
--
--    0.8.8.2
--    Bug fixes:
--        > fix automatically color new items when set to custom color (advanced settings)
--        > when set main palette color settings, reset highlighting
--        > when reset main or custom palette, also reset highlighting
--        > switching between tracks and items under specific corner cases
--        
--    Imrpovements:
--        > refinement of "Color_new_items_automatically" function
--        > gradient coloring in Rightclick Menu 
--    
--    0.8.8
--      NEW features:
--        > All actions implemented for markers/regions and their manager
--        > static mode for Region/Marker Manager
--        > Rightclick "Actions Menu" for all color buttons
--        > "Get selected color(s) to button(s)" added as well for "Edit custom Color" and "Last touched"
--        > Show Mouse Modifier description in Menubar when widgets with modifiers are hovered
--        > Tooltips with description for some widgets
--        > Ghostmode for Menubar (hide menus at the top)
--        > Option for: open at mouse position (Settings)
--        > Resize window when tick/untick sections
--        > All widgets and fonts are now resizeable
--        > Automatically color new tracks when files are imported via drag'n'drop
--        > Automatically color auto added tracks when items are dragged to bottom of tracklist
--
--      Improvements:
--        > Reorganized Mousemodifiers (significant changes!!)
--        > Reset/set/edit custom color buttons functionalty via mousemodifiers
--        > Get Palette Menu to the foreground if already open 
--        > Make font size look the same for WinOs and MacOs
--        > straighten out code under the hood


--    0.8.7.1
--      Improvements
--        > better bitfield calculation for read out of config vars
--
--    0.8.7
--      NEW features:
--        > Added aditional Script "CHROMA - Discrete Auto Coloring" when autocoloring should continue after exit
--
--      Performance:
--        > Improved current project lookup
--
--      Bug fixes/improvements:
--        > Improved static context mode for regions and markers, so one or the other is static
--        > Fixed reasonless recoloring selected tracks when new project is opened in same tab
--        > Fixed reset palette indicates "modified" for current saved palette
--        > Fixed staticmode for regions and markers when items moved in shinycolors mode
--
--
--    0.8.6
--      NEW features:
--        > Marker and region coloring
--        > Region/Marker Manager support
--        > "Static selection mode" via hold of ctrl/cmd and clicking selection indicator
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

local script_name = 'Chroma - Coloring Tool'
local OS = reaper.GetOS()
local sys_os, sys_offset, sys_scale, modifier_text
local font_divider1, font_divider2, font_divider3, font_size, saved_font_size
local frame_paddingY, cntrl_key

if OS:find("OSX") or OS:find("macOS") then
  sys_os = 1
  sys_offset = 0
  font_size, frame_paddingY = 15, 0.18
  font_divider1, font_divider2, font_divider3 = 42, 45, 50 
  modifier_text = { "SHIFT: Color to custom palette (start with pressed)", "SHIFT: Color to main palette (start with pressed)",
                    "CMD+SHIFT: Color to gradient (2 clicks)", "OPTION: Reset custom palette button", 
                    "CMD+OPTION: Get selected colors to buttons", "CMD: Color tracks and all their items (hard reset)",
                    "CMD: Color items and its tracks to same color", "CMD: Color mrks/regions inside timeselection to same color",
                    "Modifier not used", "SHIFT+OPTION: Edit color", "SHIFT: Color to gradient shade"}
else 
  sys_os = 0
  sys_offset = 30
  font_size, frame_paddingY = 16, 0.1
  font_divider1, font_divider2, font_divider3 = 38, 42, 46 
  modifier_text = { "SHIFT: Color to custom palette (start with pressed)", "SHIFT: Color to main palette (start with pressed)",
                    "CTRL+SHIFT: Color to gradient (2 clicks)", "ALT: Reset custom palette button", 
                    "CTRL+ALT: Get selected color to button", "CTRL: Color tracks and all their items (hard reset)",
                    "CTRL: Color items and its tracks to same color", "CTRL: Color markers/regions inside timeselection to same color",
                    "Modifier not used", "SHIFT+ALT: Edit color", "SHIFT: Color to gradient shade"}
end


-- CONSOLE OUTPUT --
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

function OpenURL(url)
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
insert = table.insert
local max = math.max
local min = math.min

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
local palette_high = {main = {}, cust = {}}
local user_palette = {}
local auto_track = {auto_pal, auto_palette, auto_retval, auto_custom = loadsetting("auto_custom", false), auto_stable = loadsetting("auto_stable", false)}
local userpalette = {}
local user_mainpalette = {}
local user_main_settings = {}
local rv_markers = {} 
local sel_markers = { retval={}, number={}, m_type={} }
local combo_items = { '   Track color', ' Custom color' }
local mouse_item = {}

local luminance = {
  colorspace_lum        = loadsetting2("colorspace_lum", 0),
  darkness_lum          = loadsetting2("darkness_lum", 0.100),    
  lightness_lum         = loadsetting2("lightness_lum", 0.95),
  cycle_lum             = loadsetting("cycle_lum", true),
  range                 
  }

if luminance.colorspace_lum == 1 then luminance.range = 1 else luminance.range = 0.95 end


-- CONTROL VARIABLES -- run out of local variables
local pre_cntrl = {
  current_item             = loadsetting2("current_item", 1),
  hovered_preset           = ' ',
  combo_preview_value,
  current_main_item        = loadsetting2("current_main_item", 1), 
  hovered_main_preset      = ' ',
  main_combo_preview_value,
  stop                     = loadsetting("stop", false),
  stop2                    = loadsetting("stop2", false),
  mouse_open_X             = loadsetting2("mouse_open_X", 0.5),
  mouse_open_Y             = loadsetting2("mouse_open_Y", 0.5),
  differs, differs2, differs3, new_combo_preview_value, main_new_combo_preview_value
  }

local set_cntrl = {
  tree_node_open           = loadsetting("tree_node_open_save", false),
  tree_node_open_save,
  tree_node_open2          = loadsetting("tree_node_open_save2", false),
  tree_node_open_save2,
  tree_node_open3          = loadsetting("tree_node_open_save3", false),
  tree_node_open_save3,
  keep_running1            = loadsetting("keep_running1", false),
  keep_running2            = ' ',
  background_color_mode    = loadsetting("background_color_mode", false),
  topbar_ghost_mode        = loadsetting("topbar_ghost_mode", false),
  modifier_info            = loadsetting("modifier_info", true),
  quit                     = loadsetting("quit", false),
  tooltip_info             = loadsetting("tooltip_info", true),
  dont_ask                 = loadsetting("dont_ask", false),
  random_custom            = loadsetting("random_custom", false), 
  random_main              = loadsetting("random_main", false),
  resize_height,
  open_at_mouse            = loadsetting("open_at_mouse", false),        
  open_at_mouse_true,
  selectables              = {align     = {{false, false, false },
                                           {false, false, false },
                                           {false, false, false }},
                              x         = {'Left ', 'Center ', 'Right '},
                              y         = {'- Top', '- Center', '- Bottom'},
                              selected  = {s_y = loadsetting2("p_selected_Y", 2),
                                           s_x = loadsetting2("p_selected_X", 2)},
                              keys      = {1, .5, 0}
                             }
                  }
  
do
  local t = set_cntrl.selectables
  local row = t.align[t.selected.s_y]
  row[t.selected.s_x] = true
end

if set_cntrl.open_at_mouse then set_cntrl.open_at_mouse_true = true end


-- PREDEFINE VALUES AS LOCAL--
local items_mode, item_sw, takecolor2, projfn2, h, av_y, sel_mk
local button_text1, button_text2, button_text3, button_text4, button_text5       
local remainder, init_state_saved, max_x, max_y, go, ImGui_scale2, mouse_over
local old_project, track_number_stop, tr_cnt_sw, padding_x, padding_y
local set_pos, takelane_mode2, visible2, nextitemforeground, timer2, sel_tracks2 
local static_mode, resize, can_re, counter = 0, 0, "", 0
local test_take, test_take2, test_track_it, test_item_sw, test_track_sw, sel_items, sel_items_sw, it_cnt_sw, track_sw2
local check_mark = 0
local tr_txt = '##No_selection' 
local shortcut_text = ''
local automode_id               = loadsetting2("automode_id", 1)
local colorspace                = loadsetting2("colorspace", 0)
local lightness                 = loadsetting2("lightness", 0.65)
local darkness                  = loadsetting2("darkness", 0.2)
local saturation                = loadsetting2("saturation", 0.8)
local rgba                      = loadsetting2("rgba", 630132991)
local rgba3                     = loadsetting2("rgba3", 630132991)
local last_touched_color        = loadsetting2("last_touched_color", 630132991)
local selected_mode             = loadsetting2("selected_mode", 0)
local show_action_buttons       = loadsetting("show_action_buttons", true)  
local show_custompalette        = loadsetting("show_custompalette", true)       
local show_edit                 = loadsetting("show_edit", true)         
local show_luminance_adjuster   = loadsetting("show_luminance_adjuster", false)      
local show_lasttouched          = loadsetting("show_lasttouched", true)      
local show_mainpalette          = loadsetting("show_mainpalette", true)      
local show_seperators           = loadsetting("show_seperators", true)  
local auto_trk                  = loadsetting("auto_trk", true)
local w                         = loadsetting2("w", 777)
local sides = w/44.671349
local av_x = w-(sides*2)
local spacing = max((w*0.002), 1)
local size = (av_x-spacing*23)/24
local size2 = (w-sides*2-spacing*23)/24
--local _

-- go, sys_os, sel_mk could go into bitfield

-- Thanks to Sexan for the next two functions -- 
function stringToTable(str)
  local f, err = load("return "..str)
  return f ~= nil and f() or nil
end


function serializeTable(val, name, depth)
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
  local r, g, b = ImGui.ColorConvertHSVtoRGB(h, s, v)
  return ImGui.ColorConvertDouble4ToU32(r, g, b, a or 1.0)
end


local function IntToRgba(Int_color)
  local r, g, b = ColorFromNative(Int_color)
  return ImGui.ColorConvertDouble4ToU32(r/255, g/255, b/255, a or 1.0)
end


-- LOADING SETTINGS --
if reaper.HasExtState(script_name, "custom_palette") then
  for i in string.gmatch(reaper.GetExtState(script_name, "custom_palette"), "[^,]+") do 
    insert(custom_palette, tonumber(string.match(i, "[^,]+"))) 
  end
else
  for m = 1, 24 do
    custom_palette[m] = HSL(m / 24+0.69, 0.1, 0.2, 1)
  end
end

if reaper.HasExtState(script_name, "user_palette") then
  local serialized2 = reaper.GetExtState(script_name, "user_palette")
  user_palette = stringToTable(serialized2) 
else
  insert(user_palette, '*Last unsaved*')
  SetExtState(script_name , 'userpalette.*Last unsaved*',  table.concat(custom_palette,","),true)
end

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

if pre_cntrl.stop == true then
  pre_cntrl.new_combo_preview_value = user_palette[pre_cntrl.current_item]..' (modified)'
end

if pre_cntrl.stop2 then 
  pre_cntrl.main_combo_preview_value = user_mainpalette[pre_cntrl.current_main_item]..' (modified)'
end


-- IMGUI CONTEXT --
local ctx = ImGui.CreateContext(script_name) 
local sans_serif = ImGui.CreateFont('sans-serif', font_size)
local buttons_font, buttons_font2, buttons_font3, buttons_font4 
ImGui.Attach(ctx, sans_serif)
local openSettingWnd = false

local button_colors = {
                        button_color1 = {HSV(0.555, 0.59, 0.4, 1), HSV(0.555, 0.59, 0.6, 1), HSV(0.555, 0.59, 0.8, 1), HSV(0.555, 0.2, 0.3, 0.55), HSV(0.555, 0.2, 0.05, 0.55)}, --[1] = normal, [2] = hovered, [3] = pressed, [4] = border, [5] = border_shadow
                        button_color2 = {HSV(0.644, 0.45, 0.63, 1), HSV(0.644, 0.45, 0.83, 1), HSV(0.644, 0.45, 1, 1), HSV(0.558, 0.45, 0.33, 0.55), HSV(0.558, 0.45, 0.08, 0.55)},
                        button_color3 = {HSV(0.610, 0.5, 0.2, 1), HSV(0.610, 0.5, 0.4, 1), HSV(0.644, 0.45, 1, 1), HSV(0.555, 0.2, 0.3, 0.55), HSV(0.555, 0.2, 0.05, 0.55)},
                        button_color4 = {0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000}
                      }

-- GET HANDLES OF WINDOWS AND INTERCEPT --
local main = reaper.GetMainHwnd()
local ruler_win = reaper.JS_Window_FindChildByID(main, 0x3ED)
local arrange = reaper.JS_Window_FindChildByID(main, 0x3E8)
local TCPDisplay = reaper.JS_Window_FindEx(main, main, "REAPERTCPDisplay", "" )
local seen_msgs = {}
local msgs = 'WM_LBUTTONDOWN'

reaper.JS_WindowMessage_Intercept(ruler_win, msgs, true)
reaper.JS_WindowMessage_Intercept(arrange, msgs, true)
reaper.JS_WindowMessage_Intercept(TCPDisplay, msgs, true)

-- CHECK FOR RUN AUTOCOLORING AFTER EXIT SCIPT --
do
  local Automode_script = reaper.NamedCommandLookup("_RS202fa170b3900414fbac3e51b3ff3cb514dabda5")
  local state = reaper.GetToggleCommandState(Automode_script)
  set_cntrl.keep_running2 = Automode_script
  if state == 1 then 
    reaper.Main_OnCommand(Automode_script, 0)
    set_cntrl.keep_running1 = true
  elseif state == -1 then
    local i = 0
    repeat
      local cmd, name = reaper.kbd_enumerateActions(0,i)
      if name:find("^Script: Discrete Auto Coloring (Chroma_Extension)") then
        state = reaper.GetToggleCommandState(cmd)
        set_cntrl.keep_running2 = cmd
        if state == 1 then
          reaper.Main_OnCommand(cmd, 0)
          set_cntrl.keep_running1 = true
        end
      break
      end
      i = i + 1
    until cmd == 0
  end
end
  

-- CUMSTOM PALETTES FOR GENERATOR --
function custom_palette_analogous()
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
    generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_track.auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
    cust_tbl = nil
    return custom_palette
  end
end


function custom_palette_triadic()
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
    generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_track.auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
    cust_tbl = nil
    return custom_palette
  end
end


function custom_palette_complementary()
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
    generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_track.auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
    cust_tbl = nil
    return custom_palette
  end
end


function custom_palette_split_complementary()
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
    generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_track.auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
    cust_tbl = nil
    return custom_palette
  end
end


function custom_palette_double_split_complementary()
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
    generated_color, pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_track.auto_pal = nil, pre_cntrl.current_item, 1, nil, nil
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


-- GET ITEM OR TRACK COLORS FOR HIGHLIGHTING AND COLORING (CACHE) -- 
local function get_sel_items_or_tracks_colors(sel_items, sel_tracks, test_item, test_take, test_track)
  if items_mode == 3 and sel_markers and check_mark&1 == 1 then
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
    check_mark = check_mark& ~1
    
  elseif go and sel_items > 0 and (test_take2 ~= test_take or sel_items ~= it_cnt_sw or test_item_sw ~= test_item) then
    if (static_mode == 0 or static_mode == 2) then
      palette_high = {main = {}, cust = {}}
    end
    sel_color = {}
    sel_tbl = {it = {}, tke = {}, tr = {}, it_tr = {}}
    move_tbl = {it = {}, trk_ip = {}}
    local index, tr_index, it_index, sel_index, trk_ip, same_col, itemtrack2, itemtrack = 0, 0, 0, 0
    
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
      if itemcolor and itemcolor ~= itemcolor_sw  then
        itemcolor = IntToRgba(itemcolor)
        if (static_mode == 0 or static_mode == 2) then
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
        end
        sel_index, itemcolor_sw = sel_index+1, itemcolor
        sel_color[sel_index] = itemcolor
      end
    end
    test_track_sw, itemtrack2, test_take2, test_item_sw, itemcolor_sw = nil, nil, test_take, test_item, nil   
    it_cnt_sw, col_found  = sel_items, nil
    
  elseif sel_tracks > 0 and (test_track_sw ~= test_track or sel_tracks2 ~= sel_tracks) and items_mode == 0 then 
    if (static_mode == 0 or static_mode == 1) then
      palette_high = {main = {}, cust = {}}
    end
    sel_color = {}
    for i=0, sel_tracks -1 do
      test_track_sw, sel_tracks2 = test_track, sel_tracks
      local track = GetSelectedTrack(0,i)
      sel_tbl.tr[i+1] = track
      local trackcolor = IntToRgba(GetTrackColor(track)) 
      sel_color[i+1] = trackcolor
      if (static_mode == 0 or static_mode == 1) then
        for i =1, #main_palette do
          if trackcolor == main_palette[i] then
            palette_high.main[i] = 1
            break
          end
        end
        for i =1, #custom_palette do
          if trackcolor == custom_palette[i] then
            palette_high.cust[i] = 1
            break
          end
        end
      end
    end
  end
  return sel_color, move_tbl
end


-- FUNCTIONS FOR VARIOUS COLORING --
--________________________________--

-- caching trackcolors -- (could be extended and refined with a function written by justin by first check if already cached. Maybe faster)
function generate_trackcolor_table(tr_cnt)
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


local function Color_items_to_track_color_in_shiny_mode(track, background_color)
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
      local trackip = GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
      if trackitemcolor == col_tbl.it[trackip] then
        SetMediaItemInfo_Value(trackitem,"I_CUSTOMCOLOR", background_color)
      end
    end
  end
end


-- COLOR ITEMS TO TRACK COLOR IN SHINYCOLORS MODE WHEN MOVING --
local function automatic_item_coloring() 
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
local function reselect_take(init_state, sel_items)
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


-- COLOR SELECTED ITEMS TO TRACK COLOR --
local function Reset_to_default_color(sel_items, sel_tracks) 
  PreventUIRefresh(1) 
  if items_mode == 1 then
    Undo_BeginBlock2(0) 
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
    sel_tracks2, it_cnt_sw = nil
    UpdateArrange()
    Undo_EndBlock2(0, "CHROMA: Set selected to default color", 1+4)
  elseif items_mode == 3 then
    if sel_markers then
      Undo_BeginBlock2(0) 
      local mark_col = {reaper.GetThemeColor('marker'), reaper.GetThemeColor('region')}
      for i = 1, #sel_markers.retval do
        local what
        if rv_markers.isrgn[sel_markers.retval[i]] == true then what = mark_col[2] else what = mark_col[1] end
        reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[sel_markers.retval[i]], rv_markers.isrgn[sel_markers.retval[i]], rv_markers.pos[sel_markers.retval[i]], rv_markers.rgnend[sel_markers.retval[i]], rv_markers.name[sel_markers.retval[i]], what, 0)
        rv_markers.color[sel_markers.retval[i]] = what
      end
      Undo_EndBlock2(0, "CHROMA: Set selected to default color", 8)
    end
  else 
    if selected_mode == 1 then
      Undo_BeginBlock2(0) 
      for i=0, sel_tracks -1 do
        track = GetSelectedTrack(0, i)
        SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", 0)
        trackcolor = GetTrackColor(track)
        Color_items_to_track_color_in_shiny_mode(track, trackcolor)
      end
      Undo_EndBlock2(0, "CHROMA: Set selected to default color", 1+4)
      UpdateArrange()
    else
      Main_OnCommandEx(40359, 0, 0)
      Undo_EndBlock2(0, "CHROMA: Set selected to default color", 1)
    end
    sel_tracks2, col_tbl = nil
  end
  PreventUIRefresh(-1)
end


function GradientShade(first_r, first_g, first_b)
  local color_mode, color_mode2
  if colorspace == 1 then color_mode, color_mode2 = ImGui.ColorConvertRGBtoHSV, ImGui.ColorConvertHSVtoRGB else color_mode, color_mode2 = rgbToHsl, hslToRgb  end
  local h, s, v = color_mode(first_r, first_g, first_b) 
  if v > 0.25-((1-lightness)/4)+(darkness/4*3) then 
    if v-(lightness-darkness)*0.75 < darkness then v = darkness else v = v-(lightness-darkness)*0.75 end
  else
    if v+(lightness-darkness)*0.75 > lightness then v = lightness else v = v+(lightness-darkness)*0.75 end
  end
  last_r, last_g, last_b = color_mode2(h, s, v)
  return last_r, last_g, last_b
end

  local function Background_color_R_G_B(r,g,b)
    local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b)
    local s=s/3.7
    local v=v+((0.92-v)/1.3)
    if v > 0.99 then v = 0.99 end
    local background_color = ImGui.ColorConvertNative(HSV(h, s, v, 1.0) >> 8)|0x1000000
    return background_color
  end


local function Color_selected_elements_with_gradient(sel_tracks, sel_items, first, last, stay, grad_mode, tr_cnt) 
  local selection, first_r, first_g, first_b, first2
  local function DefineFirstAndLast(first, last, selection)
    if first == 255 and last == 255 then
      first_r, first_g, first_b = ImGui.ColorConvertU32ToDouble4(main_palette[1])
      if grad_mode then 
        last_r, last_g, last_b = GradientShade(first_r, first_g, first_b)
      else
        last_r, last_g, last_b = ImGui.ColorConvertU32ToDouble4(main_palette[16]) 
      end
      stay = true
      first2 =  main_palette[1]
    elseif first == 255 then 
      local r, g, b, a = ImGui.ColorConvertU32ToDouble4(last) 
      local h, s, v = ImGui.ColorConvertRGBtoHSV(r, g, b) 
      if h+2/3 > 1 then h = h+2/3%1 else h = h+2/3 end
      first_r, first_g, first_b = ImGui.ColorConvertHSVtoRGB(h, s, v)
      last_r, last_g, last_b = ImGui.ColorConvertU32ToDouble4(last) 
      first2 =  main_palette[1]
      stay = true
    elseif last == 255 or first ~= 255 and last == first then 
      first_r, first_g, first_b= ImGui.ColorConvertU32ToDouble4(first)
      if grad_mode then 
        last_r, last_g, last_b = GradientShade(first_r, first_g, first_b)
      else
        local h, s, v = ImGui.ColorConvertRGBtoHSV(first_r, first_g, first_b) 
        if h+2/3 > 1 then h = h+2/3%1 else h = h+2/3 end
        last_r, last_g, last_b = ImGui.ColorConvertHSVtoRGB(h, s, v)
      end
    else  
      first_r, first_g, first_b = ImGui.ColorConvertU32ToDouble4(first)
      if grad_mode then 
        last_r, last_g, last_b = GradientShade(first_r, first_g, first_b)
      else
        last_r, last_g, last_b = ImGui.ColorConvertU32ToDouble4(last) 
      end
    end
    local r_step = (last_r-first_r)/(selection)
    local g_step = (last_g-first_g)/(selection) 
    local b_step = (last_b-first_b)/(selection)
    return first_r, first_g, first_b, last_r, last_g, last_b, r_step, g_step, b_step, first2
  end
  
  local function get_child_tracks2(folder_track, tr_cnt)
    local all_tracks = {}
    if GetMediaTrackInfo_Value(folder_track, "I_FOLDERDEPTH") ~= 1 then
      return all_tracks
    end
    local tracks_count = tr_cnt
    local folder_track_depth = GetTrackDepth(folder_track) 
    local track_index = GetMediaTrackInfo_Value(folder_track, "IP_TRACKNUMBER")
    local tr_index = 0
    for i = track_index, tr_cnt - 1 do
      local track = GetTrack(0, i)
      local is_parent = GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
      local track_depth = GetTrackDepth(track)
      if is_parent and track_depth == folder_track_depth then
        break
      elseif not is_parent and track_depth-1 == folder_track_depth then 
        tr_index = tr_index+1
        all_tracks[tr_index] = track
      end
    end
    return all_tracks
  end

  if items_mode == 0 then selection = sel_tracks elseif items_mode == 1 then selection = sel_items elseif items_mode == 3 then selection = #sel_markers.retval end
  
  if grad_mode == 2 then
    if sel_tracks then
      local check_tracks
      for i = 1, sel_tracks do
        local track = sel_tbl.tr[i]
        local check_for_parent = reaper.GetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH') == 1
        if check_for_parent then
          if not check_tracks then
            PreventUIRefresh(1) 
            Undo_BeginBlock2(0)
            check_tracks = true
          end
          local first_r, first_g, first_b, last_r, last_g, last_b, r_step, g_step, b_step, first2
          local child_tracks = get_child_tracks2(track, tr_cnt)
          
          if stay then
            SetTrackColor(track, ImGui.ColorConvertNative(first >>8))
            first_r, first_g, first_b, last_r, last_g, last_b, r_step, g_step, b_step, first2 = DefineFirstAndLast(first, last, #child_tracks)
          else
            local trackcolor = sel_color[i]
            first_r, first_g, first_b, last_r, last_g, last_b, r_step, g_step, b_step, first2 = DefineFirstAndLast(trackcolor, last, #child_tracks)
            if stay then
              SetTrackColor(track, ImGui.ColorConvertNative(first2 >>8))
              stay = false
            end
          end
          for y = 1, #child_tracks do
            local value_r, value_g, value_b = first_r+r_step*y, first_g+g_step*y, first_b+b_step*y
            SetTrackColor(child_tracks[y], ColorToNative((value_r*255+.5)//1, (value_g*255+.5)//1, (value_b*255+.5)//1)|0x1000000) 
            if selected_mode == 1 then 
              Color_items_to_track_color_in_shiny_mode(child_tracks[y], Background_color_R_G_B(value_r, value_g, value_b)) 
            end 
          end
        end
      end
      if check_tracks then
        col_tbl, sel_tracks2 = nil, nil
        PreventUIRefresh(-1)
        Undo_EndBlock2(0, "CHROMA: Color selected folder's tracks with gradient colors", 5) 
      end
    end
  else 
    if selection > 1 then 
      local first_r, first_g, first_b, last_r, last_g, last_b, r_step, g_step, b_step = DefineFirstAndLast(first, last, selection-1)
      local i
      if stay then i = 0 else i = 1 end
  
      PreventUIRefresh(1) 
      Undo_BeginBlock2(0) 
      if items_mode == 0 then
        local t = sel_tbl.tr
        for i=i,sel_tracks-1 do 
          local track = t[i+1]
          local value_r, value_g, value_b = first_r+r_step*i, first_g+g_step*i, first_b+b_step*i
          SetTrackColor(track, ColorToNative((value_r*255+.5)//1, (value_g*255+.5)//1, (value_b*255+.5)//1)|0x1000000) 
          if selected_mode == 1 then 
            Color_items_to_track_color_in_shiny_mode(track, Background_color_R_G_B(value_r, value_g, value_b)) 
          end 
        end
        col_tbl, sel_tracks2 = nil, nil
        Undo_EndBlock2(0, "CHROMA: Color selected tracks with gradient colors", 5) 
      elseif items_mode == 1 then
        local t1, t2 = sel_tbl.it, sel_tbl.tke
        for i=i,sel_items-1 do
          local value_r, value_g, value_b = first_r+r_step*i, first_g+g_step*i, first_b+b_step*i
          if selected_mode == 1 then
            SetMediaItemInfo_Value(t1[i+1], "I_CUSTOMCOLOR", Background_color_R_G_B(value_r, value_g, value_b))
            if t2[i+1] then
              SetMediaItemTakeInfo_Value(t2[i+1], "I_CUSTOMCOLOR", ColorToNative((value_r*255+.5)//1, (value_g*255+.5)//1, (value_b*255+.5)//1)|0x1000000)
            end
          else
            if t2[i+1] then
              SetMediaItemTakeInfo_Value(t2[i+1], "I_CUSTOMCOLOR", ColorToNative((value_r*255+.5)//1, (value_g*255+.5)//1, (value_b*255+.5)//1)|0x1000000)
            else
              SetMediaItemInfo_Value(t1[i+1], "I_CUSTOMCOLOR", ColorToNative((value_r*255+.5)//1, (value_g*255+.5)//1, (value_b*255+.5)//1)|0x1000000)
            end    
          end
        end
        it_cnt_sw = nil 
        UpdateArrange()
        Undo_EndBlock2(0, "CHROMA: Color selected items with gradient colors", 4) 
      elseif items_mode == 3 then
        for i= i, #sel_markers.retval-1  do
          local value_r, value_g, value_b = first_r+r_step*i, first_g+g_step*i, first_b+b_step*i
          local n = sel_markers.retval[i+1]
          reaper.SetProjectMarker4(0, rv_markers.markrgnindexnumber[n], rv_markers.isrgn[n],
          rv_markers.pos[n], rv_markers.rgnend[n], rv_markers.name[n], ColorToNative((value_r*255+.5)//1, (value_g*255+.5)//1, (value_b*255+.5)//1)|0x1000000, 0)
          rv_markers.color[n] = ColorToNative((value_r*255+.5)//1, (value_g*255+.5)//1, (value_b*255+.5)//1)|0x1000000
        end
        --UpdateArrange()
        Undo_EndBlock2(0, "CHROMA: Color selected markers/regions with gradient colors", 8) 
        check_mark = check_mark|1
      end
      PreventUIRefresh(-1)
    else 
      local text_element 
      if items_mode == 0 then text_element = "tracks" elseif items_mode == 1 then text_element = "items" else text_element = "markers & regions"  end
      reaper.MB( "Select at least 3 "..text_element, "Can't create gradient colors", 0 ) 
    end 
  end
end


-- COLORING FOR MAIN AND CUSTOM PALETTE WIDGETS --

local function coloring(sel_items, sel_tracks, tbl_tr, tbl_it, mods_retval, color_input, tr_cnt, m, div, specific)
  PreventUIRefresh(1)
  if mods_retval == 28672 then
    Color_selected_elements_with_gradient(sel_tracks, sel_items, color_input, 255, 1, 1) 
  elseif items_mode == 1 then
    if mods_retval == 4096 then
      Undo_BeginBlock2(0)
      for j = 0, #sel_tbl.tr -1 do
        SetMediaTrackInfo_Value(sel_tbl.tr[j+1],"I_CUSTOMCOLOR", tbl_tr)
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[j+1], tbl_it)
        end
      end
      for i = 0, sel_items - 1 do
        if selected_mode == 1 then
          SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", tbl_it)
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
      Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 1+4)
    elseif mods_retval == 12288 then
      if not stop_gradient and sel_items > 0 then
        Undo_BeginBlock2(0)
        first_color = color_input
        if selected_mode == 1 then 
          SetMediaItemInfo_Value(sel_tbl.it[1],"I_CUSTOMCOLOR", tbl_it)
          if sel_tbl.tke[1] then 
            SetMediaItemTakeInfo_Value(sel_tbl.tke[1],"I_CUSTOMCOLOR", tbl_tr)
          end
        else
          if sel_tbl.tke[1] then 
            SetMediaItemTakeInfo_Value(sel_tbl.tke[1],"I_CUSTOMCOLOR", tbl_tr) 
          else
            SetMediaItemInfo_Value(sel_tbl.it[1],"I_CUSTOMCOLOR", tbl_tr)
          end
        end
        if not stop_coloring then
          stop_coloring = true
        end
        it_cnt_sw = sel_items
        stop_gradient = true
        Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 4)
      elseif stop_coloring then
        Undo_BeginBlock2(0)
        local n = #sel_tbl.it
        if selected_mode == 1 then 
          SetMediaItemInfo_Value(sel_tbl.it[n],"I_CUSTOMCOLOR", tbl_it)
          if sel_tbl.tke[n] then 
            SetMediaItemTakeInfo_Value(sel_tbl.tke[n],"I_CUSTOMCOLOR", tbl_tr)
          end
        else
          if sel_tbl.tke[n] then 
            SetMediaItemTakeInfo_Value(sel_tbl.tke[n],"I_CUSTOMCOLOR", tbl_tr) 
          else
            SetMediaItemInfo_Value(sel_tbl.it[n],"I_CUSTOMCOLOR", tbl_tr)
          end
        end
        it_cnt_sw = sel_items
        Color_selected_elements_with_gradient(sel_tracks, sel_items, first_color, color_input, 1, nil) 
        
        stop_gradient, stop_coloring = nil 
        it_cnt_sw = sel_items
        Undo_EndBlock2( 0, "CHROMA: Apply gradient color", 4)
      end
    elseif mods_retval == 20480 then
      item_track_color_to_custom_palette(m, div)
    else 
      Undo_BeginBlock2(0)
      for i = 0, sel_items - 1 do
        if selected_mode == 1 then 
          SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", tbl_it)
          if sel_tbl.tke[i+1] then 
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", tbl_tr)
          end
        else
          if sel_tbl.tke[i+1] then 
            SetMediaItemTakeInfo_Value(sel_tbl.tke[i+1],"I_CUSTOMCOLOR", tbl_tr) 
          else
            SetMediaItemInfo_Value(sel_tbl.it[i+1],"I_CUSTOMCOLOR", tbl_tr)
          end
        end
      end
      Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 4)
    end
    it_cnt_sw = nil 

  elseif items_mode == 0 then
    if mods_retval == 4096 then
      Undo_BeginBlock2(0)
      for i = 0, sel_tracks -1 do
        SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", tbl_tr)
        local cnt_items = CountTrackMediaItems(sel_tbl.tr[i+1])
        if cnt_items > 0 then
          for j = 0, cnt_items -1 do
            local new_item = GetTrackMediaItem(sel_tbl.tr[i+1], j)
            local new_take = GetActiveTake(new_item)
            if new_take then 
              SetMediaItemTakeInfo_Value(new_take,"I_CUSTOMCOLOR", 0) 
            end 
            if selected_mode == 1 then
              SetMediaItemInfo_Value(new_item,"I_CUSTOMCOLOR", tbl_it)
            else
              SetMediaItemInfo_Value(new_item,"I_CUSTOMCOLOR", 0)
            end
          end
        end
      end
      Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 1+4)
    elseif mods_retval == 12288 then
      if not stop_gradient and sel_tracks > 0 then
        Undo_BeginBlock2(0)
        first_color = color_input
        SetMediaTrackInfo_Value(sel_tbl.tr[1],"I_CUSTOMCOLOR", tbl_tr)
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[1], tbl_it)
        end
        stop_gradient = true
        Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 1+4)
      elseif stop_coloring then
        Undo_BeginBlock2(0)
        SetMediaTrackInfo_Value(sel_tbl.tr[#sel_tbl.tr],"I_CUSTOMCOLOR", tbl_tr)
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[#sel_tbl.tr], tbl_it)
        end
        test_track = sel_tbl.tr[1]
        Color_selected_elements_with_gradient(sel_tracks, sel_items, first_color, color_input, 1, nil) 
        stop_gradient, stop_coloring, col_tbl = nil 
        generate_trackcolor_table(tr_cnt)
        tr_cnt_sw = tr_cnt
        Undo_EndBlock2( 0, "CHROMA: Apply gradient color", 1+4)
      end
      if not stop_coloring then
        stop_coloring = true
      end
    elseif mods_retval == 20480 then
      item_track_color_to_custom_palette(m, div)
    else
      Undo_BeginBlock2(0)
      for i = 0, sel_tracks -1 do
        SetMediaTrackInfo_Value(sel_tbl.tr[i+1],"I_CUSTOMCOLOR", tbl_tr)
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i+1], tbl_it) 
        end
      end
      Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 1+4)
    end
    col_tbl, sel_tracks2 = nil, nil
    
  elseif items_mode == 3 then
    if mods_retval == 4096 then
      ColorMarkerTimeRange(tbl_tr, specific)
    elseif mods_retval == 12288 then
      if not stop_gradient and #sel_markers.retval > 0 then
        Undo_BeginBlock2(0)
        first_color = color_input
        local n = sel_markers.retval[1]
        reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[n], rv_markers.isrgn[n], rv_markers.pos[n], rv_markers.rgnend[n], rv_markers.name[n], tbl_tr, 0)
        rv_markers.color[n] = tbl_tr
        stop_gradient = true
        check_mark = check_mark|1 
        Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 8)
      elseif stop_coloring then
        Undo_BeginBlock2(0)
        local n = sel_markers.retval[#sel_markers.retval]
        reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[n], rv_markers.isrgn[n], rv_markers.pos[n], rv_markers.rgnend[n], rv_markers.name[n], tbl_tr, 0)
        rv_markers.color[n] = tbl_tr
        last_color = color_input
        Color_selected_elements_with_gradient(sel_tracks, sel_items, first_color, last_color, 1, nil) 
        stop_gradient, stop_coloring = nil
        Undo_EndBlock2( 0, "CHROMA: Apply gradient color", 8)
      end
      if not stop_coloring then
        stop_coloring = true
      end
    elseif mods_retval == 20480 then
      item_track_color_to_custom_palette(m, div)
    elseif sel_markers then
      Undo_BeginBlock2(0)
      for i = 1, #sel_markers.retval do
        reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[sel_markers.retval[i]], rv_markers.isrgn[sel_markers.retval[i]], rv_markers.pos[sel_markers.retval[i]], rv_markers.rgnend[sel_markers.retval[i]], rv_markers.name[sel_markers.retval[i]], tbl_tr, 0)
        rv_markers.color[sel_markers.retval[i]] = tbl_tr
      end
      Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 8)
    end
    check_mark = check_mark|1
  end
  UpdateArrange()
  PreventUIRefresh(-1)
end


function ColorMarkerTimeRange(tbl_tr, specific)
  Undo_BeginBlock2(0)
  local start, fin = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  if sel_mk == 1 then
    for i = 0, #rv_markers.pos  do
      if rv_markers.pos[i] >= start and rv_markers.pos[i] <= fin and rv_markers.isrgn[i] == false then
        reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], tbl_tr, 0)
        rv_markers.color[i] = tbl_tr
      end
    end
  
  elseif sel_mk == 2 then
    for i = 0, #rv_markers.pos do
      if rv_markers.pos[i] >= start and rv_markers.pos[i] <= fin and rv_markers.isrgn[i] == true then
        reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], tbl_tr, 0)
        rv_markers.color[i] = tbl_tr
      end
    end
  end
  Undo_EndBlock2( 0, "CHROMA: Apply "..specific.." color", 8)
end


function get_child_tracks(folder_track, tr_cnt)
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


-- COLOR CHILDS TO PARENTCOLOR -- Thanks to ChMaha and BirdBird for this functions
function color_childs_to_parentcolor(sel_tracks, tr_cnt, stay, first_in) 
  PreventUIRefresh(1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
  for i=0, sel_tracks -1 do
    local track = GetSelectedTrack(0,i)
    local check_for_parent = reaper.GetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH')
    if check_for_parent == 1 then
      local trackcolor
      if stay then 
        trackcolor = ImGui.ColorConvertNative(first_in>> 8)
        SetTrackColor(track, trackcolor)
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(track, background_color_native(trackcolor))
        end
      else
        trackcolor = GetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR")
      end
      local child_tracks = get_child_tracks(track, tr_cnt)
      for i = 1, #child_tracks do
        SetTrackColor(child_tracks[i], trackcolor)
        if selected_mode == 1 then
          Color_items_to_track_color_in_shiny_mode(child_tracks[i], background_color_native(trackcolor))
        end
      end
    end
  end
  col_tbl, sel_tracks2  = nil   
  if selected_mode == 1 then
    Undo_EndBlock2(0, "CHROMA: Set children to parent color", 1+4) 
  else
    Undo_EndBlock2(0, "CHROMA: Set children to parent color", 1) 
  end
  PreventUIRefresh(-1) 
end


-- MULTIPLE ELEMENT COLORING --
function Color_multiple_elements_to_palette_colors(sel_tracks, sel_items, first_stay, pal_tab, tab_num, random_in, tbl_tr, tbl_it, pop_key)
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
  local pal_div, color_state, i, found_value, mul_tbl, palette_name, first_color = #pal_tab, 0
  if tab_num then mul_tbl, palette_name = cust_tbl, "custom" else mul_tbl, palette_name = pal_tbl, "main" end
  local numbers = shuffled_numbers (pal_div)
  if first_stay then i, first_color = 1, pal_tab[pop_key] else i, first_color = 0, sel_color[1] end
  for p=1, pal_div do
    if first_color==pal_tab[p] then
      color_state = 1
      found_value = p
    break
    end
  end
  
  local function track_path()
    PreventUIRefresh(1) 
    if first_stay then
      SetMediaTrackInfo_Value(sel_tbl.tr[1],"I_CUSTOMCOLOR", tbl_tr)
      if selected_mode == 1 then
        Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[1], tbl_it) 
      end
      sel_color[1] = pal_tab[pop_key]
      last_touched_color = pal_tab[pop_key] 
    end
    local t = sel_tbl.tr
    for i=i, sel_tracks -1 do
      local value
      local track = t[i+1]
      if random_in then value = numbers[i%pal_div+1]
      elseif color_state ==1 then if sel_tracks < 2 then value = (i+found_value)%pal_div+1 else value = (i+found_value-1)%pal_div+1 end
      else value = i%pal_div+1  end
      SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR", mul_tbl.tr[value])
      if selected_mode == 1 then
        Color_items_to_track_color_in_shiny_mode(track, mul_tbl.it[value])
      end
    end
    col_tbl, sel_tracks2 = nil, nil
    UpdateArrange()
    PreventUIRefresh(-1)
  end
  
  local function item_path()
    PreventUIRefresh(1) 
    local t1, t2 = sel_tbl.it, sel_tbl.tke
    if first_stay then
      if selected_mode == 1 then 
        SetMediaItemInfo_Value(t1[1],"I_CUSTOMCOLOR", tbl_it)
        if t2[1] then 
          SetMediaItemTakeInfo_Value(t2[1],"I_CUSTOMCOLOR", tbl_tr)
        end
      else
        if t2[1] then 
          SetMediaItemTakeInfo_Value(t2[1],"I_CUSTOMCOLOR", tbl_tr) 
        else
          SetMediaItemInfo_Value(t1[1],"I_CUSTOMCOLOR", tbl_tr)
        end
      end
      sel_color[1], last_touched_color = pal_tab[pop_key], pal_tab[pop_key] 
    end
    for i=i, sel_items -1 do
      local value
      if random_in then value = numbers[i%pal_div+1]
      elseif color_state ==1 then if sel_items < 2 then value = (i+found_value)%pal_div+1 else value = (i+found_value-1)%pal_div+1 end
      else value = i%pal_div+1 end
      if selected_mode == 1 then
        if t2[i+1] then
          SetMediaItemTakeInfo_Value(t2[i+1], "I_CUSTOMCOLOR", mul_tbl.tr[value])
          SetMediaItemInfo_Value(t1[i+1], "I_CUSTOMCOLOR", mul_tbl.it[value])  
        else
          SetMediaItemInfo_Value(t1[i+1], "I_CUSTOMCOLOR", mul_tbl.it[value])
        end
      else
        if t2[i+1] then
          SetMediaItemTakeInfo_Value(t2[i+1], "I_CUSTOMCOLOR", mul_tbl.tr[value])
        else
          SetMediaItemInfo_Value(t1[i+1], "I_CUSTOMCOLOR", mul_tbl.tr[value])
        end
      end
    end
    it_cnt_sw = nil 
    UpdateArrange()
    PreventUIRefresh(-1)
  end
  
  local function marker_path()
    if first_stay then
      if sel_markers then
        local n = sel_markers.retval[i]
        reaper.SetProjectMarker4( 0, rv_markers.markrgnindexnumber[n], rv_markers.isrgn[n], rv_markers.pos[n], rv_markers.rgnend[n], rv_markers.name[n], tbl_tr, 0)
        rv_markers.color[n] = tbl_tr
      end
      sel_color[1], last_touched_color = pal_tab[pop_key], pal_tab[pop_key] 
    end
    local num_mark = #sel_markers.retval
    for i=i+1, num_mark do
      local value
      if random_in then value = numbers[i%pal_div]
      elseif color_state ==1 then if num_mark < 2 then value = (i+found_value)%pal_div else value = (i+found_value-1)%pal_div end
      else value = i%pal_div end
      local n = sel_markers.retval[i]
      reaper.SetProjectMarker4(0, rv_markers.markrgnindexnumber[n], rv_markers.isrgn[n],
      rv_markers.pos[n], rv_markers.rgnend[n], rv_markers.name[n], mul_tbl.tr[value], 0)
      rv_markers.color[n] = mul_tbl.tr[value]
    end
    check_mark = check_mark|1
  end
  Undo_BeginBlock2(0) 
  if items_mode == 0 then
    track_path()
    Undo_EndBlock2(0, "CHROMA: Color multiple tracks to"..palette_name.." palette", 1+4)
  elseif items_mode == 1 then
    item_path()
    Undo_EndBlock2(0, "CHROMA: Color multiple items to"..palette_name.." palette", 4)
  elseif items_mode == 3 then
    marker_path()
    Undo_EndBlock2(0, "CHROMA: Color multiple markers/regions to"..palette_name.." palette", 8)
  end
end


-- COLOR NEW TRACKS AUTOMATICALLY --
local function Color_new_tracks_automatically() 
  local track_number_sw, stored_val, found, track, tr_ip, prev_tr_ip, state2
  return function(sel_tracks, test_track, state, tr_cnt)
    local track = GetTrack(0, tr_cnt-1) 
    if track and track ~= col_tbl.ptr[#col_tbl.ptr] and test_track ~= track  then
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
      state2 = state2 +1
      track_number_sw, sel_tracks2, col_tbl, found = tr_cnt, nil, nil, nil
      Undo_EndBlock2(0, "CHROMA: Automatically color new tracks", 1+4)
    end
    return track_number_sw
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
  local text_min_x, text_min_y = ImGui.GetItemRectMin(ctx)
  local text_max_x, text_max_y = ImGui.GetItemRectMax(ctx)
  if not ImGui.IsItemHovered(ctx) then
    ImGui.DrawList_AddRect(draw_list, text_min_x, text_min_y, text_max_x, text_max_y, HSV(h, s, v, a), round)
  elseif ImGui.IsItemHovered(ctx) then
    ImGui.DrawList_AddRect(draw_list, text_min_x, text_min_y, text_max_x, text_max_y, HSV(h, s, v, a), round)
  elseif ImGui.IsItemActive(ctx) then
    ImGui.DrawList_AddRect(draw_list, text_min_x, text_min_y, text_max_x, text_max_y, HSV(h, s, v, a), round)      
  end
  return state
end


-- BUTTON TEMPLATE 2 --
local function button_action(butt_col_t, name, size_w, size_h, border, b_thickness, rounding) -- b_= border
  local n, m = 0, 0
  
  ImGui.PushStyleColor(ctx, ImGui.Col_Button, butt_col_t[1]) n=n+1
  ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, butt_col_t[2]) n=n+1
  ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive, butt_col_t[3]) n=n+1
  if rounding then
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding,rounding) m=m+1
  end
  if border == true then 
    ImGui.PushStyleColor(ctx, ImGui.Col_Border, butt_col_t[4])n=n+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize, b_thickness) m=m+1 
    ImGui.PushStyleColor(ctx, ImGui.Col_BorderShadow, butt_col_t[5])n=n+1
  else 
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize, 0) m=m+1 
  end
  
  local state = ImGui.Button(ctx, name, size_w, size_h)
  ImGui.PopStyleColor(ctx, n)
  ImGui.PopStyleVar(ctx, m)
  return state
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


-- for simply recall pre-generated colors --
function generate_custom_color_table()
  cust_tbl = {tr={}, it={}}
  for y=1, #custom_palette do
    cust_tbl.tr[y] = ImGui.ColorConvertNative(custom_palette[y] >>8)|0x1000000
    cust_tbl.it[y] = Background_color_rgba(custom_palette[y])
  end 
  return cust_tbl
end


function item_track_color_to_custom_palette(m, div)
  local sel_colorcnt
  local calc
  if m then 
    if m >= 0 then
      if #sel_color > div then sel_colorcnt = div else sel_colorcnt = #sel_color end
      for i = 1, sel_colorcnt do
        if (m+i-1)%div == 0 then calc = div else calc = (m+i-1)%div end
        custom_palette[calc] = sel_color[i]
      end
    elseif m == -1 then
      last_touched_color = sel_color[1]
    elseif m == -2 then
      rgba = sel_color[1]
    end
  end
  cust_tbl = nil
  check_mark = check_mark&1
  pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop = pre_cntrl.current_item, 1, nil
end


-- USER CUSTOM PALETTE BUTTON FUNCTIONS --
function SaveCustomPaletteButton()
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


function DeleteCustomPalettePreset()
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
    pre_cntrl.new_combo_preview_value, pre_cntrl.combo_preview_value, pre_cntrl.differs, pre_cntrl.stop = nil, nil, pre_cntrl.current_item, false
    cust_tbl = nil
  end
end


-- USER MAIN PALETTE BUTTON FUNCTIONS --
function SaveMainPalettePreset()
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
          SetExtState(script_name ,'current_main_item',       tostring(pre_cntrl.current_main_item),true)
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
      SetExtState(script_name ,'current_main_item', tostring(pre_cntrl.current_main_item),true)
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
      colorspace = user_main_settings[1] 
      saturation = user_main_settings[2] 
      lightness = user_main_settings[3] 
      darkness = user_main_settings[4]
    end
    pre_cntrl.differs3, pre_cntrl.stop2, pre_cntrl.main_new_combo_preview_value, pre_cntrl.main_combo_preview_value = pre_cntrl.current_main_item, false, nil, nil
  end
end


-- PALETTE MENU WINDOW --
local function PaletteMenu(p_y, p_x, w, h)
  local var, set_x, set_h, change_true, sat_true, contrast_true = 0
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowPadding, 8, 0) var=var+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 5) var=var+1
  if sys_os == 1 then
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 4) var=var+1
  else
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 3) var=var+1
  end
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, sans_serif)
  
  ImGui.SetNextWindowSize(ctx, 236, 730, ImGui.Cond_Appearing) 
  ImGui.SetNextWindowSizeConstraints(ctx, 236, 200, 250, 730, nil)
  local set_y = p_y +30
  if set_y < 0 then
    set_y = p_y + h 
  end
  if  p_x -300 < 0 then set_x = p_x + w +30 else set_x = p_x -300 end
  
  if not set_pos then
    ImGui.SetNextWindowPos(ctx, set_x, set_y, ImGui.Cond_Appearing)
  end

  visible2, openSettingWnd = ImGui.Begin(ctx, 'Palette Menu', true, ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoDocking) 
  if visible2 then
    -- GENERATE CUSTOM PALETTES -- 
    local space_btwn = 2
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    button_action(button_colors.button_color4,'CUSTOM PALETTE:##set', 220, 19, false) 
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    button_action(button_colors.button_color4,'Generate Custom Palette:', 220, 19, false) 
    if button_action(button_colors.button_color1, 'analogous', 220, 21, true, 4, 5) then 
      custom_palette_analogous()
      go, check_mark, sel_tracks2, it_cnt_sw = true, check_mark|1, nil 
    end
    if button_action(button_colors.button_color1, 'triadic', 220, 21, true, 4, 5) then 
      custom_palette_triadic()
      go, check_mark, sel_tracks2, it_cnt_sw = true, check_mark|1, nil 
    end
    if button_action(button_colors.button_color1, 'complementary', 220, 21, true, 4, 5) then 
      custom_palette_complementary()
      go, check_mark, sel_tracks2, it_cnt_sw = true, check_mark|1, nil 
    end
    if button_action(button_colors.button_color1, 'split complementary', 220, 21, true, 4, 5) then 
      custom_palette_split_complementary()
      go, check_mark, sel_tracks2, it_cnt_sw = true, check_mark|1, nil 
    end
    if button_action(button_colors.button_color1, 'double split complementary', 220, 21, true, 4, 5) then 
      custom_palette_double_split_complementary()
      go, check_mark, sel_tracks2, it_cnt_sw = true, check_mark|1, nil 
    end
    ImGui.Dummy(ctx, 0, space_btwn)
    button_action(button_colors.button_color4,'Custom Presets:', 220, 19, true, 0, 0) 
   
    -- SAVING USER CUSTOM PALETTE PRESETS --
    
    -- SAVE BUTTON --
    if button_action(button_colors.button_color1, 'Save', 90, 21, true, 4, 5) then
      SaveCustomPaletteButton()
    end
      
    -- DELETE BUTTON --
    ImGui.SameLine(ctx, 0,38)
    if button_action(button_colors.button_color1, 'Delete', 90, 21, true, 4, 5) then
      DeleteCustomPalettePreset()
    end
    
    -- USER PALETTE MENU COMBO BOX --
    if not pre_cntrl.stop and not pre_cntrl.combo_preview_value then
      pre_cntrl.combo_preview_value = user_palette[pre_cntrl.current_item]
    elseif not pre_cntrl.combo_preview_value then
      pre_cntrl.combo_preview_value = pre_cntrl.new_combo_preview_value
    end

    if sys_os == 0 then
      ImGui.PopStyleVar(ctx)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 4) 
    end
    
    ImGui.PushItemWidth(ctx, 220)
    local combo = ImGui.BeginCombo(ctx, '##6', pre_cntrl.combo_preview_value, 0) 
    if combo then 
      for i,v in ipairs(user_palette) do
        local is_selected = pre_cntrl.current_item == i
        if ImGui.Selectable(ctx, user_palette[i], is_selected, ImGui.SelectableFlags_None,  300.0,  0.0) then
          pre_cntrl.current_item = i
          SetExtState(script_name ,'current_item', tostring(pre_cntrl.current_item),true)
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

    ImGui.Dummy(ctx, 0, space_btwn)
    _, set_cntrl.random_custom = ImGui.Checkbox(ctx, "Random coloring via button##1", set_cntrl.random_custom)
    
    ImGui.PopStyleVar(ctx)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 2) 
    
    if button_color(0.14, 0.9, 0.7, 1, 'Reset Custom Palette', 220, 19, false, 3)  then 
      custom_palette = {}
      cust_tbl = nil
      it_cnt_sw = nil
      test_track_sw = nil
      go = true
      for m = 0, 23 do
        insert(custom_palette, HSL(m / 24+0.69, 0.1, 0.2, 1))
      end
      pre_cntrl.differs = true
      pre_cntrl.differs2 = 1
    end
    
    if pre_cntrl.differs and not pre_cntrl.stop and pre_cntrl.differs2 == 1 then
      pre_cntrl.new_combo_preview_value = user_palette[pre_cntrl.current_item]..' (modified)'
      pre_cntrl.stop, pre_cntrl.differs2, pre_cntrl.combo_preview_value = true, nil, nil
    end
    
    ImGui.Separator(ctx)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.PopStyleVar(ctx)
    if sys_os == 1 then
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 4)
    else
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 3) 
    end
    
    -- MAIN PALETTE SETTINGS --
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    button_action(button_colors.button_color4,'MAIN PALETTE:##set', 220, 19, false) 
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 2)
    ImGui.AlignTextToFramePadding(ctx)
    ImGui.Text(ctx, 'Color model:')
    ImGui.SameLine(ctx, 0, 10) 
    
    if ImGui.RadioButtonEx(ctx, 'HSL', colorspace, 0) then
      colorspace, lightness, darkness = 0, 0.7, 0.20
      check_mark =check_mark|4
      change_true = true
      SetExtState(script_name ,'colorspace', tostring(colorspace),true)
      SetExtState(script_name ,'lightness', tostring(lightness),true)
      SetExtState(script_name ,'darkness', tostring(darkness),true)
    end
    if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 4)
      ImGui.SetTooltip(ctx, '\n HSL:\n\n Even pure colors (maximum saturation) can reach full white at a maximum (capped to 80%).\n\n')
      ImGui.PopStyleVar(ctx, 1)
    end
    ImGui.SameLine(ctx, 0, 10) 
    if ImGui.RadioButtonEx(ctx, 'HSV', colorspace, 1) then
      colorspace, lightness, darkness = 1, 1, 0.3
      check_mark = check_mark|4
      change_true = true
      SetExtState(script_name ,'colorspace', tostring(colorspace),true)
      SetExtState(script_name ,'lightness', tostring(lightness),true)
    end
    if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 4)
      ImGui.SetTooltip(ctx, "\n HSV:\n\n In contrast, HSVs brightest point is always the pure color itself,\n with darker shades as values go down towards black.\n\n")
      ImGui.PopStyleVar(ctx, 1)
    end
    
    local lightness_range
    if colorspace == 1 then lightness_range = 1 else lightness_range = 0.8 end
    
    ImGui.PopStyleVar(ctx, 1)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 2)
    button_action(button_colors.button_color4,'saturation##set', 220, 19, false) 
    ImGui.PopStyleVar(ctx, 1)
    ImGui.PushItemWidth(ctx, 220)
    sat_true, saturation = ImGui.SliderDouble(ctx, '##1', saturation, 0.3, 1.0, '%.3f', ImGui.SliderFlags_None)
    
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 2)
    button_action(button_colors.button_color4,'darkness - lightness', 220, 19, false) 
    ImGui.PopStyleVar(ctx, 1)
    contrast_true ,darkness, lightness = ImGui.SliderDouble2(ctx, '##2', darkness, lightness, 0.12, lightness_range)
    
    if sat_true or contrast_true then
    check_mark, go, it_cnt_sw, test_track_sw = check_mark|4, true, nil
    end
    
    -- USER MAIN PALETTE PRESET --
    
    -- SAVE BUTTON --
    ImGui.Dummy(ctx, 0, space_btwn)
    button_action(button_colors.button_color4,'Main Presets:', 220, 19, false) 
    
    if button_action(button_colors.button_color1, 'Save##2', 90, 21, true, 4, 5) then
      SaveMainPalettePreset()
    end
      
    -- DELETE BUTTON --
    ImGui.SameLine(ctx, 0,38)
    if button_action(button_colors.button_color1, 'Delete##2', 90, 21, true, 4, 5) then
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
          SetExtState(script_name ,'current_main_item', tostring(pre_cntrl.current_main_item),true)
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
            SetExtState(script_name ,'colorspace', tostring(colorspace),true)
            SetExtState(script_name ,'saturation', tostring(saturation),true)
            SetExtState(script_name ,'lightness', tostring(lightness),true)
            SetExtState(script_name ,'darkness', tostring(darkness),true)
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
    ImGui.Dummy(ctx, 0, space_btwn)
    _, set_cntrl.random_main = ImGui.Checkbox(ctx, "Random coloring via button##2", set_cntrl.random_main)
    
    ImGui.PopStyleVar(ctx)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 2) 
    
    if button_color(0.14, 0.9, 0.7, 1, 'Reset Main Palette', 220, 19, false, 3)  then 
      saturation, lightness, darkness, colorspace, set_cntrl.dont_ask = 0.8, 0.65, 0.20, 0, false
      check_mark, go, it_cnt_sw, test_track_sw = check_mark|4, true, nil
      SetExtState(script_name ,'colorspace', tostring(colorspace),true)
      SetExtState(script_name ,'dont_ask', tostring(set_cntrl.dont_ask),true)
      SetExtState(script_name ,'saturation', tostring(saturation),true)
      SetExtState(script_name ,'lightness', tostring(lightness),true)
      SetExtState(script_name ,'darkness', tostring(darkness),true)
    end
    
    if check_mark&4 == 4 and pre_cntrl.current_main_item > 1 and not pre_cntrl.stop2 then
      pre_cntrl.main_new_combo_preview_value = user_mainpalette[pre_cntrl.current_main_item]..' (modified)'
      pre_cntrl.stop2, pre_cntrl.main_combo_preview_value = true, nil
    end
    ImGui.Separator(ctx)
    ImGui.Dummy(ctx, 0, 6)
    
    if button_action(button_colors.button_color1, '##Info2', 31, 31, true, 4, 15) then
      openSettingWnd2 = true
      scroll_amount = 0
      get_scroll = false
    end

    -- DRAWING --
    local pos = {ImGui.GetCursorScreenPos(ctx)}
    local center = {pos[1]+10, pos[2]}
    local draw_list = ImGui.GetWindowDrawList(ctx)
    local draw_color = 0xffe8acff
    local draw_thickness = 3
    
    ImGui.DrawList_AddLine(draw_list, center[1]+6, center[2]-21, center[1]+6, center[2]-13, draw_color, draw_thickness)
    ImGui.DrawList_AddLine(draw_list, center[1]+3, center[2]-21, center[1]+8, center[2]-21, draw_color, 2)
    ImGui.DrawList_AddLine(draw_list, center[1]+3, center[2]-13, center[1]+10, center[2]-13, draw_color, 2)
    ImGui.DrawList_AddCircleFilled(draw_list, center[1]+6, center[2]-27, 2, draw_color,  0)
    
    ImGui.End(ctx)
    set_pos = {ImGui.GetWindowPos(ctx)}
  end
  ImGui.PopStyleVar(ctx, var)
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, buttons_font2)
end


-- PALETTE MENU WINDOW --
function InfoWindow(p_y, p_x, w, h)
  local var, set_x, set_h = 0
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowPadding, 8, 0) var=var+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 8) var=var+1
  if sys_os == 1 then
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 4) var=var+1
  else
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 3) var=var+1
  end
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, sans_serif)
  ImGui.SetNextWindowSize(ctx, 400, 690, ImGui.Cond_Appearing) 
  ImGui.SetNextWindowSizeConstraints(ctx, 400, 200, 400, 690, nil)
  local _, _, right, _ = reaper.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true)
  local set_y = p_y 
  if set_y < 0 then
    set_y = p_y + h 
  end
  set_x = right - 420
  if not set_pos2 then
    ImGui.SetNextWindowPos(ctx, set_x, set_y, ImGui.Cond_Appearing)
  end
  
  visible3, openSettingWnd2 = ImGui.Begin(ctx, 'Guidance', true, ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoDocking) 
  if visible3 then
    if not get_scroll then
      ImGui.SetScrollY(ctx, scroll_amount)
      get_scroll = true
    end
    local space_btwn = 6
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    button_action(button_colors.button_color4,'ALL COLOR BUTTONS:', 360, 19, false) 
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize,3) 
    ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign, 0.5, 0.5)
    ImGui.SeparatorText(ctx, '  Selection is the key:  ')
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '  TCP/ARRANGE/RULER/MANAGER Window\n  context-aware.')
    ImGui.Text(ctx, '  Selection Indicator and Action Buttons follow selection.')
    ImGui.Text(ctx, '  Selection Indicator is located in the top right-hand\n  corner and shows what is being colored.')
    ImGui.Text(ctx, '  Click it to switch between tracks and items.')
    ImGui.Text(ctx, '  Static Context Mode is activated by holding ctrl/cmd\n  and clicking selection indicator.')
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    ImGui.SeparatorText(ctx, "  Drag'n'Drop:  ")
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '  Drag colors from all color buttons.')
    ImGui.Text(ctx, '  Drop colors to the Custom Colors Palette and the Custom Color Editing Button.')
    ImGui.SeparatorText(ctx, '')
    ImGui.Dummy(ctx, 0, 2)
    
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    button_action(button_colors.button_color4,'PALETTE MENU:', 360, 19, false) 
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.SeparatorText(ctx, '  Generate Custom Palette:  ')
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '  Drag a color from the Main Palette to the first button\n  of the Custom Palette as your base color.')
    ImGui.Text(ctx, '  Click one of the five buttons in the Palette Menu for\n  the desired automatically generated Custom Palette.')
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    ImGui.SeparatorText(ctx, "  Presets:  ")
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '  Save/Load/Delete your Custom Palette Presets.')
    ImGui.SeparatorText(ctx, '')
    
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    button_action(button_colors.button_color4,'GRADIENT COLORING INFO:', 360, 19, false) 
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.SeparatorText(ctx, ' Gradient Action Button ')
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '"Color elements to gradient" - action button:')
    ImGui.Dummy(ctx, 0, 2)
    ImGui.Text(ctx, '  colors selected elements with gradient between\n  first selected element color and last selected.')
    ImGui.Text(ctx, "  if first or last color is missing, there's a\n  autocoloring logic to it.")
    ImGui.Text(ctx, '  hold "SHIFT" and press button for\n  "color elements to gradient shade" action shortcut.')
    ImGui.Text(ctx, '  Rightclick Menu contains additional functions')
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    ImGui.SeparatorText(ctx, '  Gradient Modifiers ')
    ImGui.PopStyleColor(ctx, 1)
    
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, 'Mouse Modifiers for Gradient of any color button:')
    ImGui.Dummy(ctx, 0, 2)
    ImGui.Text(ctx, '  "CTRL/CMD + SHIFT" - gradient in two steps:')
    ImGui.Text(ctx, '    hold shortcut, select first and then last gradient color\n    via any color button.')
    ImGui.Dummy(ctx, 0, 2)
    ImGui.Text(ctx, '  "CTRL/CMD + ALT/OPTION + SHIFT":')
    ImGui.Text(ctx, '    Shortcut for "Set elements to gradient shade"\n    while first element color get set.')
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    ImGui.SeparatorText(ctx, '  Gradient in Rightclick Menus  ')
    ImGui.PopStyleColor(ctx, 1)
    
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, 'Actions in righclick menu of any color button:')
    ImGui.Dummy(ctx, 0, 2)
    ImGui.Text(ctx, '  "Color elements to gradient (define first)" - action:')
    ImGui.Text(ctx, '    sets first selected element to button color\n    and all elements to gradient between\n    first and last element color.')
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '  "Color elements to gradient shade" - action:')
    ImGui.Text(ctx, '    sets first selected element to button color\n    and all elements to gradient between\n    first and its darker/lighter shade.')
    
    ImGui.SeparatorText(ctx, '')
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    button_action(button_colors.button_color4,'MOUSE MODIFIERS:', 360, 19, false) 
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.SeparatorText(ctx, '  Color Buttons  ')
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, 'SHIFT:')
    ImGui.Text(ctx, '  Shortcut for coloring any Element with multiple\n  Main/Custom Palette colors by Color Button click.')
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.Text(ctx, 'SHIFT+CMD/CTRL:')
    ImGui.Text(ctx, '  Gradient shortcut by choosing a start color (1st click)\n  and then a last color (2nd click).')
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.Text(ctx, 'CMD/CTRL:')
    ImGui.Text(ctx, '  If "items" are indicated, it colors selected items\n  their tracks and items that contain track color.')
    ImGui.Text(ctx, '  If "tracks" are indicated, it ruthlessly colors\n  selected tracks and all containing items.')
    ImGui.Text(ctx, '  If "markers/regions" are indicated, it colors\n  all inside time selection.')
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.Text(ctx, 'CMD/CTRL + ALT/OPTIONS:')
    ImGui.Text(ctx, '  Get selected colors to Custom Palette Buttons.')
    ImGui.Dummy(ctx, 0, space_btwn)

    ImGui.Text(ctx, 'ALT/OPTIONS:')
    ImGui.Text(ctx, '  Reset Custom Palette Button.')
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.Text(ctx, 'ALT/OPTIONS+SHIFT:')
    ImGui.Text(ctx, '  Edit Custom Palette Button.')
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.Text(ctx, 'RIGHTCLICK:')
    ImGui.Text(ctx, '  Action Popup on Color Buttons.')
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.SeparatorText(ctx, '')
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    button_action(button_colors.button_color4,'INFO BAR:', 360, 19, false) 
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.Text(ctx, 'Tick "Show Mouse Modifier description in the Menubar"\nunder settings.')
    ImGui.Text(ctx, 'Hold a Mouse Modifier or multiple Modifiers to let appear\ninformation in the MenuBar at the top next to "Settings".')
    ImGui.Dummy(ctx, 0, space_btwn)
    
    ImGui.SeparatorText(ctx, '')
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    button_action(button_colors.button_color4,'THE TWO MODES:', 360, 19, false) 
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.SeparatorText(ctx, '  Normal Mode  ')
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '  Regular coloring:')
    ImGui.Text(ctx, '  we focused on take color for items. Let us know,\n  if it doesn’t fit your preferences or themes.')
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.SeparatorText(ctx, '  ShinyColors Mode:  ')
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '  Take color sets the peak, item color sets\n  the much lighter background color.')
    ImGui.Text(ctx, '  Important Notes:')
    ImGui.Text(ctx, '  This mode needs a value of 50 for tinttcp in your\n  theme to be used properly and work as expected.')
    ImGui.Text(ctx, '  It is not intended to be used together with\n  spectral peaks.')
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.SeparatorText(ctx, '')
    ImGui.Dummy(ctx, 0, 2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) 
    button_action(button_colors.button_color4,'ADDITIONAL:', 360, 19, false) 
    ImGui.PopStyleColor(ctx, 1)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.Text(ctx, '  Exit the script via "Escape Key".')
    ImGui.SeparatorText(ctx, '')

    ImGui.PushItemWidth(ctx, 220)
    ImGui.Dummy(ctx, 0, space_btwn)
    ImGui.PopStyleVar(ctx, 2)
    ImGui.End(ctx)
    set_pos2 = {ImGui.GetWindowPos(ctx)}
  end
  ImGui.PopStyleVar(ctx, var)
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, buttons_font2)
end


local function SettingsPopUp(size, bttn_height, spacing, fontsize)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 3, 3) 
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 12) 
  ImGui.Dummy(ctx, 0, 0)
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
  -- HIDING SECTIONS --
  if set_cntrl.tree_node_open then
    ImGui.SetNextItemOpen(ctx, true, ImGui.Cond_Once)
  end
  set_cntrl.tree_node_open = ImGui.TreeNode(ctx, 'SECTIONS (show/hide)')
  if set_cntrl.tree_node_open then -- first treenode --
    set_cntrl.tree_node_open_save = true
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
    if ImGui.Checkbox(ctx, 'Show Custom Palette', show_custompalette) then
      if show_custompalette then
        show_custompalette, resize = false, 2
        SetExtState(script_name ,'show_custompalette', tostring(show_custompalette),true)
      else
        show_custompalette, resize = true, 5
        SetExtState(script_name ,'show_custompalette', tostring(show_custompalette),true)
        if show_seperators then set_cntrl.resize_height = (size+.5)//1+(size*0.2)//1+fontsize
        elseif show_mainpalette and (not show_lasttouched or not show_edit or not show_luminance_adjuster) then
          set_cntrl.resize_height = (size+.5)//1+fontsize
        elseif (show_lasttouched or show_edit) then
          set_cntrl.resize_height = (size+.5)//1+(size*0.3)//1+(size*0.2)//1+(size*0.1)//1
        else set_cntrl.resize_height = size*1.2 end
      end
    end
    if ImGui.Checkbox(ctx, 'Show Edit custom color', show_edit) then
      if show_edit then show_edit, resize = false, 2
        SetExtState(script_name ,'show_edit', tostring(show_edit),true)
      else show_edit = true
        SetExtState(script_name ,'show_edit', tostring(show_edit),true)
        if show_seperators then
          if show_lasttouched or show_luminance_adjuster then set_cntrl.resize_height, resize = 0, 0
          elseif show_custompalette and not show_mainpalette then
            set_cntrl.resize_height, resize = (size+.5)//1+(size2*0.3)//1, 9
          elseif show_custompalette then
            set_cntrl.resize_height, resize = (size+.5)//1, 9
          elseif not show_mainpalette and not show_custompalette then
            set_cntrl.resize_height, resize = (size+.5)//1+(size*0.3)//1, 9
          else set_cntrl.resize_height, resize = size*1.1, 9 end
        else
          if show_lasttouched or show_luminance_adjuster then resize, set_cntrl.resize_height = 0, 0
          elseif not show_mainpalette and not show_custompalette then
            set_cntrl.resize_height, resize = (size+.5)//1+(size2*0.3)//1, 9 
          else
            if not show_custompalette then resize = 9 else resize = 521 end
            set_cntrl.resize_height = (size+.5)//1+(size*0.2)//1+(size*0.3)//1+(size*0.2)//1 end
        end
      end
      SetExtState(script_name ,'show_custompalette', tostring(show_custompalette),true)
    end
    if ImGui.Checkbox(ctx, 'Show Last touched', show_lasttouched) then
      if show_lasttouched then
        show_lasttouched, resize = false, 2
      else
        show_lasttouched = true
        if show_seperators then
          if show_edit or show_luminance_adjuster then set_cntrl.resize_height, resize = 0, 0 
          elseif show_custompalette and not show_mainpalette then
            set_cntrl.resize_height, resize  = (size+.5)//1+(size*0.3)//1, 17
          elseif show_custompalette then
            set_cntrl.resize_height, resize  = (size+.5)//1, 17
          elseif not show_mainpalette and not show_custompalette then
            set_cntrl.resize_height, resize = (size+.5)//1+(size*0.3)//1, 17
          else set_cntrl.resize_height, resize  = size*1.1, 17  end
        else
          if show_edit or show_luminance_adjuster then set_cntrl.resize_height = 0 resize = 0 
          elseif not show_mainpalette and not show_custompalette then
            set_cntrl.resize_height, resize = (size+.5)//1+(size*0.3)//1, 17
          else
            if not show_custompalette then resize = 17 else resize = 529 end
            set_cntrl.resize_height = (size+.5)//1+(size*0.3)//1+(size*0.3)//1+(size*0.1)//1 end
        end
      end
      SetExtState(script_name ,'show_lasttouched', tostring(show_lasttouched),true)
    end
    if ImGui.Checkbox(ctx, 'Show Luminance Adjuster', show_luminance_adjuster) then
      if show_luminance_adjuster then
        show_luminance_adjuster, resize = false, 2
      else
        show_luminance_adjuster = true
        if show_seperators then
          if show_edit or show_lasttouched then set_cntrl.resize_height, resize = 0, 0 
          elseif show_custompalette and not show_mainpalette then
            set_cntrl.resize_height, resize  = (size+.5)//1+(size*0.3)//1, 4097
          elseif show_custompalette then
            set_cntrl.resize_height, resize  = (size+.5)//1, 4097
          elseif not show_mainpalette and not show_custompalette then
            set_cntrl.resize_height, resize = (size+.5)//1+(size*0.3)//1, 4097
          else set_cntrl.resize_height, resize  = size*1.1, 4097  end
        else
          if show_edit or show_lasttouched then set_cntrl.resize_height = 0 resize = 0 
          elseif not show_mainpalette and not show_custompalette then
            set_cntrl.resize_height, resize = (size+.5)//1+(size*0.3)//1, 4097
          else
            if not show_custompalette then resize = 4097 else resize = 4609 end
            set_cntrl.resize_height = (size+.5)//1+(size*0.3)//1+(size*0.3)//1+(size*0.1)//1
          end
        end
      end
      SetExtState(script_name ,'show_luminance_adjuster', tostring(show_luminance_adjuster),true)
    end
    if ImGui.Checkbox(ctx, 'Show Seperators', show_seperators) then
      if show_seperators then
        show_seperators, resize = false, 2 
      else
        show_seperators, resize = true, 129
        if show_custompalette and show_mainpalette and (show_lasttouched or show_edit or show_luminance_adjuster) then
          set_cntrl.resize_height, resize = fontsize*2-math.ceil(size*0.05)-(size*0.3)//1-(size*0.3)//1, 897
        elseif show_custompalette and show_mainpalette then
          set_cntrl.resize_height, resize = fontsize+(size*0.2)//1+(size*0.1)//1, 2433 
        elseif show_custompalette and not show_mainpalette and (show_edit or show_lasttouched or show_luminance_adjuster) then
          set_cntrl.resize_height, resize = fontsize-math.ceil(size*0.02), 641
        elseif not show_custompalette and show_mainpalette and (show_edit or show_lasttouched or show_luminance_adjuster) then
          set_cntrl.resize_height, resize = fontsize-math.ceil(size*0.02)-(size*0.2)//1, 1281
        elseif not show_custompalette and show_mainpalette and not show_edit and not show_lasttouched and not show_luminance_adjuster then
          set_cntrl.resize_height, resize = fontsize+(size*0.1)//1, 257
        elseif not show_custompalette and not show_mainpalette and (show_edit or show_lasttouched or show_luminance_adjuster) then
          set_cntrl.resize_height, resize = size*0, 0
        elseif show_custompalette then
          set_cntrl.resize_height, resize = fontsize+(size*0.3+.5)//1, 129
        else
          set_cntrl.resize_height, resize = 0, 129
        end
      end
      SetExtState(script_name ,'show_seperators', tostring(show_seperators),true)
    end
    if ImGui.Checkbox(ctx, 'Show Main Palette', show_mainpalette) then
      if show_mainpalette then
        show_mainpalette, resize = false, 2
      else
        show_mainpalette = true
        if show_seperators and not show_lasttouched and not show_edit then
          set_cntrl.resize_height, resize = ((size+.5)//1)*5+spacing//1*5+fontsize+(size*0.1)//1, 289
        elseif show_seperators then
          set_cntrl.resize_height, resize = (size+.5)//1*5+spacing//1*5+(size*0.1)//1+fontsize-math.ceil(size*0.05), 289
        elseif (show_lasttouched or show_edit or show_luminance_adjuster) and show_custompalette then
          set_cntrl.resize_height, resize = (size+.5)//1*5+spacing//1*5+(size*0.1)//1, 801
        elseif show_lasttouched or show_edit or show_luminance_adjuster then
          set_cntrl.resize_height, resize = (size+.5)//1*5+spacing//1*5+(size*0.1)//1, 289
        elseif show_custompalette then
          set_cntrl.resize_height, resize = (size+.5)//1*5+spacing//1*5+fontsize, 289
        else
          set_cntrl.resize_height, resize = (size+.5)//1*5+spacing//1*5, 289
        end
      end
      SetExtState(script_name ,'show_mainpalette', tostring(show_mainpalette),true)
    end
    ImGui.PopStyleVar(ctx, 1)
    if ImGui.Checkbox(ctx, 'Show Action buttons', show_action_buttons) then
      if show_action_buttons then 
        show_action_buttons, resize = false, 2 
      else 
        show_action_buttons, resize, set_cntrl.resize_height = true, 65, bttn_height//1+(size*0.6)//1
      end
      SetExtState(script_name ,'show_action_buttons', tostring(show_action_buttons),true)
    end
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
  set_cntrl.tree_node_open3 = ImGui.TreeNode(ctx, 'APPEARANCE')
  if set_cntrl.tree_node_open3 then -- first treenode --
    set_cntrl.tree_node_open_save3 = true
    -- APPEARANCE --
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
    ImGui.PopStyleVar(ctx, 1)
    
    if ImGui.Checkbox(ctx, 'Use REAPER theme background color', set_cntrl.background_color_mode) then
      if set_cntrl.background_color_mode then
        set_cntrl.background_color_mode = false
      else
        set_cntrl.background_color_mode = true
      end
      SetExtState(script_name ,'background_color_mode', tostring(set_cntrl.background_color_mode),true)
    end
    
    if ImGui.Checkbox(ctx, 'Set GhostMode for Menubar', set_cntrl.topbar_ghost_mode) then
      if set_cntrl.topbar_ghost_mode then
        set_cntrl.topbar_ghost_mode = false
        set_cntrl.resize_height = size+size*0.6
        resize = 1
      else
        set_cntrl.topbar_ghost_mode = true
        resize = 2
      end
      SetExtState(script_name ,'topbar_ghost_mode', tostring(set_cntrl.topbar_ghost_mode),true)
    end
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 4)
    if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
      ImGui.SetTooltip(ctx, '\n Hovering the low part of the titlebar will bring up the Menubar\n\n')
    end
    
    if ImGui.Checkbox(ctx, 'Show Mouse Modifier description in Menubar', set_cntrl.modifier_info) then
      if set_cntrl.modifier_info then
        set_cntrl.modifier_info = false
      else
        set_cntrl.modifier_info = true
      end
      SetExtState(script_name ,'modifier_info', tostring(set_cntrl.modifier_info),true)
    end
    
    if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
      ImGui.SetTooltip(ctx, '\n Show up infos for buttons with mouse modifiers when hovered\n\n')
    end
    
    if ImGui.Checkbox(ctx, 'Show Tooltips for some Elements when hovered', set_cntrl.tooltip_info) then
      if set_cntrl.tooltip_info then
        set_cntrl.tooltip_info = false
      else
        set_cntrl.tooltip_info = true
      end
      SetExtState(script_name ,'tooltip_info', tostring(set_cntrl.tooltip_info),true)
    end
    
    if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info  then
      ImGui.SetTooltip(ctx, '\n Not all Elements are in need for extra information\n\n')
    end

    if ImGui.Checkbox(ctx, 'Quit after coloring', set_cntrl.quit) then
      if set_cntrl.quit then
        set_cntrl.quit = false
      else
        set_cntrl.quit = true
      end
      SetExtState(script_name ,'quit', tostring(set_cntrl.quit),true)
    end
    
    if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.quit  then
      --ImGui.SetTooltip(ctx, '\n Not all Elements are in need for extra information\n\n')
    end
    
    if ImGui.Checkbox(ctx, 'Open at mouse position:', set_cntrl.open_at_mouse) then
      if set_cntrl.open_at_mouse then
        set_cntrl.open_at_mouse = false
      else
        set_cntrl.open_at_mouse = true
      end
      SetExtState(script_name ,'open_at_mouse', tostring(set_cntrl.open_at_mouse),true)
    end
    
    ImGui.PopStyleColor(ctx,1)
    ImGui.PopStyleVar(ctx, 1)
    ImGui.SameLine(ctx, 0, 20)
    
    if ImGui.BeginPopupContextItem(ctx, '##Settings10') then
      local t = set_cntrl.selectables
      local n = #t.keys
      for i = 0, n*3-1 do
        local x, y = i%n+1, i//n+1
        local name = t.x[x]..t.y[y]
        if x > 1 then ImGui.SameLine(ctx); end
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_SelectableTextAlign, 0.5, 0.5)
        local row = t.align[y]
        if ImGui.Selectable(ctx, name, row[x], ImGui.SelectableFlags_DontClosePopups, 116, 40) then
          local reset = t.align[t.selected.s_y]
          reset[t.selected.s_x] = false
          row[x] = true
          t.selected.s_y, t.selected.s_x = y, x
          pre_cntrl.mouse_open_Y, pre_cntrl.mouse_open_X = t.keys[y], t.keys[x]
          SetExtState(script_name ,'mouse_open_X', tostring(pre_cntrl.mouse_open_X),true)
          SetExtState(script_name ,'mouse_open_Y', tostring(pre_cntrl.mouse_open_Y),true)
        end
        ImGui.PopStyleVar(ctx)
      end
      ImGui.EndPopup(ctx)
    end
    if ImGui.Button(ctx, 'Alignment', 100, 25) then
      ImGui.OpenPopup(ctx, '##Settings10')
    end
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
    ImGui.PopStyleColor(ctx, 1)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
  
    -- MODE SELECTION --
    ImGui.AlignTextToFramePadding(ctx)
    ImGui.Text(ctx, 'Mode:')
    ImGui.SameLine(ctx, 0, 7)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
    if  ImGui.RadioButtonEx(ctx, 'Normal', selected_mode, 0) then
      selected_mode = 0
      SetExtState(script_name ,'selected_mode',   tostring(selected_mode),true)
    end
    ImGui.SameLine(ctx, 0 , 25)
    if ImGui.RadioButtonEx(ctx, 'ShinyColors', selected_mode, 1) then
      if not set_cntrl.dont_ask then
        ImGui.OpenPopup(ctx, 'ShinyColors Mode')
      else
        selected_mode = 1
        SetExtState(script_name ,'selected_mode',   tostring(selected_mode),true)
      end
    end
  
    -- SHINYCOLORS MODE POPUP --
    local center = {ImGui.Viewport_GetCenter(ImGui.GetWindowViewport(ctx))}
    ImGui.SetNextWindowPos(ctx, center[1], center[2], ImGui.Cond_Appearing, 0.5, 0.5)
    if ImGui.BeginPopupModal(ctx, 'ShinyColors Mode', nil, ImGui.WindowFlags_AlwaysAutoResize) then
      ImGui.Text(ctx, '\nTo use the full potential of ShinyColors Mode,\nmake sure Custom colors settings are set correctly under:\n\n"REAPER/ Preferences/ Appearance/",\n\nor that the currently used theme has a value of 50 for "tinttcp"\ninside its rtconfig.txt file!')
      ImGui.Dummy(ctx, 0, 0)
      ImGui.AlignTextToFramePadding(ctx)
      ImGui.Text(ctx, 'More info:')
      ImGui.SameLine(ctx, 0, 20)
      if button_action(button_colors.button_color1, 'Open PDF in browser', 200, 21, true, 4, 5) then
        OpenURL('https://drive.google.com/file/d/1fnRfPrMjsfWTdJtjSAny39dWvJTOyni1/view?usp=share_link')
      end
      ImGui.Dummy(ctx, 0, 0)
      ImGui.Separator(ctx)
      ImGui.Dummy(ctx, 0, 10)
      ImGui.AlignTextToFramePadding(ctx)
      ImGui.Text(ctx, 'Continue with ShinyColors Mode?')
    
      if button_action(button_colors.button_color1, 'OK', 90, 21, true, 4, 5) then
        ImGui.CloseCurrentPopup(ctx)
        selected_mode = 1
        SetExtState(script_name ,'selected_mode',   tostring(selected_mode),true)
      end
      ImGui.SetItemDefaultFocus(ctx)
      ImGui.SameLine(ctx, 0, 20)
    
      if button_action(button_colors.button_color1, 'Cancel', 90, 21, true, 4, 5) then
        ImGui.CloseCurrentPopup(ctx); selected_mode = 0
      end
      ImGui.SameLine(ctx, 0, 20)
      _, set_cntrl.dont_ask = ImGui.Checkbox(ctx, " Don't ask me next time", set_cntrl.dont_ask)
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
    if ImGui.Checkbox(ctx, "Autocolor new tracks", auto_trk) then
      if auto_trk then
        auto_trk = false
        SetExtState(script_name ,'auto_trk', tostring(auto_trk),true)
      else
        auto_trk = true
        SetExtState(script_name ,'auto_trk', tostring(auto_trk),true)
      end
    end
    
    if auto_trk then 
      ImGui.Dummy(ctx, 0, 0) 
      ImGui.SameLine(ctx, 0.0, 20)
      
      if ImGui.Checkbox(ctx, "Autocolor new tracks to custom palette", auto_track.auto_custom) then
        if not auto_track.auto_custom then
          auto_track.auto_stable = false
          SetExtState(script_name ,'auto_stable', tostring(auto_track.auto_stable),true)
          auto_track.auto_custom = true
          SetExtState(script_name ,'auto_custom', tostring(auto_track.auto_custom),true)
          auto_track.auto_pal = cust_tbl
          auto_track.auto_palette = custom_palette
          remainder = 24
        else
          auto_track.auto_custom = false
          SetExtState(script_name ,'auto_custom', tostring(auto_track.auto_custom),true)
          auto_track.auto_stable = false
          SetExtState(script_name ,'auto_stable', tostring(auto_track.auto_stable),true)
          auto_track.auto_pal = pal_tbl
          auto_track.auto_palette = main_palette
          remainder = 120
        end
      end
      ImGui.Dummy(ctx, 0, 0) 
      ImGui.SameLine(ctx, 0.0, 20)
      if ImGui.Checkbox(ctx, "Autocolor new tracks to defined color:", auto_track.auto_stable) then
        if auto_track.auto_stable then
          auto_track.auto_stable = false
          SetExtState(script_name ,'auto_stable', tostring(auto_track.auto_stable),true)
          auto_track.auto_pal = pal_tbl
          auto_track.auto_palette = main_palette
          remainder = 120
        else
          auto_track.auto_stable = true
          SetExtState(script_name ,'auto_stable', tostring(auto_track.auto_stable),true)
          auto_track.auto_custom = false
          SetExtState(script_name ,'auto_custom', tostring(auto_track.auto_custom),true)
          auto_track.auto_pal = {tr ={ImGui.ColorConvertNative(rgba3 >>8)|0x1000000}, it ={Background_color_rgba(rgba3)}}
          auto_track.auto_palette = {rgba3}
          remainder = 1
        end
      end
      ImGui.SameLine(ctx, 0.0, 20)
      
      if ImGui.ColorButton(ctx, '##stable',  rgba3, ImGui.ButtonFlags_MouseButtonLeft, size, (size+.5)//1) then
        ImGui.OpenPopup(ctx, 'Choose color#3', ImGui.PopupFlags_MouseButtonLeft)
        backup_color3 = rgba3
      end
      
      local open_popup3 = ImGui.BeginPopup(ctx, 'Choose color#3')
      if open_popup3 then
        rgba3 = ColorEditPopup(backup_color3, rgba3, rgba3)
        stable_t = {tr ={ImGui.ColorConvertNative(rgba3 >>8)|0x1000000}, it ={Background_color_rgba(rgba3)}}
      end
    end
    
    ImGui.Dummy(ctx, 0, 10)
    if ImGui.Checkbox(ctx, "Keep running AutoColor options after exit", set_cntrl.keep_running1) then
      if set_cntrl.keep_running1 then
        set_cntrl.keep_running1 = false
        SetExtState(script_name ,'keep_running1', tostring(set_cntrl.keep_running1),true)
      else
        set_cntrl.keep_running1 = true
        SetExtState(script_name ,'keep_running1', tostring(set_cntrl.keep_running1),true)
      end
    end
    
    if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
      ImGui.SetTooltip(ctx, '\n Starts "Discrete Auto Coloring (Chroma_Extension).lua" Script after exit\n\n which keeps all autocolor functions running\n\n')
    end
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
          SetExtState(script_name ,'automode_id', tostring(automode_id),true)
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
  ImGui.PopStyleVar(ctx, 2)
  ImGui.PopStyleColor(ctx)
  ImGui.Dummy(ctx, 0, 0) 
end


function text_pos(x, z, bol1)
  local function str(y)
    local string_length = ImGui.CalcTextSize(ctx, y, nil, nil, false, -1.0)
    return string_length
  end
  local key
  if bol1 then
    max_str = 'Color items to gradient hell(define first) '
  else
    max_str = 'Color items to gradient hell(define first) '
  end
  local k = str(max_str) + str(max_str)-str(z) - str(x)-140
  return k
end


function GradientPopUp(sel_tracks, sel_items, sel_color_patch, sel_color_num, stay_mode, grad, p_y, p_x, w, h, tr_cnt)
  local cntrl_key, alt_key
  local width = true
  local selectable_flags = ImGui.SelectableFlags_DontClosePopups
  if sys_os == 1 then cntrl_key, alt_key  = 'CMD', 'OPTION' else cntrl_key, alt_key = 'CTRL', 'ALT' end
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ButtonTextAlign, 0, 0.5)
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
  
  local button_text1, button_text2
  
  if items_mode == 1 then
    button_text1 = 'Set items to gradient shade'
  elseif items_mode == 3 and sel_mk == 1 then
    button_text1 = 'Set markers to gradient shade'
  elseif items_mode == 3 and sel_mk == 2 then
    button_text1 = 'Set regions to gradient shade'
  else
    button_text1 = 'Set tracks to gradient shade'
    button_text2 = 'Set trackfolder to gradient shade'
  end
  
  if ImGui.Selectable(ctx, button_text1, p_selected1, selectable_flags, 0, 0) then
    Color_selected_elements_with_gradient(sel_tracks, sel_items, sel_color_patch, sel_color_num, stay_mode, 1)
    if set_cntrl.quit then set_cntrl.open = true end
  end
  
  local text_pos1 = text_pos("SHIFT", button_text1, width)
  ImGui.SameLine(ctx, 0, text_pos1)
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
  ImGui.Text(ctx, "SHIFT")
  
  if items_mode == 0 then
    ImGui.PopStyleColor(ctx, 1)
    if ImGui.Selectable(ctx, button_text2, p_selected12, selectable_flags, 0, 0) then
      Color_selected_elements_with_gradient(sel_tracks, sel_items, sel_color_patch, sel_color_num, stay_mode, 2, tr_cnt)
      if set_cntrl.quit then set_cntrl.open = true end
    end

    --Color_selected_elements_with_gradient(sel_tracks, sel_items, sel_color_patch, sel_color[#sel_color], nil, grad_mode, tr_cnt)
    
    local text_pos2 = text_pos("SHIFT+"..cntrl_key, button_text2, width)
    ImGui.SameLine(ctx, 0, text_pos2)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    ImGui.Text(ctx, "SHIFT+"..cntrl_key)
  end
  
  ImGui.PopStyleColor(ctx, 1)
  ImGui.PopStyleVar(ctx, 1)
  ImGui.Separator(ctx)
  ImGui.Dummy(ctx, 0, size*0.4)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ButtonTextAlign, 0.5, 0.5)
  if button_action(button_colors.button_color1, '##Info', size*1, size*1, true, size*0.14, size*0.5) then
    openSettingWnd2 = true
    scroll_amount = 646
    get_scroll = false
  end
  
  -- INFO DRAWING --
  local pos = {ImGui.GetCursorScreenPos(ctx)}
  local center = {pos[1]+size*0.25, pos[2]}
  local draw_list = ImGui.GetWindowDrawList(ctx)
  local draw_color = 0xffe8acff
  local draw_thickness = size*0.11
  
  ImGui.DrawList_AddLine(draw_list, center[1]+size*0.25, center[2]-size*0.5, center[1]+size*0.25, center[2]-size*0.25, draw_color, draw_thickness)
  ImGui.DrawList_AddLine(draw_list, center[1]+size*0.11, center[2]-size*0.5, center[1]+size*0.3, center[2]-size*0.5, draw_color, size*0.075)
  ImGui.DrawList_AddLine(draw_list, center[1]+size*0.11, center[2]-size*0.25, center[1]+size*0.4, center[2]-size*0.25, draw_color, size*0.075)
  ImGui.DrawList_AddCircleFilled(draw_list, center[1]+size*0.25, center[2]-size*0.7, size*0.075, draw_color,  0)
  
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PopStyleVar(ctx, 2)
  ImGui.PopStyleColor(ctx)
end


function MultiplePalPopUp()
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ButtonTextAlign, 0, 0.5)
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, size*0.3)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, size*0.14); 
  ImGui.PushStyleColor(ctx, ImGui.Col_Border,0x303030ff) 
  ImGui.PushStyleColor(ctx, ImGui.Col_BorderShadow, 0x10101050)
  _, set_cntrl.random_main = ImGui.Checkbox(ctx, "Random coloring##2", set_cntrl.random_main)
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PopStyleVar(ctx, 3)
  ImGui.PopStyleColor(ctx, 3)
end

function MultipleCustPopUp()
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ButtonTextAlign, 0, 0.5)
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, size*0.3)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, size*0.14); 
  ImGui.PushStyleColor(ctx, ImGui.Col_Border,0x303030ff) 
  ImGui.PushStyleColor(ctx, ImGui.Col_BorderShadow, 0x10101050)
  _, set_cntrl.random_custom = ImGui.Checkbox(ctx, "Random coloring##1", set_cntrl.random_custom)
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PopStyleVar(ctx, 3)
  ImGui.PopStyleColor(ctx, 3)
end

function LuminancePopUp(p_y, p_x, w, h, tr_cnt)
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, sans_serif)

  local selectable_flags = ImGui.SelectableFlags_DontClosePopups
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ButtonTextAlign, 0, 0.5)
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ButtonTextAlign, 0.5, 0.5)
  if sys_os == 1 then
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 4) 
  else
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 8, 3) 
  end
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
  button_action(button_colors.button_color4,'Luminance Adjuster Settings:', 220, 19, false) 
  ImGui.PopStyleColor(ctx, 1)
  ImGui.Dummy(ctx, 0, 6)
  
  ImGui.AlignTextToFramePadding(ctx)
  ImGui.Text(ctx, 'Color model:')
  ImGui.SameLine(ctx, 0, 10) 
  
  if ImGui.RadioButtonEx(ctx, 'HSL##2', luminance.colorspace_lum, 0) then
    luminance.colorspace_lum = 0
    luminance.lightness_range_lum = 0.9
    luminance.range = 0.95
    SetExtState(script_name ,'colorspace_lum', tostring(luminance.colorspace_lum),true)
  end
  if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 4)
    ImGui.SetTooltip(ctx, '\n HSL:\n\n Even pure colors (maximum saturation) can reach full white at a maximum.\n\n')
    ImGui.PopStyleVar(ctx, 1)
  end
  ImGui.SameLine(ctx, 0, 10) 
  if ImGui.RadioButtonEx(ctx, 'HSV##2', luminance.colorspace_lum, 1) then
    luminance.colorspace_lum = 1
    luminance.lightness_range_lum = 1
    luminance.range = 1
    SetExtState(script_name ,'colorspace_lum', tostring(luminance.colorspace_lum),true)
  end
  if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 4)
    ImGui.SetTooltip(ctx, "\n HSV:\n\n HSVs brightest point is always the pure color itself,\n with darker shades as values go down towards black.\n\n")
    ImGui.PopStyleVar(ctx, 1)
  end

   
  
  ImGui.PushItemWidth(ctx, 220)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 2)
  button_action(button_colors.button_color4,'darkness - lightness', 220, 19, false) 
  _, luminance.darkness_lum, luminance.lightness_lum = ImGui.SliderDouble2(ctx, '##2', luminance.darkness_lum, luminance.lightness_lum, 0.07, luminance.range )
  
  
  ImGui.Dummy(ctx, 0, 6)
  _, luminance.cycle_lum = ImGui.Checkbox(ctx, "cycle thru luminance", luminance.cycle_lum)
  
  ImGui.Separator(ctx)
  ImGui.Dummy(ctx, 0, 6)
  --[[
  if button_action(button_colors.button_color1, '##Info2', 31, 31, true, 4, 15) then
    openSettingWnd2 = true
    scroll_amount = 0
    get_scroll = false
  end

  -- DRAWING --
  local pos = {ImGui.GetCursorScreenPos(ctx)}
  local center = {pos[1]+10, pos[2]+2}
  local draw_list = ImGui.GetWindowDrawList(ctx)
  local draw_color = 0xffe8acff
  local draw_thickness = 3
  
  ImGui.DrawList_AddLine(draw_list, center[1]+6, center[2]-21, center[1]+6, center[2]-13, draw_color, draw_thickness)
  ImGui.DrawList_AddLine(draw_list, center[1]+3, center[2]-21, center[1]+8, center[2]-21, draw_color, 2)
  ImGui.DrawList_AddLine(draw_list, center[1]+3, center[2]-13, center[1]+10, center[2]-13, draw_color, 2)
  ImGui.DrawList_AddCircleFilled(draw_list, center[1]+6, center[2]-27, 2, draw_color,  0)
  --]]
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PopStyleVar(ctx, 4)
  ImGui.PopStyleVar(ctx, 1)
  ImGui.PopStyleColor(ctx)
end


-- ACTIONS POPUP --
function ActionsPopUp(sel_items, sel_tracks, tr_cnt, test_item, pop_key, current_tbl, which_item, in_table, specific)
  local cntrl_key, alt_key
  if sys_os == 1 then cntrl_key, alt_key  = 'CMD', 'OPTION' else cntrl_key, alt_key = 'CTRL', 'ALT' end
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ButtonTextAlign, 0, 0.5)
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 6)
    
  local button_text2 = 'Color children to parent'
  local button_text6 = 'Get selected colors to buttons'
  local button_text7 = 'Reset custom palette button'
  local button_text11 = 'Set custom palette button'
  local button_text12 = "Set folder's tracks to gradient shade"
  local button_text8, button_text9
  
  if items_mode == 1 then
    button_text1 = 'Set items to default color'
    button_text3 = 'Color items to gradient'
    button_text4 = 'Color items to main palette'
    button_text5 = 'Color items to custom palette'
    button_text9 = 'Color items to gradient shade'
  elseif items_mode == 3 and sel_mk == 1 then
    button_text1 = 'Set markers to default color'
    button_text3 = 'Color markers to gradient'
    button_text4 = 'Color markers to main palette'
    button_text5 = 'Color markers to custom palette'
    button_text9 = 'Color markers to gradient shade'
    button_text10 = 'Color markers in time selection'
  elseif items_mode == 3 and sel_mk == 2 then
    button_text1 = 'Set regions to default color'
    button_text3 = 'Color regions to gradient'
    button_text4 = 'Color regions to main palette'
    button_text5 = 'Color regions to custom palette'
    button_text9 = 'Color regions to gradient shade'
    button_text10 = 'Color regions in time selection'
  else
    button_text1 = 'Set tracks to default color'
    button_text3 = 'Color tracks to gradient'
    button_text4 = 'Color tracks to main palette'
    button_text5 = 'Color tracks to custom palette'
    button_text9 = 'Color tracks to gradient shade'
  end
  local selectable_flags = ImGui.SelectableFlags_DontClosePopups
  
  local stay
  if which_item&8 ~= 0 then stay, button_text8 = true, ' (define first)' else stay, button_text8 = false, '' end
  
  local width
  if which_item&4 ~= 0 then width = true else width = false end
  
  local first_in, marker_in
  if pop_key == -2 then
    first_in = rgba
    marker_in = ImGui.ColorConvertNative(rgba >>8)|0x1000000
  elseif pop_key == -1 then 
    first_in = last_touched_color
    marker_in = ImGui.ColorConvertNative(last_touched_color >>8)|0x1000000
  elseif in_table then
    first_in = in_table[pop_key]
    marker_in = current_tbl.tr[pop_key]
  else   
    first_in = sel_color[1]
    --marker_in = sel_color[1]
  end
  
  if ImGui.Selectable(ctx, button_text1, p_selected1, selectable_flags, 0, 0) then
    Reset_to_default_color(sel_items, sel_tracks) 
  end
  if items_mode == 0 then
    if ImGui.Selectable(ctx, button_text2, p_selected2, selectable_flags, 0, 0) then
      color_childs_to_parentcolor(sel_tracks, tr_cnt, stay, first_in) 
      if set_cntrl.quit then set_cntrl.open = true end
    end
  end
  ImGui.Separator(ctx)
  
  if ImGui.Selectable(ctx, button_text3..button_text8, p_selected3, selectable_flags, 0, 0) then
    Color_selected_elements_with_gradient(sel_tracks, sel_items, first_in, sel_color[#sel_color], stay, nil)
    last_touched_color = first_in
    if set_cntrl.quit then set_cntrl.open = true end
  end
  if which_item&32 ~= 0 then
    local text_pos1 = text_pos(cntrl_key.."+SHIFT", button_text3..button_text8, width)
    ImGui.SameLine(ctx, 0, text_pos1)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    ImGui.Text(ctx, cntrl_key.."+SHIFT")
    ImGui.PopStyleColor(ctx, 1)
  end
  
  if ImGui.Selectable(ctx, button_text9, p_selected8, selectable_flags, 0, 0) then
    Color_selected_elements_with_gradient(sel_tracks, sel_items, first_in, sel_color[#sel_color], stay, 1)
    last_touched_color = first_in
    if set_cntrl.quit then set_cntrl.open = true end
  end
  if which_item&32 ~= 0 then
    local text_pos1 = text_pos(cntrl_key.."+SHIFT+"..alt_key, button_text9, width)
    ImGui.SameLine(ctx, 0, text_pos1)
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
    ImGui.Text(ctx, cntrl_key.."+SHIFT+"..alt_key)
    ImGui.PopStyleColor(ctx, 1) 
  end
  if items_mode == 0 then
    if ImGui.Selectable(ctx, button_text12, p_selected11, selectable_flags, 0, 0) then
      Color_selected_elements_with_gradient(sel_tracks, sel_items, first_in, sel_color[#sel_color], stay, 2, tr_cnt)
      last_touched_color = first_in
      if set_cntrl.quit then set_cntrl.open = true end
    end
  end
  ImGui.Separator(ctx)
 
  if which_item&4 ~= 0 then 
    if ImGui.Selectable(ctx, button_text4, p_selected4, selectable_flags, 0, 0) then
      Color_multiple_elements_to_palette_colors(sel_tracks, sel_items, stay, main_palette, nil, set_cntrl.random_main, pal_tbl.tr[pop_key], pal_tbl.it[pop_key], pop_key)
      if set_cntrl.quit then set_cntrl.open = true end
    end
    if which_item&32 ~= 0 then
      local text_pos2 = text_pos("SHIFT", button_text4, width)
      ImGui.SameLine(ctx, 0, text_pos2)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.Text(ctx, "SHIFT")
      ImGui.PopStyleColor(ctx, 1)
    end
  end
  
  if which_item&2 ~= 0 then 
    if ImGui.Selectable(ctx, button_text5, p_selected5, selectable_flags, 0, 0) then
      Color_multiple_elements_to_palette_colors(sel_tracks, sel_items, stay, custom_palette, 1, set_cntrl.random_custom, cust_tbl.tr[pop_key], cust_tbl.it[pop_key], pop_key)
      if set_cntrl.quit then set_cntrl.open = true end
    end
    if which_item&32 ~= 0 then
      local text_pos3 = text_pos("SHIFT", button_text5, width)
      ImGui.SameLine(ctx, 0, text_pos3)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.Text(ctx, "SHIFT")
      ImGui.PopStyleColor(ctx, 1)
    end
  end
  
  if items_mode == 3 and which_item&8 ~= 0 then
    if ImGui.Selectable(ctx, button_text10, p_selected9, selectable_flags, 0, 0) then
       ColorMarkerTimeRange(marker_in, specific)
       if set_cntrl.quit then set_cntrl.open = true end
    end
    if which_item&32 ~= 0 then
      local text_pos1 = text_pos(cntrl_key, button_text10, width)
      ImGui.SameLine(ctx, 0, text_pos1)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.Text(ctx, cntrl_key)
      ImGui.PopStyleColor(ctx, 1)
    end
  end
  
  if which_item&16 ~= 0 then
    ImGui.Separator(ctx)
    if ImGui.Selectable(ctx, button_text6, p_selected6, selectable_flags, 0, 0) then
      item_track_color_to_custom_palette(pop_key, 24)
      it_cnt_sw, test_track_sw = nil
      if set_cntrl.quit then set_cntrl.open = true end
    end
    if which_item&32 ~= 0 then
      local text_pos4 = text_pos(cntrl_key.."+"..alt_key, button_text6, width)
      ImGui.SameLine(ctx, 0, text_pos4)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.Text(ctx, cntrl_key.."+"..alt_key)
      ImGui.PopStyleColor(ctx, 1)
    end
  end
  if which_item&64 ~= 0 then -- show reset action
    if ImGui.Selectable(ctx, button_text7, p_selected7, selectable_flags, 0, 0) then
      backup_color, rgba2 = custom_palette[pop_key], custom_palette[pop_key]
      custom_palette[pop_key] = HSL((pop_key-1) / 24+0.69, 0.1, 0.2, 1)
      palette_high.cust[pop_key] = 0
      if set_cntrl.quit then set_cntrl.open = true end
    end
    if which_item&32 ~= 0 then
      local text_pos5 = text_pos(alt_key, button_text7, width) 
      ImGui.SameLine(ctx, 0.0, text_pos5)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.Text(ctx, alt_key)
      ImGui.PopStyleColor(ctx, 1)
    end
  end
  
  if which_item&64 ~= 0 then -- show set action
    if ImGui.Selectable(ctx, button_text11, p_selected10, selectable_flags, 0, 0) then
      backup_color, rgba2 = custom_palette[pop_key], custom_palette[pop_key]
      ImGui.OpenPopup(ctx, 'Choose color#4', ImGui.PopupFlags_MouseButtonLeft)
    end
    local open_popup4 = ImGui.BeginPopup(ctx, 'Choose color#4')
    if open_popup4 then
      rgba2 =ColorEditPopup(backup_color, rgba2, custom_palette[pop_key] )
      if got_color then
        pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_track.auto_pal, cust_tbl  = pre_cntrl.current_item, 1, false, nil, nil
        custom_palette[pop_key] = rgba2
      end
    end
    if which_item&32 ~= 0 then
      local text_pos5 = text_pos("SHIFT+"..alt_key, button_text11, width) 
      ImGui.SameLine(ctx, 0.0, text_pos5)
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.Text(ctx, "SHIFT+"..alt_key)
      ImGui.PopStyleColor(ctx, 1)
    end
  end
  ImGui.PopStyleVar(ctx, 1)
  ImGui.Separator(ctx)
  ImGui.Dummy(ctx, 0, size*0.4)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ButtonTextAlign, 0.5, 0.5)
  if button_action(button_colors.button_color1, '##Info3', size*1, size*1, true, size*0.14, size*0.5) then
    openSettingWnd2 = true
    scroll_amount = 1413
    get_scroll = false
  end
  
  -- INFO DRAWING --
  local pos = {ImGui.GetCursorScreenPos(ctx)}
  local center = {pos[1]+size*0.25, pos[2]}
  local draw_list = ImGui.GetWindowDrawList(ctx)
  local draw_color = 0xffe8acff
  local draw_thickness = size*0.11
  
  ImGui.DrawList_AddLine(draw_list, center[1]+size*0.25, center[2]-size*0.5, center[1]+size*0.25, center[2]-size*0.25, draw_color, draw_thickness)
  ImGui.DrawList_AddLine(draw_list, center[1]+size*0.11, center[2]-size*0.5, center[1]+size*0.3, center[2]-size*0.5, draw_color, size*0.075)
  ImGui.DrawList_AddLine(draw_list, center[1]+size*0.11, center[2]-size*0.25, center[1]+size*0.4, center[2]-size*0.25, draw_color, size*0.075)
  ImGui.DrawList_AddCircleFilled(draw_list, center[1]+size*0.25, center[2]-size*0.7, size*0.075, draw_color,  0)
  
  ImGui.Dummy(ctx, 0, 20)
  ImGui.PopStyleVar(ctx, 2)
  ImGui.PopStyleColor(ctx)
end


-- OWN VERSION OF "GET RULER MOUSE CONTEXT" --
local function GetRulerMouseContext(mouse_pos, SYS_scale, UI_scale)
  local height_key, lane_count, mark_mode, seperate_mode, timeline_offset, tempo_time_offs, mark_lane_num, reg_lane_num, timeline
  local regions_h, markers_h, mouse_section_name, mouse_section_lane, scale
  
  if sys_os == 1 then scale = UI_scale else scale = SYS_scale end
  local lane_height, top_offs, timeline = 17*scale//1, 3*scale//1, 29*scale//1
  local height_key = lane_height*4+top_offs*2+timeline+((1*UI_scale+.5)//1)
  local timeline_mode = reaper.SNM_GetIntConfigVar("projtimemode", 1)
  if timeline_mode < 9 and timeline_mode ~= 1 and timeline_mode ~= 7 or timeline_mode == 256 then
    timeline_offset = 0 else timeline_offset = 9*scale//1
  end
  local _, _, height = reaper.JS_Window_GetClientSize(ruler_win) 
  local rulerlayout = reaper.SNM_GetIntConfigVar("rulerlayout", 1)
  if rulerlayout&2 ~= 0 then mark_mode = false else mark_mode = true end
  if rulerlayout&4 ~= 0 then seperate_mode = 1 else seperate_mode = 0 end
  if rulerlayout&16 ~= 0 and rulerlayout&8 ~= 0 then tempo_time_offs = 14*scale//1 else tempo_time_offs = 0 end
  
  if height < height_key+timeline_offset-tempo_time_offs then
    regions_h = height/6.6
    markers_h, lane_count, reg_lane_num, mark_lane_num = regions_h, 2, 1, 1
  elseif height >= height_key+timeline_offset-tempo_time_offs then
    lane_count = (height-height_key-timeline_offset+tempo_time_offs)//lane_height+3-seperate_mode
    if rulerlayout&1 == 0 then 
      if mark_mode == true then
        reg_lane_num, mark_lane_num = lane_count//2+(lane_count%2), lane_count//2
        regions_h, markers_h = top_offs+lane_height*reg_lane_num, top_offs+lane_height*mark_lane_num
      else
        mark_lane_num, regions_h = 1, top_offs+lane_height*(lane_count-1)
        reg_lane_num, markers_h = lane_count-mark_lane_num, top_offs+lane_height+regions_h
      end
    else
      regions_h, reg_lane_num = top_offs+lane_height, 1
      if mark_mode == true then
        markers_h, mark_lane_num = top_offs+lane_height*(lane_count-1), lane_count-reg_lane_num
      else
        markers_h, mark_lane_num = top_offs+lane_height, 1 
      end
    end
  end

  if mouse_pos < regions_h then 
    mouse_section_name = "region_lane"
    mouse_section_lane = (mouse_pos/(regions_h/reg_lane_num))//1+1
  elseif mouse_pos < top_offs*2+lane_height*lane_count then 
    mouse_section_name = "marker_lane"
    mouse_section_lane = ((mouse_pos-regions_h)/(markers_h/mark_lane_num))//1+1
  else
    mouse_section_name = "timeline"
  end
  return mouse_section_name, mouse_section_lane, reg_lane_num, mark_lane_num
end


local function GetSelectedMarkers2(container2) -- should get renamed
  local sel_key_m, sel_key_r
  items_mode, sel_mk = 3
  check_mark = check_mark&~1
  local mark_cnt = reaper.CountProjectMarkers(0)
  if (static_mode == 0 or static_mode == 5) then
    local sel_count, sel_indexes = reaper.JS_ListView_ListAllSelItems(container2)
    rv_markers = {retval={},isrgn={},pos={},rgnend={},name={},markrgnindexnumber={},color={},length={},lane={}}
    sel_markers = { retval={}, number={}, m_type={} }
        
    local i = 0
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
      check_mark = check_mark|1
    end

    for i = 0, mark_cnt-1 do 
      rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
      for j = 1, #sel_markers.number do
        if sel_markers.m_type[j] == "M" and rv_markers.isrgn[i] == false and rv_markers.markrgnindexnumber[i] == sel_markers.number[j] then
          sel_markers.retval[j] = rv_markers.retval[i]-1
        elseif sel_markers.m_type[j] == "R" and rv_markers.isrgn[i] == true and rv_markers.markrgnindexnumber[i] == sel_markers.number[j] then
          sel_markers.retval[j] = rv_markers.retval[i]-1
        end
      end
    end
    
    if check_mark&1 == 1 then
      if sel_key_m == true and sel_key_r == true then
        tr_txt = 'Mrk+Rgn'
      elseif sel_key_m == true then
        tr_txt = 'Manager'
        sel_mk = 1
      elseif sel_key_r == true then
        tr_txt = 'Manager'
        sel_mk = 2
      end
    elseif check_mark&1 == 0 and static_mode == 0 then
      tr_txt = '##No_selection'
      check_mark = check_mark|1
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
  test_item = nil
end
  

local function GetMarkerUnderMouse(rvs_ret, sys_scale, ui_scale, sel_items)
  -- CALCULATE MARKER LANE --
  local function GetMarkerLane(i, last_marker, numofoverlap, shortest_t, zoom, sel_mk, num_lanes, cur_pos)
    if last_marker then
      local shortest_index, marker_lane, prv_overlap, shortest, shortest_key = 0, 0
      for k = 1, #shortest_t.lane  do
        local prev_length = rv_markers.length[shortest_t.key[k]]
        if sel_mk == 1 then 
          prev_length = prev_length/zoom
        end
        local prv_pos = rv_markers.pos[shortest_t.key[k]]
        local prv_lane = shortest_t.lane[k]
        
        if numofoverlap < num_lanes then
          if prv_pos <= cur_pos and prv_pos+prev_length >= cur_pos then
            numofoverlap = numofoverlap +1
            local prv_overlap = prev_length+prv_pos-cur_pos
            if prv_lane == marker_lane then
              marker_lane = (prv_lane +1)%num_lanes
            end
            if shortest then
              if prv_overlap < shortest then
                shortest, shortest_key = prv_overlap, k
              end
            else
              shortest, shortest_key = prv_overlap, k
            end
          elseif prv_lane == marker_lane then
            marker_lane = prv_lane
          end
        else
          local prv_overlap = prev_length+prv_pos-cur_pos
          if prv_pos <= cur_pos and prv_pos+prev_length >= cur_pos then
            if shortest then
              if prv_overlap < shortest then
                shortest, shortest_key, marker_lane = prv_overlap, k, rv_markers.lane[shortest_t.key[k]]
              else
                marker_lane = rv_markers.lane[shortest_t.key[shortest_key]]
              end
            else
              shortest, shortest_key, marker_lane = prv_overlap, k, rv_markers.lane[shortest_t.key[k]]
            end
          else
            if shortest then
              if shortest > 0 then
                shortest, shortest_key, marker_lane = prv_overlap, k, rv_markers.lane[shortest_t.key[k]]
              end
            else
              shortest, shortest_key, marker_lane = prv_overlap, k, rv_markers.lane[shortest_t.key[k]]
            end
          end
        end
      end
      rv_markers.lane[i], shortest_index, shortest_t.pos = marker_lane, marker_lane, cur_pos
      shortest_t.key[shortest_index+1], shortest_t.lane[shortest_index+1] = i, marker_lane
    else
      local shortest_index = 0
      rv_markers.lane[i], shortest_t.key[shortest_index+1] = 0, i
      shortest_t.pos, shortest_t.lane[shortest_index+1] = rv_markers.pos[i], 0
    end
    return numofoverlap
  end
  
  local _, ui_scale = reaper.get_config_var_string("uiscale")
  local sel_ruler, mouse_lane, region_lanes, marker_lanes  = GetRulerMouseContext(rvs_ret, sys_scale, ui_scale)
  
  if sel_ruler == 'marker_lane' and (static_mode == 0 or static_mode == 3)  then 
    items_mode, sel_mk = 3, 1
    local last_marker, length_offset, button_1, button_2
    local mark_cnt, mouse_position = reaper.CountProjectMarkers(0), reaper.BR_PositionAtMouseCursor(true)
    local zoom = reaper.GetHZoomLevel()
    local pre_button_offset, same_pos_index, marker_lane, lanes = 1/zoom*((sys_scale)//1), 1, 0, marker_lanes
    local button_3, button_4 = 21*sys_scale/zoom, 13*sys_scale/zoom
    local same_pos_t, shortest_t = {pos={}, num={}}, {pos={}, value={}, key={}, lane={}}
    rv_markers = {retval={},isrgn={},pos={},rgnend={},name={},markrgnindexnumber={},color={},length={},lane={}} 
    if marker_lanes > 1 then -- more than 1 lane seen!! 
      local font_size, nativedraw, osx_display, bm, bmDC, font, bk_mode, Text_length
      
      local function SearchForEndOfMarker(bmp, target, pixel_i)
        local step, text_length = 0
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
            Msg("MARKER END NOT FOUND")
            break -- prevent infinite loop
          end 
        end
        return text_length
      end
      
      local function GetFontInfo()
        local tl_font
        -- GET TIMELINE FONT FROM COLORTHEME_FILE OR INI
        local inipath = reaper.get_ini_file()
        local lasttheme = select(2, reaper.BR_Win32_GetPrivateProfileString("reaper", "lastthemefn5", "Error", inipath))
        if lasttheme == "*unsaved*" then
          tl_font = select(2, reaper.BR_Win32_GetPrivateProfileString("reaper", "tl_font", "Error", inipath))
        else 
          local theme = reaper.GetLastColorThemeFile()
          tl_font = select(2, reaper.BR_Win32_GetPrivateProfileString("reaper", "tl_font", "Error", theme))
          if tl_font == "Error" then 
            local ext = theme:find("(.-)%Zip") 
            if not ext then
              theme = theme.."Zip"
            end
            local zip = reaper.JS_Zip_Open(theme, 'r', 6)
            local ent_str = select(2, reaper.JS_Zip_ListAllEntries(zip))
            local file_name
            for name in ent_str:gmatch("[^\0]+")do
              local file = name:match("(.-)%.ReaperTheme$")
              if file then
                file_name = name
                break
              end
            end
            reaper.JS_Zip_Entry_OpenByName(zip, file_name)
            local contents = select(2, reaper.JS_Zip_Entry_ExtractToMemory(zip))
            tl_font = string.match(tostring(contents), "tl_font=(%x*)")
            reaper.JS_Zip_Entry_Close(zip)
            reaper.JS_Zip_Close(theme)
          end
        end
        tl_font = tl_font:gsub(('[A-F0-9]'):rep(2), function(byte)
          return string.char(tonumber(byte, 16))
        end)
        return tl_font
      end
      
      local Tl_font = GetFontInfo()
      local height, _, _, _, weight, italic, underline, _, _, _, _, _, _, facename =
        ('iiiiibbbbbbbbc32'):unpack(Tl_font) 
      if sys_os ==1 then -- MacOS
        bk_mode, nativedraw = 1, tonumber(reaper.SNM_GetIntConfigVar('nativedrawtext',-1))
        if nativedraw == -1 then
          nativedraw = tonumber(reaper.SNM_GetIntConfigVar('nativedrawtext2',-1))
        end
        button_1, button_2 = ((13*ui_scale)//1)+((3*ui_scale)//1),((21*ui_scale)//1)+((3*ui_scale)//1)
        osx_display = reaper.SNM_GetIntConfigVar("osxdisplayoptions", 666)
        
        if osx_display&2 ~= 0 then 
          font_size = math.ceil(((height*ui_scale)//1)*0.777) 
        else
          font_size = math.ceil(((height*sys_scale)//1)*0.777) 
        end

        if font_size == 24 and tonumber(ui_scale) > 1.548 and tonumber(ui_scale) < 1.55 then font_size = 25 end -- what a shame...
        length_offset = (4*ui_scale)//1

      else -- Windows
        bk_mode, nativedraw = 2, 1
        button_1, button_2 = ((13*sys_scale)//1)+((3*sys_scale)//1),((21*sys_scale)//1)+((3*sys_scale)//1)
        font_size = ((math.ceil(height*sys_scale))*0.777)//1
        length_offset = (4*sys_scale)//1
        
        local alt_face = {"Script", "Modern", "Roman", "Marlett", "8514oem", "Terminal", "Webdings" , "Wingdings"} 
        local face = string.match(facename, "%w*")
        for i = 1, #alt_face do
          if alt_face[i] == face then
            nativedraw = 0
            break
          end
        end
      end
      
      if nativedraw == 1 then 
        -- CREATE GDI FONT AND SYSTEM BITMAP --
        bm = reaper.JS_LICE_CreateBitmap(true, (2500*sys_scale+0.5)//1, 1)
        bmDC = reaper.JS_LICE_GetDC(bm)
        font = reaper.JS_GDI_CreateFont(font_size, weight, 0, italic, underline, false, facename) 
        reaper.JS_GDI_SetTextColor(bmDC, 0xFFFF0000)
        reaper.JS_GDI_SetTextBkColor(bmDC, 0xFFFF0000) 
        reaper.JS_GDI_SetTextBkMode(bmDC, bk_mode)
        reaper.JS_GDI_SelectObject(bmDC, font)
      else 
        -- GFX TEXT MEASUREMENT --
        local flags = ''
        if weight > 649 then flags = 'b' end --could also simply be 700
        if italic == -1 then flags = flags..'i' end
        if underline == -1 then flags = flags..'u' end
        
        local function fontflags(str) 
          local v = 0
          for a = 1, str:len() do 
            v = v * 256 + string.byte(str, a) 
          end 
          return v 
        end
        gfx.setfont(1, facename, font_size, fontflags(flags))
      end
      
      for i = 0, mark_cnt -1 do 
        rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
        if rv_markers.isrgn[i] == false then
          local post_button_offset, button
          local current_pos = rv_markers.pos[i]
          if rv_markers.markrgnindexnumber[i] > 9 then
            post_button_offset, button = button_3, button_2
          else
            post_button_offset, button = button_4, button_1
          end
          -- STORE ALL MARKERS AT MOUSE POSITION IN TABLE --
          if current_pos-pre_button_offset < mouse_position and current_pos+post_button_offset > mouse_position then
            tr_txt = 'Marker'
            check_mark = check_mark|1
            same_pos_t.pos[same_pos_index], same_pos_t.num[same_pos_index], same_pos_index = rv_markers.retval[i], i, same_pos_index+1
          end
          -- CALCULATE TEXT LENGTH --
          if nativedraw == 1 then
            local target_color
            local str_length = string.len(rv_markers.name[i])
            reaper.JS_LICE_Clear(bm, 0xFF000000)
            reaper.JS_GDI_DrawText(bmDC, rv_markers.name[i], str_length, 0, 0, 3500, 1000, "LEFT")
            if sys_os == 1 then target_color = 0xFFFF0000 else target_color = 0xFF0000 end
            Text_length = SearchForEndOfMarker(bm, target_color, 0)
          else
            Text_length = gfx.measurestr(rv_markers.name[i])
          end
          
          local marker_length, numofoverlap = Text_length+button+length_offset, 1
          rv_markers.length[i] = marker_length
          GetMarkerLane(i, last_marker, numofoverlap, shortest_t, zoom, sel_mk, lanes, current_pos)
          last_marker = i
        end
      end
      
      -- RESET JS_GDI AND LICE --
      reaper.JS_GDI_ReleaseDC( bmDC, bm )
      reaper.JS_GDI_DeleteObject(font)
      reaper.JS_LICE_DestroyBitmap(bm)
      
    else -- if only one lane is seen
      for i = 0, mark_cnt -1 do 
        rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
        if rv_markers.isrgn[i] == false then
          local post_button_offset, button
          if rv_markers.markrgnindexnumber[i] > 9 then
            post_button_offset = button_3
          else
            post_button_offset = button_4
          end
          
          -- STORE ALL MARKERS AT MOUSE POSITION IN TABLE --
          if rv_markers.pos[i]-pre_button_offset < mouse_position and rv_markers.pos[i]+post_button_offset > mouse_position then
            tr_txt = 'Marker'
            --tr_txt_h =  0.663
            check_mark = check_mark|1
            same_pos_t.pos[same_pos_index], same_pos_t.num[same_pos_index], same_pos_index = rv_markers.retval[i], i, same_pos_index+1
          end
        end
      end
    end

    if marker_lanes > 1 then
      if #same_pos_t.pos > 1 then
        for i=1, #same_pos_t.pos do
          if rv_markers.lane[same_pos_t.num[i]] == mouse_lane-1 then
            sel_markers.retval[#sel_markers.retval+1] = same_pos_t.num[i]
            break
          end  
        end
      else
        if rv_markers.lane[same_pos_t.num[1]] == mouse_lane-1 then
          sel_markers.retval[#sel_markers.retval+1] = same_pos_t.num[1]
        end
      end
    else
      sel_markers.retval[#sel_markers.retval+1] = same_pos_t.num[1]
    end
    
    -- IF MEASUREMENT IS BUGGY --
    if not sel_markers.retval[1] and reaper.JS_Mouse_GetCursor() ~= reaper.JS_Mouse_LoadCursor(429) then
      sel_markers.retval[1] = same_pos_t.num[1]
    end
      
    if check_mark&1 == 0 and static_mode == 0 then
      tr_txt = '##No_selection'
    end
      
  elseif sel_ruler == 'region_lane' and (static_mode == 0 or static_mode == 4) then
    items_mode, sel_mk = 3, 2
    local same_pos_index, marker_lane, lanes, last_marker, shortest = 1, 0, region_lanes
    local mark_cnt, mouse_position = reaper.CountProjectMarkers(0), reaper.BR_PositionAtMouseCursor(true)
    local same_pos_t, shortest_t = {pos={}, num={}}, {pos={}, value={}, key={}, lane={}}
    rv_markers = {retval={},isrgn={},pos={},rgnend={},name={},markrgnindexnumber={},color={},length={},lane={}} 
    
    for i = 0, mark_cnt -1 do 
      rv_markers.retval[i], rv_markers.isrgn[i], rv_markers.pos[i], rv_markers.rgnend[i], rv_markers.name[i], rv_markers.markrgnindexnumber[i], rv_markers.color[i] = reaper.EnumProjectMarkers3( 0, i )
      if rv_markers.isrgn[i] == true then
        local current_pos = rv_markers.pos[i]
        -- STORE ALL MARKERS AT MOUSE POSITION IN TABLE --
        if current_pos <= mouse_position and rv_markers.rgnend[i] >= mouse_position then
          tr_txt = 'Region'
          check_mark = check_mark|1
          same_pos_t.pos[same_pos_index], same_pos_t.num[same_pos_index], same_pos_index = rv_markers.retval[i], i, same_pos_index+1
        end
        local marker_length, numofoverlap = rv_markers.rgnend[i] - current_pos, 1
        rv_markers.length[i] = marker_length
      
        -- CALCULATE REGION LANE --
        GetMarkerLane(i, last_marker, numofoverlap, shortest_t, zoom, sel_mk, lanes, current_pos)
        last_marker = i
      end
    end
    
    if region_lanes > 1 then
      if #same_pos_t.pos > 1 then
        for i=1, #same_pos_t.pos do
          if rv_markers.lane[same_pos_t.num[i]] == mouse_lane-1 then
            sel_markers.retval[#sel_markers.retval+1] = same_pos_t.num[i]
          end  
        end
      else
        if rv_markers.lane[same_pos_t.num[1]] == mouse_lane-1 then
          sel_markers.retval[#sel_markers.retval+1] = same_pos_t.num[1]
        end
      end
    else
      sel_markers.retval[#sel_markers.retval+1] = same_pos_t.num[#same_pos_t.num]
    end
    
    -- IF MEASUREMENT IS BUGGY --
    if not sel_markers.retval[1] and reaper.JS_Mouse_GetCursor() ~= reaper.JS_Mouse_LoadCursor(429) then
      sel_markers.retval[#sel_markers.retval+1] = same_pos_t.num[1]
    end
    
    if check_mark&1 == 0 and static_mode == 0 then
      tr_txt = '##No_selection'
    end 

  elseif static_mode == 0 then
    if sel_items > 0 then
      items_mode = 1
    else
      items_mode = 0
    end
  end
end


function IsManagerWindowClicked()
  local state_count, focused_hWnd, focused_hWnd_sw, parent_hWnd, is_focused_sw, list_item_sw, parent_hWnd_sw, list_hWnd
  local inputbox_hWnd, region_manager_state, state_count_sw, list_item, list_item_sw, had_mouse_input, time
  local mouseclick, time = false, 0
  local title = reaper.JS_Localize("Region/Marker Manager", "DLG_508")
  
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


-- TOPBAR --
local function Topbar(menu_w, menu_h, size, p_y, p_x, w, h, sel_items, sel_tracks, mods_retval, av_x, bttn_height, spacing)
  local pos = {ImGui.GetCursorScreenPos(ctx)}
  local col2 = 0
  local var2 = 0
  
  -- PALETTE MENU --
  ImGui.PushFont(ctx, buttons_font2)
  local fontsize = ImGui.GetFontSize(ctx)
  if button_action(button_colors.button_color1, 'Palette Menu', menu_w, menu_h, true, size*0.12, size*0.15) then 
    openSettingWnd = true
    check_mark = check_mark|2
  end
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, sans_serif)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_PopupRounding, 4)var2=var2+1

  if ImGui.BeginPopupContextItem(ctx, '##Settings3') then
    SettingsPopUp(size, bttn_height, spacing, fontsize)
    ImGui.EndPopup(ctx)
  end 

  -- SETTINGS BUTTON --
  ImGui.SameLine(ctx, 0, size*0.3)
  if button_action(button_colors.button_color1, '##Settings2', size*1.4, menu_h, true, size*0.12, size*0.15) then 
    ImGui.OpenPopup(ctx, '##Settings3')
  end
  
  if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 5)
    ImGui.SetTooltip(ctx, '\n Settings Menu:\n\n')
    ImGui.PopStyleVar(ctx, 1)
  end

  -- DRAWING --
  local center = {pos[1]+menu_w+size*0.3+size*0.3, pos[2]+menu_h*0.35}
  local draw_list = ImGui.GetWindowDrawList(ctx)
  local draw_color = 0xffe8acff
  local draw_thickness
  if ImGui.IsItemHovered(ctx) then
    draw_thickness = size*0.05
  else
    draw_thickness = size*0.04
  end
  ImGui.DrawList_AddLine(draw_list, center[1], center[2], center[1]+size*0.15, center[2], draw_color, draw_thickness)
  ImGui.DrawList_AddLine(draw_list, center[1]+size*0.35, center[2], center[1]+size*0.8, center[2], draw_color, draw_thickness)
  ImGui.DrawList_AddLine(draw_list, center[1], center[2]+menu_h*0.3, center[1]+size*0.43, center[2]+menu_h*0.3, draw_color, draw_thickness)
  ImGui.DrawList_AddLine(draw_list, center[1]+size*0.65, center[2]+menu_h*0.3, center[1]+size*0.8, center[2]+menu_h*0.3, draw_color, draw_thickness)
  ImGui.DrawList_AddCircle(draw_list, center[1]+size*0.26, center[2], size*0.11, draw_color,  0, draw_thickness)
  ImGui.DrawList_AddCircle(draw_list, center[1]+size*0.54, center[2]+menu_h*0.3, size*0.11, draw_color,  0, draw_thickness)
  
    ImGui.PopFont(ctx)
    ImGui.PushFont(ctx, buttons_font3)
    
    -- MOUSE MODIFIERS DISCRIPTION --
    if not ImGui.IsAnyItemHovered(ctx) then 
      shortcut_text = ""
    end
    ImGui.SameLine(ctx, 0, size*0.6)
    local shortcut_pos = (menu_h-ImGui.GetFontSize(ctx))*0.4/2 
    ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx)+shortcut_pos)
    if set_cntrl.modifier_info and ImGui.IsWindowFocused(ctx) then
      ImGui.Text(ctx, shortcut_text)
    end
    ImGui.PopFont(ctx)
    ImGui.PushFont(ctx, buttons_font2)
  
  -- SELECTION INDICATOR TEXT AND COLOR --
  if items_mode == 0 then 
    tr_txt = 'Tracks'
  elseif items_mode == 1 then 
    tr_txt = 'Items'
  elseif items_mode == 2 then 
    tr_txt = '##No_selection'
  end
  
  ImGui.SameLine(ctx, -1, av_x-size*3.5+sides)
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff) col2=col2+1


  -- SELECTION INDICATOR --
  if button_action(button_colors.button_color3, tr_txt, size*3.5 , menu_h, true, size*0.12, size*0.15) then
    if mods_retval == 4096 then
      if static_mode == 0 and items_mode ~= 2 then 
        if items_mode == 0 then
          static_mode = 1
        elseif items_mode == 1 then static_mode = 2
        elseif items_mode == 3 and tr_txt == 'Manager' then static_mode = 5
        elseif items_mode == 3 and sel_mk == 1 then static_mode = 3
        elseif items_mode == 3 and sel_mk == 2 then static_mode = 4
        end
      else
        static_mode = 0 
        if items_mode == 1 or items_mode == 3 then seen_msgs[3] = rvs3 end
      end
    elseif mods_retval == 16384 then
      Main_OnCommandEx(40769, 0, 0) -- Unselect (clear selection of) all tracks/items/envelope points
    elseif items_mode == 0 and sel_items>0 then
      items_mode, go, static_mode, test_item_sw, test_take2 = 1, true, 0, nil
    elseif items_mode == 1 and sel_tracks>0 then 
      items_mode, static_mode, sel_tracks2 = 0 , 0, nil
    elseif items_mode == 3 then
      static_mode = 0
      if sel_items>0 then 
        items_mode, go, test_item_sw, test_take2 = 1, true, nil
      else
        items_mode = 0
      end
    elseif items_mode == 0 and static_mode == 1 then
      static_mode = 0
    end
  end
  
  
  if ImGui.IsItemHovered(ctx) then
    if mods_retval == 4096 then
      shortcut_text = "Modifiers: Activate static context mode"
    elseif mods_retval == 16384 then
      shortcut_text = "Modifiers: Unselect (clear selection of) everything"
    elseif mods_retval == 0  then
      shortcut_text = "Modifiers: Press modifier keys to display functionality"
    else
      shortcut_text = modifier_text[9]
    end
  end
  ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffffffff) col2=col2+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 5) 
  if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
    ImGui.SetTooltip(ctx, '\n Context Indicator:\n\n Switch between tracks and items if any selected\n\n')
  end
  ImGui.PopStyleVar(ctx, 1)
    
  -- STATIC DRAWING --
  if  static_mode ~= 0 then
    local text_min_x, text_min_y = ImGui.GetItemRectMin(ctx)
    local text_max_x, text_max_y = ImGui.GetItemRectMax(ctx)
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
    
    ImGui.PushStyleColor(ctx, ImGui.Col_Border, HSV(0.555, 0.1, 0.39, 1)); col2=col2+1
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize,0); var2=var2+1
    ImGui.PushStyleVar (ctx, ImGui.StyleVar_FramePadding, 0, 0); var2=var2+1


    local font_size = ImGui.GetFontSize(ctx)
    ImGui.SameLine(ctx, -1, av_x-size*3.5+sides-font_size-size*0.4)
    ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx)+(menu_h-font_size-size*0.1)*0.5)
    ImGui.RadioButtonEx(ctx, '##', selected_mode, 1)
    if ImGui.IsItemHovered(ctx, ImGui.HoveredFlags_DelayNormal | ImGui.HoveredFlags_NoSharedDelay) and set_cntrl.tooltip_info then
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 4)
      ImGui.SetTooltip(ctx, '\n ShinyColorsMode: ACTIVE \n\n')
      ImGui.PopStyleVar(ctx, 1)
    end
  end
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, buttons_font2)
  ImGui.PopStyleVar(ctx, var2) 
  ImGui.PopStyleColor(ctx, col2) 
  ImGui.PopFont(ctx)
end


local function hovered_button(bitfield, mods_retval)
  if mods_retval == 0 then
    local timer = reaper.time_precise()
    if not timer2 then
      timer2 = timer
    end
    if timer2+3 > timer then
      shortcut_text = "Modifiers: Press modifier keys to display functionality"
    elseif timer2+6 > timer then
      shortcut_text = "Use rightclick menu on some widgets and empty area"
    else 
      timer2 = nil
    end
  elseif mods_retval == 4096 then
    if items_mode == 0 then
      shortcut_text = modifier_text[6]
    elseif items_mode == 1 then
      shortcut_text = modifier_text[7]
    else
      shortcut_text = modifier_text[8]
    end
  elseif bitfield&1 == 1 and mods_retval == 8192 then
    shortcut_text = modifier_text[1]
  elseif bitfield&2 == 2 and mods_retval == 12288 then
    shortcut_text = modifier_text[3]
  elseif bitfield&4 == 4 and mods_retval == 16384 then
    shortcut_text = modifier_text[4]
  elseif bitfield&8 == 8 and mods_retval == 20480 then
    shortcut_text = modifier_text[5]
  elseif bitfield&16 == 16 and mods_retval == 24576 then
    shortcut_text = modifier_text[10]
  elseif bitfield&32 == 32 and mods_retval == 8192 then
    shortcut_text = modifier_text[11]
  elseif bitfield&32 ~= 32 and mods_retval == 28672 then
    shortcut_text = modifier_text[11]
  else
    shortcut_text = modifier_text[9]
  end
end


function ColorEditPopup(backup2, color2, ref_col2)
  if not backup2 then backup2 = color2 end
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, size*0.1)
  ImGui.Dummy(ctx, 0, size*0.4)
  got_color, color2 = ImGui.ColorPicker4(ctx, '##Current', color2, ImGui.ColorEditFlags_NoSidePreview | ImGui.ColorEditFlags_NoSmallPreview, color2)
  if sys_os == 1 then ImGui.SameLine(ctx, size*10) else ImGui.SameLine(ctx, size*10.5) end
  ImGui.BeginGroup(ctx) -- Lock X position
  ImGui.Text(ctx, 'Current')
  ImGui.ColorButton(ctx, '##current2', color2, ImGui.ColorEditFlags_NoPicker, size*2, size*1.5)
  ImGui.Dummy(ctx, 0, 1)
  ImGui.Text(ctx, 'Previous')
  if ImGui.ColorButton(ctx, '##previous', backup2, ImGui.ColorEditFlags_NoPicker, size*2, size*1.5) then
    color2 = backup2
    got_color = true
  end
  ImGui.EndGroup(ctx) 
  ImGui.Dummy(ctx, 0, size*0.4)
  ImGui.PopStyleVar(ctx, 1)
  ImGui.EndPopup(ctx)
  return color2
end


local mod_flag_t = {}
function CheckForMod()
  local mod_actions = {'1 m','2 m', '3 m', '5 m', '6 m', '16 m', '18 m', '23 m', '24 m'}
  local index, mod = 0
  for i = 0 , 7 do
    local action = reaper.GetMouseModifier('MM_CTX_TRACK',i )
    for z = 1, 9 do
      if mod_actions[z] == action then
        if i == 1 then mod = 8
        elseif i == 2 then mod = 4
        elseif i == 3 then mod = 12
        elseif i == 4 then mod = 16
        elseif i == 5 then mod = 24
        elseif i == 6 then mod = 20
        elseif i == 7 then mod = 28 end
        index = index +1 
        mod_flag_t[index] = mod
      end
    end
  end
end

CheckForMod()


function DrawnItem(modifier)
  if not mouse_item.stop then
    mouse_item.stop = true
    mouse_item.current = reaper.JS_Mouse_GetCursor()
    mouse_item.cursor = reaper.JS_Mouse_LoadCursor(185)
  end
  if mouse_item.current == mouse_item.cursor and not mouse_item.pressed then
    for i = 1, #mod_flag_t do
      if modifier&28 == mod_flag_t[i] then
        mouse_item.pressed = true
        mouse_item.pos = {reaper.GetMousePosition()}
      break
      end
    end
  end
  if mouse_item.pressed and not mouse_item.found then
    mouse_item.item = reaper.GetItemFromPoint(mouse_item.pos[1]+1, mouse_item.pos[2], 0)
    if mouse_item.item ~= nil then
      if automode_id == 1 then
        PreventUIRefresh(1) 
        local tr_ip = GetMediaTrackInfo_Value(GetMediaItemTrack(mouse_item.item), "IP_TRACKNUMBER")
        SetMediaItemInfo_Value(mouse_item.item, "I_CUSTOMCOLOR", col_tbl.it[tr_ip] )
        UpdateArrange()
        PreventUIRefresh(-1)
      elseif automode_id == 2 then
        PreventUIRefresh(1) 
        SetMediaItemTakeInfo_Value(GetActiveTake(mouse_item.item), "I_CUSTOMCOLOR", ImGui.ColorConvertNative(rgba >>8)|0x1000000)
        if selected_mode == 1 then
          SetMediaItemInfo_Value(mouse_item.item, "I_CUSTOMCOLOR", Background_color_rgba(rgba))
        end
        UpdateArrange()
        PreventUIRefresh(-1) 
      end
      mouse_item.found = true
    end
  end
end


function AdjustLightness(sel_tracks, sel_items, direction)
  local undo_str, undo_flag
  if items_mode == 0 then selection, undo_str, undo_flag  = sel_tracks, "tracks darker", 5 elseif items_mode == 1 then selection, undo_str, undo_flag = sel_items, "items darker", 4 elseif items_mode == 3 then selection, undo_str, undo_flag = #sel_markers.retval, "markers/regions darker", 8 end
  if selection then
    PreventUIRefresh(1) 
    Undo_BeginBlock2(0) 
    for i = 1, selection do
      color = sel_color[i]
      local r, g, b = ImGui.ColorConvertU32ToDouble4(color)

      local color_mode, color_mode2
      if luminance.colorspace_lum  == 1 then color_mode, color_mode2 = ImGui.ColorConvertRGBtoHSV, ImGui.ColorConvertHSVtoRGB else color_mode, color_mode2 = rgbToHsl, hslToRgb  end
      local h, s, v = color_mode(r, g, b) 
      if direction then
        if luminance.cycle_lum then
          if v-0.06 < luminance.darkness_lum then v = v-0.06+luminance.lightness_lum-luminance.darkness_lum else v = v-0.06 end
        else
          if v-0.06 < luminance.darkness_lum then v = luminance.darkness_lum else v = v-0.06 end
        end
      else
        if luminance.cycle_lum then
          if v+0.06 > luminance.lightness_lum then v = v+0.06-luminance.lightness_lum+luminance.darkness_lum else v = v+0.06 end
        else
          if v+0.06 > luminance.lightness_lum then v = luminance.lightness_lum else v = v+0.06 end
        end
      end

      r, g, b = color_mode2(h, s, v)

      local new_color = ColorToNative(r*255//1, g*255//1, b*255//1)

      if items_mode == 0 then
        SetTrackColor(sel_tbl.tr[i], new_color) 
        if selected_mode == 1 then 
          
          Color_items_to_track_color_in_shiny_mode(sel_tbl.tr[i], Background_color_R_G_B(r, g, b)) 
        end
        col_tbl, sel_tracks2 = nil, nil
      elseif items_mode == 1 then
        local t1, t2 = sel_tbl.it, sel_tbl.tke
        if selected_mode == 1 then
          SetMediaItemInfo_Value(t1[i], "I_CUSTOMCOLOR", Background_color_R_G_B(r, g, b))
          if t2[i] then
            SetMediaItemTakeInfo_Value(t2[i], "I_CUSTOMCOLOR", new_color|0x1000000)
          end
        else
          if t2[i] then
            SetMediaItemTakeInfo_Value(t2[i], "I_CUSTOMCOLOR", new_color|0x1000000)
          else
            SetMediaItemInfo_Value(t1[i], "I_CUSTOMCOLOR", new_color|0x1000000)
          end    
        end
        it_cnt_sw = nil 
        
      elseif items_mode == 3 then
        local n = sel_markers.retval[i]
        reaper.SetProjectMarker4(0, rv_markers.markrgnindexnumber[n], rv_markers.isrgn[n],
        rv_markers.pos[n], rv_markers.rgnend[n], rv_markers.name[n], new_color|0x1000000, 0)
        rv_markers.color[n] = new_color|0x1000000 -- enablebit really needed ??
        check_mark = check_mark|1
      end
    end
    UpdateArrange()
    Undo_EndBlock2(0, undo_str, undo_flag)
    PreventUIRefresh(-1)
  end
end


-- MAKE ANONYMOUS FUNCTIONS LOCAL --
local IsManagerWindow = IsManagerWindowClicked()
local AutoItem = automatic_item_coloring()
local Color_new_tracks = Color_new_tracks_automatically() 

    
--[[_______________________________________________________________________________
  _______________________________________________________________________________]]


-- THE COLORPALETTE GUI--

local function ColorPalette(init_state, go, w, h, av_x, av_y, size, size2, spacing, sides) 
  local ImGui_scale = ImGui.GetWindowDpiScale(ctx)
  if ImGui_scale ~= ImGui_scale2 then
    sys_scale, ImGui_scale2 = ImGui_scale, ImGui_scale
  end
  
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, buttons_font2)
  local cur_fontsize = ImGui.GetFontSize(ctx)
  local p_x, p_y = ImGui.GetWindowPos(ctx)
  local menu_w = (size)*5+spacing*3
  local menu_w2 = (size2)*5+spacing*3
  local menu_h = (menu_w/6.4+.5)//1
  local menu_h2 = (menu_w2/6.4+.5)//1
  -- button calculations --
  local divider = 14
  local bttn_gap = max(av_x/(divider*5-1), 1)
  local bttn_width = bttn_gap*(divider-1)
  local bttn_height = bttn_width/5*2
  local bttn_gap2 = max((w-size*1.2)/(divider*5-1), 1)
  local bttn_width2 = bttn_gap2*(divider-1)
  local bttn_height2 = bttn_width2/5*2
  local title_h = select(2, ImGui.GetCursorStartPos(ctx)) + ImGui.GetScrollY(ctx) - select(2, ImGui.GetStyleVar(ctx, ImGui.StyleVar_WindowPadding))
  local h_calc = title_h
  local mods_retval = ImGui.GetKeyMods(ctx)
  
  -- DEFINE "GLOBAL" VARIABLES --
  if go then
    sel_items = CountSelectedMediaItems(0)
  end
  local test_item = GetSelectedMediaItem(0, 0) 
  local sel_tracks = CountSelectedTracks(0) 
  local test_track = GetSelectedTrack(0, 0) 
  local tr_cnt = CountTracks(0)
  
  -- CHECK FOR PROJECT TAP CHANGE AND NEW PROJECT LOAD--
  local cur_project, projfn = reaper.EnumProjects( -1 )
  if cur_project ~= old_project or projfn ~= projfn2 then
    old_project, projfn2, track_number_stop = cur_project, projfn, tr_cnt
    track_number_sw, col_tbl, cur_state4, it_cnt_sw, items_mode, test_track_sw = nil
  end
  
  -- CHECK FOR WINDOW LMOUSEBUTTONDOWN --
  local rvs = {reaper.JS_WindowMessage_Peek(ruler_win, msgs)} -- multiple values are required, so must be a table
  local rvs2 = select(3, reaper.JS_WindowMessage_Peek(arrange, msgs))
  local rvs3 = select(3, reaper.JS_WindowMessage_Peek(TCPDisplay, msgs))
  local _, rvs4, _, win = IsManagerWindow()
    
  -- IF UNDO THEN RESET CACHES --
  if go
    and Undo_CanRedo2(0)
      and (Undo_CanRedo2(0) ~= can_re or reaper.Undo_CanUndo2(0) == Undo_CanRedo2(0))
        and string.match(Undo_CanRedo2(0), "CHROMA:") then 
    it_cnt_sw, test_track_sw, col_tbl = nil
    can_re = Undo_CanRedo2(0) 
  end 
  
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
    or tr_cnt ~= tr_cnt_sw
      or Undo_CanUndo2(0)== 'Change track order' then
    generate_trackcolor_table(tr_cnt)
    tr_cnt_sw = tr_cnt 
    if sel_tracks < 1 then
      items_mode = 2
      sel_color = {}
      palette_high = {main = {}, cust = {}}
    end
  end
  
  -- BRING PALETTE MENU TO FRONT IF ALREADY OPEN --
  if check_mark&2 ==2 then
    if openSettingWnd and nextitemforeground then
      reaper.JS_Window_SetForeground(nextitemforeground)
    else
      nextitemforeground =reaper.JS_Window_GetForeground()
    end
    check_mark = check_mark&~2
  end
  
  if not openSettingWnd then
    nextitemforeground = nil
  end
  
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, size2*0.17, size2*frame_paddingY)
  local var, col = 0, 0
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, size*0); var=var+1 
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, 5); var=var+1 -- for settings menu sliders
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_GrabRounding, 2); var=var+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_PopupRounding, 2); var=var+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize,2) var=var+1
  ImGui.PushStyleColor(ctx, ImGui.Col_Border,0x303030ff) col= col+1
  ImGui.PushStyleColor(ctx, ImGui.Col_BorderShadow, 0x10101050) col= col+1
  
  ImGui.Dummy(ctx, av_x, size*0.6) -- mimic window pad at the top
  h_calc = (h_calc+size2*0.6)//1
  
  -- PALETTE MENU, SETTINGS POPUP AND INDICATOR --
  if set_cntrl.topbar_ghost_mode then
    local topbar_h = p_y + title_h
    local _, im_mouse_y = ImGui.GetMousePos(ctx)
    local center = {ImGui.Viewport_GetCenter(ImGui.GetWindowViewport(ctx))}
    ImGui.SetNextWindowPos(ctx, center[1], topbar_h, ImGui.Cond_Appearing, 0.5, 0.0)
    
    if ImGui.BeginPopupContextItem(ctx, '##Settings6') then
      ImGui.Dummy(ctx, av_x, size*0.4)
      Topbar(menu_w, menu_h, size, p_y, p_x, w, h, sel_items, sel_tracks, mods_retval, av_x, bttn_height, spacing)
      ImGui.Dummy(ctx, av_x, size*0.4)
      h_calc = h_calc+menu_h2
      if mouse_over == false and ImGui.IsWindowFocused(ctx, FocusedFlags_None) then 
        ImGui.CloseCurrentPopup(ctx)
      end
      ImGui.EndPopup(ctx)
    end 

    if im_mouse_y  <= topbar_h+title_h*0.5 and im_mouse_y  >= topbar_h and ImGui.IsWindowHovered(ctx, HoveredFlags_None) and ImGui.IsWindowFocused(ctx, FocusedFlags_None) then
      mouse_over = true
      ImGui.OpenPopup(ctx, '##Settings6')
    elseif im_mouse_y > 0 and mouse_over == true and im_mouse_y > topbar_h+size*0.4+menu_h or im_mouse_y < topbar_h then
      mouse_over = false
    end
  else
    Topbar(menu_w, menu_h, size, p_y, p_x, w, h, sel_items, sel_tracks, mods_retval, av_x, bttn_height, spacing)
    ImGui.Dummy(ctx, av_x, size*0.5)
    h_calc = (h_calc+menu_h+size2*0.5)//1
  end
  
  if ImGui.BeginPopup(ctx, '##Settings7') then
    ActionsPopUp(sel_items, sel_tracks, tr_cnt, test_item, m, cust_tbl, 6)
    ImGui.EndPopup(ctx)
  end 
  
  -- OPEN SETTINGS POPUP VIA RIGHT CLICK --
  if ImGui.IsMouseClicked(ctx, ImGui.MouseButton_Right, false) and ImGui.IsWindowHovered(ctx) and not ImGui.IsAnyItemHovered(ctx) then
    ImGui.OpenPopup(ctx, '##Settings7')
  end
  
  -- OPEN PALETTE MENU
  if openSettingWnd then
    PaletteMenu(p_y, p_x, w, h)
  end
  
  -- OPEN INFO WINDOW --
  if openSettingWnd2 then
    InfoWindow(p_y, p_x, w, h)
  end

  ImGui.PopStyleVar(ctx, var) -- for upper part
  ImGui.PopStyleColor(ctx, col) -- for upper part

  -- -- GENERATING TABLES -- --
  if not main_palette or pre_cntrl.differs3 or check_mark&4 == 4 then
    main_palette = Palette()
    pal_tbl = generate_palette_color_table()
    user_main_settings = {colorspace, saturation, lightness, darkness}
    check_mark = check_mark&~4
  end
  
  if not cust_tbl then
    cust_tbl = generate_custom_color_table()
  end
  
  -- WHEN MARKERS OR REGIONS MOVED --
  if items_mode == 3 and go
      and (Undo_CanUndo2(0)=='Move marker'
        or Undo_CanUndo2(0)=='Reorder region') then
    seen_msgs[1] = nil
  end 
  
  -- UNDO after adding tracks --
  if reaper.Undo_CanRedo2(0) =='CHROMA: Automatically color new tracks' then
    reaper.Undo_DoUndo2(0)
  end
  
  -- SWITCHING BETWEEN MODES ALONG WITH MARKERS AND REGIONS --

  -- MOUSE CLICK RULER --
  if rvs[3] ~= (seen_msgs[1] or 0) and (static_mode == 0 or static_mode == 3  or static_mode == 4) then
    local shift = reaper.JS_Mouse_GetState(0x000C) 
    if shift == 8 or shift == 4 then
      if not sel_markers.retval[1] then
        sel_markers = {retval={}}
      end
    else
      sel_markers = {retval={}}
    end
    GetMarkerUnderMouse(rvs[7], sys_scale, ui_scale, sel_items)
    seen_msgs[1], test_item = rvs[3], nil
    check_mark = check_mark|3
  elseif rvs[3] ~= (seen_msgs[1] or 0) and (static_mode == 5) then
    GetSelectedMarkers2(win)
    seen_msgs[1] = rvs[3]
  -- MOUSE CLICK MANAGER --
  elseif rvs4 ~= (seen_msgs[4] or 0) and (static_mode == 0 or static_mode == 5) then
    GetSelectedMarkers2(win)
    seen_msgs[4] = rvs4
    test_item = nil
  -- MOUSE CLICK ARRANGE --
  elseif rvs2 ~= (seen_msgs[2] or 0) and (static_mode == 0 or static_mode == 2) then
    if sel_items > 0 then
      it_cnt_sw = nil
      if test_item then
        test_take = GetActiveTake(test_item)
        test_track_it = GetMediaItemTrack(test_item)
        test_track_sw = nil
      end
      if (static_mode == 0 or static_mode == 2) then
        items_mode = 1
      end
    elseif sel_tracks > 0 then
      if static_mode == 0 then
        items_mode = 0
        test_item = nil
      end
    else
      if static_mode == 0 then
        items_mode = 2
      end
      sel_color = {}
    end
    seen_msgs[2] = rvs2
  -- MOUSE CLICK TCP --
  elseif rvs3 ~= (seen_msgs[3] or 0) and (static_mode == 0 or static_mode == 1) then
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
  
  if selected_mode == 1 then
    -- CHECK FOR CURRENT DRAWN ITEM IN SHINY MODE --
    local modifier = reaper.JS_Mouse_GetState(29)
    if modifier&1 == 1 and modifier&28 ~= 0 then
      DrawnItem(modifier)
    else
      mouse_item.pressed, mouse_item.current, mouse_item.pos, mouse_item.stop, mouse_item.found = nil
    end
  end

  -- CALLING FUNCTIONS -- 
  Color_new_items_automatically(init_state, sel_items, go, test_item)
  get_sel_items_or_tracks_colors(sel_items, sel_tracks, test_item, test_take, test_track) 
  
  do
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
      elseif test_item and sel_items > 60000 then -- for safety in extreme situations
        local Func_mode = 2
        AutoItem(Func_mode, track_sw2, item_track, init_state)
      end
      reselect_take(init_state, sel_items, item_track) 
    end
  end

  -- -- ==== MIDDLE PART ==== -- --
  
  ImGui.PopFont(ctx)
  ImGui.PushFont(ctx, buttons_font2)
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, size*0.07)    -- general rounding for color widgets
  
  -- CUSTOM COLOR PALETTE --
  if show_custompalette and resize&4 ~= 4 then
    h_calc = h_calc+(size2+.5)//1
    
    for m=1, #custom_palette do
      ImGui.PushID(ctx, m)
      if ((m - 1) % 24) ~= 0 then
        ImGui.SameLine(ctx, 0.0, spacing)
      end
      local highlight2 = false
      local palette_button_flags2 =
                    ImGui.ColorEditFlags_NoPicker |
                    ImGui.ColorEditFlags_NoTooltip
      if palette_high.cust[m] == 1 then
        ImGui.PushStyleColor(ctx, ImGui.Col_Border,0xffffffff)
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize, size*0.08)
        highlight2 = true
      end
      if highlight2 == false then
        palette_button_flags2 = palette_button_flags2 | ImGui.ColorEditFlags_NoBorder
      end
      if ImGui.ColorButton(ctx, '##palette2', custom_palette[m], palette_button_flags2, size, (size+.5)//1) then
        if mods_retval == 16384 then
          backup_color, rgba2 = custom_palette[m], custom_palette[m]
          custom_palette[m] = HSL((m-1) / 24+0.69, 0.1, 0.2, 1)
          palette_high.cust[m] = 0
        elseif mods_retval == 24576 then
          ImGui.OpenPopup(ctx, 'Choose color#1', ImGui.PopupFlags_MouseButtonLeft)
          backup_color, rgba2 = custom_palette[m], custom_palette[m]
        elseif custom_palette[m] ~= HSL((m-1) / 24+0.69, 0.1, 0.2, 1) or mods_retval == 20480 then
          if mods_retval == 8192 then
            sel_color[1] =custom_palette[m]
            Color_multiple_elements_to_palette_colors(sel_tracks, sel_items, true, custom_palette, 1, set_cntrl.random_custom, cust_tbl.tr[m], cust_tbl.it[m], m)
          else
            coloring(sel_items, sel_tracks, cust_tbl.tr[m], cust_tbl.it[m], mods_retval, custom_palette[m], tr_cnt, m, 24, 'custom_palette') 
            if mods_retval ~= 20480 then
              last_touched_color = custom_palette[m]
              sel_color[1] = custom_palette[m]
            end
          end
        else
          ImGui.OpenPopup(ctx, 'Choose color#1', ImGui.PopupFlags_MouseButtonLeft)
          rgba2 = custom_palette[m]
        end
        
        if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) then
          ImGui.OpenPopup(ctx, '##Settings5')
        end
      
        if set_cntrl.quit then set_cntrl.open = true end
      end
      if highlight2 == true then
        ImGui.PopStyleColor(ctx,1)
        ImGui.PopStyleVar(ctx,1)
      end
      local open_popup = ImGui.BeginPopup(ctx, 'Choose color#1')
      if open_popup then
        rgba2 =ColorEditPopup(backup_color, rgba2, custom_palette[m] )
        if got_color then
          pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_track.auto_pal, cust_tbl  = pre_cntrl.current_item, 1, false, nil, nil
          custom_palette[m] = rgba2
        end
      end
      
      -- MOUSE MODIFIERS INFO FOR CUSTOM PALETTE --
      if ImGui.IsItemHovered(ctx) then
        hovered_button(31, mods_retval)
      end
      
      if ImGui.BeginPopupContextItem(ctx, '##Settings5') then
        ActionsPopUp(sel_items, sel_tracks, tr_cnt, test_item, m, cust_tbl, 123, custom_palette, 'custom_palette')
        ImGui.EndPopup(ctx)
      end 
      
      if ImGui.BeginDragDropTarget(ctx) then
        local rv,drop_color = ImGui.AcceptDragDropPayloadRGBA(ctx)
        if rv then
          custom_palette[m] = drop_color 
          pre_cntrl.differs, pre_cntrl.differs2, pre_cntrl.stop, auto_track.auto_pal = pre_cntrl.current_item, 1, false, nil
          cust_tbl = nil
        end
        ImGui.EndDragDropTarget(ctx)
      end
      ImGui.PopID(ctx)
    end
    
    if show_seperators and resize&128 ~= 128 then
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize, size*0.1) 
      ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign, 1, 0.5)
      ImGui.Dummy(ctx, av_x, (size*0.2)//1)
      ImGui.SeparatorText(ctx, '  Custom Palette  ')
      ImGui.PopStyleVar(ctx, 2)
      ImGui.PopStyleColor(ctx,1)
      h_calc = h_calc+(size2*0.2)//1+cur_fontsize
    end
  end
  
  -- DUMMIES AFTER CUSTOMPALETTE --
  if resize&2048 == 2048 or (not show_edit and not show_lasttouched and not show_luminance_adjuster and not show_seperators
      and show_custompalette and show_mainpalette and resize&8 ~= 8
        and resize&4 ~= 4 and resize&32 ~= 32 and resize&128 ~= 128) then
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize,size*0.1)
    ImGui.SeparatorText(ctx, '')
    ImGui.PopStyleVar(ctx, 1)
    h_calc = h_calc+cur_fontsize
  elseif (not show_seperators and resize&128 ~= 128 and resize&4 ~= 4 and resize&32 ~= 32 and show_custompalette) or resize&512 == 512 then
    ImGui.Dummy(ctx, av_x, (size*0.2)//1)
    h_calc = h_calc+(size2*0.2)//1
  end

  -- CUSTOM COLOR WIDGET --
  if show_edit and resize&8 ~= 8 then
    if resize&512 == 512 or show_custompalette and not show_seperators and resize&4 ~= 4 and resize&128 ~= 128 then
      ImGui.Dummy(ctx, av_x, (size*0.3)//1)
      h_calc = h_calc+(size2*0.3)//1
    --elseif show_seperators and show_custompalette then
    end
    -- BORDERCOLOR FOR "EDIT CUSTOM COLOR" AND COLORPICKER --
    local rc, gc, bc = ImGui.ColorConvertU32ToDouble4(rgba)
    local hc, sc, vc = ImGui.ColorConvertRGBtoHSV(rc, gc, bc)
    
    if button_color(hc, sc, vc, 1, 'Edit custom color', size*5+spacing*5+size*.1, (size+.5)//1, false, 2) then
      ImGui.OpenPopup(ctx, 'Choose color#2', ImGui.PopupFlags_MouseButtonLeft)
      backup_color2 = rgba
    end
    local open_popup2 = ImGui.BeginPopup(ctx, 'Choose color#2')
    if open_popup2 then
      rgba = ColorEditPopup(backup_color2, rgba, rgba)
    end
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 5, 5)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowPadding, 8, 6)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 5)
    ImGui.SameLine(ctx, -1, size*5+spacing*5+size*.6) -- overlapping items
    
    -- APPLY CUSTOM COLOR --
    if ImGui.ColorButton(ctx, 'Apply custom color##3', rgba, ImGui.ColorEditFlags_NoBorder, size, (size+.5)//1) then
      coloring(sel_items, sel_tracks, ImGui.ColorConvertNative(rgba >>8)|0x1000000, Background_color_rgba(rgba), mods_retval, rgba, tr_cnt, -2, 1, 'custom')
      if mods_retval ~= 20480 then
        last_touched_color = rgba
      end
      if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and ImGui.IsWindowHovered(ctx) then
        ImGui.OpenPopup(ctx, '##Settings8')
      end
      
      if set_cntrl.quit then set_cntrl.open = true end
    end
    ImGui.PopStyleVar(ctx, 3)
    
    -- MOUSE MODIFIERS INFO FOR EDIT CUSTOM COLOR WIDGET --
    if ImGui.IsItemHovered(ctx) then
      hovered_button(10, mods_retval)
    end
    if ImGui.BeginPopupContextItem(ctx, '##Settings8') then
      ActionsPopUp(sel_items, sel_tracks, tr_cnt, test_item, -2, pal_tbl, 57, nil, 'custom color')
      ImGui.EndPopup(ctx)
    end 
    
    -- Drag and Drop --
    if ImGui.BeginDragDropTarget(ctx) then
      local rv,drop_color = ImGui.AcceptDragDropPayloadRGBA(ctx)
      if rv then
        rgba = drop_color
      end
      ImGui.EndDragDropTarget(ctx)
    end
  end

  -- LAST TOUCHED --
  if show_lasttouched and resize&16 ~= 16  then
    if show_edit then
      ImGui.SameLine(ctx, 0.0, spacing)
    elseif show_seperators and show_custompalette and not show_edit and resize&512 ~= 512 and show_mainpalette then
    
    elseif resize&512 ~= 512 and not show_mainpalette and (show_custompalette and not show_seperators) then
      ImGui.Dummy(ctx, av_x, (size*0.3)//1)
      h_calc = h_calc+(size2*0.3)//1
      
    elseif resize&512 == 512 or (show_custompalette and not show_seperators) then
      ImGui.Dummy(ctx, av_x, (size*0.3)//1)
      h_calc = h_calc+(size2*0.3)//1
      
    end
    ImGui.PopFont(ctx)
    ImGui.PushFont(ctx, buttons_font2)
    --[[
     custom_color_flags =  
                   ImGui.ColorEditFlags_DisplayHSV
                  |ImGui.ColorEditFlags_NoSmallPreview
                  |ImGui.ColorEditFlags_NoBorder
                  |ImGui.ColorEditFlags_NoInputs
    --]]
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 5, 5)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowPadding, 8, 6)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, 5) 

    button_action(button_colors.button_color4, 'Last touched:', size*4+spacing*4, (size+.5)//1, false)
    ImGui.SameLine(ctx, 0.0, 0.0)

    if ImGui.ColorButton(ctx, 'Apply last color##6', last_touched_color, ImGui.ColorEditFlags_NoBorder, size, (size+.5)//1) then
      coloring(sel_items, sel_tracks, ImGui.ColorConvertNative(last_touched_color >>8)|0x1000000, Background_color_rgba(last_touched_color), mods_retval, last_touched_color, tr_cnt, -1, 1, 'last touched')
      if set_cntrl.quit then set_cntrl.open = true end
    end
    
    -- MOUSE MODIFIERS INFO FOR CUSTOM PALETTE --
    if ImGui.IsItemHovered(ctx) then
      hovered_button(10, mods_retval)
    end
    ImGui.PopStyleVar(ctx, 3)
    if ImGui.BeginPopupContextItem(ctx, '##Settings9') then
      ActionsPopUp(sel_items, sel_tracks, tr_cnt, test_item, -1, pal_tbl, 57, nil, 'last touched')
      ImGui.EndPopup(ctx)
    end 
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and ImGui.IsWindowHovered(ctx) then
      ImGui.OpenPopup(ctx, '##Settings9')
    end
  end
  
  if show_luminance_adjuster and resize&4096 ~= 4096 then
    if show_edit or show_lasttouched then
      ImGui.SameLine(ctx, 0, size*2.1+spacing*3)
    elseif resize&512 == 512 or (show_custompalette and not show_seperators) then
      ImGui.Dummy(ctx, av_x, (size*0.3)//1)
      h_calc = h_calc+(size2*0.3)//1
    end
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 5, 5)
    if not show_edit and not show_lasttouched then
      h_calc = h_calc+(size2)//1
    end
    ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx) +(size*0.1))
    if button_action(button_colors.button_color1, '-##Settings14', size*0.8, size*0.8, true, size*0.12, size*0.15) then 
      AdjustLightness(sel_tracks, sel_items, 1)
    end
    
    -- MOUSE MODIFIERS INFO FOR LUMINANCE ADJUSTER --
    if ImGui.IsItemHovered(ctx) then
      hovered_button(32, mods_retval)
    end
    -- RIGHTCLICK MENU --
    if ImGui.BeginPopupContextItem(ctx, '##Settings16') then
      --GradientPopUp(sel_tracks, sel_items, sel_color[1], sel_color[#sel_color], nil, grad_mode, p_y, p_x, w, h, tr_cnt)
      LuminancePopUp(p_y, p_x, w, h, tr_cnt)
      ImGui.EndPopup(ctx)
      ImGui.PopFont(ctx)
      ImGui.PushFont(ctx, buttons_font2)
    end    
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and ImGui.IsWindowHovered(ctx) then
      ImGui.OpenPopup(ctx, '##Settings16')
    end
    
    ImGui.SameLine(ctx, 0, size*0.2+spacing)
    if show_edit or show_lasttouched then
      ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx) +(size*0.1))
    end
    if button_action(button_colors.button_color1, '+##Settings15', size*0.8, size*0.8, true, size*0.12, size*0.15) then 
      AdjustLightness(sel_tracks, sel_items, nil)
    end
    
    -- MOUSE MODIFIERS INFO FOR LUMINANCE ADJUSTER --
    if ImGui.IsItemHovered(ctx) then
      hovered_button(32, mods_retval)
    end
    
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and ImGui.IsWindowHovered(ctx) then
      ImGui.OpenPopup(ctx, '##Settings16')
    end
    
    ImGui.SameLine(ctx, 0, size*0.2+spacing)
    if resize&512 == 512 or not (show_edit or show_lasttouched) then
      ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx) -(size*0.1))
    end
    ImGui.Dummy(ctx, size, (size+.5)//1)
    ImGui.PopStyleVar(ctx, 1)
  end
  
  -- OFFSET AND DUMMIES BEFORE MAINPALETTE --
  if (show_lasttouched or show_edit or show_luminance_adjuster) and resize&8 ~= 8 and resize&16 ~= 16 and resize&4096 ~= 4096 then
    ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx)-5)
    h_calc = (h_calc)+(size2+.5)//1
    if resize&512== 512 or resize&1024 == 1024 or (not show_mainpalette or not show_seperators) and resize&128 ~= 128 then
      ImGui.Dummy(ctx, av_x, size*0.3)
      h_calc = h_calc+(size2*0.3)//1
    end
  end

  -- MAIN PALETTE --
  if show_mainpalette and resize&32 ~= 32 then
    if show_seperators and resize&256 ~= 256 and resize&512 ~= 512 then
      ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xffe8acff)
      ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize, size*0.1)
      if show_edit or show_lasttouched or show_luminance_adjuster  then
        ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign, 1, 0.5)
        ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx) -math.ceil(size*0.05))
        h_calc = h_calc-math.ceil(size2*0.05)
      else
        ImGui.PushStyleVar (ctx, ImGui.StyleVar_SeparatorTextAlign, 0, 0.5)
      end
      ImGui.PopFont(ctx)
      ImGui.PushFont(ctx, buttons_font2)
      ImGui.SeparatorText(ctx, '  Main Palette  ')
      ImGui.PopStyleVar(ctx,2) 
      ImGui.PopStyleColor(ctx, 1)
      ImGui.Dummy(ctx, av_x, (size*0.1)//1)
      h_calc = h_calc+cur_fontsize+(size2*0.1)//1
    elseif resize&512 == 512 or (resize&128 ~= 128 and resize&4 ~= 4 and resize&16 ~= 16 and resize&8 ~= 8 and resize&4096 ~= 4096 and (show_edit or show_lasttouched or show_luminance_adjuster)) then
      ImGui.Dummy(ctx, av_x, size*0.1)
      h_calc = h_calc+(size2*0.1)//1
    end
    ImGui.PopStyleVar(ctx, 1) 
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, size*0.07)    -- general rounding for color widgets
    h_calc = h_calc+((size+.5)//1+spacing//1)*5

    -- MAIN COLOR PALETTE --
    for n=1, #main_palette do
      ImGui.PushID(ctx, n)
      if ((n - 1) % 24) ~= 0 then
        ImGui.SameLine(ctx, 0.0, spacing)
      else
        ImGui.SetCursorPosY(ctx, ImGui.GetCursorPosY(ctx)+spacing)
      end
      local highlight = false
      local palette_button_flags =
                  ImGui.ColorEditFlags_NoPicker |
                  ImGui.ColorEditFlags_NoTooltip
      if palette_high.main[n] == 1 then
        ImGui.PushStyleColor(ctx, ImGui.Col_Border,0xffffffff)
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameBorderSize, size*0.08)
        highlight = true
      end
      if highlight == false then
        palette_button_flags = palette_button_flags | ImGui.ColorEditFlags_NoBorder
      end
      -- MAIN PALETTE BUTTONS --
      if ImGui.ColorButton(ctx, '##palette', main_palette[n], palette_button_flags, size, (size+.5)//1) then
        if mods_retval == 8192 then
          sel_color[1] = main_palette[n]
          Color_multiple_elements_to_palette_colors(sel_tracks, sel_items, true, main_palette, nil, set_cntrl.random_main, pal_tbl.tr[n], pal_tbl.it[n], n)
        else
          last_touched_color = main_palette[n] 
          coloring(sel_items, sel_tracks, pal_tbl.tr[n], pal_tbl.it[n], mods_retval, main_palette[n], tr_cnt, nil, nil, "main_palette")
          sel_color[1] = main_palette[n]
        end
        if set_cntrl.quit then set_cntrl.open = true end
      end
      if highlight == true then
        ImGui.PopStyleColor(ctx,1)
        ImGui.PopStyleVar(ctx,1)
      end
      -- MOUSE MODIFIERS INFO FOR MAIN PALETTE --
      if ImGui.IsItemHovered(ctx) then
        hovered_button(3, mods_retval)
      end
      -- RIGHTCLICK MENU --
      if ImGui.BeginPopupContextItem(ctx, '##Settings4') then
        ActionsPopUp(sel_items, sel_tracks, tr_cnt, test_item, n, pal_tbl, 45, main_palette, "main_palette")
        ImGui.EndPopup(ctx)
      end    
      if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and ImGui.IsWindowHovered(ctx) then
        ImGui.OpenPopup(ctx, '##Settings4')
      end
      ImGui.PopID(ctx)
    end
  end
  
  -- if shortcut gradient get cancelled after first click --
  if mods_retval == 0 and stop_coloring then 
    stop_gradient, stop_coloring = nil -- all variables should get nil
    if items_mode == 0 then
      col_tbl = nil
    end
  end
  
  ImGui.PopStyleVar(ctx,1) 
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize,3) 
    
  -- TRIGGER ACTIONS/FUNCTIONS VIA BUTTONS --
  if show_action_buttons and resize&64 ~= 64 then
    ImGui.PopFont(ctx)
    ImGui.PushFont(ctx, buttons_font2)

    if w >= 440 then  
      button_text2 = 'Color children\n    to parent'
      if items_mode == 1 then
        button_text1 = 'Set items to\ndefault color'
        button_text3 = 'Color items\n to gradient'
        button_text4 = 'Color items to\n main palette'
        button_text5 = 'Color items to\ncustom palette'
      elseif items_mode == 3 and sel_mk == 2 then
        button_text1 = 'Set regions to\n default color'
        button_text3 = 'Color regions\n  to gradient'
        button_text4 = ' Color regions\nto main palette'
        button_text5 = 'Color regions to\n custom palette'
      elseif items_mode == 3 and sel_mk == 1 then
        button_text1 = 'Set markers to\n default color'
        button_text3 = 'Color markers\n  to gradient'
        button_text4 = 'Color markers\nto main palette'
        button_text5 = 'Color markers to\n  custom palette'
      elseif items_mode == 3 then
        button_text1 = 'Set mk/rgn to\ndefault color'
        button_text3 = 'Color mk/rgn\n to gradient'
        button_text4 = ' Color mk/rgn\nto main palette'
        button_text5 = 'Color mk/rgn to\n custom palette'
      else
        button_text1 = 'Set tracks to\ndefault color'
        button_text2 = 'Color children\n    to parent'
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
    
    ImGui.Dummy(ctx, av_x, size*0.6)
    h_calc = h_calc+(size2*0.6)//1+bttn_height2//1
    ImGui.PushStyleColor(ctx, ImGui.Col_Text,0xffffffff) 
    
    if button_action(button_colors.button_color2,  button_text1, bttn_width, bttn_height, true, size*0.14, size*0.14) then
      Reset_to_default_color(sel_items, sel_tracks) 
      if set_cntrl.quit then set_cntrl.open = true end
    end
    
    ImGui.SameLine(ctx, 0.0, bttn_gap)
    if button_action(button_colors.button_color2, button_text2, bttn_width, bttn_height, true, size*0.14, size*0.14) then 
      color_childs_to_parentcolor(sel_tracks, tr_cnt) 
      if set_cntrl.quit then set_cntrl.open = true end
    end 
    
    ImGui.SameLine(ctx, 0.0, bttn_gap)
    if button_action(button_colors.button_color2, button_text3, bttn_width, bttn_height, true, size*0.14, size*0.14) then
      local grad_mode
      if mods_retval == 8192 then grad_mode = 1
      elseif mods_retval == 12288 then grad_mode = 2 end
      Color_selected_elements_with_gradient(sel_tracks, sel_items, sel_color[1], sel_color[#sel_color], nil, grad_mode, tr_cnt)
      if set_cntrl.quit then set_cntrl.open = true end
    end
    -- MOUSE MODIFIERS INFO FOR MAIN PALETTE --
    if ImGui.IsItemHovered(ctx) then
      hovered_button(32, mods_retval)
    end
    -- RIGHTCLICK MENU --
    if ImGui.BeginPopupContextItem(ctx, '##Settings11') then
      GradientPopUp(sel_tracks, sel_items, sel_color[1], sel_color[#sel_color], nil, grad_mode, p_y, p_x, w, h, tr_cnt)
      ImGui.EndPopup(ctx)
      ImGui.PopFont(ctx)
      ImGui.PushFont(ctx, buttons_font2)
    end    
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and ImGui.IsWindowHovered(ctx) then
      ImGui.OpenPopup(ctx, '##Settings11')
    end
    
    ImGui.SameLine(ctx, 0.0, bttn_gap)
    if button_action(button_colors.button_color2, button_text4, bttn_width, bttn_height, true, size*0.14, size*0.14) then 
      Color_multiple_elements_to_palette_colors(sel_tracks, sel_items, nil, main_palette, nil, set_cntrl.random_main)
      if set_cntrl.quit then set_cntrl.open = true end
    end
    -- RIGHTCLICK MENU --
    if ImGui.BeginPopupContextItem(ctx, '##Settings12') then
      MultiplePalPopUp()
      ImGui.EndPopup(ctx)
    end    
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and ImGui.IsWindowHovered(ctx) then
      ImGui.OpenPopup(ctx, '##Settings12')
    end
    
    ImGui.SameLine(ctx, 0.0, bttn_gap)
    if button_action(button_colors.button_color2, button_text5, bttn_width, bttn_height, true, size*0.14, size*0.14) then 
      Color_multiple_elements_to_palette_colors(sel_tracks, sel_items, nil, custom_palette, 1, set_cntrl.random_custom)
      if set_cntrl.quit then set_cntrl.open = true end
    end
    -- RIGHTCLICK MENU --
    if ImGui.BeginPopupContextItem(ctx, '##Settings13') then
      MultipleCustPopUp()
      ImGui.EndPopup(ctx)
    end    
    if ImGui.IsItemClicked(ctx, ImGui.MouseButton_Right) and ImGui.IsWindowHovered(ctx) then
      ImGui.OpenPopup(ctx, '##Settings13')
    end
    ImGui.PopStyleColor(ctx)
  end
  
  ImGui.Dummy(ctx, av_x, size*0.9)
  h_calc = h_calc+(size*0.9)//1

  -- CHECK FOR RESIZE --
  ImGui.SameLine(ctx)
  max_x = ImGui.GetCursorPos(ctx)
  ImGui.NewLine(ctx)
  max_y = ImGui.GetCursorPosY(ctx)
  
  if w > (av_x+sides*2+.5)//1 then 
    if h < h_calc+size*0.3 then
      ImGui.Dummy(ctx, size*0.4, h_calc-max_y+size*0.3)
    end
  end
  
  ImGui.PopStyleVar(ctx,2)
  return size
end -- END OF GUI
  
-----------------------------------
-----------------------------------


local function CollapsedPalette(init_state)
  -- CHECK FOR PROJECT TAP CHANGE --
  local cur_project, projfn = reaper.EnumProjects( -1 )
  if cur_project ~= old_project or projfn ~= projfn2 then
    old_project, projfn2, track_number_stop = cur_project, projfn, tr_cnt
    track_number_sw, col_tbl, cur_state4, it_cnt_sw, items_mode, test_track_sw = nil
  end

  -- DEFINE "GLOBAL" VARIABLES --
  if go then
    sel_items = CountSelectedMediaItems(0)
  end
  local sel_tracks = CountSelectedTracks(0)
  local test_track = GetSelectedTrack(0, 0)
  local tr_cnt = CountTracks(0)
  
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
  
  -- CHECK FOR CURRENT DRAWN ITEM IN SHINY MODE --
  local modifier = reaper.JS_Mouse_GetState(29)
  if modifier&1 == 1 and modifier&28 ~= 0 then
    DrawnItem(modifier)
  else
    mouse_item.pressed, mouse_item.current, mouse_item.pos, mouse_item.stop, mouse_item.found = nil
  end
  
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


function save_current_settings()
  SetExtState(script_name ,'selected_mode',           tostring(selected_mode),true)
  SetExtState(script_name ,'colorspace',              tostring(colorspace),true)
  SetExtState(script_name ,'dont_ask',                tostring(set_cntrl.dont_ask),true)
  SetExtState(script_name ,'automode_id',             tostring(automode_id),true)
  SetExtState(script_name ,'saturation',              tostring(saturation),true)
  SetExtState(script_name ,'lightness',               tostring(lightness),true)
  SetExtState(script_name ,'darkness',                tostring(darkness),true)
  SetExtState(script_name ,'rgba',                    tostring(rgba),true)
  SetExtState(script_name ,'rgba3',                   tostring(rgba3),true)
  SetExtState(script_name ,'last_touched_color',      tostring(last_touched_color),true)
  SetExtState(script_name ,'custom_palette',          table.concat(custom_palette,","),true)
  SetExtState(script_name ,'random_custom',           tostring(set_cntrl.random_custom),true)
  SetExtState(script_name ,'random_main',             tostring(set_cntrl.random_main),true)
  SetExtState(script_name ,'auto_trk',                tostring(auto_trk),true)
  SetExtState(script_name ,'show_custompalette',      tostring(show_custompalette),true)
  SetExtState(script_name ,'show_edit',               tostring(show_edit),true)
  SetExtState(script_name ,'show_lasttouched',        tostring(show_lasttouched),true)
  SetExtState(script_name ,'show_luminance_adjuster', tostring(show_luminance_adjuster),true)
  SetExtState(script_name ,'show_mainpalette',        tostring(show_mainpalette),true)
  SetExtState(script_name ,'show_action_buttons',     tostring(show_action_buttons),true)
  SetExtState(script_name ,'show_seperators',         tostring(show_seperators),true)
  SetExtState(script_name ,'current_item',            tostring(pre_cntrl.current_item),true)
  SetExtState(script_name ,'current_main_item',       tostring(pre_cntrl.current_main_item),true)
  SetExtState(script_name ,'mouse_open_X',            tostring(pre_cntrl.mouse_open_X),true)
  SetExtState(script_name ,'mouse_open_Y',            tostring(pre_cntrl.mouse_open_Y),true)
  SetExtState(script_name ,'auto_custom',             tostring(auto_track.auto_custom),true)
  SetExtState(script_name ,'auto_stable',             tostring(auto_track.auto_stable),true)
  SetExtState(script_name ,'tree_node_open_save',     tostring(set_cntrl.tree_node_open_save),true)
  SetExtState(script_name ,'tree_node_open_save2',    tostring(set_cntrl.tree_node_open_save2),true)
  SetExtState(script_name ,'tree_node_open_save3',    tostring(set_cntrl.tree_node_open_save3),true)
  SetExtState(script_name ,'stop',                    tostring(pre_cntrl.stop),true)
  SetExtState(script_name ,'stop2',                   tostring(pre_cntrl.stop2),true)
  SetExtState(script_name ,'background_color_mode',   tostring(set_cntrl.background_color_mode),true)
  SetExtState(script_name ,'topbar_ghost_mode',       tostring(set_cntrl.topbar_ghost_mode),true)
  SetExtState(script_name ,'modifier_info',           tostring(set_cntrl.modifier_info),true)
  SetExtState(script_name ,'quit',                    tostring(set_cntrl.quit),true)
  SetExtState(script_name ,'tooltip_info',            tostring(set_cntrl.tooltip_info),true)
  SetExtState(script_name ,'keep_running1',           tostring(set_cntrl.keep_running1),true)
  SetExtState(script_name ,'open_at_mouse',           tostring(set_cntrl.open_at_mouse),true)
  SetExtState(script_name ,'p_selected_Y',            tostring(set_cntrl.selectables.selected.s_y),true)
  SetExtState(script_name ,'p_selected_X',            tostring(set_cntrl.selectables.selected.s_x),true)
  SetExtState(script_name ,'w',                       tostring(w),true)
  SetExtState(script_name ,'colorspace_lum',          tostring(luminance.colorspace_lum),true)
  SetExtState(script_name ,'darkness_lum',            tostring(luminance.darkness_lum),true)
  SetExtState(script_name ,'lightness_lum',           tostring(luminance.lightness_lum),true)
  SetExtState(script_name ,'cycle_lum',               tostring(luminance.cycle_lum),true)
  
end


-- PUSH STYLE COLOR AND VAR COUNTING --
local function push_style_color()
  local n = 0
  ImGui.PushStyleColor(ctx, ImGui.Col_TitleBgActive, 0x1b3542ff) n=n+1
  ImGui.PushStyleColor(ctx, ImGui.Col_FrameBg , 0x1b3542ff) n=n+1
  ImGui.PushStyleColor(ctx, ImGui.Col_SliderGrab, 0x47aaaaff) n=n+1
  ImGui.PushStyleColor(ctx, ImGui.Col_CheckMark, 0x9eff59ff) n=n+1
  
  if set_cntrl.background_color_mode then
    local theme_color = ImGui.ColorConvertNative(reaper.GetThemeColor('col_main_bg2', -1))
    local theme_color = (theme_color << 8) | 0xFF 
    ImGui.PushStyleColor(ctx, ImGui.Col_WindowBg, theme_color) n=n+1
  end
  return n
end


local function push_style_var(Size, Size2, sides) 
  local m = 0
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ItemSpacing, 0, 0) m=m+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding, Size2*0.4) m=m+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowTitleAlign,0.5, 0.5) m=m+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowPadding, sides, 0) m=m+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_ScrollbarSize, Size2*0.5) m=m+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, Size*0.17, Size*0.17) m=m+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextPadding, Size*0.5, 0) m=m+1
  ImGui.PushStyleVar(ctx, ImGui.StyleVar_PopupRounding, 4)m=m+1
  return m
end


-- LOOP -- MAIN FUNCTION --

local function loop()
  local want_font_size = max((av_x/font_divider1)//1, 10)
  local want_font_size2 = max((av_x/font_divider2)//1, 2)
  local want_font_size3 = (av_x/font_divider3)//1
  local want_font_size4 = ((w-sides*2)/font_divider2)//1
  if want_font_size2 ~= saved_font_size then
    if buttons_font then ImGui.Detach(ctx, buttons_font) end
    if buttons_font2 then ImGui.Detach(ctx, buttons_font2) end
    if buttons_font3 then ImGui.Detach(ctx, buttons_font3) end
    if buttons_font4 then ImGui.Detach(ctx, buttons_font4) end
    buttons_font = ImGui.CreateFont('sans-serif', want_font_size)
    buttons_font2 = ImGui.CreateFont('sans-serif', want_font_size2)
    buttons_font3 = ImGui.CreateFont('sans-serif', want_font_size3)
    buttons_font4 = ImGui.CreateFont('sans-serif', want_font_size4)
    saved_font_size = want_font_size2
    ImGui.Attach(ctx, buttons_font)
    ImGui.Attach(ctx, buttons_font2)
    ImGui.Attach(ctx, buttons_font3)
    ImGui.Attach(ctx, buttons_font4)
  end

  ImGui.PushFont(ctx, buttons_font4)
  local window_flags = ImGui.WindowFlags_None 
  local style_color_n = push_style_color()
  local style_var_m = push_style_var(size, size2, sides)
  
  ImGui.SetNextWindowSize(ctx, 777, 429, ImGui.Cond_FirstUseEver)
  padding_x, padding_y = ImGui.GetStyleVar(ctx, ImGui.StyleVar_WindowPadding)
  local mouse_released = ImGui.IsMouseReleased(ctx, ImGui.MouseButton_Left)
  
  if resize&1 ~= 0 then
    resize = 2
    ImGui.SetNextWindowSize(ctx, max_x+padding_x+1, max_y+set_cntrl.resize_height)
  elseif (mouse_released or (resize and resize&2 == 2)) and h > max_y and (w+.5)//1==(av_x+padding_x*2+.5)//1 then
    ImGui.SetNextWindowSize(ctx, max_x+padding_x+1, max_y)
  end
  
  ImGui.SetNextWindowSizeConstraints(ctx, 328, 50, 3000, 2000, nil)
  if set_cntrl.open_at_mouse_true then
    local m_x, m_y = ImGui.PointConvertNative(ctx, reaper.GetMousePosition())
    ImGui.SetNextWindowPos(ctx, m_x, m_y, Cond_Once, pre_cntrl.mouse_open_X, pre_cntrl.mouse_open_Y)
    set_cntrl.open_at_mouse_true = false
    m_x, m_y = nil
  end

  local visible, open = ImGui.Begin(ctx, 'Chroma - Coloring Tool', true, window_flags)
  local init_state = GetProjectStateChangeCount(0)
  
  if init_state ~= init_state_saved then
    go = true
    init_state_saved = init_state
  else
    go = false
  end
  
  if visible then
    w, h = ImGui.GetWindowSize(ctx)
    av_x, av_y = ImGui.GetContentRegionAvail(ctx)
    local spacing = max((w*0.002), 1)
    size = (av_x-spacing*23)/24
    sides = w/44.671349
    size2 = (w-sides*2-spacing*23)/24

    ColorPalette(init_state, go, w, h, av_x, av_y, size, size2, spacing, sides) 
    ImGui.End(ctx)
  else
    CollapsedPalette(init_state, nil, go)
  end

  ImGui.PopFont(ctx)
  ImGui.PopStyleColor(ctx, style_color_n)
  ImGui.PopStyleVar(ctx, style_var_m)
  if ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) then open = false end -- Escape Key
  if set_cntrl.open then open = false end
  if open then
    defer(loop)
  end
end


-- EXECUTE --
function Exit()
  reaper.set_action_options(8)
end

reaper.atexit(Exit)
reaper.set_action_options(1|4)

defer(loop)

reaper.atexit(function()
  save_current_settings()
  reaper.JS_WindowMessage_Release(ruler_win, msgs)
  reaper.JS_WindowMessage_Release(arrange, msgs)
  reaper.JS_WindowMessage_Release(TCPDisplay, msgs)
end)

reaper.atexit(function()
    if set_cntrl.keep_running1 == true and (auto_trk == true or selected_mode == 1) then
      reaper.Main_OnCommand(set_cntrl.keep_running2, 0)
    end
  end)
  
