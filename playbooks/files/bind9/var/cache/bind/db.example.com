; BIND reverse data file for empty rfc1918 zone
;
; DO NOT EDIT THIS FILE - it is used for multiple zones.
; Instead, copy it, edit named.conf, and use that copy.
;
$TTL    5
@	IN	SOA	nodo1.example.com. vagrant.example.com. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@	IN	NS	nodo1.example.com.
$ORIGIN	example.com.

nodo1		IN	A	10.0.100.2
nodo2		IN	A	10.0.100.3
drupalkevin	IN	CNAME	nodo2
