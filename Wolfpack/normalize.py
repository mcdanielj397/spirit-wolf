#!/usr/bin/env python3
"""
Wolfpack Layer Normalizer
Resizes all layer files to 2048x2048 for on-chain random generation.
Outputs clean layers to Wolfpack/layers/ organized by trait.
"""

import os
from PIL import Image

WOLFPACK = '/home/sigma/Desktop/spirit-wolf/Wolfpack'
LAYERS_OUT = os.path.join(WOLFPACK, 'layers')
TARGET = (2048, 2048)

# Input -> Output directories
traits = {
    'background': {'in': 'background-*.jpg', 'out': 'Background'},
    'stone':      {'in': 'stone-*.png',      'out': 'Stone'},
    'base':       {'in': 'base-*.png',       'out': 'Wolf'},
    'aura':       {'in': 'aura-*.png',       'out': 'Aura'},
}

import glob

for trait, paths in traits.items():
    out_dir = os.path.join(LAYERS_OUT, paths['out'])
    os.makedirs(out_dir, exist_ok=True)
    
    files = sorted(glob.glob(os.path.join(WOLFPACK, paths['in'])))
    print(f"\n{trait}: {len(files)} files")
    
    for f in files:
        img = Image.open(f).convert('RGBA')
        
        # Resize to target using center crop (no stretching)
        ratio = img.width / img.height
        if ratio > 1:  # wider than tall
            nh = TARGET[1]
            nw = int(img.width * (nh / img.height))
        else:  # taller than wide or square
            nw = TARGET[0]
            nh = int(img.height * (nw / img.width))
        
        img = img.resize((nw, nh), Image.LANCZOS)
        left = (img.width - TARGET[0]) // 2
        top = (img.height - TARGET[1]) // 2
        img = img.crop((left, top, left + TARGET[0], top + TARGET[1]))
        
        # Save as PNG preserving transparency
        name = os.path.basename(f)
        out_path = os.path.join(out_dir, name)
        img.save(out_path, 'PNG')
        print(f"  {name} -> {out_dir}/{name}")

print(f"\nDone! Normalized layers in {LAYERS_OUT}")
print("Ready for IPFS upload and contract mint logic.")
