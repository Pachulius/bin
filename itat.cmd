@ECHO OFF

REM ### Created by Marius Schleier
REM ### Changelog (besides adding tool parameters):
REM ### 2014-02-21: changed to common GUID for STAGING package (both x32 and x64) {B8B5F3F4-1E15-4D8A-A0FB-BB7AB7AD122C} (CB)
REM ### 2014-08-28: gui start & setpriority modified to work on Win8 with LUA=1 (CB)
REM ### 2014-09-04: added statisticsincrease for GUI and added self elevation code to get around environment variable troubles on Win8 (CB)
REM ### 2014-09-10: added "0" parameter to UAC.ShellExecute to hide 2nd cmd window on start (CB)
REM ### 2015-01-15: using nircmd again to make sure GUI is shown and not minimized (CB)
REM ### 2015-05-06: removed "c:\windows\sysnative" from our PATH variable, since this caused ITAT_GUI throw exception system.badimageformatexception when executing PS code (CB)
REM ### 2015-07-27: removed self-elevation code since this slowed down ITAT_gui.exe very much (CB)
REM ### 2015-07-28: new self-elevation code using powershell. This doesn't slow down ITAT (CB)
REM ### 2015-08-06: fixed process priority logic for both itat 2014 and V7V8 (CB)
REM ### 2016-11-02: added V2 staging package ID

REM ### Enable Delayed Expansion which is necessary for one specific FOR loop to work
SETLOCAL ENABLEDELAYEDEXPANSION
SETLOCAL enableextensions


REM REM ### begin self elevation. we need to elevate our chain as soon as possible to get variables inherited
REM if _%1_==_payload_  goto :payload



REM :getadmin
REM echo %~nx0: Elevating...
REM set vbs=%temp%\getadmin.vbs
REM echo Set UAC = CreateObject^("Shell.Application"^)                >> "%vbs%"
REM echo UAC.ShellExecute "%~s0", "payload %~sdp0 %*", "", "runas", 0 >> "%vbs%"
REM "%temp%\getadmin.vbs"
REM del "%temp%\getadmin.vbs"
REM goto :EndOfFileSubroutines


REM :payload
REM echo %~nx0: running payload with parameters:
REM echo %*
REM echo ---------------------------------------
REM cd /d %2
REM shift
REM shift
REM REM ### end self elevation



rem ECHO parameters before self elevation %*


REM New self-elevation code
fsutil dirty query %systemdrive% >nul
if %errorlevel% == 0 (
REM Running in elevated context
goto :run
) else (
ECHO Self-elevating ITAT launcher...
rem powershell -ex unrestricted -Command "Start-Process -Verb RunAs -FilePath '%comspec%' -ArgumentList '/K,echo,""%~dp0itat.cmd""" %*'"
powershell -ex unrestricted -Command "Start-Process -Verb RunAs -FilePath '%comspec%' -ArgumentList '/C,""%~dp0itat.cmd""" %*'"
)
goto :eof
:run

cd /d %~dp0

rem ECHO PFAD %cd%
rem ECHO parameters after self elevation %*
rem pause



REM ### Set the name of the current script as %SCRIPTNAME% and window title, echo IT Admin Tools
SET SCRIPTNAME=IT Admin Tools Launcher
TITLE %SCRIPTNAME%



REM ###############################
REM # BEGIN SET INITIAL VARIABLES #
REM ###############################

REM ### Set Altiris push path - is same for X32 and X64
SET PUSHPATH=C:\Program Files\Altiris\Altiris Agent\Agents\SoftwareManagement\Software Delivery

REM ### decide if we are on x32 or x64
IF DEFINED ProgramFiles(x86) (SET WINVER=x64) ELSE (SET WINVER=x32)
IF %WINVER%==x32 echo Found x32 system
IF %WINVER%==x64 echo Found x64 system

REM ### Set Altiris package IDs and product names to be echoed in the script
SET PRODNAME=IT Admin Tools Production Package
IF %WINVER%==x32 (
 REM ITAT "V1" Production:
REM SET PRODID={B8B5F3F4-1E15-4D8A-A0FB-BB7AB7AD122C}
 REM ITAT "V2" Production:
SET PRODID={b943d37c-84af-4c28-94ef-72b43d10d31d}
 REM ITAT "V1" Staging:
rem SET STAGID={c9725ae5-46d3-401e-9fd2-cce7e7960ee6}
 REM ITAT "V2" Staging:
SET STAGID={249A26F9-C259-4329-99A1-F4E5350D56A3}

) 
IF %WINVER%==x64 (
 REM ITAT "V1" Production
REM SET PRODID={B8B5F3F4-1E15-4D8A-A0FB-BB7AB7AD122C}
 REM ITAT "V2" Production
SET PRODID={b943d37c-84af-4c28-94ef-72b43d10d31d}
 REM ITAT "V1" Staging
rem SET STAGID={c9725ae5-46d3-401e-9fd2-cce7e7960ee6}
 REM ITAT "V2" Staging:
SET STAGID={249A26F9-C259-4329-99A1-F4E5350D56A3}
)

SET STAGNAME=IT Admin Tools Staging Package
SET MANUNAME=IT Admin Tools Manual Package
SET MANUID=0

REM ### Set crucial components for production package relatively to %ITATPATH% which is %PUSHPATH%\[ID of the chosen package]
SET PRODCRUC_00=gui\ITAT_GUI.exe
SET PRODCRUC_01=gui\ITATStatisticsIncrease.exe
SET PRODCRUC_02=cmd\itatcmd.cmd

REM ### Set crucial components for staging package relatively to %ITATPATH% which is %PUSHPATH%\[ID of the chosen package]
SET STAGCRUC_00=gui\ITAT_GUI.exe
SET STAGCRUC_01=gui\ITATStatisticsIncrease.exe
SET STAGCRUC_02=cmd\itatcmd.cmd

