#!/bin/bash

# Function to check if a string is numeric
is_numeric() {
    [[ $1 =~ ^[0-9]+$ ]]
}

# Get the search term from command line argument or prompt the user
if [ -z "$1" ]; then
    read -p "Enter the search term: " search_term
else
    search_term="$1"
fi

count=0
index=0
declare -A file_count

# Loop through HTML files
for f in *.html 1/*.html 2/*.html 3/*.html 4/*.html 5/*.html 6/*.html 7/*.html 8/*.html 9/*.html 10/*.html 11/*.html 12/*.html; do
    filename=$(basename "$f" .html)

    # Check if the filename is numeric
    if is_numeric "$filename"; then
        count=$(grep -ic "$search_term" "$f")
        if [ "$count" -gt 0 ]; then
            index=$((index + 1))
            # Store only the numeric part of the filename
            file_count["$index"]="$filename"
            count_array["$index"]="$count"
        fi
    fi
done

# Sort the results based on count
for ((i=1; i<=index; i++)); do
    for ((j=i+1; j<=index; j++)); do
        if [ "${count_array[$i]}" -lt "${count_array[$j]}" ]; then
            # Swap
            temp_file="${file_count[$i]}"
            temp_count="${count_array[$i]}"
            file_count[$i]="${file_count[$j]}"
            count_array[$i]="${count_array[$j]}"
            file_count[$j]="$temp_file"
            count_array[$j]="$temp_count"
        fi
    done
done

# Prepare JSON output
outputFile="Search${search_term}.json"
jsonContent='{"generatedQuestions":['

for ((i=1; i<=index; i++)); do
    line="${file_count[$i]}"
    jsonContent+="$line"
    if [ "$i" -lt "$index" ]; then
        jsonContent+=","
    fi
done

jsonContent+='],"correctAnswers":0,"wrongAnswers":0,"questionIndex":0,"answerBox":"","answerBox2":""}'

# Write to output file
echo "$jsonContent" > "$outputFile"
