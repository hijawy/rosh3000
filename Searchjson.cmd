@echo off
setlocal enabledelayedexpansion

if "%~1" == "" (
    set /p search_term=Enter the search term:
    set "search_term=!search_term:"=!"
) else (
    set "search_term=%~1"
)

set count=0
set index=0

for %%f in (*.html,1\*.html,2\*.html,3\*.html,4\*.html,5\*.html,6\*.html,7\*.html,8\*.html,9\*.html,10\*.html,11\*.html,12\*.html) do (
    rem Check if the filename is numeric
    set "filename=%%~nf"
    if "!filename!" neq "" (
        set "isNumeric=1"
        for /l %%i in (0,1,9) do (
            set "char=!filename:~%%i,1!"
            if "!char!" neq "" (
                if "!char!" lss "0" (
                    set "isNumeric=0"
                ) else if "!char!" gtr "9" (
                    set "isNumeric=0"
                )
            )
        )
        if !isNumeric! equ 1 (
            for /f "tokens=*" %%a in ('type "%%f" ^| find /i "%search_term%"') do (
                set /a count+=1
            )
            if !count! gtr 0 (
                set /a index+=1
                set "file[!index!]=%%~nxf"
                set "count[!index!]=!count!"
            )
        )
    )
    set count=0
)

:: Sort the results
for /l %%i in (1,1,!index!) do (
    for /l %%j in (%%i,1,!index!) do (
        if !count[%%i]! lss !count[%%j]! (
            set "temp_file=!file[%%i]!"
            set "temp_count=!count[%%i]!"
            set "file[%%i]=!file[%%j]!"
            set "count[%%i]=!count[%%j]!"
            set "file[%%j]=!temp_file!"
            set "count[%%j]=!temp_count!"
        )
    )
)

set "outputFile=Search%search_term%.json"
set "jsonContent="

:: Output the sorted results to output.html
for /l %%i in (1,1,!index!) do (
    if %%i equ 1 (
        set "line=!file[%%i]!"
        rem Remove .html and spaces
        set "line=!line:.html=!"
        set "line=!line: =!"
        set "jsonContent=!jsonContent!!line!"
    ) else (
        set "line=!file[%%i]!"
        rem Remove .html and spaces
        set "line=!line:.html=!"
        set "line=!line: =!"
        set "jsonContent=!jsonContent!,!line!"
    )
)
set "jsonContent={"generatedQuestions":[!jsonContent!],"correctAnswers":0,"wrongAnswers":0,"questionIndex":0,"answerBox":"","answerBox2":""}"
(
    echo !jsonContent:~0,-1!}
) > "%outputFile%"
