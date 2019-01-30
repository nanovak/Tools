echo off

REM do the needful
D:
cd D:\Repos\SPONETSE-DeviceConfigs
git pull

REM clean up the mess
forfiles /p "D:\Repos\_syncjob" /s /m *.log /D -30 /C "cmd /c del @path" > D:\Repos\_syncjob\LogCleanup_%LOGFILENAME%.log 2>&1