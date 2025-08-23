# N8N Self-Hosted với Cloudflare Tunnel

Dự án này cài đặt N8N trên server với Cloudflare Tunnel để truy cập an toàn qua domain `your-domain.com`.

## 🚀 **QUICK START - Khởi tạo hệ thống trong 5 phút**

### **Bước 1: Kiểm tra và chuẩn bị môi trường**
```bash
# Đảm bảo đã cài Docker và Docker Compose
docker --version
docker-compose --version

# Clone repository (nếu chưa có)
git clone <your-repo>
cd n8n-seflhost-docker
```

### **Bước 2: Thiết lập Cloudflare Tunnel**
1. **Đăng nhập** [Cloudflare Dashboard](https://dash.cloudflare.com)
2. **Vào Zero Trust** → **Networks** → **Tunnels**
3. **Click "Create a tunnel"**
4. **Đặt tên**: `your-tunnel-name`
5. **Thêm Public Hostname**:
   - Subdomain: `your-subdomain`
   - Domain: `your-domain.com`
   - Service: `http://n8n:5678`
6. **Copy tunnel token** và ghi nhớ domain

### **Bước 3: Tạo file cấu hình**
```bash
# Copy template cấu hình
cp env.example .env

# Chỉnh sửa file .env với thông tin đã có
nano .env
```

**Điền thông tin từ bước 2:**
```bash
# 1. Token từ Cloudflare (đã copy ở bước 2)
CLOUDFLARE_TUNNEL_TOKEN=your_tunnel_token_here

# 2. Domain của bạn (đã tạo ở bước 2)
N8N_HOST=https://your-subdomain.your-domain.com
```

### **Bước 4: Khởi động hệ thống**
```bash
# Chạy một lệnh duy nhất
docker-compose up -d

# Đợi tất cả services khởi động (khoảng 2-3 phút)
docker-compose ps
```

### **Bước 5: Kiểm tra hoạt động**
```bash
# Xem trạng thái services
docker-compose ps

# Xem logs nếu có lỗi
docker-compose logs -f

# Truy cập N8N qua domain của bạn
# https://your-subdomain.your-domain.com
```

## 📋 Yêu cầu hệ thống

- Docker và Docker Compose
- Domain được quản lý bởi Cloudflare
- Ít nhất 4GB RAM
- 20GB disk space
- CPU: 2 cores trở lên



### **🚨 Troubleshooting nhanh**
```bash
# Nếu services không start
docker-compose down
docker-compose up -d

# Nếu có lỗi permission
sudo chown -R $USER:$USER .

# Nếu có lỗi port
sudo lsof -i :5678
sudo kill -9 <PID>

# Kiểm tra Docker daemon
sudo systemctl status docker
```

### **🔑 Thông tin đăng nhập mặc định**
```
URL: https://your-subdomain.your-domain.com
```

---

## 📋 **Quản lý cơ bản**

### 🔧 **Lệnh cần thiết**
```bash
# Xem trạng thái services
docker-compose ps

# Xem logs nếu có lỗi
docker-compose logs -f

# Restart toàn bộ stack
docker-compose restart

# Dừng stack
docker-compose down
```
## 🔧 **Quản lý nâng cao**

### **Scaling Workers (tùy chọn)**
```bash
# Tăng số worker (ví dụ: 3 workers)
docker-compose up -d --scale n8n-worker=3

# Giảm về 1 worker
docker-compose up -d --scale n8n-worker=1
```

## 🔒 **Bảo mật**

- **Cloudflare Tunnel**: Tất cả traffic từ internet đi qua tunnel an toàn
- **Database isolation**: PostgreSQL chỉ accessible trong Docker network
- **SSL tự động**: Cloudflare xử lý SSL/TLS
- **Authentication**: Basic auth được kích hoạt

### **Xem logs**
```bash
# Xem logs tất cả services
docker-compose logs -f

# Xem logs service cụ thể
docker-compose logs -f n8n
```

## 🚀 **Tính năng nâng cao**

### **Worker System**
- **Main Process**: Xử lý UI, API, và quản lý workflows
- **Worker Processes**: Chuyên xử lý workflow execution
- **Hỗ trợ nhiều người dùng**: Có thể xử lý nhiều workflow cùng lúc
- **Scaling**: Có thể tăng số worker khi cần

## 🚨 **Xử lý lỗi thường gặp**

### **N8N không khởi động**
```bash
# Kiểm tra logs
docker-compose logs n8n

# Restart toàn bộ stack
docker-compose restart
```

### **Tunnel không hoạt động**
```bash
# Kiểm tra tunnel logs
docker-compose logs cloudflared

# Restart tunnel
docker-compose restart cloudflared
```

## ⚠️ **Lưu ý quan trọng**

- **Các mật khẩu đã được cấu hình sẵn** trong docker-compose.yml, thay đổi nếu bạn muốn.
- **Chỉ cần thiết lập 2 biến**: CLOUDFLARE_TUNNEL_TOKEN và N8N_HOST
- **Cloudflare tự động thiết lập DNS và SSL** khi tạo hostname

## 📞 **Hỗ trợ**

Nếu gặp vấn đề, hãy kiểm tra:
1. Logs của containers: `docker-compose logs -f`
2. Trạng thái Cloudflare Tunnel
3. Tunnel token trong file `.env`
