@ECHO OFF
ECHO %1
"c:\Program Files\Tiled\tmxrasterizer.exe" --size 300 --hide-layer "management" "%1" "%1.thumb.png"
"C:\Program Files (x86)\Tiled\tmxrasterizer.exe" --size 300 --hide-layer "management" "%1" "%1.thumb.png"