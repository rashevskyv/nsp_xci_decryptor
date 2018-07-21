@echo off

pushd games
cls

echo ------------------------------------------------------------------------
echo.
echo        %~n1
echo.
echo ------------------------------------------------------------------------

echo * Unpacking of %~n1, please wait!
echo    - Programm is not freeze. Please wait!

set tmp=%time:~0,2%%time:~-2%%~z1
set tempdir=%~dp0temp\%tmp%
set bkps=%~dp0backups
set finaldir_full=%bkps%\%~n1
set filename=%~f1

REM echo %~1
REM echo tmp %tmp%
REM echo tempdir %tempdir%
REM echo bkps %bkps%
REM echo finaldir_full %finaldir_full%
REM echo filename %filename%

cd ..

md %tempdir%

if "%~x1" == ".nsp" (hactool.exe -t pfs0 -k keys.txt "%filename%" --pfs0dir="%tempdir%" >nul 2>&1
) else (hactool.exe -k keys.txt -txci "%filename%" --securedir="%tempdir%" >nul 2>&1)

if "%~x1" == ".nsp" call :get_key

dir "%tempdir%" /b /o-s > nca_name.txt
set /P nca_file= < nca_name.txt 
del nca_name.txt

echo    - DONE

echo.
echo * Unpacking of %nca_file%
echo    - Programm is not freeze. Please wait!

if "%~x1" == ".nsp" (hactool -k keys.txt --titlekey=%key% --exefsdir="%tempdir%\exefs" --romfs="%tempdir%\romfs.bin" "%tempdir%\%nca_file%" >nul 2>&1
)else (hactool.exe -k keys.txt --romfs="%tempdir%\romfs.bin" --exefsdir="%tempdir%\exefs" "%tempdir%\%nca_file%" >nul 2>&1)

del "%tempdir%\*.nca"

echo    - DONE

echo.
echo * Moving files to %finaldir_full%

mkdir "%bkps%" >nul 2>&1
move "%tempdir%" "%bkps%\%~n1" >nul 2>&1

echo    - DONE
echo.

echo.
echo ------------------------------------------------------------------------
echo.
echo             Copy backup folder to root of Switche's microSD. 
echo    Use Atmosphere mod Plague v0.3 anl hekate LayerFS to inject games
echo.
echo ------------------------------------------------------------------------
echo.
exit

:get_key
	cd %tempdir%
	rename *.tik title.tik
	cd ../..
	echo     * Extrackting title_key
	py title_key.py %tempdir
	set /P key= < %tempdir%.txt
	del %tempdir%.txt
	echo        - DONE
exit /b

