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