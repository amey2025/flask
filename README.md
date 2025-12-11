# Flask ##
Flask application deployment in k8s with Helm & Fleet

## Create Docker image for flask ##
Create Dockerfile with latest Python-slim image as base image to avoid any vulnerabilities
Use latest and stable versions of Flask & gunicorn in requirements.txt file to avoid any vulnerabilities
Create .dockerignore file to prevent adding any irrelevant files to the docker image

docker build . -t  abhyankar/flask:latest
docker login
docker push abhyankar/flask:latest

docker run --rm -p 5000:5000 --name my-flask-app abhyankar/flask:latest
Open the web-brwoser in local laptop and visit http://127.0.0.1:5000 = The page will be displayed

This exercise confirms that the Flask docker image building process is sucessful and by running the Flask using "docker run" ensures that we can access the output in web-browser on port 5000

## Github ##

Create public repository named flask 
Configure docker secrets & env vars inside the repository
Create docker-ci.yaml workflow and define the steps including docker login
Onserve the docker build from Actions TAB
After sucesful build, go to https://hub.docker.com/repository/docker/abhyankar/flask/general and ensure that the image is visible

Following are the important folders in the repository =
- flask-app = Helm chart , Fleet deployment file
- k8s = raw dpeloyment of Flask in k8s , fleet CRD deployment file
- Files = Dockerfile , .ignore files, .github/workflows for build
- src = contains app.py for Flask


## Port forwarding to access the web service on port 5000 ##
kubectl port-forward service/flask 5000:5000 --namespace=fleet

## Helm ##
Install Helm in laptop
Go to flask directory and execute following command = helm create flask-app
Now go inside flask/flask-app dir and modify the required files > git commit > git push > git pull

## Helm chart install ##
helm install flask-app .\flask-app\ --namespace fleet
helm uninstall flask-app -n fleet

## Fleet deployment ##
helm repo add fleet https://rancher.github.io/fleet-helm-charts/
helm repo update
helm -n cattle-fleet-system install --create-namespace --wait fleet   fleet/fleet

- Useful commands related to Fleet =
    kubectl describe gitrepo flask-fleet -n fleet-local
    kubectl get bundles.fleet.cattle.io -A
    kubectl replace -f .\fleet-gitrepo.yaml --force
    kubectl logs -n cattle-fleet-system deploy/fleet-controller
    kubectl logs -n cattle-fleet-system -l app=fleet-agent
    
BLOCKER = Fleet is able to deploy the Helm chart how ever Fleet deployment fails to create the service for Flask app. No errors observed in the logs.
