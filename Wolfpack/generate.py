#!/usr/bin/env python3
"""
Wolfpack NFT Generator — Final
Pre-renders all 625 combinations at 1024x1024 WebP (~150KB each)
Outputs to Wolfpack/output/ ready for IPFS upload.
"""

import os, json
from PIL import Image

WOLFPACK = '/home/sigma/Desktop/spirit-wolf/Wolfpack'
OUTPUT = os.path.join(WOLFPACK, 'output')
IMAGES_OUT = os.path.join(OUTPUT, 'images')
META_OUT = os.path.join(OUTPUT, 'metadata')

os.makedirs(IMAGES_OUT, exist_ok=True)
os.makedirs(META_OUT, exist_ok=True)

# Collect layers
bases = sorted([f for f in os.listdir(WOLFPACK) if f.startswith('base-') and f.endswith('.png')])
backgrounds = sorted([f for f in os.listdir(WOLFPACK) if f.startswith('background-') and f.endswith('.jpg')])
stones = sorted([f for f in os.listdir(WOLFPACK) if f.startswith('stone-') and f.endswith('.png')])
auras = sorted([f for f in os.listdir(WOLFPACK) if f.startswith('aura-') and f.endswith('.png')])

print(f"Bases: {len(bases)}")
print(f"Backgrounds: {len(backgrounds)}")
print(f"Stones: {len(stones)}")
print(f"Auras: {len(auras)}")
print(f"Total: {len(bases)*len(backgrounds)*len(stones)*len(auras)} combinations")

TARGET = (1024, 1024)
token_id = 0

for bg_idx, bg_file in enumerate(backgrounds):
    bg_path = os.path.join(WOLFPACK, bg_file)
    bg_img = Image.open(bg_path).convert('RGBA')
    bg_ratio = bg_img.width / bg_img.height
    if bg_ratio > 1:
        nh, nw = TARGET[1], int(bg_img.width * (TARGET[1] / bg_img.height))
    else:
        nw, nh = TARGET[0], int(bg_img.height * (TARGET[0] / bg_img.width))
    bg_img = bg_img.resize((nw, nh), Image.LANCZOS)
    left = (bg_img.width - TARGET[0]) // 2
    top = (bg_img.height - TARGET[1]) // 2
    bg_img = bg_img.crop((left, top, left + TARGET[0], top + TARGET[1]))
    
    for stone_idx, stone_file in enumerate(stones):
        stone_img = Image.open(os.path.join(WOLFPACK, stone_file)).convert('RGBA').resize(TARGET, Image.LANCZOS)
        
        for base_idx, base_file in enumerate(bases):
            base_img = Image.open(os.path.join(WOLFPACK, base_file)).convert('RGBA').resize(TARGET, Image.LANCZOS)
            
            for aura_idx, aura_file in enumerate(auras):
                aura_img = Image.open(os.path.join(WOLFPACK, aura_file)).convert('RGBA').resize(TARGET, Image.LANCZOS)
                
                # Composite: background -> stone -> aura -> wolf (aura behind wolf)
                final = bg_img.copy()
                final = Image.alpha_composite(final, stone_img)
                final = Image.alpha_composite(final, aura_img)
                final = Image.alpha_composite(final, base_img)
                
                image_name = f"{token_id}.webp"
                final.convert('RGB').save(os.path.join(IMAGES_OUT, image_name), 'WEBP', quality=80)
                
                meta = {
                    "name": f"Wolfpack #{token_id}",
                    "description": "A unique wolf from the Wolfpack collection by WolfMan.",
                    "image": f"ipfs://CID/{image_name}",
                    "external_url": "https://spiritwolf3397.github.io/spirit-wolf/mint",
                    "artist": "WolfMan",
                    "partner": "Alsania I/O — alsania-io.com",
                    "license": "https://spiritwolf3397.github.io/spirit-wolf/license",
                    "attributes": [
                        {"trait_type": "Background", "value": f"Scene {bg_idx}"},
                        {"trait_type": "Stone", "value": f"Stone {stone_idx}"},
                        {"trait_type": "Wolf", "value": f"Wolf {base_idx}"},
                        {"trait_type": "Aura", "value": f"Aura {aura_idx}"}
                    ]
                }
                with open(os.path.join(META_OUT, f"{token_id}.json"), 'w') as f:
                    json.dump(meta, f, indent=2)
                
                token_id += 1
                if token_id % 100 == 0:
                    print(f"  {token_id}/625...")

print(f"\nDone! {token_id} images generated.")
print(f"Images: {IMAGES_OUT} ({token_id} WebP files)")
print(f"Metadata: {META_OUT} ({token_id} JSON files)")

# Check total size
import subprocess
result = subprocess.run(['du', '-sh', IMAGES_OUT], capture_output=True, text=True)
print(f"Total image size: {result.stdout.split()[0]}")
