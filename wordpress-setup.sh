#!/bin/bash
# @author leandro@serfe.com / Serfe SA
# This script will help to install edge Wordpress version with a really simple wizard

#exit when detect any fails.
set -e

#collect data from input
echo -n "Enter URL (http://www.example.com): "
read URL
 
 
if [ ! $URL ]; then
    echo "Please provide a valid url"
    exit
fi
 
echo -n "Enter Title: "
read TITLE
 
echo -n "Enter DB Name: "
read DBNAME
 
echo -n "Enter DB User: "
read DBUSER
 
echo -n "Enter DB Password: "
read -s DBPASS
echo

echo -n "Enter absolute webroot path (leave empty to use current folder):"
echo -n ">"
read WPDIR

echo -n "Enter Your Admin User: "
read ADMIN

echo -n "Enter Your Admin Password: "
read -s ADMIN_PWD
echo

echo -n "Enter Your Admin Email: "
read EMAIL

#go to folder based on input, stay in current folder otherwise
if [ -n "$WPDIR" ]; 
then cd $WPDIR;
fi

     
#download latest wordpress
wp core download
 
#ECHO default config
echo "url: ${URL}
user: ${ADMIN}
color: auto
disabled_commands:
  - db drop
 
core config:
    dbname: ${DBNAME}
    dbuser: ${DBUSER}
    dbpass: ${DBPASS}
    extra-php: |
	    define( 'WP_DEBUG', true );
	    define( 'WP_POST_REVISIONS', 50 );" > wp-cli.yml
 
#source config file
wp core config
 
#Install wordpress based on given config and site information
wp core install --title="${TITLE}" --admin_user="${ADMIN}" --admin_password="${ADMIN_PWD}" --admin_email="${EMAIL}"
 
wp core verify-checksums
 
if [ $? -eq 0 ]; then
    wp plugin install wordpress-seo --activate
    wp plugin install w3-total-cache --activate
    wp plugin install wordfence
    wp plugin install contact-form-7 --activate
fi
 
cp ./wp-config.php wp-config.php.local
cp ./.htaccess .htaccess.local
 
GREEN='\e[92m'
NC='\e[0m'
 
echo -e "${GREEN}Ready!!!${NC} -> Wordpress is ready to use. User: ${ADMIN} - Pass: ${ADMIN_PWD} - Admin Email: ${EMAIL}"
