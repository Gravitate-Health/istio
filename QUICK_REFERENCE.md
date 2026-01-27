# Istio Gravitate Health - Quick Reference

Quick reference for common Helm operations with the Istio Gravitate Health chart.

## Installation

### From OCI Registry (Recommended)

```bash
# Default installation
helm install istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth --version 0.1.0

# With custom domain
helm install istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth \
  --version 0.1.0 \
  --set gateway.hosts[0]=myapp.example.com \
  --set certManager.clusterIssuer.email=admin@example.com

# IP-based (no DNS)
helm install istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth \
  --version 0.1.0 \
  --set gateway.useIP=true \
  --set certManager.enabled=false
```

### From Local Chart

```bash
# Default
helm install istio-gh ./charts/istio-gravitatehealth

# With values file
helm install istio-gh ./charts/istio-gravitatehealth -f my-values.yaml
```

## Management

```bash
# List releases
helm list

# Get status
helm status istio-gh

# Get values
helm get values istio-gh

# Get all info
helm get all istio-gh
```

## Upgrade

```bash
# Upgrade to new version
helm upgrade istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth --version 0.2.0

# Change a value
helm upgrade istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth \
  --version 0.1.0 \
  --set gateway.hosts[0]=newdomain.com \
  --reuse-values

# Upgrade with new values file
helm upgrade istio-gh ./charts/istio-gravitatehealth -f updated-values.yaml
```

## Rollback

```bash
# Rollback to previous
helm rollback istio-gh

# Rollback to specific revision
helm history istio-gh
helm rollback istio-gh 2
```

## Uninstall

```bash
# Uninstall release
helm uninstall istio-gh

# With cleanup
helm uninstall istio-gh --wait
kubectl delete crd $(kubectl get crd | grep istio.io | awk '{print $1}')
```

## Development

```bash
# Lint
helm lint ./charts/istio-gravitatehealth

# Template (render)
helm template test-release ./charts/istio-gravitatehealth

# Template with values
helm template test-release ./charts/istio-gravitatehealth -f my-values.yaml

# Dry run
helm install istio-gh ./charts/istio-gravitatehealth --dry-run --debug

# Package
helm package ./charts/istio-gravitatehealth
```

## Verification

```bash
# Check Istio pods
kubectl get pods -n istio-system

# Check gateway
kubectl get gateway -A

# Check virtual services
kubectl get virtualservice -A

# Check certificates
kubectl get certificate -n istio-system

# Get ingress IP
kubectl get svc istio-ingressgateway -n istio-system

# Check authentication
kubectl get requestauthentication -A
```

## Common Values Overrides

```bash
# Change Istio profile
--set istio.profile=demo

# Enable/disable components
--set istio.components.egressGateway.enabled=false

# Multiple hosts
--set gateway.hosts[0]=app1.example.com \
--set gateway.hosts[1]=app2.example.com

# Staging Let's Encrypt
--set certManager.clusterIssuer.server=https://acme-staging-v02.api.letsencrypt.org/directory

# Disable authentication
--set authentication.enabled=false

# HTTP to HTTPS redirect
--set gateway.http.redirect=true
```

## OCI Registry Operations

```bash
# Login to GHCR
helm registry login ghcr.io -u <username>

# Pull chart
helm pull oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth --version 0.1.0

# Push chart (maintainers only)
helm package ./charts/istio-gravitatehealth
helm push istio-gravitatehealth-0.1.0.tgz oci://ghcr.io/gravitate-health/charts
```

## Troubleshooting

```bash
# Get deployment logs
kubectl logs -n istio-system -l app=istiod

# Check cert-manager
kubectl logs -n cert-manager -l app=cert-manager

# Describe certificate
kubectl describe certificate <name> -n istio-system

# Check gateway config
kubectl describe gateway <name>

# Port forward to test
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80

# Test with curl
curl -v http://localhost:8080 -H "Host: your-domain.com"
```

## Example Values Files

### Production with DNS

```yaml
gateway:
  hosts:
    - prod.example.com
  tls:
    enabled: true

certManager:
  enabled: true
  clusterIssuer:
    email: ops@example.com
    server: https://acme-v02.api.letsencrypt.org/directory

authentication:
  enabled: true
```

### Development IP-based

```yaml
gateway:
  useIP: true
  tls:
    enabled: false

certManager:
  enabled: false

authentication:
  enabled: false
```

### Staging

```yaml
gateway:
  hosts:
    - staging.example.com

certManager:
  clusterIssuer:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
```

## Resources

- Chart README: [charts/istio-gravitatehealth/README.md](charts/istio-gravitatehealth/README.md)
- Istio Docs: https://istio.io/
- Helm Docs: https://helm.sh/docs/
