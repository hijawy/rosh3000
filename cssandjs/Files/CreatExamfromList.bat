Rem To creat alist " dir /b 5255*.html >examlist.txt "
@echo off 
setlocal EnableDelayedExpansion
IF EXIST exam.html del exam.html
for /L %%a in (1 1 %1 %2) do (
        call:get_random_number
        echo !RAND_NUM!
        echo ^<p^>^<a href=^"!RAND_NUM!^"^>Question Number %%a^</a^>^</p^>>>exam.html
)

goto:EOF

REM The script ends at the above goto:EOF.  The following are functions.

REM get_random_number()
REM Output: RAND_NUM is set to a random number from examlist.txt.
:get_random_number
set /a line_count=0
for /f "delims=" %%i in (examlist.txt) do set /a line_count+=1

set /a line_num=%random% %% line_count + 1
set /a count=1
for /f "delims=" %%i in (examlist.txt) do (
    if !count! == !line_num! set RAND_NUM=%%i
    set /a count+=1
)

REM Remove the chosen number from the file
findstr /v /c:"%RAND_NUM%" "examlist.txt" > "temp.txt"
move /y "temp.txt" "examlist.txt" > nul

goto :EOF

