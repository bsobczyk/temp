#!/bin/bash

# Odczytanie zawartości pliku servers.txt
servers=$(cat servers.txt)

# Generowanie wpisów do pliku ini
ini_entries=""
while IFS= read -r server; do
    ini_entries+="$server ansible_host=$server ansible_connection=local\n"
done <<< "$servers"

# Odczytanie istniejącej zawartości pliku ini
existing_content=$(cat servers.ini)

# Zapisanie nowych wpisów od drugiej linii pliku ini
echo -e "$(head -n 1 servers.ini)\n$ini_entries$(tail -n +2 servers.ini)" > servers.ini

echo "Nowe wpisy zostały dodane od drugiej linii pliku servers.ini."
