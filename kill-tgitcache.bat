@ECHO OFF
SET PROCESS=TGitCache.exe
SET WAIT=2000
TASKKILL /F /IM %PROCESS% 
TASKLIST | find "PROCESS"
ping 1.1.1.1 -n 1 -w %WAIT% > nul
