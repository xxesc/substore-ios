#!/bin/sh
# sign.sh <unsigned.ipa> — 用 rcodesign + 本机 PEM 签 SubStore.app
set -eu
ROOT=/var/minis/workspace/substore-ios
P12DIR="/var/minis/mounts/com~apple~CloudDocs/Downloads/证书_00008110-000155EA0E85401E 2"
PEM=/root/.cdtk/sign/cdtk.pem
ENTS=$ROOT/sign/ents.plist
PROV="$P12DIR/描述文件.mobileprovision"
IPA="$1"
OUT=$ROOT/build/signed
WORK=$ROOT/build/work

[ -f "$IPA" ] || { echo "IPA 不存在: $IPA"; exit 1; }
[ -f "$PEM" ] || { echo "PEM 不存在"; exit 1; }
[ -f "$PROV" ] || { echo "描述文件不存在"; exit 1; }

rm -rf "$WORK" "$OUT"
mkdir -p "$WORK" "$OUT"
cd "$WORK"
unzip -q -o "$IPA"
APP=$(find . -maxdepth 2 -name "*.app" -type d | head -1)
[ -n "$APP" ] || { echo "未找到 .app"; exit 1; }

cp "$PROV" "$APP/embedded.mobileprovision"
rcodesign sign \
  --pem-file "$PEM" \
  --entitlements-xml-file "$ENTS" \
  --code-signature-flags runtime \
  "$APP"

cd "$WORK"
rm -f "$OUT/SubStore-signed.ipa"
zip -qry "$OUT/SubStore-signed.ipa" "$(basename "$APP")"
ls -lh "$OUT/SubStore-signed.ipa"
echo "SIGNED_OK"
