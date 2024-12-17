import json
import random
import sys

# Check if a filename was provided as a command-line argument
if len(sys.argv) != 2:
    print("Usage: python randomize_questions.py <filename.json>")
    sys.exit(1)

# Get the filename from the command-line arguments
filename = sys.argv[1]

# Load the JSON data from the specified file
with open(filename, 'r') as file:
    # Read the file and load the JSON data
    data = json.load(file)

# Check the original order of generatedQuestions
#print("Original generatedQuestions:", data['generatedQuestions'])

# Randomize the order of the numbers in the generatedQuestions array
random.shuffle(data['generatedQuestions'])

# Check the new order of generatedQuestions after shuffling
#print("Randomized generatedQuestions:", data['generatedQuestions'])

# Save the modified data back to the file
with open(filename, 'w') as file:
    # Dump the data in a compact format with no spaces
    json.dump(data, file, separators=(',', ':'), indent=None)

print("The generatedQuestions array has been randomized.")