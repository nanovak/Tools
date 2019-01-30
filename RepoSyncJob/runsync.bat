echo off

REM set log file name variable to include date/time of the job run
set CUR_YYYY=%date:~10,4%
set CUR_MM=%date:~4,2%
set CUR_DD=%date:~7,2%
set CUR_HH=%time:~0,2%
if %CUR_HH% lss 10 (set CUR_HH=0%time:~1,1%)

set CUR_NN=%time:~3,2%
set CUR_SS=%time:~6,2%
set CUR_MS=%time:~9,2%

set LOGFILENAME=%CUR_YYYY%%CUR_MM%%CUR_DD%-%CUR_HH%%CUR_NN%%CUR_SS%

REM do the needful
D:\Repos\gitpulls.bat > D:\Repos\_syncjob\DeviceConfigs_%LOGFILENAME%.log 2>&1

REM clean up the mess
REM forfiles /p "D:\Repos\_syncjob" /s /m *.log /D -30 /C "cmd /c del @path" > D:\Repos\_syncjob\LogCleanup.log 2>&1


exit