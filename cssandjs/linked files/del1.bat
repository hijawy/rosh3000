@echo off

set /p search_term=Enter the search term:

echo ^<html^>^<body^>^<table border="1"^>^<tr^>^<th^>File Name^</th^>^<th^>Word Count^</th^>^</tr^> > output.html

for %%f in (*.html) do (
    set count=0
    for /f "tokens=*" %%a in ('type "%%f" ^| find /i "%search_term%"') do (
        set /a count+=1
    )
    echo ^<tr^>^<td^>%%f^</td^>^<td^>!count!^</td^>^</tr^> >> output.html
)

echo ^</table^>^</body^>^</html^> >> output.html
