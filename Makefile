SHELL=/bin/bash

DOCKER_IMAGE_NAME=jack_bunny

HOST_PORT=7015

build-docker-image:
	docker build -t ${DOCKER_IMAGE_NAME} .

run-docker: build-docker-image
	docker run -d \
		--name ${DOCKER_IMAGE_NAME} \
                -p ${HOST_PORT}:80 \
		--restart always \
		${DOCKER_IMAGE_NAME}

attach-to-docker:
	docker exec -u 0 -it `docker ps | grep ${DOCKER_IMAGE_NAME} | awk '{print $$1;}'` /bin/sh

clear-docker:
	docker stop `docker ps | grep ${DOCKER_IMAGE_NAME} | awk '{print $$1;}'` || true
	docker rm `docker ps -a | grep ${DOCKER_IMAGE_NAME} | awk '{print $$1;}'` || true

read-logs:
	docker exec ${DOCKER_IMAGE_NAME} cat /var/log/nginx/{access,error,jack_bunny}.log

prepare-master:
# Step 1: Check out the confirm branch and copy the file
	git checkout confirm
	cp code/jack_bunny/jack_bunny.py code/jack_bunny/jack_bunny.py.bak

# Step 2: Remove custom shortcuts blocks
	perl -0777 -pe 's/(.*# \[CUSTOM SHORTCUTS\] Add your company shortcuts here\.\n).*?(.*# \[END CUSTOM SHORTCUTS\]\n)/\1\2/gs' code/jack_bunny/jack_bunny.py.bak > code/jack_bunny/jack_bunny_cleaned.py

# Step 3: Check out the master branch
	git checkout master

# Step 4: Replace the file in the master branch with the cleaned file
	cp code/jack_bunny/jack_bunny_cleaned.py code/jack_bunny/jack_bunny.py

# Step 5: Clean up temporary files
	rm code/jack_bunny/jack_bunny.py.bak code/jack_bunny/jack_bunny_cleaned.py
