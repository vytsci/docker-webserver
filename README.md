* Install docker and docker-compose
* Copy .env.dist to .env and enter correct data
* Build image with `docker build ./ -t yourname/workstation:php7.1-apache-latest`
* Push image to your own hub channel `docker push yourname/workstation:php7.1-apache-latest`
* Copy docker-compose.yml and .docker to you location.
* From that location run command `docker-compose up -d`
