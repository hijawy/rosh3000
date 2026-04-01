$search_term = $args[0]

if (!$search_term) {
    $search_term = Read-Host "Enter the search term:"
}

$output_file = "SearchResult.html"

$index = 0
$results = @()

Get-ChildItem -Path . -Filter *.html | ForEach-Object {
    $file_name = $_.Name
    $word_count = (Get-Content $_.FullName -Raw) -split "\W" | Where-Object { $_ -eq $search_term } | Measure-Object | Select-Object -ExpandProperty Count
    if ($word_count -gt 0) {
        $index++
        $results += [PSCustomObject]@{
            FileName = $file_name
            WordCount = $word_count
        }
    }
}

$results = $results | Sort-Object -Property WordCount -Descending

$html = @"
<h2>Search For [ $search_term ] Found in Files as Follows:</h2>
<html>
<body>
<table border="1">
<tr><th>File Name</th><th>Word Count</th></tr>
"@

$results | ForEach-Object {
    $html += "<tr><td><a href='file:///$pwd\$($_.FileName)'>$($_.FileName)</a></td><td>$($_.WordCount)</td></tr>"
}

$html += "</table></body></html>"

$html | Out-File $output_file

Start-Process $output_file
