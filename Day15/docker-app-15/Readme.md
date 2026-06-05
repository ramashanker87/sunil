## Start Application

    python app.py

## List running docker container

    docker ps 
    docker ps -a

## List all docker images

    docker images

## Stop Docker container
    
    docker stop <container-id>

## Remove Docker container

    docker rm <container-id>

## Remove all docker container

    docker rm $(docker ps -a -q)

## Remove docker image

    docker rmi <image-id>

## Build Docker image

    docker build -t falcon007/hello-docker:v1 .

## Run docker images in container

    docker run -d --name hello-docker -p 8082:8080 falcon007/hello-docker:v1

## Docker exec or enter inside container

    docker exec -it <container-id> bash