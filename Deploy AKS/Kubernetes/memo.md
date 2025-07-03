kubectl create ing boutique --class=nginx --rule="tdeoliveira2024.ovh/*=app1:80,tls=clef-letsencrypt-prod" --annotation cert-manager.io/cluster-issuer=letsencrypt-production

kubectl get Ingress,CertificateRequest,Challenge,Secret,Certificate -o wide

kubectl -n ingress-nginx patch cm ingress-nginx-controller -p '{"data":{"strict-validate-path-type":"false"}}'