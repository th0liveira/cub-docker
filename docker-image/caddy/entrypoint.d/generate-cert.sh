# !/bin/bash

if [ ! -d "/mnt/certs" ]; then
  echo "- Path /mnt/certs not exists"
  exit 0;
fi

makeCnf() {
  FILE_CNF="ssl_${1}.cnf"
  FILE_EXT_CNF="ssl_${1}_ext.cnf"
  DOMAINS=${2}

  echo "[ req ]
default_bits        = ${CA_CERT_KEY_BITS}
prompt              = no
distinguished_name  = dn
string_mask         = utf8only

[ dn ]
C                   = ${CA_CERT_COUNTRY}
ST                  = ${CA_CERT_STATE}
L                   = ${CA_CERT_CITY}
O                   = ${CA_CERT_ORGANIZATION}
OU                  = ${CA_CERT_ORGANIZATION_UNIT}
emailAddress        = ${CA_CERT_EMAIL}
CN                  = ${DOMAINS}" > ${FILE_CNF}

  if [ ${FILE_CNF} = "ssl_ca.cnf" ];
  then
    return;
  fi

  echo "authorityKeyIdentifier  = keyid,issuer
basicConstraints        = CA:FALSE
keyUsage                = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName          = @alt_names

[alt_names]" > ${FILE_EXT_CNF}

  c=1
  for DOMAIN in $(echo $DOMAINS | tr ';' "\n");
  do
    echo "DNS.${c} = ${DOMAIN}" >>${FILE_EXT_CNF}
    ((c=c+1))
  done
}

# -------------------------------------------------------------------------

cd /mnt/certs

if [ ! -f "ca.crt" ];
then
  echo "- Make CA cert" | tee -a /mnt/certs/generate-cert.log

  makeCnf "ca" "*" "true"

  openssl genrsa -out ca.key \
          -aes256 \
          -passout pass:password \
          2048 >> /mnt/certs/generate-cert.log 2>&1

  openssl req -x509 -new -nodes \
          -days 825 \
          -key ca.key \
          -out ca.crt \
          -passin pass:password \
          -config ssl_ca.cnf >> /mnt/certs/generate-cert.log 2>&1

  openssl pkcs12 -export \
          -in ca.crt \
          -inkey ca.key \
          -passin pass:password \
          -passout pass:password \
          -out ca.p12 >> /mnt/certs/generate-cert.log 2>&1

  openssl pkcs12 \
          -in ca.p12 \
          -nodes \
          -passin pass:password \
          -out ca.pem >> /mnt/certs/generate-cert.log 2>&1

  rm ca.p12 ssl_ca.cnf
fi

# -------------------------------------------------------------------------

if [ ! -f "/mnt/vhosts" ]; then
  echo "- Domains list /mnt/vhosts not exists"
  exit 0;
fi

> /mnt/certs/generate-cert.log

while IFS= read -r DOMAIN || [[ -n "$DOMAIN" ]]; do
  echo "- Make cert: $DOMAIN" | tee -a /mnt/certs/generate-cert.log

  FILENAME=$(echo ${DOMAIN})

  if [ -f "${FILENAME}.pem" ] && [ -f "${FILENAME}-key.pem" ]; then
    echo "  - Cert already exists" | tee -a /mnt/certs/generate-cert.log
    continue
  fi

  rm "${FILENAME}*" >> /mnt/certs/generate-cert.log 2>&1

  if [ ! -f "${FILENAME}.cnf" ];
  then
    echo "  - Prepare cert cnf" | tee -a /mnt/certs/generate-cert.log
    makeCnf ${FILENAME} ${DOMAIN}
  fi

  if [ ! -f "${FILENAME}.csr" ];
  then
    echo "  - Create CSR" | tee -a /mnt/certs/generate-cert.log
    openssl req -new -nodes \
        -sha256 \
        -out ${FILENAME}.csr \
        -newkey rsa:2048 \
        -keyout ${FILENAME}.key \
        -passin pass:password  \
        -config ssl_${FILENAME}.cnf >> /mnt/certs/generate-cert.log 2>&1
  fi

  if [ ! -f "${FILENAME}.crt" ];
  then
    echo "  - Create CRT" | tee -a /mnt/certs/generate-cert.log
    openssl x509 -req \
        -in ${FILENAME}.csr \
        -CA ca.crt \
        -CAkey ca.key \
        -CAcreateserial -CAserial ${FILENAME}.srl \
        -out ${FILENAME}.crt \
        -days 825 \
        -sha256 \
        -passin pass:password \
        -extfile ssl_${FILENAME}_ext.cnf >> /mnt/certs/generate-cert.log 2>&1
  fi

  if [ ! -f "${FILENAME}.pem" ];
  then
    echo "  - Create PEM" | tee -a /mnt/certs/generate-cert.log
    cat ${FILENAME}.crt ${FILENAME}.key > ${FILENAME}.pem
  fi

  if [ ! -f "${FILENAME}-key.pem" ];
  then
    echo "  - Create KEY PEM" | tee -a /mnt/certs/generate-cert.log
    openssl rsa -in ${FILENAME}.key -out ${FILENAME}-key.pem >> /mnt/certs/generate-cert.log 2>&1
  fi

  echo "  - Clean files" | tee -a /mnt/certs/generate-cert.log

  rm ${FILENAME}*.srl ${FILENAME}*.csr ${FILENAME}*.crt ssl_${FILENAME}_ext.cnf ssl_${FILENAME}.cnf ${FILENAME}.key

done < /mnt/vhosts

chown 1000.1000 /mnt/certs/*

chmod 644 /mnt/certs/*.pem /mnt/certs/*.key
