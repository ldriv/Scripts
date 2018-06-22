# Debug script for gui programming to get positions of gui windows, controls, and hwid information
# 2013 LDR

MouseGetPos, xpos, ypos 
Msgbox , The cursor is at X%xpos% Y%ypos%. 
CoordMode ,Pixel, Screen
#Persistent
SetTimer , WatchCursor, 1000
col:=0xFFFFFFFF
gui, 1:add , text
gui, 1:show, w30 h30

~^n::
;controlgettext , output , %control% , ahk_id %id%
controlget , output , list , , %control% , ahk_id %id%
msgbox %control% ahk_id %id% %output%
return

WatchCursor:
gui, 1:color, %col%
MouseGetPos , mx , my , id, control
WinGetTitle , title, ahk_id %id%
WinGetClass , class, ahk_id %id%
WinGetPos , xp , yp , xs, ys, ahk_id %id%
WinGet , active_id, ID, A
WinGetClass , active, ahk_id %active_id%
Controlgetpos , cx , cy , cw , ch , %control% , ahk_id %id%
PixelGetColor , col , mx , my , slow
Clipboard:=col
ptitle:=DllCall("GetParent", uint, id)
ToolTip , ahk_id %id%`nahk_class %class%`n%title%`nControl: %control% `nParent:%ptitle%`nActive:%active%`nXp:%xp% Yp:%yp% Xs:%xs% Ys:%ys%`n%cx% %cy% %cw% %ch%`n%col%
return 
