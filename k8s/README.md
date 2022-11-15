# Legacy PKI with Kubernetes

## Stage 1: Migrating to Kubernetes (Semi-Automated)
- Install kompose, kubernetes and start up a kind cluster with a docker local registry
  ```shell
  cd ~/spiresplash
  source ~/spiresplash/ansible_venv/bin/activate
  python3.9 -m ansible playbook \
    -i ./ansible/inventories/inventory.ini \
    -e @./ansible/inventories/overrides.yml -b -v \
    ./ansible/site.yaml -t k8s
  ```
- Let's push our demo images to the local registry
  ```shell
  docker push localhost:5001/frontend
  docker push localhost:5001/backend
  ```
- We will make use of kompose to convert [spiresplash/pki/docker-compose.yaml](../pki/docker-compose.yaml)
into kubernetes configuration file (will be stored at `spiresplash/k8s/pki` then deploy our pki demo into 
the kind cluster using our shell script [spiresplash/scripts/setup-pki.sh](../scripts/setup-pki.sh)
  ```shell
  cd ~/spiresplash
  scripts/setup-pki.sh
  ```
- Port-forward and check the web app at http://localhost:3000
  ```shell
  export FRONTEND_POD=`kubectl get po -o jsonpath='{.items[1].metadata.name}'`
  kubectl port-forward $FRONTEND_POD 3000:3000
  ```
- Clean up:
  ```shell
  kubectl delete -f ~/spiresplash/k8s/pki/
  kubectl delete secret backend-tls
  ```