# Flask Application Deployment with Kubernetes, Helm & Fleet

This repository demonstrates how to:
- Containerize a Flask application with Docker
- Build and publish the image using GitHub Actions
- Deploy the app to Kubernetes using Helm
- Manage GitOps-style deployments with Rancher Fleet

## Repository structure
The repository is organized as follows:
- **src/**: Flask application source code (`app.py`)
- **Files/**: `Dockerfile`, `.dockerignore`, GitHub Actions workflow files
- **flask-app/**: Helm chart for the Flask application and Fleet deployment configuration
- **k8s/**: Raw Kubernetes manifests for the Flask app and Fleet CRDs

---

## Docker: Build and run the Flask image

### Requirements
- **Base image**: Use the latest `python-slim` image to reduce vulnerabilities.
- **Dependencies**: Use the latest stable versions of `Flask` and `gunicorn` in `requirements.txt`.
- **.dockerignore**: Ensure unnecessary files are excluded from the build context.

### Build and push the image
- docker build . -t abhyankar/flask:latest
- docker login
- docker push abhyankar/flask:latest


### Run locally
To verify the image works before deploying:
- docker run --rm -p 5000:5000 --name my-flask-app abhyankar/flask:latest



Open your browser and visit: [http://127.0.0.1:5000](http://127.0.0.1:5000).  
If the page loads, the Docker image build and runtime behavior are verified.

---

## GitHub: CI build and Docker Hub publish

### Repository Configuration
1. **Repo Name**: `flask` (Public)
2. **Secrets**: Configure Docker Hub credentials (e.g., `DOCKER_USERNAME`, `DOCKER_PASSWORD`) in the repository settings.
3. **Workflow**: Create `.github/workflows/docker-ci.yaml` to define steps for checkout, login, build, and push.

### Observe builds
1. Navigate to the **Actions** tab in GitHub.
2. Monitor the build process.
3. Upon success, verify the image exists at:  
   [https://hub.docker.com/repository/docker/abhyankar/flask/general](https://hub.docker.com/repository/docker/abhyankar/flask/general)

---

## Kubernetes: Accessing the Flask service

Once deployed, use port-forwarding to access the service locally: kubectl port-forward service/flask 5000:5000 --namespace=fleet


Visit: [http://127.0.0.1:5000](http://127.0.0.1:5000)

---

## Helm: Chart setup and deployment

### Install Helm
Ensure Helm is installed on your local machine.

### Create and update the Helm chart
- Go to the flask directory
- helm create flask-app


### Manual Install/Uninstall
To test the chart manually without Fleet:

- Install
    helm install flask-app ./flask-app/ --namespace fleet

- Uninstall
    helm uninstall flask-app -n fleet

---

## Fleet: GitOps deployment

### Install Fleet
- helm repo add fleet https://rancher.github.io/fleet-helm-charts/
- helm repo update
- helm -n cattle-fleet-system install --create-namespace --wait fleet fleet/fleet


### Useful Fleet commands
- Check the status of the GitRepo
    kubectl describe gitrepo flask-fleet -n fleet-local

- View Fleet bundles
    kubectl get bundles.fleet.cattle.io -A

- Force update the Fleet configuration
    kubectl replace -f ./fleet-gitrepo.yaml --force

- Check Fleet Controller logs
    kubectl logs -n cattle-fleet-system deploy/fleet-controller

- Check Fleet Agent logs
    kubectl logs -n cattle-fleet-system -l app=fleet-agent


---

## Known Issues / Blockers

**Status**:  
- Fleet successfully deploys the Helm chart.
- **Issue**: The Fleet deployment fails to create the Service resource for the Flask app.

**Troubleshooting steps**:
1. Verify `service.yaml` exists in the Helm chart `templates/` folder.
2. Check `values.yaml` to ensure service creation is enabled.
3. Review Fleet agent logs for permission errors or templating failures.

- Modify values.yaml and templates in flask/flask-app/ as needed
- git add .
- git commit -m "Update helm chart"
- git push


