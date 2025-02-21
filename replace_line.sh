#!/bin/bash

# Generowanie wpisów do pliku ini
ini_entries=""
while IFS= read -r server; do
    # Pomijaj puste linie
    if [ -n "$server" ]; then
        # Usuwamy wszystkie znaki nowej linii i dodajemy tylko jeden na końcu
        ini_entries+="${server} ansible_host=${server} ansible_connection=local\n"
    fi
done < servers.txt

# Sprawdzamy czy plik servers.ini istnieje
if [ ! -f servers.ini ]; then
    echo "[servers]" > servers.ini
fi

# Odczytanie istniejącej zawartości pliku ini
header=$(head -n 1 servers.ini)
rest=$(tail -n +2 servers.ini 2>/dev/null || echo "")

# Zapisanie zawartości do pliku
echo -e "${header}\n${ini_entries}${rest}" > servers.ini

echo "Nowe wpisy zostały dodane od drugiej linii pliku servers.ini."
