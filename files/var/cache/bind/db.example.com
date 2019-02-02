$ORIGIN .
$TTL 86400      ; 1 day
example.com     IN SOA nodo1.example.com. postmaster.example.com. (
                                1          ; serial
                                21600      ; refresh (6 hours)
                                3600       ; retry (1 hour)
                                604800     ; expire (1 week)
                                21600      ; minimum (6 hours)
                                )
                        NS      nodo1.example.com.
$ORIGIN	example.com.
nodo1	IN	A	10.0.100.2
nodo2	IN	A	10.0.100.3
drupal	IN	CNAME	nodo2
