# GoMandap Web Brand Assets

## Files

| File | Purpose |
|------|---------|
| `logo.svg` | GoMandap icon — stylized mandap silhouette integrated with "G", Champagne Gold strokes on transparent background (48×48 viewBox, 2.5px stroke) |
| `logo-full.svg` | Full wordmark — icon + "GoMandap" text |
| `favicon.svg` | Simplified icon for browser favicon (Royal Navy circle with gold G) |
| `manifest.json` | PWA manifest snippet with icon references and theme colors |

## Design Tokens

- **Champagne Gold:** `#DFBA73`
- **Royal Navy:** `#0F172A`
- **Font:** Outfit (bold, 700 weight for wordmark)

## PNG Export Instructions

PNG icons at 16px, 32px, 180px, and 512px must be generated from the SVG source files. Use one of the following tools:

### Option 1: Using `sharp` (Node.js)

```bash
npm install sharp
```

```js
const sharp = require('sharp');

const sizes = [16, 32, 180, 512];
const input = './favicon.svg';

for (const size of sizes) {
  sharp(input)
    .resize(size, size)
    .png()
    .toFile(`./icons/icon-${size}x${size}.png`)
    .then(() => console.log(`Generated icon-${size}x${size}.png`))
    .catch(err => console.error(err));
}
```

### Option 2: Using `svgexport` (CLI)

```bash
npm install -g svgexport
```

```bash
svgexport favicon.svg icons/icon-16x16.png 16:16
svgexport favicon.svg icons/icon-32x32.png 32:32
svgexport favicon.svg icons/apple-touch-icon-180x180.png 180:180
svgexport favicon.svg icons/icon-512x512.png 512:512
```

### Option 3: Using `@resvg/resvg-js` (high-quality rendering)

```bash
npm install @resvg/resvg-js
```

```js
const { Resvg } = require('@resvg/resvg-js');
const fs = require('fs');

const svg = fs.readFileSync('./favicon.svg', 'utf-8');
const sizes = [16, 32, 180, 512];

for (const size of sizes) {
  const resvg = new Resvg(svg, {
    fitTo: { mode: 'width', value: size }
  });
  const pngData = resvg.render();
  const pngBuffer = pngData.asPng();
  fs.writeFileSync(`./icons/icon-${size}x${size}.png`, pngBuffer);
  console.log(`Generated icon-${size}x${size}.png`);
}
```

## Notes

- The SVG source files are the single source of truth for all icon sizes.
- PNG exports should be regenerated whenever the SVG source is updated.
- The `favicon.svg` (with Royal Navy background) is used for PNG icon generation since favicons and PWA icons need a solid background for visibility.
- The `logo.svg` (transparent background) is used for inline display within the app UI.
- All assets use identical source artwork across web and native Android platforms.
- The Android VectorDrawable source is located at: `android/common/src/main/res/drawable/ic_gomandap_logo.xml`