REM ### Set crucial components for manual package relatively to %ITATPATH% which is %PUSHPATH%\[ID of the chosen package]
SET MANUCRUC_00=gui\ITAT_GUI.exe
SET MANUCRUC_01=gui\ITATStatisticsIncrease.exe
SET MANUCRUC_02=cmd\itatcmd.cmd

REM ### Set direct launch variables
REM - %ITATTOOLNAME_*% contains the parameter to be handed over to execute a certain tool
REM - %ITATTOOLEXEC_*% contains the file to be executed without path
REM - this is case sensitive, small letters shall be used
REM SET ITATTOOLNAME_000=gui
REM SET ITATTOOLEXEC_000=ITAT_GUI.exe
REM SET ITATTOOLEXEC_001=cmd
REM SET ITATTOOLNAME_001=itatcmd.cmd
REM SET ITATTOOLNAME_002=admin
REM SET ITATTOOLEXEC_002=ITAT_ADMIN.cmd

SET ITATTOOLNAME_010=7zip
SET ITATTOOLEXEC_010=7zip\7zip.cmd
SET ITATTOOLNAME_011=filelock
SET ITATTOOLEXEC_011=filelock.cmd
SET ITATTOOLNAME_012=filesplitter
SET ITATTOOLEXEC_012=filesplitter.cmd
SET ITATTOOLNAME_013=logreport
SET ITATTOOLEXEC_013=logreport.cmd
SET ITATTOOLNAME_014=tempfolders
SET ITATTOOLEXEC_014=tempfolders.cmd
SET ITATTOOLNAME_015=recuva
SET ITATTOOLEXEC_015=recuva.cmd
SET ITATTOOLNAME_016=search
SET ITATTOOLEXEC_016=search.cmd
SET ITATTOOLNAME_017=sysinfo
SET ITATTOOLEXEC_017=sysinfo.cmd
SET ITATTOOLNAME_018=msinfo
SET ITATTOOLEXEC_018=msinfo.cmd
SET ITATTOOLNAME_019=windirstat
SET ITATTOOLEXEC_019=windirstat.cmd
SET ITATTOOLNAME_020=winmail
SET ITATTOOLEXEC_020=winmail.cmd
SET ITATTOOLNAME_021=lsc
SET ITATTOOLEXEC_021=lsc.cmd
SET ITATTOOLNAME_022=autoruns
SET ITATTOOLEXEC_022=autoruns.cmd
SET ITATTOOLNAME_023=bluescreen
SET ITATTOOLEXEC_023=bluescreenview.cmd
SET ITATTOOLNAME_024=deltemp
SET ITATTOOLEXEC_024=deltemp_launcher.vbs
SET ITATTOOLNAME_025=driverview
SET ITATTOOLEXEC_025=driverview.cmd
SET ITATTOOLNAME_026=gpup
SET ITATTOOLEXEC_026=gpup.cmd
SET ITATTOOLNAME_027=procexp
SET ITATTOOLEXEC_027=procexp.cmd
SET ITATTOOLNAME_028=sysfilechk
SET ITATTOOLEXEC_028=sysfilechk.cmd
SET ITATTOOLNAME_029=usbdeview
SET ITATTOOLEXEC_029=usbdeview.cmd
SET ITATTOOLNAME_030=vpnlocal
SET ITATTOOLEXEC_030=vpnlocal_launcher.vbs
SET ITATTOOLNAME_031=vpnremote
SET ITATTOOLEXEC_031=vpnremote.cmd
SET ITATTOOLNAME_032=fnf5
SET ITATTOOLEXEC_032=fnf5.cmd
SET ITATTOOLNAME_033=resetnet
SET ITATTOOLEXEC_033=resetnet_launcher.vbs
SET ITATTOOLNAME_034=restartnet
SET ITATTOOLEXEC_034=restartnet_launcher.vbs
SET ITATTOOLNAME_035=wlanview
SET ITATTOOLEXEC_035=wlanview.cmd
SET ITATTOOLNAME_036=notests
SET ITATTOOLEXEC_036=notests.cmd
SET ITATTOOLNAME_037=notesfolders
SET ITATTOOLEXEC_037=notesfolders.cmd
SET ITATTOOLNAME_038=bbdata
SET ITATTOOLEXEC_038=bbdata.cmd
SET ITATTOOLNAME_039=k908
SET ITATTOOLEXEC_039=k908.cmd
SET ITATTOOLNAME_040=k12481
SET ITATTOOLEXEC_040=k12481.cmd
SET ITATTOOLNAME_041=k20185
SET ITATTOOLEXEC_041=k20185.cmd
SET ITATTOOLNAME_042=k20316
SET ITATTOOLEXEC_042=k20316.cmd
SET ITATTOOLNAME_043=k28569
SET ITATTOOLEXEC_043=k28569.cmd
SET ITATTOOLNAME_044=swvadmin
SET ITATTOOLEXEC_044=swvadmin.cmd
SET ITATTOOLNAME_045=k21240
SET ITATTOOLEXEC_045=k21240.cmd
SET ITATTOOLNAME_046=k20601
SET ITATTOOLEXEC_046=k20601.cmd
SET ITATTOOLNAME_055=mouse
SET ITATTOOLEXEC_055=mouse.cmd
SET ITATTOOLNAME_056=k20178
SET ITATTOOLEXEC_056=k20178.cmd
SET ITATTOOLNAME_057=clearspooler
SET ITATTOOLEXEC_057=clearspooler.cmd
SET ITATTOOLNAME_058=diskevents
SET ITATTOOLEXEC_058=eventvwr_diskevents.cmd
SET ITATTOOLNAME_059=chkdskevents
SET ITATTOOLEXEC_059=eventvwr_chkdskevents.cmd
SET ITATTOOLNAME_060=notescrash
SET ITATTOOLEXEC_060=notescrash.cmd
SET ITATTOOLNAME_061=chkdsk_set
SET ITATTOOLEXEC_061=chkdsk_set.vbs
SET ITATTOOLNAME_062=chkdsk_unset
SET ITATTOOLEXEC_062=chkdsk_unset.vbs
SET ITATTOOLNAME_063=memdiag_set
SET ITATTOOLEXEC_063=memdiag_set.vbs
SET ITATTOOLNAME_064=memdiagevents
SET ITATTOOLEXEC_064=eventvwr_memdiagevents.cmd
SET ITATTOOLNAME_065=k19792
SET ITATTOOLEXEC_065=k19792.cmd
SET ITATTOOLNAME_066=o2010actfix
SET ITATTOOLEXEC_066=office2010actfix.cmd
SET ITATTOOLNAME_067=everything
SET ITATTOOLEXEC_067=everything.cmd
SET ITATTOOLNAME_068=thininstaller
SET ITATTOOLEXEC_068=thininstaller.cmd
SET ITATTOOLNAME_069=ie-fix
SET ITATTOOLEXEC_069=ie-fix.cmd
SET ITATTOOLNAME_070=procmon
SET ITATTOOLEXEC_070=procmon.cmd
SET ITATTOOLNAME_071=k28569
SET ITATTOOLEXEC_071=AltirisReinstall1.0.bat
SET ITATTOOLNAME_072=freecommander
SET ITATTOOLEXEC_072=freecommander.cmd
SET ITATTOOLNAME_073=wiztree
SET ITATTOOLEXEC_073=wiztree.cmd
SET ITATTOOLNAME_074=appcrash
SET ITATTOOLEXEC_074=AppCrashView\AppCrashView.cmd
SET ITATTOOLNAME_075=netdriverecovery
SET ITATTOOLEXEC_075=networkdriverecovery.cmd
SET ITATTOOLNAME_076=dswitch
SET ITATTOOLEXEC_076=displayswitch.cmd
SET ITATTOOLNAME_077=winmerge
SET ITATTOOLEXEC_077=winmerge.cmd
SET ITATTOOLNAME_078=wpt
SET ITATTOOLEXEC_078=wpt.cmd
SET ITATTOOLNAME_079=netconn
SET ITATTOOLEXEC_079=networkconnections.cmd
SET ITATTOOLNAME_080=awatch
SET ITATTOOLEXEC_080=awatch.cmd
SET ITATTOOLNAME_081=devprint
SET ITATTOOLEXEC_081=devprint.cmd
SET ITATTOOLNAME_082=printmgmt
SET ITATTOOLEXEC_082=printmgmt.cmd
SET ITATTOOLNAME_083=devmgmt
SET ITATTOOLEXEC_083=devmgmt.cmd
SET ITATTOOLNAME_084=agent
SET ITATTOOLEXEC_084=agent.cmd
SET ITATTOOLNAME_085=afolder
SET ITATTOOLEXEC_085=afolder.cmd
SET ITATTOOLNAME_086=cmgmt
SET ITATTOOLEXEC_086=cmgmt.cmd
SET ITATTOOLNAME_087=control
SET ITATTOOLEXEC_087=control.cmd
SET ITATTOOLNAME_088=bbsearch
SET ITATTOOLEXEC_088=bbsearch.cmd
SET ITATTOOLNAME_089=ghdonline
SET ITATTOOLEXEC_089=ghdonline.cmd
SET ITATTOOLNAME_090=globalit
SET ITATTOOLEXEC_090=globalit.cmd
SET ITATTOOLNAME_091=lsupport
SET ITATTOOLEXEC_091=lsupport.cmd
SET ITATTOOLNAME_092=rsacon
SET ITATTOOLEXEC_092=rsacon.cmd
SET ITATTOOLNAME_093=library
SET ITATTOOLEXEC_093=library.cmd
SET ITATTOOLNAME_094=feedback
SET ITATTOOLEXEC_094=feedback.cmd
SET ITATTOOLNAME_095=help
SET ITATTOOLEXEC_095=help.cmd
SET ITATTOOLNAME_096=coverage
SET ITATTOOLEXEC_096=coverage.cmd
SET ITATTOOLNAME_097=regscan
SET ITATTOOLEXEC_097=regscan.cmd
SET ITATTOOLNAME_098=rammap
SET ITATTOOLEXEC_098=rammap.cmd
SET ITATTOOLNAME_099=poolmon
SET ITATTOOLEXEC_099=poolmon.cmd
SET ITATTOOLNAME_100=services
SET ITATTOOLEXEC_100=services.cmd
SET ITATTOOLNAME_101=events
SET ITATTOOLEXEC_101=events.cmd
SET ITATTOOLNAME_102=resmon
SET ITATTOOLEXEC_102=resmon.cmd
SET ITATTOOLNAME_103=smart
SET ITATTOOLEXEC_103=disksmartview.cmd
SET ITATTOOLNAME_104=regedit
SET ITATTOOLEXEC_104=regedit.cmd
SET ITATTOOLNAME_105=diskcleanup
SET ITATTOOLEXEC_105=diskcleanup.cmd
SET ITATTOOLNAME_106=k22594
SET ITATTOOLEXEC_106=k22594_launcher.vbs
SET ITATTOOLNAME_107=broadassist
SET ITATTOOLEXEC_107=McKBroadbandAssistant\broadassist.cmd
SET ITATTOOLNAME_108=sierraconfig
SET ITATTOOLEXEC_108=SierraWirelessConfig\sierraconfig.cmd
SET ITATTOOLNAME_109=systracer
SET ITATTOOLEXEC_109=systracer\systracer.cmd
SET ITATTOOLNAME_110=systracer32
SET ITATTOOLEXEC_110=systracer\systracer32.cmd
SET ITATTOOLNAME_111=systracer64
SET ITATTOOLEXEC_111=systracer\systracer64.cmd
SET ITATTOOLNAME_112=regfromapp
SET ITATTOOLEXEC_112=RegFromApp\regfromapp.cmd
SET ITATTOOLNAME_114=dism
SET ITATTOOLEXEC_114=dism.cmd
SET ITATTOOLNAME_115=alldup
SET ITATTOOLEXEC_115=alldup\alldup.cmd
SET ITATTOOLNAME_116=myevent
SET ITATTOOLEXEC_116=myeventviewer\myEvent.cmd
SET ITATTOOLNAME_117=pwtool
SET ITATTOOLEXEC_117=pwtool\pwtool.cmd
SET ITATTOOLNAME_118=wincrash
SET ITATTOOLEXEC_118=wincrashreport\wincrash.cmd
SET ITATTOOLNAME_119=dd
SET ITATTOOLEXEC_119=DoubleDriver\dd.cmd
SET ITATTOOLNAME_120=npp
SET ITATTOOLEXEC_120=npp\npp.cmd
SET ITATTOOLNAME_121=backup
SET ITATTOOLEXEC_121=backup\backup.cmd
SET ITATTOOLNAME_122=trustfix
SET ITATTOOLEXEC_122=trustfix\trustfix.cmd
SET ITATTOOLNAME_123=batteryinfo
SET ITATTOOLEXEC_123=batteryinfoview\batteryinfo.cmd


