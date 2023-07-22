FROM php:apache
WORKDIR /var/www/html
COPY ./wordpress/ /var/www/html/
RUN docker-php-ext-install mysqli
EXPOSE 80
