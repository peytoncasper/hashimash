# Prerequisites

1. Docker: Packer creates two Docker images that contain the API and Web components
2. Helm: Consul and Vault are installed utilizing Helm charts that are cloned locally


Identify your GCP Project Id

####Export your GCP Project Id
`export GOOGLE_PROJECT_ID=hashimash`

#### Update gcloud to use your GCP Project
`gcloud config set project $GOOGLE_PROJECT_ID`

```
gcloud services enable containerregistry.googleapis.com
gcloud services enable container.googleapis.com
```

####Create a GCP Service Account for Terraform/Packer
```
gcloud iam service-accounts create terraform-packer \
    --display-name "terraform-packer"
```

#### Export service account name 
`export GOOGLE_SERVICE_ACCOUNT=terraform-packer`

#### Add roles to service Account
```
gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/compute.admin

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/compute.instanceAdmin

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/compute.networkAdmin

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/container.admin

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/container.clusterAdmin

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/container.hostServiceAgentUser

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $GOOGLE_PROJECT_ID \
  --member serviceAccount:$GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/storage.objectViewer
```

#### Create Service Account Key
```
gcloud iam service-accounts keys create credentials/credentials.json \
  --iam-account $GOOGLE_SERVICE_ACCOUNT@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com
```

#### Build Packer Artifacts
```
packer build -var "google_project_id=$GOOGLE_PROJECT_ID" packer/api.json
packer build -var "google_project_id=$GOOGLE_PROJECT_ID" packer/web.json
packer build -var "google_project_id=$GOOGLE_PROJECT_ID" packer/sensor.json
```

# Clone with Submodules
This project relies on a modified version of the HashiCorp Consul Helm chart that enables multi-dc WAN connections.
As a result, this is included as a submodule.

`git clone --recurse-submodules https://github.com/peytoncasper/hashimash`

Requirements
1. Install Docker
1. Install Helm

# Create Terraform tfvars file

# Run Terraform
`terraform init terraform`
`terraform apply -var="google_project_id=${GOOGLE_PROJECT_ID}" terraform`