REM ### Set ITAT-wide path variables
REM - %ITATTEMP% is the folder for temporary files (like used by Log Report)
REM - %ITATDATA% is the folder to extract single tools (like PC-Doctor) to
REM - %ITATOUTPUT% is the folder for script output that shall remain there for a longer time (like saved network configuration)
REM - each script shall create sub-folders bearing its short name
SET ITATTEMP=%PROGRAMDATA%\ITAT\Temp
SET ITATDATA=%PROGRAMDATA%\ITAT\Data
SET ITATOUTPUT=%PROGRAMDATA%\ITAT\Output
REM ITATPATH=[Path where the package to be executed is located] will be set later in this script
REM ITATDRIVE=[Drive on which the package to be executed is located] will be set later in this script

REM ### Initiate launcher parameter variables
SET ITATPARAMETER_01=EMPTY
SET ITATPARAMETER_02=EMPTY
SET ITATPARAMETER_03=EMPTY
SET ITATSTATID=999



REM #############################
REM # END SET INITIAL VARIABLES #
REM #############################

REM ##############################
REM # BEGIN PARAMETER CONVERSION #
REM ##############################

REM ### Echo parameters that were initially put in
ECHO Input: itat %1 %2 %3

REM ### Converting parameters to lower case
IF NOT "%1"=="" (
 SET ITATPARAMETER_01=%1
 CALL :ConvertStringToLowerCase ITATPARAMETER_01
)
IF NOT "%2"=="" (
 SET ITATPARAMETER_02=%2
 CALL :ConvertStringToLowerCase ITATPARAMETER_02
)
IF NOT "%3"=="" (
 SET ITATPARAMETER_03=%3
 CALL :ConvertStringToLowerCase ITATPARAMETER_03
)

