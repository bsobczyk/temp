#!/bin/bash

# Upewnijmy się, że plik servers.ini istnieje z nagłówkiem
if [ ! -f servers.ini ]; then
    echo "[servers]" > servers.ini
fi

# Tworzenie tymczasowego pliku
temp_file=$(mktemp)

# Zapisanie nagłówka do pliku tymczasowego
head -n 1 servers.ini > "$temp_file"

# Przetwarzanie każdej linii z servers.txt
while IFS= read -r server; do
    # Ignoruj puste linie
    if [ -n "$server" ]; then
        # Usuń wszystkie dodatkowe spacje i znaki końca linii
        server=$(echo "$server" | tr -d '\r' | xargs)
        echo "$server ansible_host=$server ansible_connection=local" >> "$temp_file"
    fi
done < servers.txt

# Dodaj pozostałą zawartość pliku servers.ini (jeśli istnieje)
if [ $(wc -l < servers.ini) -gt 1 ]; then
    tail -n +2 servers.ini >> "$temp_file"
fi

# Zastąp oryginalny plik
cat "$temp_file" > servers.ini
rm "$temp_file"

echo "Plik servers.ini został zaktualizowany. Każda linia z servers.txt została zamieniona na jedną linię w servers.ini."
