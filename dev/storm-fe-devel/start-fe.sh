#!/bin/bash

export X509_USER_CERT=/etc/grid-security/storm/hostcert.pem
export X509_USER_KEY=/etc/grid-security/storm/hostkey.pem

/usr/sbin/storm-frontend-server -c /etc/storm/frontend-server/storm-frontend-server.conf 
