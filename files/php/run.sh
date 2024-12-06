#!/bin/bash

# Read all arguments in command line
while [ $# -gt 0 ]; do
	if [[ $1 == *"--"* ]]; then
		param="${1/--/}"
		param="${param/-/_}"
		IFS='=' read -r param value <<< "$param"
		[[ $value == "" ]] && value=$2
		[[ $value == *"--"* || $value == "" ]] && value=true
		declare $param="$value"
	fi
	shift
done

# Parameters
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

while [ -z "$directory" ]; do
	read -p 'Document root directory: /var/www/' directory
done

while [ -z "$name" ]; do
	read -p 'Name: ' name
done

[ "$port" = "" ] && port="9000"
[ "$network" = "" ] && network="network-$name"
[ "$version" = "" ] && version="fpm"

# Conf files
config="$DIR/php-$name"

if [ ! -d "$config" ]; then
	mkdir -p "$config"
fi

if [ ! -e "$config/php.ini" ]; then
	phpini=`cat "$DIR/php.ini"`
	phpini=${phpini//@name@/$name}
	touch "$config/php.ini"
	printf "$phpini" > "$config/php.ini"
fi

if [ ! -e "$config/php-fpm.conf" ]; then
	cp "$DIR/php-fpm.conf" "$config/php-fpm.conf"
fi

# Create network
docker network create "$network" 2>/dev/null

# Build php fpm image
docker pull "php:$version"
docker build -t "php-$version" --build-arg="PHP_VERSION=$version" "$DIR"

# Stop and delete existing container
docker stop "php-$name" 2>/dev/null
docker rm "php-$name" 2>/dev/null

# Run php fpm container
docker run --name "php-$name" --network "$network" --restart always -v /var/www/"$directory":/var/www/"$directory" -v "$config/php.ini":/usr/local/etc/php/conf.d/php.ini -v "$config/php-fpm.conf":/usr/local/etc/php-fpm.d/php-fpm.conf -d -p 127.0.0.1:"$port":9000 "php-$version"

# Run memcached container
docker stop "memcached-$name" 2>/dev/null
docker rm "memcached-$name" 2>/dev/null
docker run --pull always --name "memcached-$name" --network "$network" --restart always -d memcached