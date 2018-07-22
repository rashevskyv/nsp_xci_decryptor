@echo off
cls

SetLocal EnableExtensions

echo ------------------------------------------------------------------------
echo.
echo                  Game and Update merger for NSP games
echo.
echo ------------------------------------------------------------------------


set /p game="Drag and Drop here your GAME NSP, then press Enter: "
echo. 
echo. 
set /p upd="Drag and Drop here your UPDATE NSP, then press Enter: "

echo %game% > game.txt
echo %upd% > upd.txt

for %%I in (%game%) do set game_name_long=%%~nI
for %%I in (%upd%) do set upd_name_long=%%~nI
for /f "usebackq delims=[" %%I in (game.txt) do set game_name=%%~nI_updated
set "game_name=%game_name: =_%"

del upd.txt >nul 2>&1
del game.txt >nul 2>&1

set tmp_game=%game_name%_game
set temp=%~dp0temp
set tempdir_game=%temp%\%tmp_game%
set tmp_upd=%game_name%_upd
set tempdir_upd=%temp%\%tmp_upd%
set bkps=%~dp0backups
set gamedir=%temp%\%game_name%

if not exist "%temp%" (mkdir %temp% >nul 2>&1)
if not exist "%gamedir%" (mkdir %gamedir% >nul 2>&1)
mkdir %temp%\%tmp_game% >nul 2>&1
mkdir %temp%\%tmp_upd% >nul 2>&1

echo.

echo * Unpacking of %game_name_long%, please wait!
echo    - Programm is not freezing. Be patient!
hactool.exe "%game:"=%" -k keys.txt -x --intype=pfs0 --pfs0dir="%tempdir_game%" >nul 2>&1
echo    - DONE
echo.

echo * Unpacking of %upd_name_long%, please wait!
echo    - Programm is not freezing. Be patient!
hactool.exe "%upd:"=%" -k keys.txt -x --intype=pfs0 --pfs0dir="%tempdir_upd%" >nul 2>&1
echo    - DONE
echo.


:: get title_key
(for %%i in (%tempdir_game%\*.tik) do (for /f %%k in ('tf.exe %%i') do set key=%%k))>nul

:: get biggest nca
(for /f "delims=" %%i in ('dir %tempdir_game% /b /os') do set nca_file=%%~nxi)>nul

REM call :get_key %tempdir_game% >nul 2>&1

REM dir "%tempdir_game%" /b /o-s > nca_name.txt
REM set /P nca_file= < nca_name.txt 
REM del nca_name.txt >nul 2>&1

echo * Decrypting of %nca_file%
echo    - Programm is not freezing. Be patient!
hactool.exe -k keys.txt "%tempdir_game%\%nca_file:"=%" --titlekey=%key% --plaintext="%tempdir_game%\Decrypted.nca" >nul 2>&1
echo    - DONE
echo.

:: get title_key
(for %%i in (%tempdir_upd%\*.tik) do (for /f %%k in ('tf.exe %%i') do set key=%%k))>nul

:: get biggest nca
(for /f "delims=" %%i in ('dir %tempdir_upd% /b /os') do set nca_file=%%~nxi)>nul

REM call :get_key %tempdir_upd% >nul 2>&1

REM dir "%tempdir_upd%" /b /o-s > nca_name.txt
REM set /P nca_file= < nca_name.txt 
REM del nca_name.txt >nul 2>&1

echo * Merge game files with update
echo    - Programm is not freezing. Be patient!
hactool.exe -k keys.txt "%tempdir_upd%\%nca_file:"=%" --titlekey=%key% --basenca="%tempdir_game%\Decrypted.nca" --section0dir="%gamedir%\exefs" --section1="%gamedir%\romfs.bin" >nul 2>&1
echo    - DONE
echo.

echo * Moving files to %bkps%\%game_name%
if not exist "%bkps%" (mkdir "%bkps%" >nul 2>&1)
move "%gamedir%" "%bkps%\%game_name%" >nul 2>&1

rmdir /s /q "%temp%" >nul 2>&1
echo    - DONE
echo.

echo.
echo ------------------------------------------------------------------------
echo.
echo             Copy backup folder to root of Switche's microSD. 
echo    Use Atmosphere mod Plague (https://github.com/Nalorokk/mod_Plague)
echo                  and hekate LayerFS to inject games
echo.
echo ------------------------------------------------------------------------
echo.

pause
exit

REM :: get title_key from ticket
REM :get_key
	REM set tempdir=%1
	REM echo %tempdir%
	REM cd %tempdir%
	REM rename *.tik title.tik
	REM cd ../..
	REM echo     * Extrackting title_key
	REM py title_key.py %tempdir%
	REM set /P key= < %tempdir%.txt
	REM del %tempdir%.txt
	REM echo        - DONE
REM exit /b

