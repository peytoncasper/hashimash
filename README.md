# Clone with Submodules
This project relies on a modified version of the HashiCorp Consul Helm chart that enables multi-dc WAN connections.
As a result, this is included as a submodule.

`git clone --recurse-submodules https://github.com/peytoncasper/hashimash`
# Create Service Account
`gcloud `

# Create Service Account JSON file
```
mkdir credentials/
touch credentials.json
```

Requirements
1. Install Docker
1. Install Helm

`packer build -var 'google_project_id=complexity-inc' packer/api.json`

`packer build -var 'google_project_id=complexity-inc' packer/web.json`

`packer build -var 'google_project_id=complexity-inc' packer/sensor.json`

