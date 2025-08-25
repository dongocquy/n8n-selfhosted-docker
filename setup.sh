#!/bin/bash

# 🚀 N8N Self-Hosted Docker Setup Script
# Tự động tạo thư mục và cấp quyền trước khi chạy Docker Compose

set -e  # Dừng script nếu có lỗi

echo "🔧 Bắt đầu setup N8N Self-Hosted Docker..."

# Kiểm tra xem có đang chạy với sudo không
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Script cần quyền sudo để cấp quyền thư mục"
    echo "💡 Chạy: sudo ./setup.sh"
    exit 1
fi

# Kiểm tra và tạo thư mục bind mount
echo "📁 Kiểm tra và tạo thư mục data..."

# Kiểm tra n8n-data
if [ -d "n8n-data" ]; then
    echo "   ✅ n8n-data đã tồn tại"
else
    echo "   📁 Tạo thư mục n8n-data..."
    mkdir -p n8n-data
fi

# Kiểm tra postgres-data
if [ -d "postgres-data" ]; then
    echo "   ✅ postgres-data đã tồn tại"
else
    echo "   📁 Tạo thư mục postgres-data..."
    mkdir -p postgres-data
fi

# Kiểm tra workflows
if [ -d "workflows" ]; then
    echo "   ✅ workflows đã tồn tại"
else
    echo "   📁 Tạo thư mục workflows..."
    mkdir -p workflows
fi

echo ""
echo "🔐 Cấp quyền thư mục..."

# Cấp quyền cho n8n-data
echo "   🔐 Cấp quyền n8n-data..."
chown -R 1000:1000 n8n-data
chmod -R 755 n8n-data

# Cấp quyền cho postgres-data
echo "   🔐 Cấp quyền postgres-data..."
chown -R 999:999 postgres-data
chmod -R 755 postgres-data

echo ""
echo "✅ Setup hoàn tất!"
echo ""
echo "📋 Tóm tắt cấu hình:"
echo "   📁 n8n-data: Bind mount (./n8n-data) - Owner: 1000:1000, Quyền: 755"
echo "   📁 postgres-data: Bind mount (./postgres-data) - Owner: 999:999, Quyền: 755"
echo "   📁 redis-data: Named volume (redis-data) - Tự động quản lý bởi Docker"
echo ""
echo "🚀 Bây giờ bạn có thể chạy:"
echo "   docker compose up"
echo ""
echo "📝 Hoặc chạy ở background:"
echo "   docker compose up -d"
