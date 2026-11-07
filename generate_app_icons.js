const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

function createIconPNG(size) {
  const rowSize = 1 + size * 4;
  const rawData = Buffer.alloc(size * rowSize);

  let offset = 0;
  for (let y = 0; y < size; y++) {
    rawData[offset++] = 0;
    for (let x = 0; x < size; x++) {
      const isBorder = x < Math.max(2, size * 0.04) || x >= size - Math.max(2, size * 0.04) ||
                       y < Math.max(2, size * 0.04) || y >= size - Math.max(2, size * 0.04);
      if (isBorder) {
        rawData[offset++] = 212; // Gold
        rawData[offset++] = 175;
        rawData[offset++] = 55;
        rawData[offset++] = 255;
      } else {
        const cx = size / 2, cy = size / 2;
        const dist = Math.hypot(x - cx, y - cy);
        const radius = size * 0.35;
        if (Math.abs(dist - radius) < Math.max(1.5, size * 0.025)) {
          rawData[offset++] = 212; // Inner gold ring
          rawData[offset++] = 175;
          rawData[offset++] = 55;
          rawData[offset++] = 255;
        } else {
          // Deep traditional Gita red #8B1A22
          rawData[offset++] = 139;
          rawData[offset++] = 26;
          rawData[offset++] = 34;
          rawData[offset++] = 255;
        }
      }
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
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;

  return Buffer.concat([
    signature,
    makeChunk('IHDR', ihdr),
    makeChunk('IDAT', compressed),
    makeChunk('IEND', Buffer.alloc(0))
  ]);
}

// Android Mipmaps
const androidSizes = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

const resDir = path.join(__dirname, 'android', 'app', 'src', 'main', 'res');
for (const [folder, size] of Object.entries(androidSizes)) {
  const dir = path.join(resDir, folder);
  if (fs.existsSync(dir)) {
    fs.writeFileSync(path.join(dir, 'ic_launcher.png'), createIconPNG(size));
  }
}

// iOS AppIcon
const iosIconPath = path.join(__dirname, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset', 'Icon-App-1024x1024@1x.png');
if (fs.existsSync(path.dirname(iosIconPath))) {
  fs.writeFileSync(iosIconPath, createIconPNG(1024));
}

console.log('Successfully generated launcher icon assets for Android and iOS.');

