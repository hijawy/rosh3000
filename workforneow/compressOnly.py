import os
from pathlib import Path
from tqdm import tqdm
from PIL import Image
from multiprocessing import Pool, cpu_count

# ====================== CONFIGURATION ======================
DOWNLOAD_FOLDER = Path("downlinks")
COMPRESSED_FOLDER = Path("downlinks_compressed")

TARGET_MAX_SIZE_MB = 1.0
TARGET_SIZE_BYTES = int(TARGET_MAX_SIZE_MB * 1024 * 1024)

def compress_single(image_path):
    """ضغط صورة واحدة إلى حوالي 1 ميجا بسرعة"""
    try:
        with Image.open(image_path) as img:
            ratio = 0.78
            new_size = (int(img.width * ratio), int(img.height * ratio))
            resized = img.resize(new_size, Image.BILINEAR)   # أسرع

            out_path = COMPRESSED_FOLDER / image_path.name   # نفس الاسم الأصلي

            if image_path.suffix.lower() in {'.jpg', '.jpeg'}:
                resized.save(out_path, quality=82, optimize=True, progressive=True)
            else:
                resized.save(out_path, optimize=True)

        return True, image_path.name
    except Exception:
        return False, None

def compress_images():
    print("Starting compression of images larger than 1MB...")
    COMPRESSED_FOLDER.mkdir(exist_ok=True)

    # جمع الصور الأكبر من 1 ميجا فقط
    to_compress = [f for f in DOWNLOAD_FOLDER.rglob("*") 
                   if f.suffix.lower() in {'.png', '.jpg', '.jpeg', '.webp'} 
                   and f.stat().st_size > TARGET_SIZE_BYTES]

    if not to_compress:
        print("No images larger than 1MB found.")
        return

    print(f"Found {len(to_compress)} images > 1MB. Starting parallel compression...\n")

    num_workers = max(1, cpu_count() - 1)

    with Pool(processes=num_workers) as pool:
        results = list(tqdm(pool.imap(compress_single, to_compress), 
                           total=len(to_compress), 
                           desc="Compressing"))

    success_count = sum(1 for s, _ in results if s)
    print(f"\n✓ Compression completed: {success_count}/{len(to_compress)} images")
    print(f"   Compressed files saved in: {COMPRESSED_FOLDER.resolve()}\n")

# ====================== MAIN ======================
if __name__ == "__main__":
    print("=" * 70)
    print("          ROSH REVIEW - COMPRESSION SCRIPT")
    print("=" * 70)

    compress_images()

    print("=" * 70)
    print("🎉 Compression process finished!")
    print("=" * 70)

    input("\nPress Enter to exit...")