#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
time=$(date +%s)
giorni=$((($(date +%s)-$(date +%s --date "2019-01-19"))/(3600*24)))
persone="47"
ora=$(date +"%k")
oraW=$(echo "$ora*100" | bc)

source "$folder"/api

urlSW="https://www.vesselfinder.com/it/vessels/SEA-WATCH-3-IMO-7302225-MMSI-244140096"
urlPAP="https://www.vesselfinder.com/it/vessels/PROF-ALBRECHT-PENCK-IMO-5285667-MMSI-211215130"

## SEA-WATCH 3 Coordinates
curl -sL -c "$folder"/cookie 'https://www.vesselfinder.com/it/vessels/SEA-WATCH-3-IMO-7302225-MMSI-244140096' -H 'authority: www.vesselfinder.com' -H 'cache-control: max-age=0' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.17 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'referer: https://www.vesselfinder.com/it/?imo=5285667' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: it,en-US;q=0.9,en;q=0.8'  --compressed  >/dev/null

swCoord=$(curl -sL -b "$folder"/cookie 'https://www.vesselfinder.com/it/vessels/SEA-WATCH-3-IMO-7302225-MMSI-244140096' -H 'authority: www.vesselfinder.com' -H 'cache-control: max-age=0' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.17 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'referer: https://www.vesselfinder.com/it/?imo=5285667' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: it,en-US;q=0.9,en;q=0.8'  --compressed | \
# la seconda cella, dentro la riga che contiente "Coordinate", dentro la prima tabella successiva al titolo "Dati AIS"
scrape -be '//h2[contains(text(),"Dati AIS")]/following::table[1]//tr[td[contains(text(),"Coordinate")]]/td[2]' | \
xq -r '.html.body.td."#text"' | \
sed -r 's/^(.*?[0-9])( [A-Z]\/)(.*?)( .*)$/\1,\3/g')

latSW=$(echo "$swCoord" | cut -d ',' -f 1)
lonSW=$(echo "$swCoord" | cut -d ',' -f 2)


### dati meteo SEA-WATCH 3
meteoSW=$(curl -sL "https://api.stormglass.io/point?lat=$latSW&lng=$lonSW&params=waveHeight,airTemperature" -H "Authorization: $weatherAPI" | jq -r '.hours[0]|[.airTemperature[0].value,.waveHeight[0].value]|.[]')

#meteoSW=$(curl -sL "https://api.worldweatheronline.com/premium/v1/marine.ashx?key=$aweatherAPI&format=json&tp=1&q=$latSW,$lonSW&lang=it" | jq -r '.data.weather[0].hourly[] | select(.time=="'"$oraW"'")|[.tempC,.swellHeight_m]|.[]' | sed 's/"//g')


waveHeightSW=$(echo "$meteoSW" | tr "\n" "," | cut -d ',' -f 2)
airTemperatureSW=$(echo "$meteoSW" | tr "\n" "," | cut -d ',' -f 1)

<<comment1
## PROF ALBRECHT PENCK Coordinates
curl -sL -c "$folder"/cookie 'https://www.vesselfinder.com/it/vessels/PROF-ALBRECHT-PENCK-IMO-5285667-MMSI-211215130' -H 'authority: www.vesselfinder.com' -H 'cache-control: max-age=0' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.17 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'referer: https://www.vesselfinder.com/it/?imo=5285667' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: it,en-US;q=0.9,en;q=0.8'  --compressed  >/dev/null

swCoord=$(curl -sL -b "$folder"/cookie 'https://www.vesselfinder.com/it/vessels/PROF-ALBRECHT-PENCK-IMO-5285667-MMSI-211215130' -H 'authority: www.vesselfinder.com' -H 'cache-control: max-age=0' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.17 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'referer: https://www.vesselfinder.com/it/?imo=5285667' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: it,en-US;q=0.9,en;q=0.8'  --compressed | \
# la seconda cella, dentro la riga che contiente "Coordinate", dentro la prima tabella successiva al titolo "Dati AIS"
scrape -be '//h2[contains(text(),"Dati AIS")]/following::table[1]//tr[td[contains(text(),"Coordinate")]]/td[2]' | \
xq -r '.html.body.td."#text"' | \
sed -r 's/^(.*?[0-9])( [A-Z]\/)(.*?)( .*)$/\1,\3/g')

latPAP=$(echo "$swCoord" | cut -d ',' -f 1)
lonPAP=$(echo "$swCoord" | cut -d ',' -f 2)

### dati meteo PROF ALBRECHT PENCK
meteoPAP=$(curl -sL "https://api.stormglass.io/point?lat=$latPAP&lng=$lonPAP&params=waveHeight,airTemperature&start=$time&end=$time&source=dwd" -H "Authorization: $weatherAPI" | jq -r '.hours[0]|[.airTemperature[0].value,.waveHeight[0].value]|.[]')

#meteoPAP=$(curl -sL "https://api.worldweatheronline.com/premium/v1/marine.ashx?key=$aweatherAPI&format=json&tp=1&q=$latPAP,$lonPAP&lang=it" | jq -r '.data.weather[0].hourly[] | select(.time=="'"$oraW"'")|[.tempC,.swellHeight_m]|.[]' | sed 's/"//g')

waveHeightPAP=$(echo "$meteoSW" | tr "\n" "," | cut -d ',' -f 2)
airTemperaturePAP=$(echo "$meteoSW" | tr "\n" "," | cut -d ',' -f 1)
comment1

## map image
#coordsY=$(echo "($latSW+$latPAP)/2.0" | bc -l)
#coordsX=$(echo "($lonSW+$lonPAP)/2.0" | bc -l)
coordsY="$latSW"
coordsX="$lonSW"
# wget -O "$folder"/map.png "https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-1+9ed4bd($lonSW,$latSW),pin-s-2+000($lonPAP,$latPAP)/$coordsX,$coordsY,8,0,0/1024x512?access_token=$mapboxAPI"
wget -O "$folder"/map.png "https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/pin-s-1+9ed4bd($lonSW,$latSW)/$coordsX,$coordsY,5,0,0/1024x512?access_token=$mapboxAPI"

## tweet
testo='
Da '"$giorni"' giorni '"$persone"' sono a bordo di #SEAWATCH 3: temperatura di '"$airTemperatureSW"' °C, onda di '"$waveHeightSW"' m '"$urlSW"'
#ApriteIPorti
'

twurl set default ondatait
twurl -H upload.twitter.com "/1.1/media/upload.json" -f "$folder"/map.png -F media -X POST | jq -r '.media_id_string' >"$folder"/tmp_t.json
mediaID=$(cat "$folder"/tmp_t.json)
twurl "/1.1/statuses/update.json" -d "media_ids=$mediaID&status=$testo"
<<commento2
commento2
