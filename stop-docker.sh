
docker stop $(docker ps -q) && docker rm $(docker ps -a -q) && docker image prune -a -f
docker stop $(docker ps -q)

docker ps -q | xargs -r docker stop

 docker ps -a -q | xargs -r docker rm

 docker image prune -a -f

