Gravitate Health: Istio system installation and basic authentication configuration
=================================================

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Table of contents
-----------------

- [Gravitate Health: Istio system installation and basic authentication configuration](#gravitate-health-istio-system-installation-and-basic-authentication-configuration)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
    - [Istio installation](#istio-installation)
    - [Keycloak deployment and test configuration](#keycloak-deployment-and-test-configuration)
  - [Known issues and limitations](#known-issues-and-limitations)
  - [Getting help](#getting-help)
  - [Contributing](#contributing)
  - [License](#license)
  - [Authors and history](#authors-and-history)
  - [Acknowledgments](#acknowledgments)

Introduction
------------

[Istio](https://istio.io/) is a service mesh that expands Kubernetes to establish a programmable, application-aware network using the Envoy service proxy. It provides standard traffic management, telemetry, and security to Kubernetes deployments.

This repository contains the files needed for the installation of Istio inside a Kubernetes cluster. As the gateway implements a JWT auth scheme using OIDC ([Keycloak](https://github.com/keycloak/keycloak)) the instructions for the procurement of the token will also be provided.

Installation
------------

Istio can be installed using a standalone installer, Helm charts, and Operators. For this proyect we will use the installer as it is the recommended path for production enviromnents.

### Istio installation

First download Istio.

```bash
curl -L https://istio.io/downloadIstio | sh -

# or for a specific version (this README was written using 1.16.1)
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.16.1 TARGET_ARCH=x86_64 sh - 
```

After that you can add Istio to your path so it will be easier to use.

```bash
cd istio-1.16.1/
export PATH=$PWD/bin:$PATH
```

Now we begin the Istio installation. Keep in mind that depending on your platform you might need to prepare it before the Istio installation (https://istio.io/latest/docs/setup/platform-setup/)

```bash
istioctl install --set profile=default -y --set components.egressGateways[0].name=istio-egressgateway --set components.egressGateways[0].enabled=true --set meshConfig.accessLogFile=/dev/stdout    # Use 'default' profile for production environments 

kubectl label namespace default istio-injection=enabled     # Prepare the default namespace for injection
```

Istio should be installed and working as of this point. You can check everything has deployed correctly running the following command:

```bash
kubectl get all -n istio-system
```
```bash
NAME                                       READY   STATUS    RESTARTS   AGE
pod/istio-ingressgateway-6785fcd48-r6qxf   1/1     Running   0          3m30s
pod/istiod-65448977c9-zl8sz                1/1     Running   0          3m44s

NAME                           TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                      AGE
service/istio-ingressgateway   LoadBalancer   10.108.58.179   <pending>     15021:31852/TCP,80:30855/TCP,443:31061/TCP   3m30s
service/istiod                 ClusterIP      10.96.110.141   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        3m44s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-ingressgateway   1/1     1            1           3m30s
deployment.apps/istiod                 1/1     1            1           3m44s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-ingressgateway-6785fcd48   1         1         1       3m30s
replicaset.apps/istiod-65448977c9                1         1         1       3m44s

NAME                                                       REFERENCE                         TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istio-ingressgateway   Deployment/istio-ingressgateway   <unknown>/80%   1         5         1          3m30s
horizontalpodautoscaler.autoscaling/istiod                 Deployment/istiod                 <unknown>/80%   1         5         1          3m44s
```

### Keycloak deployment and test configuration

Now that we have Istio up and running lets deploy Keycloak and a sample application to provide auth to (in production environments only Keycloak, Gateway and VirtualService objects will be needed). The instructions for deploying and configuring Keycloak can be found at https://github.com/Gravitate-Health/keycloak#kubernetes-deployment.

With Keycloak deployed we will now create two Istio objects, a Gateway and a VirtualService. The Gateway takes care of load balancing the Istio ingress to achieve external routing of the application outside the cluster, as well as the configuration of protocols (HTTP, HTTPS...), and certificates. Unless you are working with multiple hosts in your cluster (e.g. subdomains) only one is needed. The VirtualService contains the routes that each application consumes, and the rules to do so, such as rewrites, matchs, etc.. Each application that wants to be explosed outside the clust must have its own VirtualService pointing to the Gateway of choice. You can learn more in the Istio documentation of the [Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/) and the [VirtualService](https://istio.io/latest/docs/reference/config/networking/virtual-service/), where you will also find available configurations.

```bash
kubectl apply -f gateway.yaml keycloak-vs.yaml
```

Once both are ready we can deploy the rules for authentication

```bash
kubectl apply -f request_auth.yaml
```

Known issues and limitations
----------------------------

Authentication for the whole cluster not working at the moment.

Getting help
------------

In case you find a problem or you need extra help, please use the issues tab to report the issue.

Contributing
------------

To contribute, fork this repository and send a pull request with the changes squashed.

License
-------

This project is distributed under the terms of the [Apache License, Version 2.0 (AL2)](http://www.apache.org/licenses/LICENSE-2.0). The license applies to this file and other files in the [GitHub repository](https://github.com/Gravitate-Health/istio) hosting this file.

```
Copyright 2022 Universidad Politécnica de Madrid

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Authors and history
---------------------------

- Álvaro Belmar ([@abelmarm](https://github.com/abelmarm))

Acknowledgments
---------------

- https://istio.io/



