import os
import re
import requests
import concurrent.futures
import time
from pathlib import Path
from tqdm import tqdm
from urllib.parse import urlparse, unquote

# ====================== CONFIGURATION ======================
TARGET_FOLDER = Path(r"F:\delete\del\rosh2024Q3000OnlinePart\rosh2024Q3000")

MAX_DOWNLOAD_WORKERS = 20

DOWNLOAD_FOLDER = Path("downlinks")

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
            for chunk in r.iter_content(32768):
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
    print(f"\n✓ Download completed: {success}/{len(urls)} images saved in 'downlinks' folder\n")

# ====================== MAIN ======================
if __name__ == "__main__":
    print("=" * 80)
    print("          ROSH REVIEW - DOWNLOAD SCRIPT")
    print("=" * 80)

    extract_links()
    download_images()

    print("\n" + "=" * 80)
    print("🎉 Download process completed!")
    print("   Files saved in: downlinks/")
    print("   Ready for compression (use compress.py next)")
    print("=" * 80)

    input("\nPress Enter to exit...")