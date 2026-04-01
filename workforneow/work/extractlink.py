import os
import re
from pathlib import Path

# المسار المطلوب
target_folder = Path(r"F:\delete\del\rosh2024Q3000OnlinePart\rosh2024Q3000")

# الـ regex الدقيق
pattern = re.compile(
    r'https://roshreview\.imgix\.net/[^\s"\'<>]*?\.(png|jpg|jpeg|gif|webp)(?=\?|$|["\'\s<>])',
    re.IGNORECASE
)

print("جاري البحث في المجلد:")
print(target_folder)
print("====================================\n")

all_links = set()   # لإزالة التكرارات

# البحث في كل ملفات .html
for html_file in target_folder.rglob("*.html"):
    try:
        with open(html_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        matches = pattern.finditer(content)
        for match in matches:
            full_link = match.group(0)
            all_links.add(full_link)
            
        print(f"تم معالجة: {html_file.name}")
        
    except Exception as e:
        print(f"خطأ في الملف: {html_file.name} → {e}")

# حفظ النتائج
output_file = Path("link.txt")

if all_links:
    with open(output_file, 'w', encoding='utf-8') as f:
        for link in sorted(all_links):
            f.write(link + '\n')
    
    print("\n====================================")
    print(f"تم الانتهاء بنجاح!")
    print(f"عدد اللينكات المستخرجة: {len(all_links)}")
    print(f"تم حفظها في الملف: {output_file.resolve()}")
else:
    print("\nلم يتم العثور على أي لينكات مطابقة.")

input("\nاضغط Enter للإغلاق...")