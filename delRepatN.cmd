@echo off

echo Processing %filename%...

:: استخدام بايثون لمعالجة المصفوفة وإزالة التكرار مع الحفاظ على الترتيب
python -c "import json;d=json.load(open('all.json', encoding='utf-8'));d['generatedQuestions']=list(dict.fromkeys(d['generatedQuestions']));json.dump(d, open('allCleaned.json','w',encoding='utf-8'), separators=(',',':'), ensure_ascii=False)" 

if %ERRORLEVEL% EQU 0 (
    echo Done! Cleaned file saved as %temp_file%
    echo Original duplicates removed.
) else (
    echo Error: Make sure Python is installed and %filename% exists.
)

pause