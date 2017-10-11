#!/bin/bash
# Start containers

# Get database (PostgreSQL by default)
if [[ $1 == 'mysql' ]]
    then
    DB='mysql';
else
	DB='postgres';
fi


if [[ $1 == 'moodle31' || $2 == 'moodle31' ]]
    then
	DBPORT=33031
	MOODLEPORT=8031
	if [[ ${DB} == 'mysql' ]]
		then
		MOODLEPORT=8131
		DBPORT=33131
	fi
	PROJECTNAME=moodle_31_${DB}
    MOODLEDEVDIR=`pwd`/${PROJECTNAME}
	if [ ! -d ${MOODLEDEVDIR} ]; then
		git clone -b MOODLE_31_STABLE git://git.moodle.org/moodle.git ${MOODLEDEVDIR}
	fi
elif [[ $1 == 'moodle32' || $2 == 'moodle32' ]]
    then
	DBPORT=33032
	MOODLEPORT=8032
	if [[ ${DB} == 'mysql' ]]
		then
		MOODLEPORT=8132
		DBPORT=33132
	fi
	PROJECTNAME=moodle_32_${DB}
    MOODLEDEVDIR=`pwd`/${PROJECTNAME}
	if [ ! -d ${MOODLEDEVDIR} ]; then
		git clone -b MOODLE_32_STABLE git://git.moodle.org/moodle.git ${MOODLEDEVDIR}
	fi
elif [[ $1 == 'moodle33' || $2 == 'moodle33' ]]
    then
	DBPORT=33033
	MOODLEPORT=8033
	if [[ ${DB} == 'mysql' ]]
		then
		MOODLEPORT=8133
		DBPORT=33133
	fi
	PROJECTNAME=moodle_33_${DB}
    MOODLEDEVDIR=`pwd`/${PROJECTNAME}
	if [ ! -d ${MOODLEDEVDIR} ]; then
		git clone -b MOODLE_33_STABLE git://git.moodle.org/moodle.git ${MOODLEDEVDIR}
	fi
else
	DBPORT=33034
	MOODLEPORT=8034
	if [[ ${DB} == 'mysql' ]]
		then
		MOODLEPORT=8134
		DBPORT=33134
	fi
	PROJECTNAME=moodle_master_${DB}
	if [ -d "moodle" ]; then
		MOODLEDEVDIR=`pwd`/moodle
	else
	    MOODLEDEVDIR=`pwd`/${PROJECTNAME}
		if [ ! -d ${MOODLEDEVDIR} ]; then
			git clone -b master git://git.moodle.org/moodle.git ${MOODLEDEVDIR}
		fi
	fi
fi

LANG=ca
ADMINUSR=admin
ADMINPWD=admin
SITENAME="Moodle ${PROJECTNAME}"
SITESHORT=${PROJECTNAME}


if [ ! "$(docker ps -a -q -f name=${PROJECTNAME})" ]; then
    echo 'Install' `echo ${PROJECTNAME}` 'docker'

    # Copy config.php file to Moodle folder
    rm -Rf ${MOODLEDEVDIR}/config.php
    cp moodle-${DB}-config.php ${MOODLEDEVDIR}/config.php

    # Create DB and Moodle containers
    if [[ ${DB} == 'mysql' ]]
    	then
		docker run -d --name ${PROJECTNAME}-db -p ${DBPORT}:3306 -e MYSQL_DATABASE=moodle -e MYSQL_ROOT_PASSWORD=moodle -e MYSQL_USER=moodle -e MYSQL_PASSWORD=moodle mysql
	else
    	docker run -d --name ${PROJECTNAME}-db -e POSTGRES_USER=moodle -e POSTGRES_PASSWORD=moodle -p=${DBPORT}:5432 postgres
    fi
    docker run -d -P --name ${PROJECTNAME}-php -p ${MOODLEPORT}:80 -v ${MOODLEDEVDIR}:/var/www/html --link ${PROJECTNAME}-db:DB -e MOODLE_URL=http://127.0.0.1:${MOODLEPORT} moodle

    # Install Moodle
    sleep 20
	docker exec -it -u www-data ${PROJECTNAME}-php /usr/bin/php /var/www/html/admin/cli/install_database.php --agree-license --adminuser=${ADMINUSR} --adminpass=${ADMINPWD} --fullname=${SITENAME} --shortname=${SITESHORT} --lang=${LANG}
else
    echo 'Run' `echo ${PROJECTNAME}` 'docker'

    docker start ${PROJECTNAME}-db ${PROJECTNAME}-php
fi

echo ""
echo "PROJECT ${PROJECTNAME}"
echo "To access Moodle: http://127.0.0.1:${MOODLEPORT}"
echo "Admin credentials: ${ADMINUSR}/${ADMINPWD}"
echo ""
echo "To connect to ${DB}: host:port=127.0.0.1:${DBPORT}, dbuser=moodle, dbpwd=moodle"
echo "To enter shell in moodle container shell: docker exec -it ${PROJECTNAME}-php bash"
