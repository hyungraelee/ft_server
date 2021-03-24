FROM	debian:buster

ARG		WP_NAME=wordpress
ARG		WP_USER=hyunlee
ARG		WP_PWD=1234

COPY	./srcs/* ./

RUN		apt update -y

RUN		apt -y install nginx curl openssl vim php-fpm mariadb-server php-mysql php-mbstring wget php-xml

RUN		openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Lee/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt; \
	mv localhost.dev.crt etc/ssl/certs/; \
	mv localhost.dev.key etc/ssl/private/; \
	chmod 600 etc/ssl/certs/localhost.dev.crt etc/ssl/private/localhost.dev.key; \
	cp -rp /default etc/nginx/sites-available/

RUN		wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.tar.gz; \
	tar -xvf phpMyAdmin-5.1.0-all-languages.tar.gz; \
	mv phpMyAdmin-5.1.0-all-languages phpmyadmin; \
	mv phpmyadmin /var/www/html/; \
	service mysql start; \
	mysql -e  "CREATE DATABASE ${WP_NAME}; \
	USE ${WP_NAME}; \
	CREATE USER '${WP_USER}'@'localhost' IDENTIFIED BY '${WP_PWD}'; \
	GRANT ALL PRIVILEGES ON ${WP_NAME}.* TO '${WP_USER}'@'localhost' WITH GRANT OPTION; \
	FLUSH PRIVILEGES;"; \
	cp -rp /config.inc.php var/www/html/phpmyadmin/


RUN		wget https://wordpress.org/latest.tar.gz; \
	tar -xvf latest.tar.gz; \
	mv wordpress/ var/www/html/; \
	chown -R www-data:www-data /var/www/html/wordpress; \
	cp -rp /wp-config.php var/www/html/wordpress/

EXPOSE	80 443

CMD bash run.sh
