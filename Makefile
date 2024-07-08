DOCKER_FILE :=  docker/Dockerfile
DOCKER_IMAGE := uriparser
DOCKER_TAG := latest


# Build

.PHONY: build
build:
	@cpan -Ti Data::Validate::URI
	@cpan -Ti Mojolicious::Lite
	@cpan -Ti Mojolicious::Plugin::Config
	@cpan -Ti Mojolicious::Plugin::OpenAPI
	@cpan -Ti Mojolicious::Plugin::RemoteAddr
	@cpan -Ti URI
	@cpan -Ti YAML::PP

.PHONY: build-dev
build-dev:
	make build
	@cpan -Ti Devel::Cover
	@cpan -Ti Test::MockModule
	@cpan -Ti Test::Mojo
	@cpan -Ti Test::Spec

.PHONY: build-docker
build-docker:
	@docker build -f ${DOCKER_FILE} -t ${DOCKER_IMAGE}:${DOCKER_TAG} .


# Run

.PHONY: run-dev
run-dev:
	morbo ./app.pl -l http://*:3000 -w $(PWD)/app.conf -w $(PWD)/openapi.json

.PHONY: run
run:
	hypnotoad ./app.pl --foreground 2>&1

.PHONY: run-docker
run-docker:
	@docker run -p 127.0.0.1:3000:3000 --name ${DOCKER_IMAGE} -it --rm ${DOCKER_IMAGE}:${DOCKER_TAG}


# Test

.PHONY: test
test:
	@prove -r t

.PHONY: test-coverage
test-coverage:
	@cover -test -ignore_re '^t/.*'

.PHONY: test-docker
test-docker:
	@docker run --name ${DOCKER_IMAGE} --rm -w /opt/uriparser -v $(PWD)/t:/opt/uriparser/t ${DOCKER_IMAGE}:${DOCKER_TAG} prove -r t

.PHONY: checkstyle
checkstyle:
	perltidy -w -b -bext='/' *.pl lib/*/*.pm t/*.t
