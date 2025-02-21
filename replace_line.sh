#!/bin/bash

# Sprawdzamy, czy plik servers.ini istnieje
if [ ! -f servers.ini ]; then
    echo "[servers]" > servers.ini
fi

# Tworzymy tymczasowy plik
temp_file=$(mktemp)

# Kopiujemy pierwszą linię (nagłówek) do pliku tymczasowego
head -n 1 servers.ini > "$temp_file"

# Dodajemy każdy serwer jako pojedynczą linię
while IFS= read -r server; do
    if [ -n "$server" ]; then
        echo "${server} ansible_host=${server} ansible_connection=local" >> "$temp_file"
    fi
done < servers.txt

# Dodajemy resztę oryginalnego pliku (wszystko po pierwszej linii)
tail -n +2 servers.ini >> "$temp_file"

# Zastępujemy oryginalny plik
mv "$temp_file" servers.ini

echo "Plik servers.ini został zaktualizowany. Każdy serwer z servers.txt jest teraz w osobnej linii."
