#!/bin/bash

# -------------------------------- #
# Create root CA
# -------------------------------- #
ROOTCA_DIR="./rootca"

if [ -d "$ROOTCA_DIR" ]
then
  rm -rf ${ROOTCA_DIR}
fi

mkdir ${ROOTCA_DIR}


keytool -v \
        -genkeypair \
        -dname "CN=rootCA,OU=Certificate Authority,O=Verdi,C=CH" \
        -keystore ${ROOTCA_DIR}/identity.jks \
        -storepass changeit \
        -keypass changeit \
        -keyalg RSA \
        -keysize 2048 \
        -alias rootca \
        -validity 3650 \
        -deststoretype pkcs12 \
        -ext KeyUsage=digitalSignature,keyCertSign \
        -ext BasicConstraints=ca:true,PathLen:3

keytool -v \
        -exportcert \
        -file ${ROOTCA_DIR}/rootca.pem \
        -alias rootca \
        -keystore ${ROOTCA_DIR}/identity.jks \
        -storepass changeit \
        -rfc


# -------------------------------- #
# Create server certificate
# -------------------------------- #

SERVER_DIR="./server"


if [ -d "$SERVER_DIR" ]
then
  rm -Rf $SERVER_DIR
fi

mkdir $SERVER_DIR

keytool -v \
        -genkeypair \
        -dname "CN=server-example.io" \
        -keystore ${SERVER_DIR}/identity.jks \
        -storepass changeit \
        -keypass changeit \
        -keyalg RSA \
        -keysize 2048 \
        -alias server \
        -validity 3650 \
        -deststoretype pkcs12 \
        -ext KeyUsage=digitalSignature,dataEncipherment,keyEncipherment,keyAgreement \
        -ext ExtendedKeyUsage=serverAuth,clientAuth \
        -ext SubjectAlternativeName:c=DNS:localhost,IP:127.0.0.1

keytool -v \
        -certreq \
        -file ${SERVER_DIR}/server.csr \
        -keystore ${SERVER_DIR}/identity.jks \
        -alias server \
        -keypass changeit \
        -storepass changeit \
        -keyalg rsa

# Certificate signing request
keytool -v \
        -gencert \
        -infile ${SERVER_DIR}/server.csr \
        -outfile ${SERVER_DIR}/server-signed.cer \
        -keystore ${ROOTCA_DIR}/identity.jks \
        -storepass changeit \
        -alias rootca \
        -validity 3650 \
        -ext KeyUsage=digitalSignature,dataEncipherment,keyEncipherment,keyAgreement \
        -ext ExtendedKeyUsage=serverAuth,clientAuth \
        -ext SubjectAlternativeName:c=DNS:localhost,DNS:raspberrypi.local,IP:127.0.0.1 \
        -rfc

# Import signed certificate
keytool -v \
        -importcert \
        -file ${ROOTCA_DIR}/rootca.pem \
        -alias rootca \
        -keystore ${SERVER_DIR}/identity.jks \
        -storepass changeit \
        -noprompt

keytool -v \
        -importcert \
        -file ${SERVER_DIR}/server-signed.cer \
        -alias server \
        -keystore ${SERVER_DIR}/identity.jks \
        -storepass changeit

keytool -v \
        -delete \
        -alias rootca \
        -keystore ${SERVER_DIR}/identity.jks \
        -storepass changeit

# Trusting the Certificate Authority Only
keytool -v \
        -importcert \
        -file ${ROOTCA_DIR}/rootca.pem \
        -alias rootca \
        -keystore ${SERVER_DIR}/truststore.jks \
        -storepass changeit \
        -noprompt

# -------------------------------- #
# Create client certificate
# -------------------------------- #
CLIENT_DIR="./client"

if [ -d "$CLIENT_DIR" ]
then
  rm -Rf $CLIENT_DIR
fi

mkdir $CLIENT_DIR

keytool -v \
       -genkeypair \
       -dname "CN=client-example.io" \
       -keystore ${CLIENT_DIR}/identity.jks \
       -storepass changeit \
       -keypass changeit \
       -keyalg RSA \
       -keysize 2048 \
       -alias client \
       -validity 3650 \
       -deststoretype pkcs12 \
       -ext KeyUsage=digitalSignature,dataEncipherment,keyEncipherment,keyAgreement \
       -ext ExtendedKeyUsage=serverAuth,clientAuth

# Certificate signing request
keytool -v \
        -certreq \
        -file ${CLIENT_DIR}/client.csr \
        -keystore ${CLIENT_DIR}/identity.jks \
        -alias client \
        -keypass changeit \
        -storepass changeit \
        -keyalg rsa

# Sign certificate with through CA
keytool -v \
        -gencert \
        -infile ${CLIENT_DIR}/client.csr \
        -outfile ${CLIENT_DIR}/client-signed.cer \
        -keystore ${ROOTCA_DIR}/identity.jks \
        -storepass changeit \
        -alias rootca \
        -validity 3650 \
        -ext KeyUsage=digitalSignature,dataEncipherment,keyEncipherment,keyAgreement \
        -ext ExtendedKeyUsage=serverAuth,clientAuth -rfc

# Import signed certificate
keytool -v \
        -importcert \
        -file ${ROOTCA_DIR}/rootca.pem \
        -alias rootca \
        -keystore ${CLIENT_DIR}/identity.jks \
        -storepass changeit \
        -noprompt

keytool -v \
        -importcert \
        -file ${CLIENT_DIR}/client-signed.cer \
        -alias client \
        -keystore ${CLIENT_DIR}/identity.jks \
        -storepass changeit

keytool -v \
        -delete \
        -alias rootca \
        -keystore ${CLIENT_DIR}/identity.jks \
        -storepass changeit


# Export PKCS#12 file for client
keytool -v \
        -importkeystore \
        -srckeystore ${CLIENT_DIR}/identity.jks \
        -destkeystore ${CLIENT_DIR}/client-signed.p12 \
        -deststoretype PKCS12 \
        -srcalias client \
        -destalias client \
        -srcstorepass changeit \
        -deststorepass changeit \
        -srckeypass changeit \
        -destkeypass changeit \
        -noprompt

