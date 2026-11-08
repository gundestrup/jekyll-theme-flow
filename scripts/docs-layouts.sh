#!/bin/sh
# Layout gallery captures — builds the demo site once per shell
# (sidebar-left, sidebar-right, topnav, bare) and screenshots the
# rendered front page with headless Chrome, then encodes the stills
# into layout-demo.{png,avif,webp} animated variants.
# Build-host tools only.
set -eu
dir="docs/assets"
site="$PWD/_site"
tmp="tmp/layout-config.yml"
chrome="${CHROME_BIN:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
[ -x "$chrome" ] || { echo "Chrome not found (set CHROME_BIN)" >&2; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg not found" >&2; exit 1; }
command -v img2webp >/dev/null 2>&1 || { echo "img2webp not found" >&2; exit 1; }
mkdir -p "$dir" tmp
for variant in sidebar-left sidebar-right topnav bare; do
  # baseurl = absolute _site path so file:// resolves relative_url links.
  printf 'baseurl: "%s"\nflow:\n  layout: %s\n' "$site" "$variant" > "$tmp"
  bundle exec jekyll build --quiet --config _config.yml,"$tmp" --destination "$site"
  if ! "$chrome" --headless=new --disable-gpu --hide-scrollbars \
    --screenshot="$dir/layout-$variant.png" --window-size=1200,800 \
    "file://$site/index.html" >/dev/null 2>&1; then
    echo "Chrome screenshot failed for $variant" >&2
    exit 1
  fi
  echo "wrote $dir/layout-$variant.png"
done

# Animated variants cycling topnav -> sidebar-left -> sidebar-right -> bare.
# ffmpeg concat demuxer keeps the frame order explicit.
cat > "tmp/layout-frames.txt" <<EOF
file '$PWD/$dir/layout-topnav.png'
duration 1
file '$PWD/$dir/layout-sidebar-left.png'
duration 1
file '$PWD/$dir/layout-sidebar-right.png'
duration 1
file '$PWD/$dir/layout-bare.png'
duration 1
file '$PWD/$dir/layout-bare.png'
EOF
cp "$dir/layout-sidebar-left.png" "$dir/layout-demo.png"
if ! ffmpeg -y -f concat -safe 0 -i "tmp/layout-frames.txt" \
  -c:v libsvtav1 -crf 35 -pix_fmt yuv420p "$dir/layout-demo.avif" >/dev/null 2>&1; then
  echo "ffmpeg AVIF encode failed (requires libsvtav1)" >&2
  exit 1
fi
if ! img2webp -loop 0 -d 1000 "$dir/layout-topnav.png" \
  "$dir/layout-sidebar-left.png" "$dir/layout-sidebar-right.png" \
  "$dir/layout-bare.png" -o "$dir/layout-demo.webp" >/dev/null 2>&1; then
  echo "img2webp encode failed" >&2
  exit 1
fi
echo "wrote $dir/layout-demo.{png,avif,webp}"
