#!/bin/bash

# Set the path to the Kubernetes secret that references the Vault role and secret path
SECRET_PATH="secret/tls-cert"

# Set the maximum number of days before the certificate expires to renew it
DAYS_BEFORE_EXPIRY=30

# Set the path to the Vault CLI
export PATH=$PATH:/usr/local/bin

# Get the certificate expiration date from Vault
CERT_EXPIRY=$(vault read -format=json $SECRET_PATH | jq -r '.data."tls.crt" | openssl x509 -noout -enddate' | cut -d= -f 2)

# Convert the expiration date to Unix timestamp
CERT_EXPIRY_TIMESTAMP=$(date -d "$CERT_EXPIRY" +%s)

# Get the current date in Unix timestamp format
CURRENT_TIMESTAMP=$(date +%s)

# Calculate the number of days until the certificate expires
DAYS_UNTIL_EXPIRY=$((($CERT_EXPIRY_TIMESTAMP - $CURRENT_TIMESTAMP) / 86400))

# Check if the certificate is expired or about to expire
if [ $DAYS_UNTIL_EXPIRY -lt $DAYS_BEFORE_EXPIRY ]; then
  echo "Certificate is expired or about to expire. Renewing..."

  # Get the new certificate from the Certificate Authority and update the secret in Vault
  vault write $SECRET_PATH \
    tls.key=@/path/to/new/key \
    tls.crt=@/path/to/new/cert

  # Update the Kubernetes secret with the new certificate from Vault
  kubectl create secret generic tls-cert --from-file=tls.key --from-file=tls.crt --dry-run=client -o yaml | kubectl apply -f -
else
  echo "Certificate is valid for $DAYS_UNTIL_EXPIRY days."
fi


