Option Explicit

Dim fso, jsonFile, content, startPos, endPos, arrayStr, numbers, dict, num, resultStr, finalContent
Set fso = CreateObject("Scripting.FileSystemObject")
Set dict = CreateObject("Scripting.Dictionary")

' 1. قراءة الملف
If fso.FileExists("all.json") Then
    Set jsonFile = fso.OpenTextFile("all.json", 1)
    content = jsonFile.ReadAll
    jsonFile.Close
Else
    MsgBox "خطأ: ملف all.json غير موجود في المجلد!", 16, "خطأ"
    WScript.Quit
End If

' 2. تحديد مكان المصفوفة (generatedQuestions)
startPos = InStr(content, "[") + 1
endPos = InStr(content, "]")
arrayStr = Mid(content, startPos, endPos - startPos)

' 3. تقسيم الأرقام وإزالة التكرار
numbers = Split(arrayStr, ",")
For Each num In numbers
    num = Trim(num)
    If num <> "" Then
        If Not dict.Exists(num) Then
            dict.Add num, ""
        End If
    End If
Next

' 4. إعادة بناء المصفوفة بدون تكرار
resultStr = Join(dict.Keys, ",")

' 5. دمج المصفوفة الجديدة في نص JSON الأصلي
finalContent = Left(content, startPos - 1) & resultStr & Mid(content, endPos)

' 6. حفظ النتيجة في ملف جديد
Set jsonFile = fso.CreateTextFile("allCleaned.json", True)
jsonFile.Write finalContent
jsonFile.Close

MsgBox "تمت العملية بنجاح! تم حفظ الملف باسم allCleaned.json", 64, "اكتمل التنظيف"