# build
docker build --platform linux/amd64 -t rstudio:4.2.2 .

# tag
docker image tag rstudio:4.2.2 zatzmanm/rstudio:4.2.2

# push
docker image push zatzmanm/rstudio:4.2.2

