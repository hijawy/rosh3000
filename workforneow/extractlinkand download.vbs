' =============================================
' ROSH REVIEW - DOWNLOAD SCRIPT (VBS)
' Save as: rosh_download.vbs
' =============================================

Option Explicit

Dim TARGET_FOLDER, DOWNLOAD_FOLDER, LINK_FILE
Dim fso, shell, regex, links, file

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

TARGET_FOLDER = "F:\delete\del\rosh2024Q3000OnlinePart\rosh2024Q3000"
DOWNLOAD_FOLDER = "downlinks"
LINK_FILE = "link.txt"

' Create download folder
If Not fso.FolderExists(DOWNLOAD_FOLDER) Then
    fso.CreateFolder(DOWNLOAD_FOLDER)
End If

' Simple regex simulation for https://roshreview.imgix.net/...png/jpg
Function ExtractLinksFromFile(htmlPath)
    Dim content, matches, link
    Set matches = CreateObject("Scripting.Dictionary")
    
    If Not fso.FileExists(htmlPath) Then Exit Function
    
    content = ReadFile(htmlPath)
    
    ' Very basic pattern matching (VBS regex is limited)
    Dim pos, startPos
    pos = 1
    Do While True
        startPos = InStr(pos, content, "https://roshreview.imgix.net/")
        If startPos = 0 Then Exit Do
        
        Dim endPos1, endPos2, endPos
        endPos1 = InStr(startPos, content, ".png")
        endPos2 = InStr(startPos, content, ".jpg")
        
        If endPos1 > 0 And (endPos2 = 0 Or endPos1 < endPos2) Then
            endPos = endPos1 + 3
        ElseIf endPos2 > 0 Then
            endPos = endPos2 + 3
        Else
            endPos = startPos + 100
        End If
        
        link = Mid(content, startPos, endPos - startPos + 1)
        If InStr(link, "?") > 0 Then link = Left(link, InStr(link, "?") - 1)
        
        If Not matches.Exists(link) Then matches.Add link, ""
        
        pos = endPos + 1
    Loop
    
    ExtractLinksFromFile = matches.Keys
End Function

Function ReadFile(path)
    Dim ts
    Set ts = fso.OpenTextFile(path, 1)
    ReadFile = ts.ReadAll
    ts.Close
End Function

' Main process
WScript.Echo "Starting link extraction from HTML files..."

Dim allLinks : Set allLinks = CreateObject("Scripting.Dictionary")
Dim htmlFiles, htmlFile

Set htmlFiles = fso.GetFolder(TARGET_FOLDER).Files

For Each htmlFile In fso.GetFolder(TARGET_FOLDER).SubFolders
    ' Recursive scan is complex in pure VBS, so we do flat for simplicity
    ' For full recursive, we would need more code
Next

' Better: simple scan (you can improve later)
Dim folder, subFolder
Set folder = fso.GetFolder(TARGET_FOLDER)

For Each file In folder.Files
    If LCase(fso.GetExtensionName(file.Name)) = "html" Then
        Dim keys : keys = ExtractLinksFromFile(file.Path)
        Dim i
        For i = 0 To UBound(keys)
            If Not allLinks.Exists(keys(i)) Then allLinks.Add keys(i), ""
        Next
    End If
Next

' Save to link.txt
Dim tsOut
Set tsOut = fso.CreateTextFile(LINK_FILE, True)
Dim key
For Each key In allLinks.Keys
    tsOut.WriteLine key
Next
tsOut.Close

WScript.Echo "✓ " & allLinks.Count & " links saved to " & LINK_FILE

' ====================== DOWNLOAD PART ======================
WScript.Echo vbCrLf & "Starting download..."

Dim urls, url
Set tsOut = fso.OpenTextFile(LINK_FILE, 1)
urls = Split(tsOut.ReadAll, vbCrLf)
tsOut.Close

Dim success : success = 0

For Each url In urls
    If Trim(url) <> "" And InStr(url, "http") = 1 Then
        Dim filename : filename = GetFileNameFromURL(url)
        Dim fullPath : fullPath = DOWNLOAD_FOLDER & "\" & filename
        
        If DownloadFile(url, fullPath) Then
            success = success + 1
            WScript.Echo "Downloaded: " & filename
        End If
    End If
Next

WScript.Echo vbCrLf & "Download finished: " & success & " files in " & DOWNLOAD_FOLDER

Function GetFileNameFromURL(url)
    Dim parts : parts = Split(url, "/")
    GetFileNameFromURL = parts(UBound(parts))
    If InStr(GetFileNameFromURL, "?") > 0 Then
        GetFileNameFromURL = Left(GetFileNameFromURL, InStr(GetFileNameFromURL, "?") - 1)
    End If
End Function

Function DownloadFile(url, savePath)
    On Error Resume Next
    Dim http, stream
    Set http = CreateObject("MSXML2.XMLHTTP")
    Set stream = CreateObject("ADODB.Stream")
    
    http.Open "GET", url, False
    http.Send
    
    If http.Status = 200 Then
        stream.Type = 1 ' Binary
        stream.Open
        stream.Write http.ResponseBody
        stream.SaveToFile savePath, 2
        stream.Close
        DownloadFile = True
    Else
        DownloadFile = False
    End If
    
    Set http = Nothing
    Set stream = Nothing
    On Error GoTo 0
End Function

WScript.Echo vbCrLf & "All done! Use compress.vbs next if needed."
WScript.Sleep 3000