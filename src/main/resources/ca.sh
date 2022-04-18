#!/bin/bash

keytool -genkeypair \
        -storepass password \
        -keyalg RSA \
        -keysize 2048 \
        -dname "CN=example-server" \
        -alias server \
        -ext "SAN:c=DNS:localhost,IP:127.0.0.1" \
        -keystore ./server-keystore.jks

keytool -genkeypair \
        -storepass password \
        -keyalg RSA \
        -keysize 2048 \
        -dname "CN=example-client" \
        -alias client \
        -ext "SAN:c=DNS:localhost,IP:127.0.0.1" \
        -keystore ./client-keystore.jks


cp ./client-keystore.jks ./server-truststore.jks

keytool -exportcert \
        -alias client \
        -storepass password \
        -keystore ./server-truststore.jks \
        -rfc \
        -file client.pem

