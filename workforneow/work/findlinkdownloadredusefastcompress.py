import os
import re
import requests
import concurrent.futures
import time
from pathlib import Path
from tqdm import tqdm
from urllib.parse import urlparse, unquote
from PIL import Image
from multiprocessing import Pool, cpu_count

# ====================== CONFIGURATION ======================
TARGET_FOLDER = Path(r"F:\delete\del\rosh2024Q3000OnlinePart\rosh2024Q3000")

MAX_DOWNLOAD_WORKERS = 20
MAX_SIZE_KB_SKIP = 600
TARGET_MAX_SIZE_MB = 1.0
TARGET_SIZE_BYTES = int(TARGET_MAX_SIZE_MB * 1024 * 1024)

DOWNLOAD_FOLDER = Path("downlinks")
COMPRESSED_FOLDER = Path("downlinks_compressed")

LINK_PATTERN = re.compile(
    r'https://roshreview\.imgix\.net/[^\s"\'<>]*?\.(png|jpg|jpeg|gif|webp)(?=\?|$|["\'\s<>])',
    re.IGNORECASE
)

# ====================== FUNCTIONS ======================
def extract_links():
    print("Step 1: Extracting links from HTML files...")
    all_links = set()
    for html_file in tqdm(list(TARGET_FOLDER.rglob("*.html")), desc="Scanning HTML"):
        try:
            with open(html_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            for match in LINK_PATTERN.finditer(content):
                all_links.add(match.group(0))
        except:
            pass

    with open('link.txt', 'w', encoding='utf-8') as f:
        for link in sorted(all_links):
            f.write(link + '\n')
    print(f"✓ {len(all_links)} unique links saved to link.txt\n")
    return all_links

def get_clean_filename(url):
    parsed = urlparse(url)
    filename = unquote(os.path.basename(parsed.path))
    filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
    if len(filename) < 8 or '.' not in filename:
        ext = '.png' if 'png' in url.lower() else '.jpg'
        filename = f"image_{int(time.time())}{ext}"
    return filename

def download_single(url):
    try:
        filename = get_clean_filename(url)
        filepath = DOWNLOAD_FOLDER / filename
        counter = 1
        original = filepath.stem
        while filepath.exists():
            filepath = DOWNLOAD_FOLDER / f"{original}_{counter}{filepath.suffix}"
            counter += 1

        r = requests.get(url, stream=True, timeout=30)
        r.raise_for_status()
        with open(filepath, 'wb') as f:
            for chunk in r.iter_content(32768):   # زيادة حجم الـ chunk للسرعة
                if chunk:
                    f.write(chunk)
        return True, filename
    except:
        return False, None

def download_images():
    print("Step 2: Starting fast multithreaded download...")
    DOWNLOAD_FOLDER.mkdir(exist_ok=True)

    if not Path("link.txt").exists():
        print("❌ link.txt not found!")
        return

    with open('link.txt', 'r', encoding='utf-8') as f:
        urls = [line.strip() for line in f if line.strip().startswith('http')]

    print(f"Downloading {len(urls)} images using {MAX_DOWNLOAD_WORKERS} threads...\n")

    with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_DOWNLOAD_WORKERS) as executor:
        results = list(tqdm(executor.map(download_single, urls), total=len(urls), desc="Downloading"))

    success = sum(1 for s, _ in results if s)
    print(f"\n✓ Download completed: {success}/{len(urls)} images\n")

def compress_single(image_path):
    """ضغط صورة واحدة إلى حوالي 1MB بسرعة أعلى"""
    try:
        with Image.open(image_path) as img:
            # نسبة تصغير أكثر توازناً وسرعة
            ratio = 0.78
            new_size = (int(img.width * ratio), int(img.height * ratio))
            resized = img.resize(new_size, Image.BILINEAR)   # BILINEAR أسرع من LANCZOS

            out_path = COMPRESSED_FOLDER / image_path.name

            if image_path.suffix.lower() in {'.jpg', '.jpeg'}:
                resized.save(out_path, quality=82, optimize=True, progressive=True)
            else:
                resized.save(out_path, optimize=True)

        return True, image_path.name
    except Exception:
        return False, None

def compress_images():
    print("Step 3: Compressing images larger than 1MB (using multiprocessing)...")
    COMPRESSED_FOLDER.mkdir(exist_ok=True)

    to_compress = [f for f in DOWNLOAD_FOLDER.rglob("*") 
                   if f.suffix.lower() in {'.png','.jpg','.jpeg','.webp'} 
                   and f.stat().st_size > TARGET_SIZE_BYTES]

    if not to_compress:
        print("No images larger than 1MB found.")
        return

    print(f"Found {len(to_compress)} images > 1MB. Starting parallel compression...\n")

    # استخدام multiprocessing للاستفادة من كل النوى
    num_workers = max(1, cpu_count() - 1)   # اترك نواة واحدة للنظام

    with Pool(processes=num_workers) as pool:
        results = list(tqdm(pool.imap(compress_single, to_compress), 
                           total=len(to_compress), 
                           desc="Compressing"))

    success_count = sum(1 for s, _ in results if s)
    print(f"\n✓ Compression finished: {success_count}/{len(to_compress)} images compressed to ≈1MB")
    print(f"   Saved in: {COMPRESSED_FOLDER.resolve()}\n")

# ====================== MAIN ======================
if __name__ == "__main__":
    print("=" * 85)
    print("          ROSH REVIEW - FULL AUTOMATION SCRIPT (Faster Version)")
    print("=" * 85)

    extract_links()
    download_images()

    print("-" * 70)
    answer = input("Do you want to compress images larger than 1MB now? (y/n): ").strip().lower()

    if answer in ['y', 'yes', '1']:
        compress_images()
    else:
        print("Compression skipped.")

    print("\n" + "=" * 85)
    print("🎉 ALL DONE!")
    print("   • Downloads  → downlinks/")
    print("   • Compressed → downlinks_compressed/ (same original names)")
    print("=" * 85)

    input("\nPress Enter to exit...")