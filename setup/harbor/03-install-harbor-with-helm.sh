#! /bin/bash -e

# Install harbor with helm chart

export KUBECONFIG=$HOME/.kube/config
kubectl create ns harbor
helm repo add harbor https://helm.goharbor.io
helm repo update
helm search repo harbor

export HARBOR_IP=`curl http://checkip.amazonaws.com`
export HARBOR_ADMIN_PWD=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`
export HARBOR_NODEPORT=30443

helm install harbor-registry harbor/harbor --version 1.6.2 \
  -n harbor \
  --set expose.type=nodePort \
  --set expose.nodePort.ports.https.nodePort=${HARBOR_NODEPORT} \
  --set expose.tls.auto.commonName=demo-harbor \
  --set externalURL=https://${HARBOR_IP}:${HARBOR_NODEPORT} \
  --set harborAdminPassword="${HARBOR_ADMIN_PWD}"

echo "Your Harbor instance is provisioning...."
echo
kubectl get all,pv,pvc -n harbor
echo
echo "URL: https://${HARBOR_IP}:${HARBOR_NODEPORT}" > harbor-credential.txt
echo "User: admin" >> harbor-credential.txt
echo "Password: ${HARBOR_ADMIN_PWD}" >> harbor-credential.txt
echo "Your login credential is saved in a file: harbor-credential.txt"
cat harbor-credential.txt

echo "Wait for 2-3 minutes until all harbor components are fully up and running"
kubectl get po -n harbor

# Output should be like this when it's completed.
# ec2-user@ip-172-26-3-222:~> kubectl get po -n harbor
# NAME                                                    READY   STATUS    RESTARTS   AGE
# harbor-registry-harbor-portal-fc7869f46-kt9j2           1/1     Running   0          82s
# harbor-registry-harbor-nginx-b9df69d4f-6x6kd            1/1     Running   0          82s
# harbor-registry-harbor-redis-0                          1/1     Running   0          82s
# harbor-registry-harbor-chartmuseum-db5657f9c-ldrkp      1/1     Running   0          82s
# harbor-registry-harbor-database-0                       1/1     Running   0          82s
# harbor-registry-harbor-notary-server-85b6b59986-4k8dq   1/1     Running   1          82s
# harbor-registry-harbor-notary-signer-7d8bbbb6d4-l28pm   1/1     Running   1          82s
# harbor-registry-harbor-registry-64ddb659db-t7bxm        2/2     Running   0          82s
# harbor-registry-harbor-trivy-0                          1/1     Running   0          82s
# harbor-registry-harbor-core-66bcd59b97-h5t94            1/1     Running   0          82s
# harbor-registry-harbor-jobservice-7fbf95459b-hc2mh      1/1     Running   0          82s