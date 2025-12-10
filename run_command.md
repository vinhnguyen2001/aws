# Xóa version cũ (nếu có)
sudo rm -f /usr/local/bin/terraform

# Download version mới nhất (1.7.0)
wget https://releases.hashicorp.com/terraform/1.14.0/terraform_1.14.0_linux_amd64.zip

# Unzip
unzip terraform_1.14.0_linux_amd64.zip

# Move vào bin
sudo mv terraform /usr/local/bin/

# Verify
terraform version

# 1. Tải về gói Terraform (ví dụ: phiên bản 1.7.5)
wget https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip

# 2. Giải nén
unzip terraform_1.7.5_linux_amd64.zip

# 3. Di chuyển file thực thi vào thư mục bin của người dùng (nơi Shell có thể tìm thấy)
mv terraform /usr/local/bin/

# 4. Kiểm tra lại phiên bản
terraform version