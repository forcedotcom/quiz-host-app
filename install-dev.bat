@echo OFF

rem set parameters
if [%1]==[] (
  set ORG_ALIAS=quiz
) else (
  set ORG_ALIAS=%1
)
if [%2]==[] (
  set DATA=sample
) else (
  set DATA=%2
)

@echo:
echo Installing Quiz org:
echo - Org alias:      %ORG_ALIAS%
echo - Data:           %DATA%
@echo:

rem Install script
echo Cleaning previous scratch org...
cmd.exe /c sf org delete scratch -p -o %ORG_ALIAS% 2>NUL
@echo:

echo Creating scratch org...
cmd.exe /c sf org create scratch -f config/project-scratch-def.json -a %ORG_ALIAS% -d -y 30 --no-ancestors --no-namespace
call :checkForError
@echo:

echo Pushing source...
cmd.exe /c sf project deploy start
call :checkForError
@echo:

echo Assigning permissions...
cmd.exe /c sf org assign permset -n Quiz_Host
call :checkForError
@echo:

echo Importing data...
cmd.exe /c sf data tree import -p data/%DATA%/plan.json
call :checkForError
@echo:

echo Generating user password...
cmd.exe /c sf org generate password
call :checkForError
@echo:

echo Opening org...
cmd.exe /c sf org open -p lightning/setup/SecurityRemoteProxy/home
call :checkForError
@echo:

rem Check exit code
@echo:
if ["%errorlevel%"]==["0"] (
  echo Installation completed.
)

:: ======== FN ======
GOTO :EOF

rem if the app has failed
:checkForError
if NOT ["%errorlevel%"]==["0"] (
    echo Installation failed.
    exit /b %errorlevel%
)