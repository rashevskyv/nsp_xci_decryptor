@echo off

pushd games
cls

echo ------------------------------------------------------------------------
echo.
echo        %~n1
echo.
echo ------------------------------------------------------------------------

echo * Unpacking of %~n1, please wait!
echo    - Programm is not freezing. Be patient!

:: define vars
set tmp=%RANDOM%%~z1
set tempdir=%~dp0temp\%tmp%
set bkps=%~dp0backups
set finaldir_full=%bkps%\%~n1
set filename=%~f1

:: echo vars
REM echo %~1
REM echo tmp %tmp%
REM echo tempdir %tempdir%
REM echo bkps %bkps%
REM echo finaldir_full %finaldir_full%
REM echo filename %filename%

cd ..

md %tempdir%

:: exctract game to nca's
if "%~x1" == ".nsp" (hactool.exe "%filename%" -k keys.txt -x --intype=pfs0 --pfs0dir="%tempdir%" >nul 2>&1
) else (hactool.exe -k keys.txt -txci "%filename%" --securedir="%tempdir%" >nul 2>&1)

::hactool -k keys.txt --titlekey=CopyPasteKeyHere --exefsdir=exefs --romfsdir=romfs game.nca

:: get title_key
(for %%i in (%tempdir%\*.tik) do (for /f %%k in ('tf.exe %%i') do set key=%%k))>nul

:: get biggest nca
(for /f "delims=" %%i in ('dir %tempdir% /b /os') do set nca_file=%%~nxi)>nul

echo    - DONE

echo.
echo * Unpacking of %nca_file%
echo    - Programm is not freezing. Be patient!

:: unpack nca's to layeredFS
if "%~x1" == ".nsp" (hactool "%tempdir%\%nca_file%" -k keys.txt --titlekey=%key% --romfs="%tempdir%\romfs.bin" --exefsdir="%tempdir%\exefs" >nul 2>&1
)else (hactool.exe -k keys.txt --romfs="%tempdir%\romfs.bin" --exefsdir="%tempdir%\exefs" "%tempdir%\%nca_file%" >nul 2>&1)

echo    - DONE

echo.
echo * Moving files to %finaldir_full%

del "%tempdir%\*.nca"

mkdir "%bkps%" >nul 2>&1
move "%tempdir%" "%bkps%\%~n1" >nul 2>&1

rmdir /s /q "%~dp0temp" >nul 2>&1

echo    - DONE
echo.

echo.
echo ------------------------------------------------------------------------
echo.
echo             Copy backup folder to root of Switche's microSD. 
echo    Use Atmosphere mod Plague (https://github.com/Nalorokk/mod_Plague)
echo                    and hekate LayerFS to inject games
echo.
echo ------------------------------------------------------------------------
echo.

pause
exit