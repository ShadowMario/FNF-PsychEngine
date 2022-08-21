echo OFF
if %random% == 0 echo penis
:build
echo Running "lime test windows -dce no %*"
lime test windows -dce no %*
pause
goto build