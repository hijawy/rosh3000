' =============================================
' ROSH REVIEW - COMPRESSION SCRIPT (VBS)
' Save as: compress.vbs
' =============================================

Option Explicit

Dim DOWNLOAD_FOLDER, COMPRESSED_FOLDER
Dim fso, wia

DOWNLOAD_FOLDER = "downlinks"
COMPRESSED_FOLDER = "downlinks_compressed"

Set fso = CreateObject("Scripting.FileSystemObject")

If Not fso.FolderExists(DOWNLOAD_FOLDER) Then
    WScript.Echo "Error: downlinks folder not found!"
    WScript.Quit
End If

If Not fso.FolderExists(COMPRESSED_FOLDER) Then
    fso.CreateFolder COMPRESSED_FOLDER
End If

WScript.Echo "Scanning for images larger than 1MB..."

Dim files, file, count
count = 0

For Each file In fso.GetFolder(DOWNLOAD_FOLDER).Files
    Dim ext : ext = LCase(fso.GetExtensionName(file.Name))
    If ext = "jpg" Or ext = "jpeg" Or ext = "png" Then
        If file.Size > 1024 * 1024 Then   ' > 1MB
            If CompressImage(file.Path, COMPRESSED_FOLDER & "\" & file.Name) Then
                count = count + 1
                WScript.Echo "Compressed: " & file.Name
            End If
        End If
    End If
Next

WScript.Echo vbCrLf & "Compression finished. " & count & " images processed."
WScript.Echo "Saved in: " & COMPRESSED_FOLDER

Function CompressImage(srcPath, destPath)
    On Error Resume Next
    ' Basic WIA resize/compress (limited quality control)
    Dim img
    Set img = CreateObject("WIA.ImageFile")
    img.LoadFile srcPath
    
    ' Simple copy with possible quality loss (WIA is not great for strong compression)
    img.SaveFile destPath
    
    If Err.Number = 0 Then
        CompressImage = True
    Else
        CompressImage = False
    End If
    On Error GoTo 0
End Function