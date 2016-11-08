@echo off
rem GET YESTERDAY DATE
set PROJ=lgdst_mod
goto SETDATE

:WINRAR
@echo on
del /S *.*~
del /S *.bak

set WINRAR_EXEC=""
if EXIST "%ProgramFiles%\WinRAR\WinRAR.exe" set WINRAR_EXEC="%ProgramFiles%\WinRAR\WinRAR.exe"
if EXIST "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" set WINRAR_EXEC="%ProgramFiles(x86)%\WinRAR\WinRAR.exe"
if %WINRAR_EXEC%=="" echo "ERROR: WINRAR.exe cannot not be found"
if %WINRAR_EXEC%=="" pause 
if %WINRAR_EXEC%=="" goto FINISH

%WINRAR_EXEC% A -afzip -r -x*\work\* -x*\*.*~ -x*\vsim.wlf -x*\*.swp -xbackup_pof\* -xbackup\* -xsyn\* -xtestbench\* -xrtl\dvbt2_modulator_demo_netlist\netlist\*.* -x*.rar -x*.zip -ed %PROJ%_full_%tdymd%.zip 

%WINRAR_EXEC% A -afzip -r -x*\*.swp -x*\*.swo -ed %PROJ%_full_%tdymd%.zip ref_doc\* syn\*.qsf syn\*.qpf syn\software\* syn\*.stp

%WINRAR_EXEC% A -afzip -r -x*\*.swp -x*\*.swp -xtestbench\work\*.* -xtestbench\altera_mf\*.* -xtestbench\alter_lnsim\*.* -x*\vsim.wlf -ed %PROJ%_full_%tdymd%.zip  testbench\*.v testbench\*.f testbench\*.mpf testbench\*.do testbench\*.sv testbench\*.f 

%WINRAR_EXEC% A -afzip -r -x*\*.swp -x*\*.swp -ed %PROJ%_full_%tdymd%.zip rtl\dvbt2_modulator_demo_netlist\netlist\*.v rtl\dvbt2_modulator_demo_netlist\netlist\*.qxp rtl\dvbt2_modulator_demo_netlist\netlist\*.qpf rtl\dvbt2_modulator_demo_netlist\netlist\*.sdc rtl\dvbt2_modulator_demo_netlist\netlist\*.qsf rtl\dvbt2_modulator_demo_netlist\netlist\*.qws rtl\dvbt2_modulator_demo_netlist\netlist\*.qarlog 


goto FINISH

:SETDATE
set dy=%date:~0,4%
set dm=%date:~5,2%
set dd=%date:~8,2%
set hr=%time:~0,2%
if %hr%==0 set hr=00
if %hr%==1 set hr=01
if %hr%==2 set hr=02
if %hr%==3 set hr=03
if %hr%==4 set hr=04
if %hr%==5 set hr=05
if %hr%==6 set hr=06
if %hr%==7 set hr=07
if %hr%==8 set hr=08
if %hr%==9 set hr=09
set tdymd=%dy:~2,2%%dm%%dd%_%hr%

if %dm%%dd%==0101 goto L01
if %dm%%dd%==0201 goto L02
if %dm%%dd%==0301 goto L07
if %dm%%dd%==0401 goto L02
if %dm%%dd%==0501 goto L04
if %dm%%dd%==0601 goto L02
if %dm%%dd%==0701 goto L04
if %dm%%dd%==0801 goto L02
if %dm%%dd%==0901 goto L02
if %dm%%dd%==1001 goto L05
if %dm%%dd%==1101 goto L03
if %dm%%dd%==1201 goto L06

if %dd%==02 goto L10
if %dd%==03 goto L10
if %dd%==04 goto L10
if %dd%==05 goto L10
if %dd%==06 goto L10
if %dd%==07 goto L10
if %dd%==08 goto L10
if %dd%==09 goto L10
if %dd%==10 goto L11
set /A dd=dd-1
set dt=%dy%%dm%%dd%
goto END
:L10
set /A dd=%dd:~1,1%-1
set dt=%dy%%dm%0%dd%
goto END
:L11
set dt=%dy%%dm%09
goto END

:L02
set /A dm=%dm:~1,1%-1
set dt=%dy%0%dm%31
goto END
:L04
set /A dm=dm-1
set dt=%dy%0%dm%30
goto END

:L05
set dt=%dy%0930
goto END
:L03
set dt=%dy%1031
goto END
:L06
set dt=%dy%1130
goto END
:L01
set /A dy=dy-1
set dt=%dy%1231
goto END

:L07
set /A "dd=dy%%4"
if not %dd%==0 goto L08
set /A "dd=dy%%100"
if not %dd%==0 goto L09
set /A "dd=dy%%400"
if %dd%==0 goto L09
:L08
set dt=%dy%0228
goto END
:L09
set dt=%dy%0229
goto END

:END
echo %dt%

goto WINRAR

:FINISH
