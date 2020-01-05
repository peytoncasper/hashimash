#!/bin/sh

sleep 10

# Install unzip
sudo apt-get update
sudo apt-get install -y unzip bind9

sudo cp /tmp/named.conf.options /etc/bind/named.conf.options
sudo mkdir /var/named
sudo mkdir /var/named/dynamic

sudo chown bind /var/named
sudo chown bind /var/named/dynamic

# Install Nomad
curl -o nomad.zip https://releases.hashicorp.com/nomad/0.10.2/nomad_0.10.2_linux_amd64.zip
unzip nomad.zip
sudo mv nomad /usr/local/bin

# Install consul
curl -o consul.zip https://releases.hashicorp.com/consul/1.6.2/consul_1.6.2_linux_amd64.zip
unzip consul.zip
sudo mv consul /usr/local/bin

# Install go
curl -o go.tar.gz https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz
tar -xf go.tar.gz
sudo mv go /usr/local/bin
export GOROOT=/usr/local/bin/go
export GOPATH=$HOME
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Make Nomad config dir
sudo mkdir /etc/nomad
sudo chown packer:packer /etc/nomad

# Make Consul dirs
sudo mkdir /etc/consul.d
sudo mkdir /var/lib/consul

sudo chown packer:packer /etc/consul.d
sudo chown packer:packer /var/lib/consul

# Build sensor binary
cd $HOME/sensor
go build cmd/main.go
sudo mv main /main