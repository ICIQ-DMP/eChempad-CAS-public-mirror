#!/bin/env bash

# Entrypoint of the docker container

# Get /run/secrets/CAS_CERTIFICATE and put it into /etc/cas/cas.crt
cp /run/secrets/CAS_CERTIFICATE /cas-overlay/cas.crt

# Gets eChempad-CAS certificate from /run/secrets/CAS_CERTIFICATE and injects it in the truststore of the
# JVM pointed by ${JAVA_HOME}/lib/security/cacerts
if "${JAVA_HOME}/bin/keytool" -trustcacerts -keystore "${JAVA_HOME}/lib/security/cacerts" -storepass "changeit" -list -alias "eChempad-CAS"; then
  echo "*** - INFO: Certificate eChempad-CAS present in ${JAVA_HOME}/lib/security/cacerts, removing and reinstalling"
  "${JAVA_HOME}/bin/keytool" -delete -alias "eChempad-CAS" -keystore "${JAVA_HOME}/lib/security/cacerts" -storepass "changeit"
fi
keytool -import -noprompt -trustcacerts \
   -file "/run/secrets/CAS_CERTIFICATE" \
   -keystore "${JAVA_HOME}/lib/security/cacerts" \
   -storepass changeit \
   -keypass changeit \
   -alias eChempad-CAS

# Gets eChempad certificate from /run/secrets/ECHEMPAD_CERTIFICATE and injects it in the truststore of
# the truststore of the JVM pointed by ${JAVA_HOME}/lib/security/cacerts
if "${JAVA_HOME}/bin/keytool" -keystore "${JAVA_HOME}/lib/security/cacerts" -storepass "changeit" -list -alias "eChempad"; then
  echo "*** - INFO: Certificate eChempad present in ${JAVA_HOME}/lib/security/cacerts, removing and reinstalling"
  "${JAVA_HOME}/bin/keytool" -delete -alias "eChempad" -keystore "${JAVA_HOME}/lib/security/cacerts" -storepass "changeit"
fi
keytool -import -noprompt -trustcacerts \
   -file "/run/secrets/ECHEMPAD_CERTIFICATE" \
   -keystore "${JAVA_HOME}/lib/security/cacerts" \
   -storepass changeit \
   -keypass changeit \
   -alias eChempad

# Get /run/secrets/CAS_CERTIFICATE and put it into /cas-overlay/eChempad.crt
cp /run/secrets/ECHEMPAD_CERTIFICATE /cas-overlay/eChempad.crt

# Inject into the application properties:
# DB password
# LDAP password
# CAS_TCG_CRYPTO_ENCRYPTION_KEY
# CAS_TGC_CRYPTO_SIGNING_KEY
# CAS_WEBFLOW_CRYPTO_ENCRYPTION_KEY
# CAS_WEBFLOW_CRYPTO_SIGNING_KEY
#TODO borrar
echo AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA PASS:
echo   -Dcas.authn.jdbc.query[0].password=$(cat /run/secrets/DB_PASSWORD)

java \
  -Dcas.authn.jdbc.query[0].user=eChempad \
  -Dcas.authn.jdbc.query[0].password=$(cat /run/secrets/DB_PASSWORD) \
  -Dcas.authn.ldap[0].bind-credential=$(cat /run/secrets/LDAP_TOKEN) \
  -Dcas.authn.pac4j.oauth2[0].secret=$(cat /run/secrets/ORCID_TOKEN) \
  -Dcas.tgc.crypto.encryption.key=$(cat /run/secrets/CAS_TGC_CRYPTO_ENCRYPTION_KEY) \
  -Dcas.tgc.crypto.signing.key=$(cat /run/secrets/CAS_TGC_CRYPTO_SIGNING_KEY) \
  -Dcas.webflow.crypto.encryption.key=$(cat /run/secrets/CAS_WEBFLOW_CRYPTO_ENCRYPTION_KEY) \
  -Dcas.webflow.crypto.signing.key=$(cat /run/secrets/CAS_WEBFLOW_CRYPTO_SIGNING_KEY) \
  -server \
  -noverify \
  -Xmx2048M \
  -jar cas.war
