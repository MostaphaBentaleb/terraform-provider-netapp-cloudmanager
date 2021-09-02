
terraform {
  required_providers {
    netapp-cloudmanager = {
      source = "NetApp/netapp-cloudmanager"
      version = "20.10.0"
    }
  }
}

# Specify CVO resources

resource "netapp-cloudmanager_connector_aws" "cm-aws" {
  provider = netapp-cloudmanager
  name = "TerraformnAWS"
  region = "us-west-2"
  company = "NetApp"
  key_name = "key1"
  subnet_id = "subnet-xxxxxxxx"
  security_group_id = "sg-xxxxxxxx"
  iam_instance_profile_name = "OCCM"
  account_id = "account-xxxxxxx"
}

# Specify CVO resources

resource "netapp-cloudmanager_cvo_aws" "cvo-aws" {
  provider = netapp-cloudmanager
  name = "TerraformCVO1"
  region = "us-west-2"
  subnet_id = "subnet-xxxxxxx"
  vpc_id = "vpc-xxxxxxxx"
  aws_tag {
              tag_key = "abcd"
              tag_value = "ABCD"
            }
  aws_tag {
              tag_key = "xxx"
              tag_value = "YYY"
            }
  svm_password = "********"
  client_id = netapp-cloudmanager_connector_aws.cm-aws.client_id 
}

resource "netapp-cloudmanager_aggregate" "cvo-aggregate" {
  provider = netapp-cloudmanager
  name = "aggr2"
  working_environment_id = netapp-cloudmanager_cvo_aws.cvo-aws.id 
  client_id = netapp-cloudmanager_connector_aws.cm-aws.client_id
  number_of_disks = 1
  disk_size_size = 100
  disk_size_unit = "GB"
}

resource "netapp-cloudmanager_cifs_server" "cvo-cifs-workgroup" {
   depends_on = [netapp-cloudmanager_aggregate.cvo-aggregate]
   provider = netapp-cloudmanager
   server_name = "server"
   workgroup_name  = "workgroup"
   client_id = netapp-cloudmanager_connector_aws.cm-aws.client_id 
   working_environment_name = "TerraformCVO1"
   is_workgroup = true
}

resource "netapp-cloudmanager_volume" "cifs-volume-1" {
  depends_on = [netapp-cloudmanager_cifs_server.cvo-cifs-workgroup]
  provider = netapp-cloudmanager
  name = "cifs_test_vol_1"
  volume_protocol = "cifs"
  provider_volume_type = "gp2"
  size = 10
  unit = "GB"
  share_name = "share_cifs"
  permission = "full_control"
  users = ["Everyone"]
  working_environment_name = "TerraformCVO1"
  client_id = netapp-cloudmanager_connector_aws.cm-aws.client_id 
  capacity_tier= "S3"
  tiering_policy = "auto"
}

resource "netapp-cloudmanager_aws_fsx" "cl-fsx-aws" {
  provider = netapp-cloudmanager
  name = "fsxTest"
  region = "us-east-2"
  workspace_id = "workspace-abaaFgcQ"
  tenant_id = "account-j3aZttuL"
  storage_capacity_size = 1024
  storage_capacity_size_unit = "GiB"
  aws_credentials_name = "tomerCred"
  primary_subnet_id = "subnet-123456"
  secondary_subnet_id = "subnet-56789"
  throughput_capacity = 512
  fsx_admin_password = "Netapp234"
}