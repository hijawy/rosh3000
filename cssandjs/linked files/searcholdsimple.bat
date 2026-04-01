

@echo off 
findstr /m /i  /C:%1 *.html  > SearchResult.txt

del SearchResult.html


 echo ^<h2^> Search For [ %1 ] Found in  Files as fallow : ^</h2^> >SearchResult.html

for /f "tokens=*" %%a in (SearchResult.txt) do (
  echo ^<p^>^<a href=^"%%a^"^>%%a^</a^>^</p^>>>SearchResult.html
) 
del SearchResult.txt

