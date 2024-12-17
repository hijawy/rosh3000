@echo off

setlocal enabledelayedexpansion

set "search_string=%1"
set "result_file=SearchResult.html"

if exist "%result_file%" del "%result_file%"

set "files="
for /f "delims=" %%f in ('dir /b /a-d *.html') do (
    set "files=!files! "%%f""
)

for %%f in (%files%) do (
    set "count=0"
    for /f "tokens=1-3 delims=," %%a in ('type "%%f" ^| find /i /c "%search_string%"') do (
        set "count=%%a"
    )
    set "counts[%%f]=!count!"
)

set "header=^<h2^>Search Results for [%search_string%]^</h2^>"
set "table_header=^<table^><tr^><th^>File Path^</th^><th^>Repetition Count^</th^></tr^>"
set "table_footer=^</table^>"

echo %header% >> %result_file%
echo %table_header% >> %result_file%

for /f "tokens=2 delims==" %%f in ('set counts[') do (
    set "file=%%~f"
    set "count=!counts[%%f]!"
    if !count! neq 0 (
        set "table_row=^<tr^><td^>^<a href="file:///%cd%/!file!"^>!file!^</a^>^</td^><td^>!count!^</td^></tr^>"
        echo !table_row! >> %result_file%
    )
)

echo %table_footer% >> %result_file%

for %%f in (%files%) do (
    set "counts[%%f]="
)

endlocal
