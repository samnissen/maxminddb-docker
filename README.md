# maxminddb-docker

Push-button deployment of a dockerized JSON web server
to host [MaxMind's free GeoCity2 Lite database](http://maxmind.github.io/MaxMind-DB/)
utilizing the Ruby gem [maxminddb](https://github.com/yhirose/maxminddb/), and SQLite database version.

Allows to find locality by ip address or by name of country, region, city. Search options support different languages, see all supported languages on the [GeoIP2](https://dev.maxmind.com/geoip/geoip2/web-services/#Languages) page.

## Using it

```
docker run --restart=always -p 8080:8080 -d -it samnissen/maxminddb

curl -XGET localhost:8080/api -d 'ip=1.2.3.4'
=> {"continent":{"code":"NA","geoname_id":6255149,"names":{"de":"Nordamerika","en":"North America","es":"Norteamérica","fr":"Amérique du Nord","ja":"北アメリカ","pt-BR":"América do Norte","ru":"Северная Америка","zh-CN":"北美洲"}},"country":{"geoname_id":6252001,"iso_code":"US","names":{"de":"USA","en":"United States","es":"Estados Unidos","fr":"États-Unis","ja":"アメリカ合衆国","pt-BR":"Estados Unidos","ru":"США","zh-CN":"美国"}},"location":{"accuracy_radius":1000,"latitude":37.751,"longitude":-97.822},"registered_country":{"geoname_id":2077456,"iso_code":"AU","names":{"de":"Australien","en":"Australia","es":"Australia","fr":"Australie","ja":"オーストラリア","pt-BR":"Austrália","ru":"Австралия","zh-CN":"澳大利亚"}}}

curl -XGET localhost:8080/api -d 'location[city]=London&location[region]=OH&location[country]=US'
=>{"ip":"12.54.76.0/23","location":{"latitude":"39.8979","longitude":"-83.3866","locality_type":"city"}}
```

You can search by different languages
```
curl -XGET localhost:8080/api -d 'location[city]=London&location[region]=England&location[country]=United Kingdom'
=>{"ip":"2.16.37.0/24","location":{"latitude":"51.5142","longitude":"-0.0931","locality_type":"city"}}

curl -XGET localhost:8080/api -d 'location[city]=ロンドン&location[region]=イングランド&location[country]=イギリス'
=>{"ip":"2.16.37.0/24","location":{"latitude":"51.5142","longitude":"-0.0931","locality_type":"city"}}
```

The 'locality type' attribute shows that exactly you got country, region or city.
```
curl -XGET localhost:8080/api -d 'location[country]=Brazil'
=>{"ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"country"}}

curl -XGET localhost:8080/api -d 'location[region]=Pernambuco'
=>{"ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"region"}}

curl -XGET localhost:8080/api -d 'location[city]=Xexeu'
=>{"ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"city"}}
```

The result is always one point of the location with one network, that is, if you are looking for a city by name, and in the world there are many such cities, then you will get an empty hash, but if this city name is unique, you will get a successful search result.

For example. Xexeu the city in Brazil with unique city name
```
curl -XGET localhost:8080/api -d 'location[city]=Xexeu'
=>{"ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"city"}}
curl -XGET localhost:8080/api -d 'location[region]=Pernambuco&location[city]=Xexeu'
=>{"ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"city"}}
curl -XGET localhost:8080/api -d 'location[country]=Brazil&location[region]=Pernambuco&location[city]=Xexeu'
=>{"ip":"167.250.18.0/25","location":{"latitude":"-8.8647","longitude":"-35.6427","locality_type":"city"}}
```

Paris in Canada, cities with this name are also present in France and the United States
```
curl -XGET localhost:8080/api -d 'location[city]=Paris'
=>{}
curl -XGET localhost:8080/api -d 'location[region]=Ontario&location[city]=Paris'
=>{"ip":"65.92.52.0/24","location":{"latitude":"43.2000","longitude":"-80.3833","locality_type":"city"}}

curl -XGET localhost:8080/api -d 'location[country]=Canada&location[city]=Paris'
=>{"ip":"65.92.52.0/24","location":{"latitude":"43.2000","longitude":"-80.3833","locality_type":"city"}}
```

London in the United States is present in several states: Arkansas, Kentucky, Ohio, Texas
```
curl -XGET localhost:8080/api -d 'location[city]=London'
=>{}
curl -XGET localhost:8080/api -d 'location[region]=Ohio&location[city]=London'
=>{"ip":"12.54.76.0/23","location":{"latitude":"39.8979","longitude":"-83.3866","locality_type":"city"}}

curl -XGET localhost:8080/api -d 'location[country]=USA&location[city]=london'
=>{"ip":"4.14.18.0/25","location":{"latitude":"33.4201","longitude":"-86.7867","locality_type":"country"}}%

curl -XGET localhost:8080/api -d 'location[country]=USA&location[region]=Ohio&location[city]=London'
=>{"ip":"12.54.76.0/23","location":{"latitude":"39.8979","longitude":"-83.3866","locality_type":"city"}}
```

#### Or, build it in your own image
```
git clone git@github.com:samnissen/maxminddb-docker.git
```
In config/settings.yml edit GeoLite2-City-CSV folder path, City-IPv4-Blocks file path, GeoLite2-City-Locations file path template and add or remove supported languages.
```
docker build -t maxminddb .
```
Attention, during build, the GeoIP2 database is converted into a SQLite database - it can take up to a few hours.
```
docker run --restart=always -p 8080:8080 -d -it maxminddb

curl -XGET localhost:8080/api -d 'ip=1.2.3.4'
=> {"continent":{"code":"NA","geoname_id":6255149,"names":{"de":"Nordamerika","en":"North America","es":"Norteamérica","fr":"Amérique du Nord","ja":"北アメリカ","pt-BR":"América do Norte","ru":"Северная Америка","zh-CN":"北美洲"}},"country":{"geoname_id":6252001,"iso_code":"US","names":{"de":"USA","en":"United States","es":"Estados Unidos","fr":"États-Unis","ja":"アメリカ合衆国","pt-BR":"Estados Unidos","ru":"США","zh-CN":"美国"}},"location":{"accuracy_radius":1000,"latitude":37.751,"longitude":-97.822},"registered_country":{"geoname_id":2077456,"iso_code":"AU","names":{"de":"Australien","en":"Australia","es":"Australia","fr":"Australie","ja":"オーストラリア","pt-BR":"Austrália","ru":"Австралия","zh-CN":"澳大利亚"}}}

curl -XGET localhost:8080/api -d 'location[city]=London&location[region]=ENG&location[country]=GBR'
=>{"ip":"2.16.37.0/24","location":{"latitude":"51.5142","longitude":"-0.0931","locality_type":"city"}}
```

## Contributing

1. Fork it ( https://github.com/samnissen/maxminddb-docker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
