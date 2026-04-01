#!/bin/bash

# Prompt for search term if not provided as an argument
if [ -z "$1" ]; then
    read -p "Enter the search term: " search_term
else
    search_term="$1"
fi

# Create the HTML output file
output_file="SearchResult${search_term//\"/}.html"
{
    echo "<h2>Search For [ $search_term ] Found in Files as follows:</h2>"
    echo "<html><body><table border=\"1\"><tr><th>File Name</th><th>Word Count</th></tr>"
} > "$output_file"

# Initialize arrays to hold file names and counts
declare -a files
declare -a counts
index=0

# Search for the term in all HTML files in subdirectories
while IFS= read -r -d '' file; do
    count=$(grep -oi "$search_term" "$file" | wc -l)
    if [ "$count" -gt 0 ]; then
        index=$((index + 1))
        files[index]="$file"
        counts[index]="$count"
    fi
done < <(find . -name "*.html" -print0)

# Sort results based on word count
for ((i=1; i<=index; i++)); do
    for ((j=i+1; j<=index; j++)); do
        if [ "${counts[i]}" -lt "${counts[j]}" ]; then
            # Swap counts
            temp_count="${counts[i]}"
            counts[i]="${counts[j]}"
            counts[j]="$temp_count"
            # Swap files
            temp_file="${files[i]}"
            files[i]="${files[j]}"
            files[j]="$temp_file"
        fi
    done
done

# Output the sorted results to the HTML file
for ((i=1; i<=index; i++)); do
    echo "<tr><td><a href=\"file://$(realpath "${files[i]}")\">${files[i]}</a></td><td>${counts[i]}</td></tr>" >> "$output_file"
done

# Close the HTML tags
echo "</table></body></html>" >> "$output_file"
