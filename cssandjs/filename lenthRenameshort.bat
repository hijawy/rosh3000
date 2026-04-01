@ECHO OFF
SETLOCAL
SET "sourcedir=G:\roshimg"
SET "tempfile=%temp%\##fn##.52"
ECHO ::>"%tempfile%"
FOR /f "delims=" %%a IN (
  'dir /s /b /a-d "%sourcedir%\*" '
 ) DO (
 SET "fullname=%%a"
 SET "name=%%~na"
 SET "ext=%%~xa"
 CALL :chgname
)
del "%tempfile%"
GOTO :EOF

:chgname
:: Proposed new name part - first 52 characters of existing name
:: also prepare for adding modifier
SET "newname=%name:~0,52%"
SET /a modifier=0
:modl
:: See whether this name has already been found
ECHO %newname%%ext%|FINDSTR /b /e /i /g:"%tempfile%" >NUL
IF ERRORLEVEL 1 GOTO makechange
:: existing name - modify it
SET "newname=%name:~0,52%@%modifier%@"
SET /a modifier+=1
GOTO modl

:makechange
IF "%name%" NEQ "%newname%" ECHO REN "%fullname%" "%newname%%ext%">>rename.txt
IF "%name%" NEQ "%newname%" ECHO REN  "%newname%%ext%" "%fullname%">>renameback.txt
::IF "%name%" NEQ "%newname%" ECHO REN "%fullname%" "%newname%%ext%">>"%tempfile%" ECHO %newname%%ext%

GOTO :eof