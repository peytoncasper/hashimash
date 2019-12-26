output "azure_consul_ip" {
	value = azurerm_public_ip.consul.ip_address
	depends_on = [
		azurerm_public_ip.consul
	]
}