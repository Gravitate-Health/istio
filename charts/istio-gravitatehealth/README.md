# Istio Gravitate Health Helm Chart

A production-ready Helm chart for deploying Istio service mesh with Gravitate Health-specific configuration including gateway setup, JWT authentication, and Let's Encrypt certificate management.

## Features

- 🚀 **Automated Istio Installation**: Deploy Istio using the operator pattern
- 🌐 **Flexible Gateway Configuration**: Support for both DNS-based and IP-based access
- 🔒 **Let's Encrypt Integration**: Automatic SSL/TLS certificate provisioning via cert-manager
- 🔐 **JWT Authentication**: Built-in OIDC/JWT authentication support
- 📊 **Observability**: Access logging and distributed tracing enabled by default
- 🎯 **Production Ready**: Sensible defaults with extensive customization options

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8+
- **istioctl CLI** (if installing Istio via this chart with `istio.install=true`)
- (Optional) A DNS domain name if using TLS certificates

> **Note on Istio Installation:** This chart uses the IstioOperator to install Istio when `istio.install=true`. This requires the `istioctl` CLI to be available. Alternatively, you can pre-install Istio separately and set `istio.install=false`.

> **Note on cert-manager:** This chart includes cert-manager as a Helm dependency and will automatically install it when `certManager.install=true` (default). If you already have cert-manager installed in your cluster, set `certManager.install=false` to skip the installation.

## Installation

### Quick Start with OCI Registry

Deploy directly from GitHub Container Registry without cloning the repository:

```bash
# Login to GHCR (if the registry is private)
helm registry login ghcr.io -u <your-username>

# Install the chart
helm install istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth --version 0.1.0

# Install with custom values
helm install istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth \
  --version 0.1.0 \
  --set gateway.hosts[0]=myapp.example.com \
  --set certManager.clusterIssuer.email=admin@example.com
```

### Install from Local Chart

```bash
# Clone the repository
git clone https://github.com/Gravitate-Health/istio.git
cd istio

# Update Helm dependencies (downloads Istio and cert-manager subcharts)
helm dependency update charts/istio-gravitatehealth

# Install the chart
helm install istio-gh charts/istio-gravitatehealth

# Install with custom values file
helm install istio-gh charts/istio-gravitatehealth -f my-values.yaml

# Install without cert-manager (if already installed in your cluster)
helm install istio-gh charts/istio-gravitatehealth --set certManager.install=false
```

## Configuration Options

### Basic Configuration

#### IP-Based Access (No DNS)

For environments without a DNS name:

```yaml
gateway:
  useIP: true
  
certManager:
  install: false  # Skip cert-manager installation
  enabled: false  # Let's Encrypt requires DNS
```

```bash
helm install istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth \
  --set gateway.useIP=true \
  --set certManager.install=false \
  --set certManager.enabled=false
```

#### DNS-Based Access with Let's Encrypt

For production deployments with a domain name:

```yaml
gateway:
  useIP: false
  hosts:
    - myapp.example.com
  tls:
    enabled: true
    credentialName: my-tls-cert

certManager:
  install: true   # Install cert-manager (default)
  enabled: true   # Create ClusterIssuer and Certificate
  clusterIssuer:
    email: admin@example.com
  certificate:
    commonName: myapp.example.com
    dnsNames:
      - myapp.example.com
```

**Using Existing cert-manager Installation:**

If cert-manager is already installed in your cluster:

```yaml
certManager:
  install: false  # Skip cert-manager installation
  enabled: true   # Still create ClusterIssuer and Certificate
  clusterIssuer:
    email: admin@example.com
  certificate:
    commonName: myapp.example.com
    dnsNames:
      - myapp.example.com
```

### Advanced Configuration

#### Custom Istio Profile

```yaml
istio:
  profile: demo  # Options: default, demo, minimal, remote, empty
  meshConfig:
    enableTracing: true
    accessLogFile: /dev/stdout
```

#### DNS-01 Challenge (for wildcard certificates)

```yaml
certManager:
  clusterIssuer:
    challengeType: dns01
    dns01Solver:
      cloudflare:
        email: admin@example.com
        apiTokenSecretRef:
          name: cloudflare-api-token-secret
          key: api-token
```

#### Multiple Virtual Services

```yaml
virtualServices:
  - enabled: true
    name: app1
    namespace: app1-namespace
    hosts:
      - app1.example.com
    gateways:
      - gh-gateway
    http:
      - route:
          - destination:
              host: app1-service.app1-namespace.svc.cluster.local
              port:
                number: 8080
  
  - enabled: true
    name: app2
    namespace: app2-namespace
    hosts:
      - app2.example.com
    gateways:
      - gh-gateway
    http:
      - route:
          - destination:
              host: app2-service.app2-namespace.svc.cluster.local
              port:
                number: 3000
```

#### JWT Authentication

```yaml
authentication:
  enabled: true
  namespace: default
  selector:
    istioRequireAuthentication: "true"
  jwtRules:
    - issuer: https://auth.example.com/realms/MyRealm
      jwksUri: https://auth.example.com/realms/MyRealm/protocol/openid-connect/certs
      forwardOriginalToken: true
```

