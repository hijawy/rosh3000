@echo off
setlocal enabledelayedexpansion
set /p search_term=Enter the search term:

echo ^<html^>^<body^>^<table border="1"^>^<tr^>^<th^>File Name^</th^>^<th^>Word Count^</th^>^</tr^> > output.html

set count=0

for %%f in (*.html) do (
    for /f "tokens=*" %%a in ('type "%%f" ^| find /i "%search_term%"') do (
        set /a count+=1
        echo !count!
    )
    if !count! gtr 0 (
        echo ^<tr^>^<td^>^<a href="file:///%cd%\%%f"^>%%f^</a^>^</td^>^<td^>!count!^</td^>^</tr^> >> output.html
    )
    set count=0
)

echo ^</table^>^</body^>^</html^> >> output.html