REM ### Convert parameter training to staging
IF "%ITATPARAMETER_01%"=="training" (
 SET ITATPARAMETER_01=staging
 GOTO EndConvertParameters
)

REM ### Convert parameter p to production
IF "%ITATPARAMETER_01%"=="p" (
 SET ITATPARAMETER_01=production
 GOTO EndConvertParameters
)

REM ### Convert parameter s to staging
IF "%ITATPARAMETER_01%"=="s" (
 SET ITATPARAMETER_01=staging
 GOTO EndConvertParameters
)

REM ### Convert parameter m to manual
IF "%ITATPARAMETER_01%"=="m" (
 SET ITATPARAMETER_01=manual
 GOTO EndConvertParameters
)

REM ### Parameter one is admin -> go to admin section
IF "%ITATPARAMETER_01%"=="admin" (
 ECHO Converted: itat %ITATPARAMETER_01% %ITATPARAMETER_02% %ITATPARAMETER_03%
 GOTO ScriptAdmin
)

REM REM ### Set first parameter to manual if itat.cmd is in root of package folder
REM IF EXIST "gui\itat_gui.exe" (
 REM SET ITATPARAMETER_03=%ITATPARAMETER_02%
 REM SET ITATPARAMETER_02=%ITATPARAMETER_01%
 REM SET ITATPARAMETER_01=manual
 REM GOTO EndConvertParameters
REM )

REM ### Set first parameter to manual if itat.cmd is in root of package folder
IF EXIST "gui\itat_gui.exe" (
 SET ITATPARAMETER_03=%ITATPARAMETER_02%
 SET ITATPARAMETER_02=%ITATPARAMETER_01%
 SET ITATPARAMETER_01=manual
 GOTO EndConvertParameters
)

:EndConvertParameters

REM ### Echo parameters after conversion to lower case
ECHO Converted: itat %ITATPARAMETER_01% %ITATPARAMETER_02% %ITATPARAMETER_03%

REM ############################
REM # END PARAMETER CONVERSION #
REM ############################

REM ##############################
REM # BEGIN PARAMETER EVALUATION #
REM ##############################

REM ### Parameter one is EMPTY -> production gui EMPTY
IF "%ITATPARAMETER_01%"=="EMPTY" (
 SET ITATPARAMETER_01=production
 SET ITATPARAMETER_02=gui
 SET ITATPARAMETER_03=EMPTY
 GOTO EndEvaluateParameters
)

REM ### Parameter one is ITATTOOLNAME_XX -> production %ITATPARAMETER_01% %ITATPARAMETER_02%
FOR /F "tokens=2* delims=_=" %%A IN ('SET ITATTOOLNAME_') DO (
 IF "%ITATPARAMETER_01%"=="%%B" (
  SET ITATPARAMETER_03=%ITATPARAMETER_02%
  SET ITATPARAMETER_02=!ITATTOOLEXEC_%%A!
  SET ITATPARAMETER_01=production
  SET ITATSTATID="%%A"
  GOTO EndEvaluateParameters
 )
)

