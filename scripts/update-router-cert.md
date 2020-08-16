# Updating router Certificate
Updating router certificate using the deployment playbook did not succeed.
Manual steps to update the certificate.
Based on https://docs.openshift.com/container-platform/3.3/install_config/redeploying_certificates.html#redeploying-registry-router-certificates

- Step 1:
  Backup your existing certificate: ```oc get --export secret router-certs > old-router-certs-secret.yaml```
- Step 2:
  Combine your certificate, ca certificate AND the private key to a single file: 
  ```cat /etc/letsencrypt/live/caas.knowbiz.ca/fullchain.pem /etc/letsencrypt/live/caas.knowbiz.ca/privkey.pem > router.pem```
  Since full chanin has both the cert and ca cert, I can just combine the fullchain and private key.
  
 - Step 3: 
   Get a copy of your private key: ```cp /etc/letsencrypt/live/caas.knowbiz.ca/privkey.pem  router.key``
   
 - Step 4:
   Create the secret:
   ```oc create secret tls router-certs --cert=router.pem \
        --key=router.key -o json --dry-run | oc replace -f -
   ```
 - Roll out the router: ```oc rollout latest dc/router```
 
