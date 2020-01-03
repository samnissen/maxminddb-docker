# maxminddb-docker

Push-button deployment of a dockerized JSON web server
to host [MaxMind's free GeoCity2 Lite database](http://maxmind.github.io/MaxMind-DB/)
utilizing the Ruby gem [maxminddb](https://github.com/yhirose/maxminddb/), and a SQLite database.

maxminddb-docker allows you geolocate by IP address
or by name of country, region, and/or city.
Search options support different languages, based on
the supported languages on the
[GeoIP2](https://dev.maxmind.com/geoip/geoip2/web-services/#Languages) page.

## Using it

```
docker run --restart=always -p 8080:8080 -d -it samnissen/maxminddb

curl -XGET localhost:8080/api -d 'ip=8.8.4.4'
#=> { "continent":{"code":"NA","geoname_id":6255149,"names":{"de":"Nordamerika","en":"North America","es":"Norteamérica","fr":"Amérique du Nord","ja":"北アメリカ","pt-BR":"América do Norte","ru":"Северная Америка","zh-CN":"北美洲"}},"country":{"geoname_id":6252001,"iso_code":"US","names":{"de":"USA","en":"United States","es":"Estados Unidos","fr":"États-Unis","ja":"アメリカ合衆国","pt-BR":"Estados Unidos","ru":"США","zh-CN":"美国"}},"location":{"accuracy_radius":1000,"latitude":37.751,"longitude":-97.822,"time_zone":"America/Chicago"},"registered_country":{"geoname_id":6252001,"iso_code":"US","names":{"de":"USA","en":"United States","es":"Estados Unidos","fr":"États-Unis","ja":"アメリカ合衆国","pt-BR":"Estados Unidos","ru":"США","zh-CN":"美国"}},"network":"8.8.0.0/17"}

curl -XGET localhost:8080/api -d 'location[city]=London&location[region]=OH&location[country]=US'
#=> { "ip":"24.123.142.8/29","location":{"latitude":"39.9001","longitude":"-83.4439","locality_type":"city"}}
```

You can search by different languages
```
curl -XGET localhost:8080/api -d 'location[city]=London&location[region]=England&location[country]=United Kingdom'
#=> { "ip":"2.16.37.0/24","location":{"latitude":"51.5142","longitude":"-0.0931","locality_type":"city"}}

curl -XGET localhost:8080/api -d 'location[city]=ロンドン&location[region]=イングランド&location[country]=イギリス'
#=> { "ip":"2.16.37.0/24","location":{"latitude":"51.5142","longitude":"-0.0931","locality_type":"city"}}
```

The 'locality type' attribute shows that exactly you got country, region or city.
```
curl -XGET localhost:8080/api -d 'location[country]=Brazil'
#=> { "ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"country"}}

curl -XGET localhost:8080/api -d 'location[region]=Pernambuco'
#=> { "ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"region"}}

curl -XGET localhost:8080/api -d 'location[city]=Xexeu'
#=> { "ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"city"}}
```

The result is always one point of the location with one network.
That is, if you are looking for a city by name,
and in the world there are many such cities,
then you will get an empty hash. But if this city name is unique,
you will get a successful search result.

For example, the city of Xexeu in Brazil is unique:
```
curl -XGET localhost:8080/api -d 'location[city]=Xexeu'
#=> { "ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"city"}}
curl -XGET localhost:8080/api -d 'location[region]=Pernambuco&location[city]=Xexeu'
#=> { "ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"city"}}
curl -XGET localhost:8080/api -d 'location[country]=Brazil&location[region]=Pernambuco&location[city]=Xexeu'
#=> { "ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"city"}}
```

Cities with the name Paris are present in France, United States and Canada:
```
curl -XGET localhost:8080/api -d 'location[city]=Paris'
#=> { }
curl -XGET localhost:8080/api -d 'location[region]=Ontario&location[city]=Paris'
#=> { "ip":"65.92.52.0/24","location":{"latitude":"43.2000","longitude":"-80.3833","locality_type":"city"}}

curl -XGET localhost:8080/api -d 'location[country]=Canada&location[city]=Paris'
#=> { "ip":"65.92.52.0/24","location":{"latitude":"43.2000","longitude":"-80.3833","locality_type":"city"}}
```

London in the United States is present in several states:
```
curl -XGET localhost:8080/api -d 'location[city]=London'
#=> { }
curl -XGET localhost:8080/api -d 'location[region]=Ohio&location[city]=London'
#=> {"ip":"12.54.76.0/23","location":{"latitude":"39.8979","longitude":"-83.3866","locality_type":"city"}}

curl -XGET localhost:8080/api -d 'location[country]=USA&location[city]=london'
#=> {"ip":"4.14.18.0/25","location":{"latitude":"33.4201","longitude":"-86.7867","locality_type":"country"}}%

curl -XGET localhost:8080/api -d 'location[country]=USA&location[region]=Ohio&location[city]=London'
#=> {"ip":"12.54.76.0/23","location":{"latitude":"39.8979","longitude":"-83.3866","locality_type":"city"}}
```

## Or, build your own image

### NEW: Register before building it

Maxmind has had to put its database behind login
for reasons detailed
in [this issue](https://github.com/samnissen/maxminddb-docker/issues/4).
This means that the link to download the database is unique to you,
and might only work for a limited amount of time &ndash;
see Maxmind documentation for more information.

This results in multiple changes:

1) You must
[register to Maxmind](https://www.maxmind.com/en/geolite2/signup)
and retrieve two URLs found on the Maxmind dashboard,
in the `GeoIP2` > `Download Files` section
of the Maxmind account page (as of December 2019).
These URLs must be modified using your API key per Maxmind's instructions.
(The `token` key has been replaced with `license_key`, for instance.)

2) These URLs must be saved in `.txt` files in the `secrets` directory
with any naming convention you prefer. Note that for this README,
the files are named:
- `secrets/geolite2citytar.txt` should contain your unique URL for the GZIP-ed GeoLite2-City database, and
- `secrets/geolite2citycsv.txt` should contain your unique URL for the ZIP-ed GeoLite2-City-CSV file

3) These links must be used in the `build` to identify your secrets' `src`s.
The `id`s must remain unchanged, as they correspond to the Dockerfile.

### Warning
During build, the GeoIP2 database is converted into a SQLite database -
it will likely take hours to build the image.

### Configuring options
In `config/settings.yml` edit GeoLite2-City-CSV folder path,
City-IPv4-Blocks file path, GeoLite2-City-Locations file path
template and add or remove supported languages.

```
git clone git@github.com:samnissen/maxminddb-docker.git

DOCKER_BUILDKIT=1 docker build \
--no-cache \
--progress=plain \
--secret id=geolite2citytar,src=secrets/geolite2citytar.txt \
--secret id=geolite2citycsv,src=secrets/geolite2citycsv.txt \
--squash \
-t maxminddb .

docker run --restart=always -p 8080:8080 -d -it maxminddb

curl -XGET localhost:8080/api -d 'ip=8.8.4.4'
#=> {"continent":{"code":"NA","geoname_id":6255149,"names":{"de":"Nordamerika","en":"North America","es":"Norteamérica","fr":"Amérique du Nord","ja":"北アメリカ","pt-BR":"América do Norte","ru":"Северная Америка","zh-CN":"北美洲"}},"country":{"geoname_id":6252001,"iso_code":"US","names":{"de":"USA","en":"United States","es":"Estados Unidos","fr":"États-Unis","ja":"アメリカ合衆国","pt-BR":"Estados Unidos","ru":"США","zh-CN":"美国"}},"location":{"accuracy_radius":1000,"latitude":37.751,"longitude":-97.822,"time_zone":"America/Chicago"},"registered_country":{"geoname_id":6252001,"iso_code":"US","names":{"de":"USA","en":"United States","es":"Estados Unidos","fr":"États-Unis","ja":"アメリカ合衆国","pt-BR":"Estados Unidos","ru":"США","zh-CN":"美国"}},"network":"8.8.0.0/17"}

curl -XGET localhost:8080/api -d 'location[city]=London&location[region]=ENG&location[country]=GBR'
#=> {"ip":"2.16.37.0/24","location":{"latitude":"51.5088","longitude":"-0.1260","locality_type":"city"}}
```

## Contributing

1. Fork it ( https://github.com/samnissen/maxminddb-docker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
