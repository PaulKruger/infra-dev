# infra-dev

To run, run `terraform init`, `terraform plan`, then `terraform apply`

The following code allows you to generate and mantain a VPC, subnet, and firewall rules. A 3-node GKE cluster is deployed on the VPC. Currently, the only services on the cluster are:

- consul cluster
- drone
- tafi-router (unable to register to consul cluster)

Any push in the dev branch of drone should kick off a new image build in google container registry.