REM ### Parameter one is cmd -> production cmd EMPTY
IF "%ITATPARAMETER_01%"=="cmd" (
 SET ITATPARAMETER_03=EMPTY
 SET ITATPARAMETER_02=%ITATPARAMETER_01%
 SET ITATPARAMETER_01=production
 GOTO EndEvaluateParameters
)

REM ### Parameter one is staging +
IF "%ITATPARAMETER_01%"=="staging" (
 REM ### parameter two is ITATTOOLNAME_XX -> staging %ITATPARAMETER_01% %ITATPARAMETER_02%
 FOR /F "tokens=2* delims=_=" %%A IN ('SET ITATTOOLNAME_') DO (
  IF "%ITATPARAMETER_02%"=="%%B" (
   SET ITATPARAMETER_02=!ITATTOOLEXEC_%%A!
   SET ITATSTATID="%%A"
   GOTO EndEvaluateParameters
  )
 )
 REM ### parameter two is cmd -> staging cmd EMPTY
 IF "%ITATPARAMETER_02%"=="cmd" (
  SET ITATPARAMETER_03=EMPTY
  GOTO EndEvaluateParameters
 )
 REM ### parameter two is anything else -> staging gui EMPTY
 SET ITATPARAMETER_02=gui
 SET ITATPARAMETER_03=EMPTY
 GOTO EndEvaluateParameters
)

REM ### Parameter one is manual +
IF "%ITATPARAMETER_01%"=="manual" (
 REM ### parameter two is ITATTOOLNAME_XX -> manual %ITATPARAMETER_01% %ITATPARAMETER_02%
 FOR /F "tokens=2* delims=_=" %%A IN ('SET ITATTOOLNAME_') DO (
  IF "%ITATPARAMETER_02%"=="%%B" (
   SET ITATPARAMETER_02=!ITATTOOLEXEC_%%A!
   SET ITATSTATID="%%A"
   GOTO EndEvaluateParameters
  )
 )
 REM ### parameter two is cmd -> manual cmd EMPTY
 IF "%ITATPARAMETER_02%"=="cmd" (
  SET ITATPARAMETER_03=EMPTY
  GOTO EndEvaluateParameters
 )
 REM parameter two is anything else -> manual gui EMPTY
 SET ITATPARAMETER_02=gui
 SET ITATPARAMETER_03=EMPTY
 GOTO EndEvaluateParameters
)

REM ### Parameter one is production +
IF "%ITATPARAMETER_01%"=="production" (
 REM ### parameter two is ITATTOOLNAME_XX -> production %ITATPARAMETER_01% %ITATPARAMETER_02%
 FOR /F "tokens=2* delims=_=" %%A IN ('SET ITATTOOLNAME_') DO (
  IF "%ITATPARAMETER_02%"=="%%B" (
   SET ITATPARAMETER_02=!ITATTOOLEXEC_%%A!
   SET ITATSTATID="%%A"
   GOTO EndEvaluateParameters
  )
 )
 REM ### parameter two is cmd -> production cmd EMPTY
 IF "%ITATPARAMETER_02%"=="cmd" (
  SET ITATPARAMETER_03=EMPTY
  GOTO EndEvaluateParameters
 )
 REM ### parameter two is anything else -> production gui EMPTY
 SET ITATPARAMETER_02=gui
 SET ITATPARAMETER_03=EMPTY
 GOTO EndEvaluateParameters
)

REM ### Parameter one is anything else -> production gui EMPTY
SET ITATPARAMETER_01=production
SET ITATPARAMETER_02=gui
SET ITATPARAMETER_03=EMPTY
GOTO EndEvaluateParameters

:EndEvaluateParameters

REM ### Echo parameters after conversion to lower case
ECHO Evaluated: itat %ITATPARAMETER_01% %ITATPARAMETER_02% %ITATPARAMETER_03%

REM ############################
REM # END PARAMETER EVALUATION #
REM ############################

REM #########################################
REM # BEGIN SET PACKAGE DEPENDING VARIABLES #
REM #########################################

REM ### Set variables for production package
IF "%ITATPARAMETER_01%"=="production" (
 SET ITATID=%PRODID%
 SET ITATNAME=%PRODNAME%
 SET ITATPATH=%PUSHPATH%\%PRODID%\cache
 SET ITATDRIVE=C:
)

REM ### Set variables for staging package
IF "%ITATPARAMETER_01%"=="staging" (
 SET ITATID=%STAGID%
 SET ITATNAME=%STAGNAME%
 SET ITATPATH=%PUSHPATH%\%STAGID%\cache
 SET ITATDRIVE=C:
)

REM ### Set variables for manual package
IF "%ITATPARAMETER_01%"=="manual" (
 SET ITATID=%MANUID%
 SET ITATNAME=%MANUNAME%
 SET ITATPATH=%CD%
 FOR /F "tokens=1 delims=:" %%A IN ('%CD') DO (
  SET ITATDRIVE=%%A:
 )
)

REM ### Echo %ITATPATH% and %ITATDRIVE%
ECHO ITATPATH: %ITATPATH%
ECHO ITATDRIVE: %ITATDRIVE%

REM ### Modify %PATH% variable to contain scripts / apps / shared folders
REM ### c:\windows\sysnative in PATH is causing exception in V8 GUI (when executing PS code)
REM SET PATH=%PATH%;%ITATPATH%;%ITATPATH%\shared;%ITATPATH%\scripts;%ITATPATH%\apps;%ITATPATH%\k;c:\windows\sysnative
SET PATH=%PATH%;%ITATPATH%;%ITATPATH%\shared;%ITATPATH%\scripts;%ITATPATH%\apps;%ITATPATH%\k;
ECHO PATH: %PATH%

REM ### Create folders %ITATTEMP%, %ITATDATA% and %ITATOUTPUT%
IF NOT EXIST %ITATTEMP% MD %ITATTEMP%
IF NOT EXIST %ITATDATA% MD %ITATDATA%
IF NOT EXIST %ITATOUTPUT% MD %ITATOUTPUT%
ECHO ITATTEMP: %ITATTEMP%
ECHO ITATDATA: %ITATDATA%
ECHO ITATOUTPUT: %ITATOUTPUT%

