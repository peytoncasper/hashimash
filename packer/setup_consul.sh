# Install Unzip Dependency
sudo apt-get install unzip

# Download and Unzip Consul
wget https://releases.hashicorp.com/consul/1.6.2/consul_1.6.2_linux_amd64.zip
unzip consul_1.6.2_linux_amd64.zip

# Move consul binary into path
sudo mv consul /usr/local/bin

# Create Data Directories
sudo mkdir /etc/consul.d
sudo mkdir /var/lib/consul