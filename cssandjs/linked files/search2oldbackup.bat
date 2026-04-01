@echo off
setlocal enabledelayedexpansion

rem set /p search_term=Enter the search term:
if %1 == "" (
    set /p search_term=Enter the search term:
    set search_term=%search_term:"=%
) else (
    set search_term=%1
)


echo ^<h2^> Search For [ %search_term% ] Found in Files as follows: ^</h2^> >SearchResult.html
echo ^<html^>^<body^>^<table border="1"^>^<tr^>^<th^>File Name^</th^>^<th^>Word Count^</th^>^</tr^> >> SearchResult.html

set count=0
set index=0

for %%f in (*.html) do (
    for /f "tokens=*" %%a in ('type "%%f" ^| find /i "%search_term%"') do (
        set /a count+=1
    )
    if !count! gtr 0 (
        set /a index+=1
        set "file[!index!]=%%f"
        set "count[!index!]=!count!"
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

:: Output the sorted results to output.html
for /l %%i in (1,1,!index!) do (
    echo ^<tr^>^<td^>^<a href="file:///%cd%\!file[%%i]!"^>!file[%%i]!^</a^>^</td^>^<td^>!count[%%i]!^</td^>^</tr^> >> SearchResult.html
)

echo ^</table^>^</body^>^</html^> >> SearchResult.html

