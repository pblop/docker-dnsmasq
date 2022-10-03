#!/bin/sh

# Start dnsmasq_exporter 
dnsmasq_exporter --listen 0.0.0.0:9153 &
ID=$!

# Start dnsmasq through webproc
webproc -c /etc/dnsmasq.conf -- dnsmasq --keep-in-foreground --log-facility=- --log-async
  
# Wait for any process to exit
kill -0 $ID
