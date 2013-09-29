#!/usr/bin/env bash

if [ ! -d mappings ]; then
    mkdir mappings
fi
cd mappings

# COMBINEDI : CCLO <-> ANZSCO

curl "https://docs.google.com/spreadsheet/pub?key=0AsjX9EgXuAkDdDAwTnRWaENIYnhYLXZtb1pWcnk2cEE&single=true&gid=11&output=csv" > combinedi.csv
curl "https://docs.google.com/spreadsheet/pub?key=0AsjX9EgXuAkDdDAwTnRWaENIYnhYLXZtb1pWcnk2cEE&single=true&gid=12&output=csv" > cclo_combinedi.csv
curl "https://docs.google.com/spreadsheet/pub?key=0AsjX9EgXuAkDdDAwTnRWaENIYnhYLXZtb1pWcnk2cEE&single=true&gid=13&output=csv" > anzsco_combinedi.csv

# COMBINEDII : ASCOII <-> ANZSCO
curl "https://docs.google.com/spreadsheet/pub?key=0AsjX9EgXuAkDdDAwTnRWaENIYnhYLXZtb1pWcnk2cEE&single=true&gid=7&output=csv" > combinedii.csv
curl "https://docs.google.com/spreadsheet/pub?key=0AsjX9EgXuAkDdDAwTnRWaENIYnhYLXZtb1pWcnk2cEE&single=true&gid=8&output=csv" > ascoii_combinedii.csv
curl "https://docs.google.com/spreadsheet/pub?key=0AsjX9EgXuAkDdDAwTnRWaENIYnhYLXZtb1pWcnk2cEE&single=true&gid=9&output=csv" > anzscoii_combinedii.csv

