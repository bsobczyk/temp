#!/bin/bash

# Sprawdzenie czy skrypt jest uruchomiony z uprawnieniami roota
if [ "$EUID" -ne 0 ]; then 
    echo "Uruchom skrypt jako root"
    exit 1
fi

# Instalacja BIND9
echo "Instalacja BIND9..."
apt-get update
apt-get install -y bind9 bind9utils bind9-doc

# Konfiguracja głównego pliku named.conf.local
echo "Konfiguracja named.conf.local..."
cat > /etc/bind/named.conf.local << EOL
zone "hole" {
    type master;
    file "/etc/bind/db.hole";
};
EOL

# Konfiguracja pliku strefy
echo "Tworzenie pliku strefy..."
cat > /etc/bind/db.hole << EOL
\$TTL    604800
@       IN      SOA     hole. root.hole. (
                     2024011901         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.hole.
@       IN      A       127.0.0.1
ns      IN      A       127.0.0.1
vc      IN      A       192.168.137.191
EOL

# Konfiguracja named.conf.options
echo "Konfiguracja named.conf.options..."
cat > /etc/bind/named.conf.options << EOL
options {
    directory "/var/cache/bind";
    recursion yes;
    listen-on { any; };
    allow-query { any; };
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    dnssec-validation auto;
};
EOL

# Sprawdzenie poprawności konfiguracji
echo "Sprawdzanie konfiguracji..."
named-checkconf
named-checkzone hole /etc/bind/db.hole

# Restart usługi BIND9
echo "Restart usługi BIND9..."
systemctl restart bind9
systemctl enable bind9

# Sprawdzenie statusu usługi
echo "Sprawdzanie statusu usługi..."
systemctl status bind9

echo "Konfiguracja zakończona. Sprawdź działanie za pomocą:"
echo "nslookup vc.hole"
echo "dig vc.hole"
