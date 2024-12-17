@echo off

setlocal enabledelayedexpansion

set "search_string=%1"
set "result_file=SearchResult.html"

if exist "%result_file%" del "%result_file%"

set "header=^<h2^>Search Results for [%search_string%]^</h2^>"
set "table_header=^<table^><tr^><th^>File Path^</th^><th^>Repetition Count^</th^></tr^>"
set "table_footer=^</table^>"

echo %header% >> %result_file%
echo %table_header% >> %result_file%

for %%f in (*.html) do (
    set "count=0"
    for /f "tokens=1-3 delims=," %%a in ('type "%%f" ^| find /i /c "%search_string%"') do (
        set "count=%%a"
    )
    if !count! neq 0 (
        set "table_row=^<tr^><td^>^<a href="%%f"^>%%f^</a^>^</td^><td^>!count!^</td^></tr^>"
        echo !table_row! >> %result_file%
    )
)

echo %table_footer% >> %result_file%

endlocal
