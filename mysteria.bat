@echo OFF

SET TCL_PATH=".\contrib\win64\Tcl9.0\bin"
SET PATH="%PATH%;%TCL_PATH%"

start /B .\contrib\win64\i2pd\start.bat
.\contrib\win64\Tcl9.0\bin\tclsh90.exe .\mysteria.tcl
start /B .\contrib\win64\i2pd\kill.bat

pause
exit /b 0
