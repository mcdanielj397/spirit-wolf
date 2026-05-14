// Quick fix script for mint page previews
const fs = require('fs');
let c = fs.readFileSync('/home/sigma/Desktop/spirit-wolf/client/public/mint/index.html', 'utf8');

// Add preview canvas and shuffle button after Wolfpack title
c = c.replace(
  '<h2>Wolfpack (ERC-721)</h2>',
  '<h2>Wolfpack (ERC-721)</h2>\n      <div style="width:100%;aspect-ratio:1;border-radius:12px;overflow:hidden;background:#0d1122;border:1px solid var(--border);margin-bottom:1rem;"><canvas id="previewCanvas" style="width:100%;height:100%;"></canvas></div>\n      <button class="btn btn-outline" id="shuffleBtn" style="margin-bottom:1rem;">Shuffle Preview</button>'
);

// Add composite CID and shuffle function
c = c.replace(
  '<script>',
  '<script>\nconst COMPOSITE_CID=\'QmUkUUUhcs89VkqJzZAhP8wnDHzDwehDSbAri8QGHbChvZ\';\nfunction shuffle(){const bg=Math.floor(Math.random()*5);const st=Math.floor(Math.random()*5);const wf=Math.floor(Math.random()*5);const au=Math.floor(Math.random()*5);const combo=bg*125+st*25+wf*5+au;const cv=document.getElementById(\'previewCanvas\');if(!cv)return;const ctx=cv.getContext(\'2d\');const img=new Image();img.crossOrigin=\'anonymous\';img.onload=()=>{cv.width=img.width;cv.height=img.height;ctx.drawImage(img,0,0);};img.src=`https://ipfs.io/ipfs/${COMPOSITE_CID}/${combo}.webp`;}\n'
);

// Add shuffle listener and initial call
c = c.replace(
  "document.getElementById('connectBtn').addEventListener('click',connect);",
  "document.getElementById('connectBtn').addEventListener('click',connect);\nif(document.getElementById('shuffleBtn'))document.getElementById('shuffleBtn').addEventListener('click',shuffle);\nshuffle();"
);

fs.writeFileSync('/home/sigma/Desktop/spirit-wolf/client/public/mint/index.html', c);
console.log('Preview and shuffle added');
