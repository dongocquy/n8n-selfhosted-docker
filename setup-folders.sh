#!/bin/bash

# Script thiết lập thư mục cho N8N Self-Hosted
# Tác giả: Assistant
# Ngày tạo: $(date)

set -e  # Dừng script nếu có lỗi

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hàm in thông báo
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Hàm kiểm tra thư mục tồn tại
check_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        print_info "Thư mục '$dir' đã tồn tại"
        return 0
    else
        print_info "Thư mục '$dir' chưa tồn tại, sẽ tạo mới"
        return 1
    fi
}

# Hàm kiểm tra quyền thư mục
check_permissions() {
    local dir="$1"
    local expected_owner="$2"
    local expected_group="$3"
    
    if [ ! -d "$dir" ]; then
        print_error "Thư mục '$dir' không tồn tại"
        return 1
    fi
    
    local current_owner=$(stat -f "%Su" "$dir" 2>/dev/null || stat -c "%U" "$dir" 2>/dev/null)
    local current_group=$(stat -f "%Sg" "$dir" 2>/dev/null || stat -c "%G" "$dir" 2>/dev/null)
    
    print_info "Thư mục '$dir': Owner=$current_owner, Group=$current_group"
    
    if [ "$current_owner" = "$expected_owner" ] && [ "$current_group" = "$expected_group" ]; then
        print_success "Quyền thư mục '$dir' đã đúng"
        return 0
    else
        print_warning "Quyền thư mục '$dir' cần cập nhật"
        return 1
    fi
}

# Hàm tạo thư mục với quyền phù hợp
create_directory() {
    local dir="$1"
    local owner="$2"
    local group="$3"
    local permissions="$4"
    
    print_info "Tạo thư mục '$dir' với owner=$owner, group=$group, permissions=$permissions"
    
    # Tạo thư mục nếu chưa có
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "Đã tạo thư mục '$dir'"
    fi
    
    # Cập nhật quyền sở hữu
    if command -v sudo >/dev/null 2>&1; then
        sudo chown -R "$owner:$group" "$dir"
        print_success "Đã cập nhật owner cho '$dir'"
    else
        print_warning "Không có sudo, không thể thay đổi owner"
    fi
    
    # Cập nhật quyền truy cập
    if command -v sudo >/dev/null 2>&1; then
        sudo chmod -R "$permissions" "$dir"
        print_success "Đã cập nhật permissions cho '$dir' (với sudo)"
    else
        chmod -R "$permissions" "$dir" || print_warning "Không thể thay đổi permissions cho '$dir'"
    fi
}

# Hàm kiểm tra Docker
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker không được cài đặt hoặc không có trong PATH"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon không chạy hoặc không có quyền truy cập"
        exit 1
    fi
    
    print_success "Docker đã sẵn sàng"
}

# Hàm kiểm tra Docker Compose
check_docker_compose() {
    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose không được cài đặt"
        exit 1
    fi
    
    print_success "Docker Compose đã sẵn sàng"
}

# Hàm dừng containers nếu đang chạy
stop_containers() {
    print_info "Kiểm tra containers đang chạy..."
    
    if docker ps --format "table {{.Names}}" | grep -q "n8n\|postgres\|redis"; then
        print_warning "Phát hiện containers N8N đang chạy"
        read -p "Bạn có muốn dừng tất cả containers không? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Dừng tất cả containers..."
            docker-compose down || docker compose down
            print_success "Đã dừng tất cả containers"
        else
            print_warning "Giữ nguyên containers, có thể gây xung đột khi mount volumes"
        fi
    else
        print_info "Không có containers N8N nào đang chạy"
    fi
}

# Hàm chính
main() {
    echo "=========================================="
    echo "  SCRIPT THIẾT LẬP THƯ MỤC N8N SELF-HOSTED"
    echo "=========================================="
    echo
    
    # Kiểm tra môi trường
    print_info "Kiểm tra môi trường..."
    check_docker
    check_docker_compose
    
    # Dừng containers nếu cần
    stop_containers
    
    echo
    print_info "Bắt đầu thiết lập thư mục..."
    
    # Định nghĩa các thư mục cần thiết (tương thích với bash cũ)
    directories=(
        "n8n-data:1000:1000:755"
        "postgres-data:999:999:700"
        "redis-data:999:999:755"
        "workflows:1000:1000:755"
    )
    
    # Xử lý từng thư mục
    for dir_info in "${directories[@]}"; do
        IFS=':' read -r dir owner group permissions <<< "$dir_info"
        
        echo
        print_info "Xử lý thư mục: $dir"
        
        # Kiểm tra thư mục hiện tại
        if check_directory "$dir"; then
            # Thư mục đã tồn tại, kiểm tra quyền
            if ! check_permissions "$dir" "$owner" "$group"; then
                # Cập nhật quyền nếu cần
                create_directory "$dir" "$owner" "$group" "$permissions"
            fi
        else
            # Tạo thư mục mới
            create_directory "$dir" "$owner" "$group" "$permissions"
        fi
    done
    
    echo
    print_info "Kiểm tra cuối cùng..."
    
    # Kiểm tra lại tất cả thư mục
    for dir_info in "${directories[@]}"; do
        IFS=':' read -r dir owner group permissions <<< "$dir_info"
        if check_permissions "$dir" "$owner" "$group"; then
            print_success "✓ $dir: OK"
        else
            print_error "✗ $dir: CÓ VẤN ĐỀ"
        fi
    done
    
    echo
    echo "=========================================="
    print_success "HOÀN THÀNH THIẾT LẬP THƯ MỤC!"
    echo "=========================================="
    echo
    print_info "Bây giờ bạn có thể chạy:"
    echo "  docker-compose up -d"
    echo "  hoặc"
    echo "  docker compose up -d"
    echo
    print_info "Dữ liệu sẽ được lưu trong:"
    echo "  - ./n8n-data (dữ liệu N8N)"
    echo "  - ./postgres-data (database PostgreSQL)"
    echo "  - ./redis-data (cache Redis)"
    echo "  - ./workflows (workflows N8N)"
}

# Chạy script
main "$@"