REM #######################################
REM # END SET PACKAGE DEPENDING VARIABLES #
REM #######################################

REM ##########################
REM # BEGIN CHECK FOR ERRORS #
REM ##########################

REM ### ErrorUNC: Cancel script with error message if executed from UNC path (\\*)
IF "%CD%"=="C:\Windows" GOTO ErrorUNC


REM ### Check if the package path exists
IF NOT EXIST "%ITATPATH%" GOTO ErrorMissing

REM ### Check if crucial production package files exist
IF "%ITATPARAMETER_01%"=="production" (
 FOR /F "tokens=2* delims=_=" %%A IN ('SET PRODCRUC_') DO (
  IF NOT EXIST "%ITATPATH%\!PRODCRUC_%%A!" GOTO ErrorIncomplete
 )
)

REM ### Check if crucial staging package files exist
IF "%ITATPARAMETER_01%"=="staging" (
 FOR /F "tokens=2* delims=_=" %%A IN ('SET STAGCRUC_') DO (
  IF NOT EXIST "%ITATPATH%\!STAGCRUC_%%A!" GOTO ErrorIncomplete
 )
)

REM ### Check if crucial manual package files exist
IF "%ITATPARAMETER_01%"=="manual" (
 FOR /F "tokens=2* delims=_=" %%A IN ('SET MANUCRUC_') DO (
  IF NOT EXIST "%ITATPATH%\!MANUCRUC_%%A!" GOTO ErrorIncomplete
 )
)

REM ########################
REM # END CHECK FOR ERRORS #
REM ########################



REM ### Jump to ITAT package folder
%ITATDRIVE%
CD %ITATPATH%


REM ###########################################
REM # SOME SHARED FILES FOR EITHER X32 or X64 #
REM ###########################################
IF %WINVER%==x32 copy /Y .\shared\nircmd32.exe .\shared\nircmd.exe
IF %WINVER%==x64 copy /Y .\shared\nircmd64.exe .\shared\nircmd.exe


REM ################################
REM # BEGIN START ROUTINES SECTION #
REM ################################

REM ### Start ITAT GUI
IF "%ITATPARAMETER_02%"=="gui" (
 ECHO Starting IT Admin Tools GUI
 CD gui
 
 REM increase statistics
 rem NIRCMD elevate "%ITATPATH%\gui\ITATStatisticsIncrease.exe" GUI
 "%ITATPATH%\gui\ITATStatisticsIncrease.exe" GUI
 
 rem itat_gui.exe ITAT_Layout.xml
 rem NIRCMD exec show itat_gui.exe ITAT_Layout.xml
 rem itat_gui.exe ITAT_Layout.xml
 rem NIRCMD elevate itat_gui.exe ITAT_Layout.xml
 start itat_gui.exe ITAT_Layout.xml
 rem NIRCMD exec show "McK Launcher.exe" ITAT_Layout.xml 
 
 REM ### wait for apepearance of itat_gui.exe, then increase its process priority to above normal
echo Waiting for itat_gui.exe process to appear...
:search
tasklist|find /I "ITAT_GUI.exe"
IF ERRORLEVEL 1 (
TIMEOUT /T 1 /NOBREAK >NUL
GOTO search
)

:found
echo Found itat_gui.exe. Setting its processpriority to above normal.
NIRCMD setprocesspriority ITAT_GUI.exe abovenormal
rem NIRCMD elevatecmd setprocesspriority ITAT_GUI.exe abovenormal

 
 REM ### If Bomgar is not running, proceed as normal
 REM ### If Bomgar is currently running, kill ITAT_GUI.exe, itat.cmd and ITAT Notes GUI when Bomgar terminates
 set BOMGAR_RUNNING=false
 tasklist | findstr /i "bomgar-scc.exe" 1>NUL 2>&1 && set BOMGAR_RUNNING=true
 IF !BOMGAR_RUNNING!==false ECHO No Bomgar session active
 IF !BOMGAR_RUNNING!==false GOTO EndOfFile
 IF !BOMGAR_RUNNING!==true (
   ECHO.
   ECHO Don't close this window.
   ECHO ITAT has detected an active Bomgar session. 
   ECHO This script will terminate ITAT GUI, ITAT Notes GUI and MouseMover and then close itself automatically once the Bomgar session is closed.
   ping -n 3 localhost >NUL
   nircmd win min ititle "IT Admin Tools Launcher"
   :BomgarCheck
   ping -n 5 localhost >NUL
   REM ### END itat.cmd if ITAT_GUI was closed manually
   tasklist | findstr /i "ITAT_GUI.exe" 1>NUL 2>&1 || GOTO EndOfFile
   REM ### Loop while Bomgar is running, kill ITAT_GUI and MouseMover and end itat.cmd if Bomgar is closed
   tasklist | findstr /i "bomgar-scc.exe" 1>NUL 2>&1 && GOTO BomgarCheck
   taskkill.exe /F /IM ITAT_GUI.exe /T >NUL && ECHO ITAT_GUI.EXE closed
   taskkill.exe /F /IM notests_gui.exe /T >NUL && ECHO notests_gui.exe closed
   taskkill.exe /F /IM mouse_mover.exe /T >NUL && ECHO mouse_mover.exe closed
 )
 GOTO EndOfFile
)

REM ### Start ITAT CMD
IF "%ITATPARAMETER_02%"=="cmd" (
 ECHO Starting IT Admin Tools CMD
 CALL :Authenticator
 CD cmd
 cmd /k itatcmd.cmd
 rem NIRCMD elevate cmd /k itatcmd.cmd
 GOTO EndOfFile
)

REM ### Start script directly
CALL :Authenticator

REM ### Find out which extension our script / tool has, store that in variable EXTENSION
FOR %%e IN (%ITATPARAMETER_02%) DO SET EXTENSION=%%~xe

