## Secure-K8s-Pipeline

### Overview
This project implements a secure, automated CI/CD style pipeline for a containerized Auth Service. It utilizes a **Shift Left** approach, integrating automated linting and vulnerability scanning to enforce a **Fail-Fast** deployment gate. The architecture ensures that only verified, stable artifacts reach the Kubernetes cluster.

## Local Environment and Security Logic
This pipeline is engineered to run entirely within a local environment. By building images directly inside the Minikube Docker daemon and avoiding external registries, we create a closed loop that is both faster and more secure.

* **Air-Gapped Workflow:** Everything stays on your machine. By not pulling from the internet, we eliminate the risk of "upstream poisoning" where public images might be compromised.
* **Integrity Guarantee:** The `imagePullPolicy: Never` setting forces Kubernetes to use the exact versions we have manually scanned and approved.
* **Terminal Synchronization:** You must run `eval $(minikube docker-env)` before execution. This tells your terminal to "talk" to Minikube’s internal Docker engine rather than your local host.

### Key Features
* **Infrastructure as Code:** Declarative YAML manifests ensure environment consistency and reproducibility.
* **Automated Security Scanning:** Trivy integration detects and blocks images containing critical CVEs.
* **Code Quality Enforcement:** Hadolint validates Dockerfiles against production grade security best practices.
* **Self-Healing Architecture:** Liveness and Readiness probes enable automatic recovery and zero-downtime.
* **Rapid-Fire Deployment:** Streamlined Bash automation offloads rollout monitoring to the K8s Control Plane.

### Tech Stack
* **Containerization:** Docker (Alpine)
* **Orchestration:** Kubernetes (Minikube)
* **Security:** Trivy, Hadolint
* **Automation:** Bash

### Security and Evidence

**Vulnerability Detection:**
Initially, the auth-svc image was found to have 3 High-severity vulnerabilities. These were specifically buffer overflows in the libpng library identified during the Trivy scan.

**Remediation:**
I patched the base image to a hardened Alpine version and implemented multi-stage builds. These changes reduced the vulnerability count to zero and passed the pipeline security gates.


**Live Deployment:**
The application successfully utilizes a rolling update strategy within a local Kubernetes NodePort service. The pipeline verifies that new secure pods are healthy before decommissioning legacy infrastructure.

Visual proof of the pipeline's security gates and deployment success can be found in the [screenshots/](./screenshots/) directory.

### How to Run

**1. Clone the repository**
```bash
git clone [https://github.com/Sidhesh300/Secure-K8s-Pipeline.git](https://github.com/Sidhesh300/Secure-K8s-Pipeline.git)
cd secure-k8s-pipeline
```
**2. Initialize Environment**
```bash
minikube start
eval $(minikube docker-env)
```

**3. Execute Pipeline**
```bash
chmod +x ./scripts/pipeline.sh
./scripts/pipeline.sh
```
**4. Access Service**
```bash
minikube service web-app -n mydevteam
```
