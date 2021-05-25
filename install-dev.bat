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
cmd.exe /c sfdx force:org:delete -p -u %ORG_ALIAS% 2>NUL
@echo:

echo Creating scratch org...
cmd.exe /c sfdx force:org:create -c -s -f config/project-scratch-def.json -a %ORG_ALIAS% -d 30
call :checkForError
@echo:

echo Pushing source...
cmd.exe /c sfdx force:source:push -f -u %ORG_ALIAS%
call :checkForError
@echo:

echo Assigning permissions...
cmd.exe /c sfdx force:user:permset:assign -n Quiz_Host -u %ORG_ALIAS%
call :checkForError
@echo:

echo Importing data...
cmd.exe /c sfdx force:data:tree:import -p data/%DATA%/plan.json -u %ORG_ALIAS%
call :checkForError
@echo:

echo Generating user password...
cmd.exe /c sfdx force:user:password:generate -u %ORG_ALIAS%
call :checkForError
@echo:

rem Check exit code
@echo:
if ["%errorlevel%"]==["0"] (
  echo Installation completed.
  @echo:
  cmd.exe /c sfdx force:org:open -p /lightning/setup/SecurityremoteProxy/home -u %ORG_ALIAS%
)

:: ======== FN ======
GOTO :EOF

rem if the app has failed
:checkForError
if NOT ["%errorlevel%"]==["0"] (
    echo Installation failed.
    exit /b %errorlevel%
)