# docker-moodle


A Dockerfile that installs and runs Moodle from external source with MySQL or PostgreSQL Database.
The PHP code of Moodle is mounted from a host's subdirectory.

All the scripts must be run from the directory containing `Dockerfile` and `docker-compose.yml`.


## Setup

Requires Docker to be installed and, optionally, Docker-compose as well.


## Installation

```
git clone https://github.com/sarjona/docker-moodle
cd docker-moodle
./build-image.sh
```

## Usage

When running locally or for a test deployment, use of localhost is acceptable.
To spawn a new instance of Moodle it's necessary to specify db engine and Moodle version.

```
./start-containers.sh
```

The start-containers.sh script:
  - If it's first time, it will download last Moodle version from GIT and create both docker containers needed (PHP server and DB). Default DB is PostgreSQL.
  - If the containers are created, it will start them.

In both cases, at the end of the execution are showed the instructions to access them. By default:

```
To access Moodle: http://127.0.0.1:8000
Admin credentials: admin/Abcd1234$

To connect to DB: host:port=127.0.0.1:32769, dbuser=moodle, dbpwd=secret
To enter shell in moodle container shell: docker exec -it moodle_33_core-php bash
```

By default, the script creates a docker with last version of Moodle and uses PostgreSQL as DB engine. It's possible create a Moodle 3.1, 3.2 or 3.3 docker with the following callback:

```
./start-containers.sh moodle31
./start-containers.sh moodle32
./start-containers.sh moodle33
```

It's also possible to specify MySQL as DB engine:

```
./start-containers.sh mysql
```


And both (Moodle version and database engine can be combined). For instance:

```
./start-containers.sh mysql moodle32
```



## Caveats
The following aren't included:
* moodle cronjob (should be called from cron container)
* log handling. Logs are stored in the default stout (/var/log/apache2/).
* email (does it even send?)


## Credits

This has been adapted from [Lorenzo Nicora](https://github.com/nicusX/dockerised-moodledev) and [Jonathan Hardison](https://github.com/jmhardison/docker-moodle) Dockerfiles.
