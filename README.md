# Server Role PHP

Submodule for server ansible playbook. Install PHP, Composer, run PHP FPM containers and Memcached containers.


## How to use it in my playbook?

Add submodule into your playbook repo:
```
git submodule add https://github.com/syone/server-role-php.git roles/php
```

Use these role variables in your playbook:
- ```php_extensions``` for installing extra php extensions (by default php-curl, php-mbstring and php-xml are installed).
- ```php_containers``` for running PHP FPM containers with Memcached containers.

Example:
```
---
  - hosts: all
    become: true
    become_user: root
    become_method: sudo

    roles:
      - role: php
        vars:
          php_extensions:
            - php-xml
            - php-curl
          php_containers:
            - name: name-1
              directory: dir-1
            - name: name-2
              directory: dir-2
              port: 9001
              version: 8.3-fpm
              network: custom-network-name
```

In this example, 2 networks are created, in each of them, a PHP FPM container and a Memcached container are created.

Network "network-name-1":
- PHP FPM container "php-name-1" running on the default port 9000
- Memcached container "memcached-name-1"

Network "custom-network-name":
- PHP FPM container "php-name-2" with PHP version 8.3 running on the port 9001
- Memcached container "memcached-name-2"


## Behind the scene

The ```php/run.sh``` script is copied in the server /root/php directory and is used for building a Docker image based on the specified version of php:fpm image and run the php-fpm container + run a memcached container for storing sessions ids.

You can run this script manually if needed:
```
sudo /root/php/run.sh --directory [DIRECTORY] --name [NAME] --port [PORT] --network [NETWORK] --version [PHP FPM IMAGE TAG]
```

* Container name will be php-[NAME]
* Default port is 9000
* Default network name is network-[NAME]
* Default php fpm image tag is "fpm". [See all the php image tags](https://github.com/docker-library/docs/blob/master/php/README.md#supported-tags-and-respective-dockerfile-links)


## PHP container configuration

Default PHP configurations files are created in a directory named like the container name.

With the previous example, the directory ```/root/php/php-name-1``` and ```/root/php/php-name-2``` will contain 2 files: ```php-fpm.conf``` and ```php.ini```. You can then customize a specific PHP container configuration by updating these 2 files. Remove and run the container after update.