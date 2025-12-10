# flask
Flask application deployment in k8s with fleet

## Create Docker image for flask ##
docker build . -t  abhyankar/flask:latest
docker run --rm -p 5000:5000 --name my-flask-app abhyankar/flask:latest

## image update to docker hub ##
docker login
docker push <user_name>/flask:latest

## Port forwarding to access the web service on port 5000 ##
kubectl port-forward service/flask 5000:5000 --namespace=fleet

## Helm ##
helm create flask-app
helm install flask-app .\flask-app\ --namespace fleet
helm uninstall flask-app -n fleet

## Fleet CRD installation in k8s ##
helm repo add fleet https://rancher.github.io/fleet-helm-charts/
helm repo update
helm -n cattle-fleet-system install --create-namespace --wait fleet   fleet/fleet
