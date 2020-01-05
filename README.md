
Requirements
1. Install Docker
1. Install Helm

`packer build -var 'google_project_id=complexity-inc' packer/api.json`

`packer build -var 'google_project_id=complexity-inc' packer/web.json`

`packer build -var 'google_project_id=complexity-inc' packer/sensor.json`

