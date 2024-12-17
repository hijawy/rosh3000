$search_term = $args[0]

if (!$search_term) {
    $search_term = Read-Host "Enter the search term:"
}

$output_file = "SearchResult.html"

$index = 0
$results = @()

$total_files = (Get-ChildItem -Path . -Filter *.html).Count
$progressbar = $Host.UI.CreateProgressMeter()
$progressbar.Activity = "Searching for [$search_term]"
$progressbar.Status = "Searching..."
$progressbar.PercentComplete = 0
$progressbar.CurrentOperation = "Starting..."
$progressbar.Total = $total_files
$progressbar.Visible = $true

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
    $progressbar.CurrentOperation = "Searching file $file_name"
    $progressbar.PercentComplete = ($index / $total_files) * 100
    $progressbar.Status = "Processed $index out of $total_files files"
    $progressbar.Refresh()
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

$progressbar.Completed = $true
$progressbar.Dispose()

Start-Process $output_file
