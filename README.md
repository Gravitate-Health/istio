Gravitate Health: Istio system installation and basic authentication configuration
=================================================

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Table of contents
-----------------

- [Gravitate Health: Istio system installation and basic authentication configuration](#gravitate-health-istio-system-installation-and-basic-authentication-configuration)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Known issues and limitations](#known-issues-and-limitations)
  - [Getting help](#getting-help)
  - [Contributing](#contributing)
  - [License](#license)
  - [Authors and history](#authors-and-history)
  - [Acknowledgments](#acknowledgments)

## Introduction

[Istio](https://istio.io/) is a service mesh that expands Kubernetes to establish a programmable, application-aware network using the Envoy service proxy. It provides standard traffic management, telemetry, and security to Kubernetes deployments.

This repository contains the files needed for the installation of Istio inside a Kubernetes cluster. As the gateway implements a JWT auth scheme using OIDC ([Keycloak](https://github.com/keycloak/keycloak)) the instructions for the procurement of the token will also be provided.

## Installation

Refer to the [General FOSPS Deployment Documentation](https://github.com/Gravitate-Health/Documentation) to deploy this service.


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
- Guillermo Mejías ([@gmej](https://github.com/gmej))
- Alejo Esteban ([@10alejospain](https://github.com/10alejospain))

Acknowledgments
---------------

- https://istio.io/
- [Istio with Let's Encrypt](https://nsirap.com/posts/040-istio-with-lets-encrypt/)


