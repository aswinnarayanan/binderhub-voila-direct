#!/bin/bash

bash stop_and_clean.sh

docker build -t $(whoami)/$(basename ${PWD}) .
docker run --rm -p 8080:8080 -p 8888:8888 $(whoami)/$(basename ${PWD})
# docker run -it --rm -p 8080:8080 -p 8888:8888 $(whoami)/$(basename ${PWD}) /bin/bash
