# Docker Container for DokuWiki
A Docker Container for [dokuwiki](https://www.dokuwiki.org/dokuwiki) with sensible default configuration.

# Configuration options
## Environment Variables
The following environmental variables can be used for configuration. Those configurations are only applied if the relevant configuration files do not exist (therefore they are only relevant for the initial start).

  - `TITLE`  
    As defined by [Dokuwiki Documentation](https://www.dokuwiki.org/config:title)  
    Default: `DokuWiki`
  - `WIKI_LANG`  
    As defined by [Dokuwiki Documentation](https://www.dokuwiki.org/config:lang)  
    Default: `en`
  - `LICENSE`  
    As defined by [Dokuwiki Documentation](https://www.dokuwiki.org/config:license)  
    Default: `cc-by-sa`
  - `USEACL`  
    As defined by [Dokuwiki Documentation](https://www.dokuwiki.org/config:useacl)  
    Default: `-1`
  - `USER`  
    This will create a default user with the given name, see [DokuWiki Documentation](https://www.dokuwiki.org/acl)  
    Default: `admin`
  - `PASSHASH`  
    The passhash for the created user, see [DokuWiki Documentation](https://www.dokuwiki.org/acl)  
    Default: `$2y$10$0a3SbrGSQReVkeaFvfCS0.YrslJgFYq05lOh7Za9FTxQjKTiMORcG` (the hash for `password`)
  - `NAME`  
    The name for the created user, see [DokuWiki Documentation](https://www.dokuwiki.org/acl)  
    Default: `John Doe`
  - `EMAIL`  
    The email for the created user, see [DokuWiki Documentation](https://www.dokuwiki.org/acl)  
    Default: `john@doe.com`
  - `ACL_ALL`  
    Defines the access level for un-authenticated users. See ACL access level definition from [DokuWiki Documentation](https://www.dokuwiki.org/acl#background_info)  
    Default: `1`
  - `ACL_USER`  
    Defines the access level for all authenticated users. See ACL access level definition from [DokuWiki Documentation](https://www.dokuwiki.org/acl#background_info)  
    Default: `8`
  - `SUPERUSER`  
    Specifies the super user, see [DokuWiki Documentation](https://www.dokuwiki.org/config:superuser)  
    Default: `@admin`
  - `DISABLE_ACTIONS`  
    Disables DokuWiki actions, see [DokuWiki Documentation](https://www.dokuwiki.org/config:disableactions)  
    Default: `register`

## Volume Mounts
The following paths are recommended for persisting state and/or accessing configurations

  - `/data`  
    All data that is written by DokuWiki is stored here (see [savedir](https://www.dokuwiki.org/config:savedir)),
  - `/conf`  
    [Configuration](https://www.dokuwiki.org/devel:configuration) data is stored here
  - `/site`  
    The [Dokuwiki Root Directory](https://www.dokuwiki.org/devel:dirlayout)
  - `/static-docs`  
    A folder directly serving the content through the endpoint `/static-docs`

# docker-compose example
Usage with `nginx-proxy` inside of predefined `steilerGroup` network, with [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) and [acme-companion](https://github.com/nginx-proxy/acme-companion). The php container needs to have `opcache mbstring xml intl json curl fileinfo pcntl` installed ([see documentation](https://www.dokuwiki.org/requirements)). I've created a purpose build image for this: [steilerdev/php:7-wiki](https://github.com/steilerDev/php-docker).

```
version: '2'
services:
  wiki:
    image: steilerdev/dokuwiki:latest
    container_name: wiki
    restart: unless-stopped
    environment:
      VIRTUAL_HOST: "wiki.<tld>.net"
      VIRTUAL_PORT: 80
      LETSENCRYPT_HOST: "wiki.<tld>.net"
      TITLE: "Wiki"
      WIKI_LANG: "de"
      LICENSE: "cc-by-nc"
      USEACL: 1
      USER: "JohnDoe"
      NAME: "John Doe"
      EMAIL: "john@doe.de"
    volumes:
      - "/opt/docker/wiki/volumes/data:/data"
      - "/opt/docker/wiki/volumes/conf:/conf"
      - "/opt/docker/wiki/volumes/site:/site"
      - "/opt/docker/wiki/volumes/static-docs:/static-docs"
  wiki_php:
    image: steilerdev/php:7-wiki
    container_name: wiki_php
    restart: unless-stopped
    volumes_from:
      - "wiki"
networks:
  default:
    external:
      name: steilerGroup
```