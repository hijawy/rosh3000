@echo off &setlocal EnableDelayedExpansion
IF EXIST exam.html del exam.html
for /L %%a in (1 1 %1 %2) do (
        call:rand 1 5000
        call:mod
        echo !RAND_NUM!
echo ^<p^>^<a href=^"!RAND_NUM!.html^"^>Question Number %%a^</a^>^</p^>>>exam.html
)

goto:EOF

REM The script ends at the above goto:EOF.  The following are functions.

REM rand()
REM Input: %1 is min, %2 is max.
REM Output: RAND_NUM is set to a random number from min through max.
:rand
SET /A RAND_NUM=%RANDOM% * (%2 - %1 + 1) / 32768 + %1
goto:EOF

:mod
SET /A RAND_NUM=!RAND_NUM! + 525583622
goto:EOF