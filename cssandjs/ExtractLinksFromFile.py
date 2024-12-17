import re

def extract_links(file_path, output_file):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Regular expression to find URLs
    urls = re.findall(r'https?://[^\s"]+', content)
    
    # Write URLs to output file
    with open(output_file, 'w', encoding='utf-8') as out_file:
        for url in urls:
            out_file.write(url + '\n')

# Usage
extract_links('all.txt', 'output.txt')
