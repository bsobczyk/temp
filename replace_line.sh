#!/bin/bash

# Sprawdzamy, czy plik servers.ini istnieje
if [ ! -f servers.ini ]; then
    echo "[servers]" > servers.ini
fi

# Zapisujemy pierwszą linię (nagłówek)
header=$(head -n 1 servers.ini)

# Zapisujemy resztę pliku (wszystko po pierwszej linii)
tail_content=$(tail -n +2 servers.ini)

# Tworzymy tymczasowy plik z nagłówkiem
echo "$header" > servers.ini.tmp

# Dodajemy odpowiednio sformatowane wpisy serwerów
while IFS= read -r server; do
    # Pomijamy puste linie
    if [ -n "$server" ]; then
        echo "${server} ansible_host=${server} ansible_connection=local" >> servers.ini.tmp
    fi
done < servers.txt

# Dodajemy pozostałą zawartość pliku
echo "$tail_content" >> servers.ini.tmp

# Zamieniamy plik tymczasowy na docelowy
mv servers.ini.tmp servers.ini

echo "Plik servers.ini został zaktualizowany. Nowe serwery dodane po nagłówku, a istniejąca zawartość zachowana."
