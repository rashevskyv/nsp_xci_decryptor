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

call :get_key %tempdir_game% >nul 2>&1

dir "%tempdir_game%" /b /o-s > nca_name.txt
set /P nca_file= < nca_name.txt 
del nca_name.txt >nul 2>&1

echo * Decrypting of %nca_file%
echo    - Programm is not freezing. Be patient!
hactool.exe -k keys.txt "%tempdir_game%\%nca_file:"=%" --titlekey=%key% --plaintext="%tempdir_game%\Decrypted.nca" >nul 2>&1
echo    - DONE
echo.

call :get_key %tempdir_upd% >nul 2>&1

dir "%tempdir_upd%" /b /o-s > nca_name.txt
set /P nca_file= < nca_name.txt 
del nca_name.txt >nul 2>&1

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

:: get title_key from ticket
:get_key
	set tempdir=%1
	echo %tempdir%
	cd %tempdir%
	rename *.tik title.tik
	cd ../..
	echo     * Extrackting title_key
	py title_key.py %tempdir%
	set /P key= < %tempdir%.txt
	del %tempdir%.txt
	echo        - DONE
exit /b

