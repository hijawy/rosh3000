import os
from pathlib import Path
from PIL import Image

# ====================== SETTINGS ======================
folder_path = Path("downlinks")          # Folder containing the images
max_size_kb = 600                        # Compress only images larger than 600 KB
reduction_ratio = 0.63                   # Reduce dimensions by ~63% (≈60% size reduction)

# Supported image extensions
supported_extensions = {'.png', '.jpg', '.jpeg', '.webp', '.gif'}

print("Scanning images in folder:", folder_path.resolve())
print("=" * 60)

processed = 0
skipped = 0
compressed_count = 0

for file_path in folder_path.rglob("*"):
    if file_path.suffix.lower() not in supported_extensions:
        continue
    
    try:
        size_kb = file_path.stat().st_size / 1024
        
        # Skip small images
        if size_kb <= max_size_kb:
            skipped += 1
            continue
        
        print(f"Processing: {file_path.name} ({size_kb:.1f} KB) → Compressing...")
        
        with Image.open(file_path) as img:
            # Calculate new dimensions while maintaining aspect ratio
            new_width = int(img.width * reduction_ratio)
            new_height = int(img.height * reduction_ratio)
            
            # Resize with high quality
            resized_img = img.resize((new_width, new_height), Image.LANCZOS)
            
            # New filename with _compressed suffix
            new_filename = file_path.stem + "_compressed" + file_path.suffix
            new_file_path = file_path.with_name(new_filename)
            
            # Save with optimal settings
            if file_path.suffix.lower() in {'.jpg', '.jpeg'}:
                resized_img.save(new_file_path, optimize=True, quality=85)
            elif file_path.suffix.lower() == '.png':
                resized_img.save(new_file_path, optimize=True, compress_level=9)
            else:
                resized_img.save(new_file_path, optimize=True)
        
        compressed_count += 1
        processed += 1
        print(f"   ✓ Done: {new_filename}")
        
    except Exception as e:
        print(f"   ✗ Error with {file_path.name}: {e}")

print("\n" + "=" * 60)
print("✅ Process completed!")
print(f"   Images compressed: {compressed_count}")
print(f"   Images skipped (≤ 600 KB): {skipped}")
print(f"   Total images processed: {processed + skipped}")

if compressed_count > 0:
    print(f"\nCompressed files are saved in the same folder with '_compressed' added to the filename.")

input("\nPress Enter to exit...")