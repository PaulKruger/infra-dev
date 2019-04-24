# infra-dev

To run, run `terraform init`, `terraform plan`, then `terraform apply`

The following code allows you to generate and mantain a VPC, subnet, and firewall rules. A 3-node GKE cluster is deployed on the VPC. Currently, the only services on the cluster are:

- consul cluster
- drone
- tafi-router (unable to register to consul cluster)

Any push in the dev branch of drone should kick off a new image build in google container registry.

## tafi router ingress
 
Applies ingress
`kubectl apply -f tafi-router/router-ingress.yaml`

Check status of ingress/view ip address
`kubectl get ingress -w` 

## ssl generation

Creates Google Managed Cert (packed by LetsEncrypt)
`gcloud beta compute ssl-certificates create "api-dev-cert" --domains api-dev.tafi.io`

Get existing URL Maps
`gcloud compute url-maps list`

Create HTTPS Target Proxy
`gcloud compute target-https-proxies create https-target --url-map=k8s-um-default-tafi-router-ingress--9da4e3799696cc88 --ssl-certificates=api-dev-cert`

Create Global Static IP Address
`gcloud compute addresses create static-https-ip --global --ip-version IPV4`

Create Global Forwarding Rule linking newly created IP Address
`gcloud compute forwarding-rules create https-global-forwarding-rule --global --ip-protocol=TCP --ports=443 --target-https-proxy=https-target --address static-https-ip`

Manually add the following to the tafi-router-service/metadata through GCP console, terraform doesn't support internal Kubernetes annotation
```
annotations:
#    ingress.kubernetes.io/target-proxy: https-target
"ingress.kubernetes.io/target-proxy" = "https-target"
```

`gcloud compute addresses list`
`gcloud beta compute ssl-certificates list`

## velero backups and restore 

tafi uses velero to back up our kubernetes cluster (instances, services and persistent volumes)

### backups

velero is currently set to run daily backups, to manually create a backup point, run the following command (gcloud and kubectl has to be properly configured, see velero getting started guide):
`velero backup create tafi-dev-backup --include-namespaces default`

### restore
to simulate a disaster:
`kubectl delete --all daemonsets,replicasets,services,deployments,pods,rc,persistentvolumes,persistentvolumeclaims,secrets,statefulsets --namespace=default`

to restore from backup, run the following command:
`velero restore create --from-backup tafi-dev-backup`

[1] https://heptio.github.io/velero/master/get-started