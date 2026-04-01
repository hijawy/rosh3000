import os
import re
import requests
import concurrent.futures
import time
from pathlib import Path
from tqdm import tqdm
from urllib.parse import urlparse, unquote
from PIL import Image

# ====================== CONFIGURATION ======================
TARGET_FOLDER = Path(r"F:\delete\del\rosh2024Q3000OnlinePart\rosh2024Q3000")

MAX_DOWNLOAD_WORKERS = 20
MAX_SIZE_KB_SKIP = 600          # Files ≤ 600KB will be skipped
TARGET_MAX_SIZE_MB = 1.0        # Target size for large images ≈ 1MB
TARGET_SIZE_BYTES = int(TARGET_MAX_SIZE_MB * 1024 * 1024)

DOWNLOAD_FOLDER = Path("downlinks")
COMPRESSED_FOLDER = Path("downlinks_compressed")

LINK_PATTERN = re.compile(
    r'https://roshreview\.imgix\.net/[^\s"\'<>]*?\.(png|jpg|jpeg|gif|webp)(?=\?|$|["\'\s<>])',
    re.IGNORECASE
)

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
            for chunk in r.iter_content(16384):
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
    print(f"\n✓ Download completed: {success}/{len(urls)} images in 'downlinks' folder\n")

def compress_to_target_size(image_path):
    """Compress image to approximately 1MB if it's larger than 1MB"""
    try:
        with Image.open(image_path) as img:
            # Start with a reasonable reduction ratio
            ratio = 0.85
            quality = 92
            
            out_path = COMPRESSED_FOLDER / image_path.name   # Same original name (no _compressed)

            # Try different ratios and quality until we get close to 1MB
            for attempt in range(8):
                new_size = (int(img.width * ratio), int(img.height * ratio))
                resized = img.resize(new_size, Image.LANCZOS)

                if image_path.suffix.lower() in {'.jpg', '.jpeg'}:
                    resized.save(out_path, quality=quality, optimize=True)
                else:
                    resized.save(out_path, optimize=True)

                current_size = out_path.stat().st_size
                if current_size <= TARGET_SIZE_BYTES * 1.08:   # Allow up to 8% over
                    break
                
                # Reduce more if still too big
                ratio *= 0.92
                quality = max(quality - 8, 45)

        return True, out_path.name
    except Exception:
        return False, None

def compress_images():
    print("Step 3: Compressing images larger than 1MB to ~1MB...")
    COMPRESSED_FOLDER.mkdir(exist_ok=True)

    # Get only images larger than 1MB
    to_compress = [f for f in DOWNLOAD_FOLDER.rglob("*") 
                   if f.suffix.lower() in {'.png','.jpg','.jpeg','.webp'} 
                   and f.stat().st_size > TARGET_SIZE_BYTES]

    if not to_compress:
        print("No images larger than 1MB found to compress.")
        return

    print(f"Found {len(to_compress)} images > 1MB. Starting compression...\n")

    count = 0
    for img in tqdm(to_compress, desc="Compressing"):
        success, name = compress_to_target_size(img)
        if success:
            count += 1

    print(f"\n✓ Compression finished: {count} images compressed to ≈1MB")
    print(f"   Saved in folder: {COMPRESSED_FOLDER.resolve()}\n")

# ====================== MAIN EXECUTION ======================
if __name__ == "__main__":
    print("=" * 85)
    print("          ROSH REVIEW - FULL AUTOMATION SCRIPT")
    print("=" * 85)

    extract_links()
    download_images()

    print("-" * 70)
    answer = input("Do you want to compress images larger than 1MB now? (y/n): ").strip().lower()

    if answer in ['y', 'yes', '1']:
        compress_images()
    else:
        print("Compression skipped by user.")

    print("\n" + "=" * 85)
    print("🎉 ALL PROCESS COMPLETED SUCCESSFULLY!")
    print("   • Links extracted     → link.txt")
    print("   • Images downloaded   → downlinks/")
    print("   • Compressed images   → downlinks_compressed/ (same original names)")
    print("=" * 85)

    input("\nPress Enter to exit...")