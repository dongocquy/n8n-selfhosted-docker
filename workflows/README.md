# 📁 Workflows Directory

## 🚀 **Cách sử dụng:**

### **1. Import Workflow Tự Động**
- Đặt các file `.json` workflow vào thư mục này
- N8N sẽ tự động import khi khởi động
- Workflows sẽ xuất hiện trong N8N UI

### **2. Cấu trúc File**
```json
{
  "name": "Tên Workflow",
  "nodes": [...],
  "connections": {...},
  "active": false,
  "settings": {},
  "versionId": "1"
}
```

### **3. Lưu ý**
- File phải có đuôi `.json`
- Workflow sẽ được import với trạng thái `inactive`
- Có thể kích hoạt workflow sau khi import
- Thư mục này được mount read-only vào container

### **4. Export Workflow từ N8N**
1. Vào N8N UI
2. Chọn workflow cần export
3. Click "Export" → "Download JSON"
4. Lưu file vào thư mục này để backup

### **5. Backup Workflows**
- Thư mục này được backup cùng với code
- Workflows sẽ được restore khi deploy lại
- Không cần lo lắng mất workflows khi restart
