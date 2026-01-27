# Pre-flight & Post-deployment Verification Checklist

Use this checklist to verify your Istio Gravitate Health Helm chart deployment.

## Pre-flight Checks

Before deploying, ensure these prerequisites are met:

### Kubernetes Cluster

- [ ] Kubernetes cluster is running (v1.19+)
  ```bash
  kubectl cluster-info
  kubectl version --short
  ```

- [ ] You have cluster-admin permissions
  ```bash
  kubectl auth can-i '*' '*' --all-namespaces
  ```

- [ ] Sufficient cluster resources
  ```bash
  kubectl top nodes  # Should have available CPU/Memory
  ```

### Helm

- [ ] Helm 3.8+ is installed
  ```bash
  helm version
  ```

- [ ] Helm can access the cluster
  ```bash
  helm list -A
  ```

### cert-manager (if using Let's Encrypt)

- [ ] cert-manager is installed (v1.11+)
  ```bash
  kubectl get pods -n cert-manager
  ```
  
- [ ] cert-manager CRDs are present
  ```bash
  kubectl get crd | grep cert-manager
  ```

### DNS (if using domain names)

- [ ] DNS record exists and points to your cluster
  ```bash
  nslookup your-domain.example.com
  dig your-domain.example.com
  ```

- [ ] Domain is publicly resolvable (for Let's Encrypt)
  ```bash
  curl -I http://your-domain.example.com
  ```

### Network

- [ ] LoadBalancer service type is supported
  ```bash
  # Check if your cluster supports LoadBalancer
  kubectl get svc -A | grep LoadBalancer
  ```

- [ ] Firewall allows HTTP (80) and HTTPS (443) traffic
  ```bash
  # Test from external machine
  nc -zv <cluster-ip> 80
  nc -zv <cluster-ip> 443
  ```

## Deployment Verification

After running `helm install`, verify the deployment:

### Helm Release

- [ ] Release is deployed
  ```bash
  helm list -A | grep istio-gh
  ```

- [ ] Release status is "deployed"
  ```bash
  helm status istio-gh
  ```

- [ ] No errors in release notes
  ```bash
  helm get notes istio-gh
  ```

### Istio System Namespace

- [ ] Namespace exists
  ```bash
  kubectl get namespace istio-system
  ```

- [ ] All pods are running
  ```bash
  kubectl get pods -n istio-system
  ```
  
  Expected pods:
  - [ ] `istiod-*` (1/1 Running)
  - [ ] `istio-ingressgateway-*` (1/1 Running)
  - [ ] `istio-egressgateway-*` (1/1 Running - if enabled)

- [ ] Services are created
  ```bash
  kubectl get svc -n istio-system
  ```

- [ ] Ingress gateway has an EXTERNAL-IP
  ```bash
  kubectl get svc istio-ingressgateway -n istio-system
  ```
  Note: May take 1-2 minutes to assign

### Gateway Configuration

- [ ] Gateway resource exists
  ```bash
  kubectl get gateway -A
  ```

- [ ] Gateway is configured correctly
  ```bash
  kubectl describe gateway -A | grep -A 10 "Spec:"
  ```

- [ ] Gateway hosts match your configuration
  ```bash
  kubectl get gateway -A -o yaml | grep -A 5 "hosts:"
  ```

### Certificate (if using Let's Encrypt)

- [ ] Certificate resource exists
  ```bash
  kubectl get certificate -n istio-system
  ```

- [ ] Certificate is issued (Ready: True)
  ```bash
  kubectl get certificate -n istio-system
  ```
  Note: May take 2-5 minutes for initial issuance

- [ ] Certificate details are correct
  ```bash
  kubectl describe certificate -n istio-system
  ```
  
  Check for:
  - [ ] Status: Certificate is up to date and has not expired
  - [ ] Events: No errors

- [ ] Secret is created
  ```bash
  kubectl get secret -n istio-system | grep cert
  ```

### CertificateRequest (if troubleshooting)

- [ ] CertificateRequest is approved
  ```bash
  kubectl get certificaterequest -n istio-system
  ```

- [ ] Order is valid
  ```bash
  kubectl get order -n istio-system
  ```

- [ ] Challenge is successful
  ```bash
  kubectl get challenge -n istio-system
  ```

### Authentication (if enabled)

- [ ] RequestAuthentication resource exists
  ```bash
  kubectl get requestauthentication -A
  ```

- [ ] Configuration matches your OIDC provider
  ```bash
  kubectl describe requestauthentication -A
  ```

### Virtual Services (if configured)

- [ ] VirtualService resources exist
  ```bash
  kubectl get virtualservice -A
  ```

- [ ] Routes are configured correctly
  ```bash
  kubectl describe virtualservice -A
  ```

### Namespace Injection

- [ ] Default namespace has injection label
  ```bash
  kubectl get namespace default --show-labels | grep istio-injection
  ```

- [ ] Additional namespaces are labeled (if configured)
  ```bash
  kubectl get namespaces --show-labels | grep istio-injection
  ```

## Functional Testing

Test that the deployment actually works:

### Network Connectivity

- [ ] Ingress gateway is reachable
  ```bash
  GATEWAY_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  curl -v http://$GATEWAY_IP
  ```

- [ ] HTTPS is working (if TLS enabled)
  ```bash
  curl -v https://your-domain.example.com
  ```

- [ ] Certificate is valid (if TLS enabled)
  ```bash
  openssl s_client -connect your-domain.example.com:443 -servername your-domain.example.com
  ```

### DNS Resolution

- [ ] Domain resolves to gateway IP
  ```bash
  nslookup your-domain.example.com
  dig your-domain.example.com
  ```

### Application Routing

- [ ] Deploy a test application
  ```bash
  kubectl create namespace test-app
  kubectl label namespace test-app istio-injection=enabled
  kubectl apply -n test-app -f <your-test-app.yaml>
  ```

- [ ] Create a VirtualService for the app
  ```yaml
  apiVersion: networking.istio.io/v1
  kind: VirtualService
  metadata:
    name: test-app
    namespace: test-app
  spec:
    hosts:
      - your-domain.example.com
    gateways:
      - gh-gateway
    http:
      - route:
          - destination:
              host: test-app.test-app.svc.cluster.local
              port:
                number: 8080
  ```

- [ ] Access the application
  ```bash
  curl http://your-domain.example.com/
  ```

### Sidecar Injection

- [ ] Test pod has Envoy sidecar
  ```bash
  kubectl get pods -n test-app -o jsonpath='{.items[0].spec.containers[*].name}'
  ```
  Should show both app container and `istio-proxy`

- [ ] Sidecar is running
  ```bash
  kubectl get pods -n test-app
  ```
  Should show 2/2 containers ready

### JWT Authentication (if enabled)

- [ ] Unauthenticated request is rejected
  ```bash
  curl -v http://your-domain.example.com/protected
  ```
  Should return 401

- [ ] Authenticated request works
  ```bash
  TOKEN=$(curl -s <your-oidc-token-endpoint>)
  curl -v -H "Authorization: Bearer $TOKEN" http://your-domain.example.com/protected
  ```
  Should return 200

## Observability Checks

Verify monitoring and logging:

### Access Logs

- [ ] Ingress gateway logs are accessible
  ```bash
  kubectl logs -n istio-system -l app=istio-ingressgateway --tail=50
  ```

- [ ] Logs show incoming requests
  ```bash
  kubectl logs -n istio-system -l app=istio-ingressgateway --tail=50 | grep "GET"
  ```

### Control Plane

- [ ] Istiod logs are healthy
  ```bash
  kubectl logs -n istio-system -l app=istiod --tail=50
  ```

- [ ] No errors or warnings
  ```bash
  kubectl logs -n istio-system -l app=istiod --tail=100 | grep -i error
  ```

## Performance Checks

Verify resource usage:

### Resource Usage

- [ ] Pods are not OOMKilled or CrashLooping
  ```bash
  kubectl get pods -n istio-system
  ```

- [ ] CPU and memory usage is reasonable
  ```bash
  kubectl top pods -n istio-system
  ```

- [ ] No resource constraints
  ```bash
  kubectl describe pods -n istio-system | grep -A 5 "Limits:"
  ```

## Troubleshooting Commands

If any checks fail, use these for debugging:

```bash
# Helm release details
helm get all istio-gh

# Helm release history
helm history istio-gh

# Pod logs (detailed)
kubectl logs -n istio-system <pod-name> --previous
kubectl logs -n istio-system <pod-name> -c <container-name>

# Pod events
kubectl describe pod -n istio-system <pod-name>

# Certificate debugging
kubectl describe certificate -n istio-system
kubectl describe certificaterequest -n istio-system
kubectl logs -n cert-manager -l app=cert-manager

# Gateway debugging
kubectl describe gateway <gateway-name>
istioctl proxy-status

# Virtual service debugging
kubectl describe virtualservice <vs-name> -n <namespace>
istioctl analyze

# Configuration sync
istioctl proxy-config routes <pod-name>.<namespace>
istioctl proxy-config clusters <pod-name>.<namespace>
```

## Rollback Procedure

If deployment fails:

```bash
# View release history
helm history istio-gh

# Rollback to previous version
helm rollback istio-gh

# Rollback to specific revision
helm rollback istio-gh <revision>

# Verify rollback
helm status istio-gh
kubectl get pods -n istio-system
```

## Success Criteria

Deployment is successful when:

- ✅ All pods in istio-system are Running (1/1 or 2/2)
- ✅ Ingress gateway has EXTERNAL-IP assigned
- ✅ Certificate is issued (if using Let's Encrypt)
- ✅ Gateway and VirtualService resources exist
- ✅ Test application is accessible via gateway
- ✅ Logs show no errors
- ✅ `helm status istio-gh` shows "deployed"

## Post-deployment Tasks

After successful verification:

- [ ] Document the ingress gateway IP
- [ ] Update DNS if not already done
- [ ] Configure monitoring alerts
- [ ] Set up backup procedures
- [ ] Document any custom values used
- [ ] Train team on Helm operations
- [ ] Schedule certificate renewal checks (automatic but verify)
- [ ] Plan upgrade strategy for future versions

## Support

If issues persist:

1. Check the [Troubleshooting section](charts/istio-gravitatehealth/README.md#troubleshooting) in the chart README
2. Open an issue using the [Helm Chart Issue template](.github/ISSUE_TEMPLATE/helm-chart-issue.md)
3. Include output from the commands above

---

**Last Updated:** January 2026  
**Chart Version:** 0.1.0
