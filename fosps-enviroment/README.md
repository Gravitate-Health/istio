# INSTALLATION README

## Docker registry - Arsys

kubectl create secret docker-registry image-pull-secret --docker-server=gravitate-registry.cr.de-fra.ionos.com --docker-username=gravitatecluster --docker-password="TOKEN" -n default

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "image-pull-secret"}]}' -n default


## Kubernetes secret for TLS

Install the cert-manager 

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
