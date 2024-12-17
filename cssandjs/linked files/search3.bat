@echo off

setlocal enableDelayedExpansion

set /p search_term=Enter the search term:

echo ^<html^>^<body^>^<table border="1"^>^<tr^>^<th^>File Name^</th^>^<th^>Word Count^</th^>^</tr^> > output.html

set count=0
set total=0

rem Get the total number of files to search through
for /f %%f in ('dir /b *.html ^| find /v /c ""') do set total=%%f

rem Loop through each file and search for the term
for %%f in (*.html) do (
    set local_count=0
    for /f "tokens=*" %%a in ('type "%%f" ^| find /i "%search_term%"') do (
        set /a local_count+=1
    )
    if !local_count! gtr 0 (
        echo ^<tr^>^<td^>^<a href="file:///%cd%\%%f"^>%%f^</a^>^</td^>^<td^>!local_count!^</td^>^</tr^> >> output.html
    )
    set /a count+=local_count
    set /a progress=count*100/total
    set "progress_bar="
    for /l %%i in (1,1,!progress!) do set "progress_bar=!progress_bar!#"
    for /l %%i in (!progress!,1,100) do set "progress_bar=!progress_bar!."
    echo Searching... !progress_bar! !progress!%% complete
)

echo ^</table^>^</body^>^</html^> >> output.html

echo Search complete. Results saved to output.html.
