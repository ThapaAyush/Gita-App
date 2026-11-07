const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// Minimal PNG generator in pure Node.js
function createPNG(width, height, getPixel) {
  const rowSize = 1 + width * 4;
  const rawData = Buffer.alloc(height * rowSize);

  let offset = 0;
  for (let y = 0; y < height; y++) {
    rawData[offset++] = 0; // Filter type: None
    for (let x = 0; x < width; x++) {
      const [r, g, b, a] = getPixel(x, y);
      rawData[offset++] = r;
      rawData[offset++] = g;
      rawData[offset++] = b;
      rawData[offset++] = a;
    }
  }

  const compressed = zlib.deflateSync(rawData);

  function crc32(buf) {
    let crc = -1;
    for (let i = 0; i < buf.length; i++) {
      crc = (crc >>> 8) ^ table[(crc ^ buf[i]) & 0xff];
    }
    return (crc ^ -1) >>> 0;
  }

  const table = new Uint32Array(256);
  for (let i = 0; i < 256; i++) {
    let c = i;
    for (let k = 0; k < 8; k++) {
      c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
    }
    table[i] = c >>> 0;
  }

  function makeChunk(type, data) {
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length, 0);
    const chunkType = Buffer.from(type, 'ascii');
    const crc = Buffer.alloc(4);
    crc.writeUInt32BE(crc32(Buffer.concat([chunkType, data])), 0);
    return Buffer.concat([len, chunkType, data, crc]);
  }

  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 6; // color type: RGBA
  ihdr[10] = 0; // compression
  ihdr[11] = 0; // filter
  ihdr[12] = 0; // interlace

  const ihdrChunk = makeChunk('IHDR', ihdr);
  const idatChunk = makeChunk('IDAT', compressed);
  const iendChunk = makeChunk('IEND', Buffer.alloc(0));

  return Buffer.concat([signature, ihdrChunk, idatChunk, iendChunk]);
}

// Generate Book Cover (400x600) with deep red background #8A1A22 and gold border #D4AF37
const coverPng = createPNG(400, 600, (x, y) => {
  const isBorder = x < 16 || x >= 384 || y < 16 || y >= 584 || 
                  (x >= 24 && x <= 26 && y >= 24 && y <= 576) ||
                  (x >= 373 && x <= 375 && y >= 24 && y <= 576) ||
                  (y >= 24 && y <= 26 && x >= 24 && x <= 376) ||
                  (y >= 573 && y <= 575 && x >= 24 && x <= 376);
  
  if (isBorder) {
    return [212, 175, 55, 255]; // Gold
  }
  
  // Center arch or medallion gradient
  const cx = 200, cy = 300;
  const dist = Math.hypot(x - cx, y - cy);
  if (dist < 120 && dist > 115) {
    return [212, 175, 55, 255]; // Gold circle
  }
  
  // Deep traditional Gita red #8B1A22
  return [139, 26, 34, 255];
});

// Generate App Icon (512x512)
const iconPng = createPNG(512, 512, (x, y) => {
  const isOuterBorder = x < 20 || x >= 492 || y < 20 || y >= 492;
  if (isOuterBorder) {
    return [212, 175, 55, 255]; // Gold
  }
  const cx = 256, cy = 256;
  const dist = Math.hypot(x - cx, y - cy);
  if (dist < 180 && dist > 170) {
    return [212, 175, 55, 255]; // Inner ring
  }
  return [139, 26, 34, 255];
});

const outDir = path.join(__dirname, 'assets', 'images');
fs.mkdirSync(outDir, { recursive: true });

fs.writeFileSync(path.join(outDir, 'bhagavad_gita_cover.png'), coverPng);
fs.writeFileSync(path.join(outDir, 'app_icon_source.png'), iconPng);
console.log('Artwork placeholder assets generated in assets/images/');

