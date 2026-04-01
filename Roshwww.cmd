rem start "" "C:\Progra~1\Google\Chrome\Applic~1\chrome.exe"  --disable-web-security  --new-window http://127.0.0.1:8080/index.html & start "" python -m http.server 8080 --bind 127.0.0.1 --directory G:\RoshwwwV17

rem echo http://127.0.0.1:8080/indexauto.html| clip

set /p ="http://127.0.0.1:8080/indexauto.html" <nul | clip
start "" python -m http.server 8080 --bind 127.0.0.1 --directory G:\RoshwwwV17