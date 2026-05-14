path = '/home/sigma/Desktop/spirit-wolf/Wolfpack/contracts/WolfpackNFT.sol'
with open(path) as f:
    c = f.read()

old = ',BG_CID,'\''/','\'',uint256(bg).toString(),'\''.jpg"'
new = ',BG_CID,'\''/background-'\'',uint256(bg).toString(),'\''.jpg"'

# Simpler approach - just replace the string part
old_simple = "BG_CID,'/',uint256(bg).toString(),'.jpg'"
new_simple = "BG_CID,'/background-',uint256(bg).toString(),'.jpg'"

if old_simple in c:
    c = c.replace(old_simple, new_simple)
    with open(path, 'w') as f:
        f.write(c)
    print('Fixed!')
else:
    print('Trying alternate...')
    print(f'Looking for: {old_simple}')
    if "BG_CID" in c:
        print('BG_CID found in file')
