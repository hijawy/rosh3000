import os
import re
import requests
from pathlib import Path
from tqdm import tqdm
from urllib.parse import urlparse, unquote

# إعدادات
input_file = Path("link.txt")
download_folder = Path("downlinks")

# إنشاء المجلد إذا لم يكن موجود
download_folder.mkdir(exist_ok=True)

def get_filename_from_url(url):
    """استخراج اسم الملف من الرابط بشكل نظيف"""
    parsed = urlparse(url)
    filename = os.path.basename(parsed.path)
    # فك الـ URL encoding (مثل %20 إلى مسافة)
    filename = unquote(filename)
    
    # تنظيف الاسم من الأحرف غير المرغوبة
    filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
    
    # إذا كان الاسم فارغ أو غير مناسب، نستخدم اسم افتراضي
    if not filename or '.' not in filename:
        filename = "image_" + os.path.basename(parsed.path)[-20:] + ".png"
    
    return filename

def download_image(url, folder):
    """تحميل صورة واحدة مع progress bar"""
    try:
        filename = get_filename_from_url(url)
        filepath = folder / filename
        
        # إذا كان الملف موجود، نضيف رقم في النهاية
        counter = 1
        original_stem = filepath.stem
        while filepath.exists():
            filepath = folder / f"{original_stem}_{counter}{filepath.suffix}"
            counter += 1
        
        # تحميل الصورة
        response = requests.get(url, stream=True, timeout=30)
        response.raise_for_status()
        
        total_size = int(response.headers.get('content-length', 0))
        
        with open(filepath, 'wb') as f, tqdm(
            desc=filename[:50],  # اختصار الاسم في الـ progress
            total=total_size,
            unit='iB',
            unit_scale=True,
            unit_divisor=1024,
        ) as bar:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    size = f.write(chunk)
                    bar.update(size)
        
        return True, filename
        
    except Exception as e:
        return False, f"خطأ في {url[:80]}... → {str(e)}"

# ====================== التشغيل الرئيسي ======================

if not input_file.exists():
    print(f"❌ الملف {input_file} غير موجود!")
    print("تأكد من وجود ملف link.txt في نفس مجلد السكريبت.")
    input("\nاضغط Enter للإغلاق...")
    exit()

print("جاري قراءة اللينكات من link.txt ...")
with open(input_file, 'r', encoding='utf-8') as f:
    urls = [line.strip() for line in f if line.strip() and line.startswith('http')]

print(f"تم العثور على {len(urls)} رابط.")
print(f"سيتم التحميل إلى المجلد: {download_folder.resolve()}\n")

success_count = 0
failed = []

for url in tqdm(urls, desc="إجمالي التحميل", unit="صورة"):
    success, message = download_image(url, download_folder)
    if success:
        success_count += 1
    else:
        failed.append(message)

# التقرير النهائي
print("\n" + "="*60)
print("✅ تم الانتهاء من التحميل!")
print(f"   نجح: {success_count} / {len(urls)}")
print(f"   فشل: {len(failed)}")

if failed:
    print("\nاللينكات التي فشل تحميلها:")
    for fail in failed:
        print(f"   • {fail}")

print(f"\nالملفات محفوظة في: {download_folder.resolve()}")
input("\nاضغط Enter للإغلاق...")