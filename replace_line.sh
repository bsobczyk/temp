#!/bin/bash

# Generowanie wpisów do pliku ini
ini_entries=""
while IFS= read -r server; do
    # Pomijaj puste linie
    if [ -n "$server" ]; then
        ini_entries+="$server ansible_host=$server ansible_connection=local\n"
    fi
done < servers.txt

# Odczytanie istniejącej zawartości pliku ini
existing_content=$(cat servers.ini 2>/dev/null || echo "[servers]")

# Zapisanie nowych wpisów od drugiej linii pliku ini
echo -e "$(echo "$existing_content" | head -n 1)\n$ini_entries$(echo "$existing_content" | tail -n +2 2>/dev/null || echo "")" > servers.ini

echo "Nowe wpisy zostały dodane od drugiej linii pliku servers.ini."
