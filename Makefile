# Build

.PHONY: build
build:
	@cpan -Ti Data::Validate::URI
	@cpan -Ti Mojolicious::Lite
	@cpan -Ti Mojolicious::Plugin::Config
	@cpan -Ti Mojolicious::Plugin::OpenAPI
	@cpan -Ti Mojolicious::Plugin::RemoteAddr
	@cpan -Ti URI

.PHONY: build-dev
build-dev:
	make build
	@cpan -Ti Devel::Cover
	@cpan -Ti Test::MockModule
	@cpan -Ti Test::Mojo
	@cpan -Ti Test::Spec


# Run

.PHONY: run-dev
run-dev:
	morbo ./app.pl -l http://*:3000 -w $(PWD)/app.conf -w $(PWD)/openapi.json

.PHONY: run
run:
	hypnotoad ./app.pl --foreground 2>&1


# Test

.PHONY: test
test:
	@prove -r t

.PHONY: test-coverage
test-coverage:
	@cover -test -ignore_re '^t/.*'

.PHONY: checkstyle
checkstyle:
	perltidy -w -b -bext='/' *.pl lib/*/*.pm t/*.t
