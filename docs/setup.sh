#!/bin/bash
# RustDesk 一键配置脚本 - 服务器: hhc.gqru.com
# 适用于 Linux / macOS

set -e

echo "============================================"
echo "  RustDesk 一键配置脚本"
echo "  服务器: hhc.gqru.com"
echo "  固定密码: kulacc123Q"
echo "============================================"
echo ""

# 1. 停止 RustDesk
echo "[1/5] 停止 RustDesk..."
pkill -f rustdesk 2>/dev/null || true
sleep 2

# 2. 配置目录
echo "[2/5] 准备配置目录..."
RUSTDESK_DIR="${HOME}/.config/rustdesk"
mkdir -p "$RUSTDESK_DIR"

# 3. 写入服务器配置
echo "[3/5] 写入 ID服务器、中继、Key、API 配置..."
cat > "$RUSTDESK_DIR/RustDesk2.toml" << 'CONFIG'
rendezvous_server = 'hhc.gqru.com:21116'
nat_type = 0
serial = 0

[options]
allow-remote-config-modification = 'Y'
custom-rendezvous-server = 'hhc.gqru.com'
relay-server = 'hhc.gqru.com'
key = 'LEdIKvbiBTLZIdeWDLtE8mYyvO07+sY4EFypb9a0NgA='
api-server = 'http://hhc.gqru.com:8585'
direct-server = 'Y'
CONFIG

# 4. 计算密码 hash 并写入
echo "[4/5] 计算并写入固定密码（kulacc123Q）..."
SALT=$(cat /dev/urandom | env LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c 12)
PASSWORD="kulacc123Q"
HASH=$(echo -n "${PASSWORD}${SALT}" | sha256sum | cut -d' ' -f1)
B64=$(echo -n "$HASH" | xxd -r -p | base64 | tr -d '\n')
PASS_FIELD="00${B64}"

cat > "$RUSTDESK_DIR/RustDesk.toml" << CONFIGEOF
password = '${PASS_FIELD}'
salt = '${SALT}'
CONFIGEOF

# 5. 完成
echo "[5/5] 配置完成！"
echo ""
echo "  ✅ 服务器: hhc.gqru.com"
echo "  ✅ 密钥: LEdIKvbiBTLZIdeWDLtE8mYyvO07+sY4EFypb9a0NgA="
echo "  ✅ API: http://hhc.gqru.com:8585"
echo "  ✅ 中继: hhc.gqru.com"
echo "  ✅ 远程配置修改: 已允许"
echo "  ✅ 固定密码: kulacc123Q（已写入）"
echo ""
echo "============================================"
echo "  启动 RustDesk 即可使用"
echo "============================================"

# macOS 路径
if [ -d "/Applications/RustDesk.app" ]; then
    echo "启动 RustDesk..."
    open -a RustDesk
elif command -v rustdesk &>/dev/null; then
    echo "启动 rustdesk..."
    rustdesk &
fi
