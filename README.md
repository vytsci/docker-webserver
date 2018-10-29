* Install docker and docker-compose
* Change all "vytsci" with your own
* Build image with `docker build ./ -t vytsci/webserver:php7.1-apache-latest`
* Push image to your own hub channel `docker push vytsci/webserver:php7.1-apache-latest`
* Copy docker-compose.yml and .docker to you location.
* From that location run command `docker-compose up -d`