## Configuration Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `istio.install` | Install Istio operator | `true` |
| `istio.namespace` | Istio system namespace | `istio-system` |
| `istio.profile` | Istio configuration profile | `default` |
| `gateway.enabled` | Enable gateway creation | `true` |
| `gateway.useIP` | Use IP-based access | `false` |
| `gateway.hosts` | Gateway hostnames | `[fosps.gravitatehealth.eu]` |
| `gateway.tls.enabled` | Enable TLS/HTTPS | `true` |
| `certManager.install` | Install cert-manager via Helm dependency | `true` |
| `certManager.enabled` | Create ClusterIssuer and Certificate resources | `true` |
| `certManager.clusterIssuer.email` | Let's Encrypt email | `gmejias@lst.tfo.upm.es` |
| `certManager.clusterIssuer.server` | ACME server URL | `https://acme-v02.api.letsencrypt.org/directory` |
| `certManager.clusterIssuer.challengeType` | Challenge type (http01/dns01) | `http01` |
| `authentication.enabled` | Enable JWT authentication | `true` |
| `authentication.namespace` | Authentication namespace | `default` |

See [values.yaml](values.yaml) for the complete list of configurable parameters.

## Post-Installation Steps

### 1. Verify Istio Installation

```bash
kubectl get all -n istio-system
```

Expected output should show running pods for:
- `istiod` (control plane)
- `istio-ingressgateway`
- `istio-egressgateway`

### 2. Get Ingress Gateway External IP

```bash
kubectl get svc istio-ingressgateway -n istio-system
```

### 3. Configure DNS (if using domain names)

Point your DNS A record to the EXTERNAL-IP from step 2.

### 4. Verify Certificate (if using Let's Encrypt)

```bash
kubectl get certificate -n istio-system
kubectl describe certificate fosps-url-cert -n istio-system
```

### 5. Enable Istio Injection for Your Namespaces

```bash
kubectl label namespace <your-namespace> istio-injection=enabled
```

Or configure via `values.yaml`:

```yaml
istio:
  namespaceLabels:
    - name: my-app-namespace
      istioInjection: true
```

## Local Development

### Lint the Chart

```bash
helm lint charts/istio-gravitatehealth
```

### Template and Review

```bash
# Generate templates with default values
helm template istio-gh charts/istio-gravitatehealth

# Generate with custom values
helm template istio-gh charts/istio-gravitatehealth -f my-values.yaml

# Output to file for review
helm template istio-gh charts/istio-gravitatehealth > output.yaml
```

### Test Installation (Dry Run)

```bash
helm install istio-gh charts/istio-gravitatehealth --dry-run --debug
```

### Package the Chart

```bash
helm package charts/istio-gravitatehealth
```

## Upgrading

### Upgrade from OCI Registry

```bash
helm upgrade istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth --version 0.2.0
```

### Upgrade from Local Chart

```bash
helm upgrade istio-gh charts/istio-gravitatehealth
```

### Upgrade with New Values

```bash
helm upgrade istio-gh oci://ghcr.io/gravitate-health/charts/istio-gravitatehealth \
  --version 0.2.0 \
  --set gateway.hosts[0]=newdomain.example.com \
  --reuse-values
```

## Uninstalling

```bash
# Uninstall the chart
helm uninstall istio-gh

# Clean up Istio CRDs (if needed)
kubectl delete crd $(kubectl get crd | grep istio.io | awk '{print $1}')
```

## Troubleshooting

### Certificate Not Issuing

Check cert-manager logs:
```bash
kubectl logs -n cert-manager -l app=cert-manager
```

Check certificate status:
```bash
kubectl describe certificate <cert-name> -n istio-system
```

### Gateway Not Routing Traffic

Check gateway status:
```bash
kubectl get gateway -A
kubectl describe gateway gh-gateway
```

Check virtual service:
```bash
kubectl get virtualservice -A
kubectl describe virtualservice <vs-name> -n <namespace>
```

### Authentication Not Working

Check RequestAuthentication:
```bash
kubectl get requestauthentication -A
kubectl describe requestauthentication <ra-name> -n <namespace>
```

Verify JWT token is valid and issuer/jwksUri are correct.

## OCI Registry Publishing

### Login to GitHub Container Registry

```bash
echo $GITHUB_TOKEN | helm registry login ghcr.io -u <username> --password-stdin
```

### Package and Push

```bash
# Package the chart
helm package charts/istio-gravitatehealth

# Push to OCI registry
helm push istio-gravitatehealth-0.1.0.tgz oci://ghcr.io/gravitate-health/charts
```

## Contributing

Please read [CONTRIBUTING.md](../../CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

Copyright 2023 Universidad Politécnica de Madrid

Licensed under the Apache License, Version 2.0. See [LICENSE](../../LICENSE) for details.

## Support

For issues and questions:
- GitHub Issues: https://github.com/Gravitate-Health/istio/issues
- Documentation: https://github.com/Gravitate-Health/Documentation

## References

- [Istio Documentation](https://istio.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