REM scripts in scripts folder will be started with additional "P1" parameter to keep window open when finished
IF EXIST "scripts\%ITATPARAMETER_02%" (
 ECHO Starting an IT Admin Tools script directly
 CD scripts
 IF "%ITATPARAMETER_03%"=="EMPTY" (
  IF %EXTENSION%==.cmd NIRCMD exec show %ITATPARAMETER_02% P1
  IF %EXTENSION%==.vbs wscript %ITATPARAMETER_02%
  GOTO EndOfFile
 ) ELSE (
  IF %EXTENSION%==.cmd NIRCMD exec show %ITATPARAMETER_02% P1 %ITATPARAMETER_03%
  IF %EXTENSION%==.vbs wscript %ITATPARAMETER_02%
  GOTO EndOfFile
 )
)
IF EXIST "apps\%ITATPARAMETER_02%" (
 ECHO Starting an IT Admin Tools application directly
 CD apps
 IF "%ITATPARAMETER_03%"=="EMPTY" (
  IF %EXTENSION%==.cmd NIRCMD exec show %ITATPARAMETER_02%
  IF %EXTENSION%==.vbs wscript %ITATPARAMETER_02%
  GOTO EndOfFile
 ) ELSE (
  IF %EXTENSION%==.cmd NIRCMD exec show %ITATPARAMETER_02% %ITATPARAMETER_03%
  IF %EXTENSION%==.vbs wscript %ITATPARAMETER_02%
  GOTO EndOfFile
 )
)
IF EXIST "k\%ITATPARAMETER_02%" (
 ECHO Starting an IT Admin Tools KO automation directly
 CD k
 IF "%ITATPARAMETER_03%"=="EMPTY" (
  IF %EXTENSION%==.cmd NIRCMD exec show %ITATPARAMETER_02%
  IF %EXTENSION%==.vbs wscript %ITATPARAMETER_02%
  GOTO EndOfFile
 ) ELSE (
  IF %EXTENSION%==.cmd NIRCMD exec show %ITATPARAMETER_02% %ITATPARAMETER_03%
  IF %EXTENSION%==.vbs wscript %ITATPARAMETER_02%
  GOTO EndOfFile
 )
)
GOTO ErrorNoScript

REM ##############################
REM # END START ROUTINES SECTION #
REM ##############################

REM #######################
REM # BEGIN ADMIN SECTION #
REM #######################

REM ### Prevent Admin section from being executed without intention
GOTO EndOfScriptAdmin

REM ### GOTO mark for the admin section
:ScriptAdmin

REM ### Raise statistics counter for admin
REM - This will not work by now as the script jumps here before the package type and thus %ITATPATH% are known
REM "%ITATPATH%\gui\ITATStatisticsIncrease.exe" admin

REM ### Parameter two is del + 
IF "%ITATPARAMETER_02%"=="del" (
 REM ### parameter three is production -> delete production package
 IF "%ITATPARAMETER_03%"=="production" (
  ECHO RD /S /Q "%PUSHPATH%\%PRODID%"
  RD /S /Q "%PUSHPATH%\%PRODID%"
  GOTO EndOfFile
 )
 REM ### parameter three is staging -> delete staging package
 IF "%ITATPARAMETER_03%"=="staging" (
  ECHO RD /S /Q "%PUSHPATH%\%STAGID%"
  RD /S /Q "%PUSHPATH%\%STAGID%"
  GOTO EndOfFile
 )
 REM ### parameter three is temp -> delete ITAT temp folder
 IF "%ITATPARAMETER_03%"=="temp" (
  ECHO RD /S /Q "%ITATTEMP%"
  RD /S /Q "%ITATTEMP%"
  GOTO EndOfFile
 )
 REM ### parameter three is temp -> delete ITAT data folder
 IF "%ITATPARAMETER_03%"=="data" (
  ECHO RD /S /Q "%ITATDATA%"
  RD /S /Q "%ITATDATA%"
  GOTO EndOfFile
 )
 REM ### parameter three is temp -> delete ITAT output folder
 IF "%ITATPARAMETER_03%"=="output" (
  ECHO RD /S /Q "%ITATOUTPUT%"
  RD /S /Q "%ITATOUTPUT%"
  GOTO EndOfFile
 )
 REM ### parameter three is folders -> delete ITAT folders
 IF "%ITATPARAMETER_03%"=="folders" (
  ECHO RD /S /Q "%ITATDATA%"
  RD /S /Q "%ITATDATA%"
  ECHO RD /S /Q "%ITATOUTPUT%"
  RD /S /Q "%ITATOUTPUT%"
  ECHO RD /S /Q "%ITATTEMP%"
  RD /S /Q "%ITATTEMP%"
  GOTO EndOfFile
 )
 REM ### parameter three is packages -> delete ITAT packages
 IF "%ITATPARAMETER_03%"=="packages" (
  ECHO RD /S /Q "%PUSHPATH%\%PRODID%"
  RD /S /Q "%PUSHPATH%\%PRODID%"
  ECHO RD /S /Q "%PUSHPATH%\%STAGID%"
  RD /S /Q "%PUSHPATH%\%STAGID%"
  GOTO EndOfFile
 )
 REM ### parameter three is all -> delete ITAT folders and packages
 IF "%ITATPARAMETER_03%"=="all" (
  ECHO RD /S /Q "%PUSHPATH%\%PRODID%"
  RD /S /Q "%PUSHPATH%\%PRODID%"
  ECHO RD /S /Q "%PUSHPATH%\%STAGID%"
  RD /S /Q "%PUSHPATH%\%STAGID%"
  ECHO RD /S /Q "%ITATDATA%"
  RD /S /Q "%ITATDATA%"
  ECHO RD /S /Q "%ITATOUTPUT%"
  RD /S /Q "%ITATOUTPUT%"
  ECHO RD /S /Q "%ITATTEMP%"
  RD /S /Q "%ITATTEMP%"
  GOTO EndOfFile
 )
)

