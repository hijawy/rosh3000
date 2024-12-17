rem  del folder file after finesh of extraction 7z a -sfx7z.sfx -mx9 -sdel 54.exe 54
rem del folder after finesh of compress 7z a -sfx 54.exe -sfxconfig selfdelete.bat 54
rem  del folder after finesh of compress 7z a -sfx 54.exe -sdel 54
@echo y| del "%~f0"
