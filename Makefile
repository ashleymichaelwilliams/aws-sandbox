#!/bin/make

.PHONY : build
build :
	docker build -t tm-tools:latest . 


.PHONY : start
start :
	(docker run -t \
	 --name tm-tools \
	 -v ${HOME}/.ssh/id_rsa:/root/.ssh/id_rsa \
	 -v ${PWD}:/project tm-tools:latest bash \
	 -c "ssh-keyscan github.com >> /root/.ssh/known_hosts; while true; do sleep 30; done;" &)


.PHONY : exec $(AWS_DEFAULT_REGION) $(AWS_ACCESS_KEY_ID) $(AWS_SECRET_ACCESS_KEY) 
exec : $(AWS_DEFAULT_REGION) $(AWS_ACCESS_KEY_ID) $(AWS_SECRET_ACCESS_KEY) 
	docker exec -it --workdir=/project tm-tools bash \
    -c 'export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}; \
				export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}; \
				export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}; \
	  		export BREW_BIN=$$(find /root/.linuxbrew/ -name terraform | head -n1 | rev | cut -d/ -f2- | rev); \
				PATH=$$PATH:$$BREW_BIN; \
				bash'


.PHONY : clean
clean :
	docker rm -f tm-tools


.PHONY : tm-fmt
tm-fmt :
	docker exec -t --workdir=/project tm-tools bash \
    -c 'terramate fmt -C /project'


.PHONY : tm-generate
tm-generate :
	docker exec -t --workdir=/project tm-tools bash \
    -c 'terramate generate -C /project'


.PHONY : tm-init
tm-init :
	docker exec -t --workdir=/project tm-tools bash \
		-c 'export BREW_BIN=$$(find /root/.linuxbrew/ -name terraform | head -n1 | rev | cut -d/ -f2- | rev); \
				PATH=$$PATH:$$BREW_BIN; \
	  		terramate run -C /project -- terraform init'


.PHONY : tm-apply $(AWS_DEFAULT_REGION) $(AWS_ACCESS_KEY_ID) $(AWS_SECRET_ACCESS_KEY) 
tm-apply : $(AWS_DEFAULT_REGION) $(AWS_ACCESS_KEY_ID) $(AWS_SECRET_ACCESS_KEY) 
	docker exec -it --workdir=/project tm-tools bash \
    -c 'export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}; \
				export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}; \
				export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}; \
	  		export BREW_BIN=$$(find /root/.linuxbrew/ -name terraform | head -n1 | rev | cut -d/ -f2- | rev); \
				PATH=$$PATH:$$BREW_BIN; \
	  		terramate run -C /project -- terraform apply'


.PHONY : tm-destroy $(AWS_DEFAULT_REGION) $(AWS_ACCESS_KEY_ID) $(AWS_SECRET_ACCESS_KEY) 
tm-destroy : $(AWS_DEFAULT_REGION) $(AWS_ACCESS_KEY_ID) $(AWS_SECRET_ACCESS_KEY) 
	docker exec -it --workdir=/project tm-tools bash \
    -c 'export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}; \
				export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}; \
				export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}; \
	  		export BREW_BIN=$$(find /root/.linuxbrew/ -name terraform | head -n1 | rev | cut -d/ -f2- | rev); \
				PATH=$$PATH:$$BREW_BIN; \
	  		terramate run -C /project -- terraform destroy'
