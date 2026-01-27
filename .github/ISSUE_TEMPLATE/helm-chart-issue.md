---
name: Helm Chart Issue
about: Report an issue with the Istio Gravitate Health Helm chart
title: '[CHART] '
labels: ['helm', 'bug']
assignees: ''

---

## Chart Information

**Chart Version:** 
<!-- e.g., 0.1.0 -->

**Installation Method:**
- [ ] OCI Registry (GHCR)
- [ ] Local chart
- [ ] Other (please specify)

**Deployment Command:**
```bash
# Paste the helm install/upgrade command you used
```

## Environment

**Kubernetes Version:**
<!-- Run: kubectl version --short -->

**Helm Version:**
<!-- Run: helm version -->

**cert-manager Version (if applicable):**
<!-- Run: kubectl get pods -n cert-manager -->

**Istio Version:**
<!-- From Chart.yaml appVersion or: istioctl version -->

## Issue Description

### Expected Behavior
<!-- What did you expect to happen? -->

### Actual Behavior
<!-- What actually happened? -->

### Steps to Reproduce
1. 
2. 
3. 

## Configuration

**Custom Values:**
```yaml
# Paste your values.yaml or --set parameters
```

## Logs and Output

**Helm Status:**
```bash
# Output of: helm status <release-name>
```

**Pod Status:**
```bash
# Output of: kubectl get pods -n istio-system
```

**Relevant Logs:**
```bash
# If applicable, paste relevant logs from:
# kubectl logs -n istio-system <pod-name>
# kubectl describe certificate <cert-name> -n istio-system
# kubectl describe gateway <gateway-name>
```

**Template Output (if applicable):**
```bash
# If the issue is with templating:
# helm template <release> ./charts/istio-gravitatehealth -f values.yaml --debug
```

## Additional Context

<!-- Add any other context about the problem here -->

## Checklist

- [ ] I have checked the [Chart README](../charts/istio-gravitatehealth/README.md)
- [ ] I have checked the [Quick Reference](../QUICK_REFERENCE.md)
- [ ] I have searched for similar issues
- [ ] I have included all relevant information above
