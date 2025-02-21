#!/bin/bash

# Sprawdźmy, czy plik servers.ini istnieje, jeśli nie - tworzymy go z nagłówkiem
if [ ! -f servers.ini ]; then
    echo "[servers]" > servers.ini
fi

# Zachowaj pierwszą linię (nagłówek) z istniejącego pliku
header=$(head -n 1 servers.ini)

# Tworzymy tymczasowy plik z nagłówkiem
echo "$header" > servers.ini.tmp

# Dodajemy odpowiednio sformatowane wpisy serwerów bezpośrednio z pliku
while IFS= read -r server; do
    # Pomijamy puste linie
    if [ -n "$server" ]; then
        # Dokładnie formatujemy linię bez dodatkowych znaków nowej linii
        echo "${server} ansible_host=${server} ansible_connection=local" >> servers.ini.tmp
    fi
done < servers.txt

# Kopiujemy zawartość pliku tymczasowego do docelowego
mv servers.ini.tmp servers.ini

echo "Plik servers.ini został zaktualizowany. Każdy serwer jest teraz w osobnej linii."