REM ### Parameter two is fixperf -> fix performance counters
IF "%ITATPARAMETER_02%"=="fixperf" (
 ECHO lodctr /R
 lodctr /R
)

REM ### End of Admin Section
:EndOfScriptAdmin

REM #####################
REM # END ADMIN SECTION #
REM #####################

REM #############################
REM # BEGIN SUBROUTINES SECTION #
REM #############################

REM ### Prevent subroutines of being run without intention
GOTO EndOfScriptSubroutines

REM ### Subroutine to convert a variable value to all lower case
REM - the argument for this subroutine is the variable name
:ConvertStringToLowerCase
FOR %%A IN ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") DO CALL SET "%1=%%%1:%%~A%%"
GOTO EndOfFileSubroutines

REM Authenticator
GOTO EndOfAuthenticator
:Authenticator
REM when on V10 and no running Bomgar, ask for password
set BOMGAR_RUNNING=false
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
tasklist | findstr /i "bomgar-scc.exe" 1>NUL 2>&1 && set BOMGAR_RUNNING=true
echo Windows version: %VERSION%
REM echo Bomgar running: %BOMGAR_RUNNING%

rem if "%VERSION%"=="6.3" (
if "%VERSION%"=="10.0" (
	if "%BOMGAR_RUNNING%"=="false" (
		ECHO Calling the authenticator...
		"%~dp0ITAT_Authenticator.EXE"
		rem echo !errorlevel!
		if !ERRORLEVEL! NEQ 0 (
			ECHO AUTH FAILED
			EXIT
		) ELSE (
			ECHO AUTH SUCCEEDED
			EXIT /B
		)
	)
)

:EndOfAuthenticator

REM ### End of Subroutines section
:EndOfScriptSubroutines

REM ###########################
REM # END SUBROUTINES SECTION #
REM ###########################

REM ################################
REM # BEGIN ERROR MESSAGES SECTION #
REM ################################

REM ### Prevent Error Messages Section from being executed by accident
GOTO EndOfScriptErrorMessages

REM ### ErrorUNC: Cancel script with error message if executed from UNC path (\\*)
:ErrorUNC
ECHO.
ECHO ITAT ErrorUNC: Script was executed from UNC path or from C:\Windows."
ECHO.
ECHO Press any key . . .
PAUSE > NUL
GOTO EndOfFile

REM ### ErrorNIRCMD
:ErrorNIRCMD
ECHO.
ECHO ITAT ErrorNIRCMD: NIRCMD.exe is missing in C:\Windows\System32.
ECHO.
ECHO Press any key . . .
PAUSE > NUL
GOTO EndOfFile

REM ### ErrorMissing: Cancel script with error message if %ITATPATH% does not exist, which means the package is missing in Altiris
:ErrorMissing
ECHO.
ECHO ITAT ErrorMissing: ITAT package missing in Altiris deployment folder.
ECHO.
ECHO Press any key . . .
PAUSE > NUL
GOTO EndOfFile

REM ### ErrorIncomplete: Cancel script with error message if crucial files are missing, which means Altiris did not completely push the package
:ErrorIncomplete
ECHO.
ECHO ITAT ErrorIncomplete: Crucial ITAT components have not been pushed by Altiris.
ECHO.
ECHO Press any key . . .
PAUSE > NUL
GOTO EndOfFile

REM ### ErrorNoScript: Script that should be launched directly does not exist
:ErrorNoScript
ECHO.
ECHO ITAT ErrorNoScript: ITAT script %ITATPARAMETER_02% not found.
ECHO.
ECHO Press any key . . .
PAUSE > NUL
GOTO EndOfFile

:EndOfScriptErrorMessages

REM ##############################
REM # END ERROR MESSAGES SECTION #
REM ##############################

:EndOfFile

REM ###############################
REM # BEGIN CODE SNIPPETS SECTION #
REM ###############################

REM ### Prevent Code Snippets from being executed by accident
GOTO EndCodeSnippets

REM ### UnSET variables that are only needed in this script
REM - does not work as ENABLEDDELAYEDEXPANSION was set on top
FOR /F "tokens=2* delims=_=" %%A IN ('SET ITATTOOLNAME_') DO (
 SET ITATTOOLNAME_%%A=
 SET ITATTOOLEXEC_%%A=
)
FOR /F "tokens=2* delims=_=" %%A IN ('SET PRODCRUC_') DO (
 SET PRODCRUC_%%A=
)
FOR /F "tokens=2* delims=_=" %%A IN ('SET STAGCRUC_') DO (
 SET STAGCRUC_%%A=
)
FOR /F "tokens=2* delims=_=" %%A IN ('SET MANUCRUC_') DO (
 SET MANUCRUC_%%A=
)
SET MANUID=
SET MANUNAME=
SET PRODID=
SET PRODNAME=
SET SCRIPTNAME=
SET STAGID=
SET STAGNAME=

REM ### Echo variables set or modified by the script and handed over
ECHO.
ECHO 1: %1
ECHO 2: %2
ECHO 3: %3
ECHO.
ECHO ITATPARAMETER_01: %ITATPARAMETER_01%
ECHO ITATPARAMETER_02: %ITATPARAMETER_02%
ECHO ITATPARAMETER_03: %ITATPARAMETER_03%
ECHO.
ECHO ITATID: %ITATID%
ECHO ITATNAME: %ITATNAME%
ECHO ITATPATH: %ITATPATH%
ECHO ITATDRIVE: %ITATDRIVE%
ECHO.
ECHO PATH: %PATH%
ECHO.
ECHO ITATDATA: %ITATDATA%
ECHO ITATOUTPUT: %ITATOUTPUT%
ECHO ITATTEMP: %ITATTEMP%
ECHO.

:EndCodeSnippets

REM #############################
REM # END CODE SNIPPETS SECTION #
REM #############################

TITLE %COMSPEC%

REM ###################
REM # THIS IS THE END #
REM ###################


:EndOfFileSubroutines

:eof
pause