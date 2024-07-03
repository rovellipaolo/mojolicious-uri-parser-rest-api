URI Parser REST API
===================

URI Parser REST API is a simple Mojolicious-based REST API to parse URIs.

[![Build Status: GitHub Actions](https://github.com/rovellipaolo/mojolicious-uri-parser-rest-api/actions/workflows/ci.yml/badge.svg)](https://github.com/rovellipaolo/mojolicious-uri-parser-rest-api/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)



## Overview

URI Parser REST API uses `URI` (https://metacpan.org/pod/URI) and `Data::Validate::URI` (https://metacpan.org/pod/Data::Validate::URI) to parse a given URI and extract its parts.

**NOTE: This is just a playground to play with Perl/Mojolicious, nothing serious.**


## Build

The first step is cloning the URI Parser REST API repository, or downloading its source code.

```shell
$ git clone https://github.com/rovellipaolo/mojolicious-uri-parser-rest-api
$ cd mojolicious-uri-parser-rest-api
```

To execute URI Parser REST API in your local machine, you need `Perl 5.30` or higher installed.
Just launch the following commands, which will install all the needed Perl dependencies.

```shell
$ make build
$ make run-dev
```
```shell
$ curl -H "Content-Type: application/json" -X POST http://127.0.0.1:3000/api/parse -d '{"uri": "https://user:password@domain.tld:8080/path?key=value#fragment"}'
{
    "fragment": "fragment",
    "host": "domain.tld",
    "path": "\/path",
    "port": 8080,
    "query": "key=value",
    "raw": "https:\/\/user:password@domain.tld:8080\/path?key=value#fragment",
    "scheme": "https",
    "userinfo": "user:password"
}
```



## Test

Once you've configured it (see the _"Installation"_ section), you can also run the tests and checkstyle as follows.

```
$ make test
$ make checkstyle
```

You can also run the tests with coverage by launching the following command:
```
$ make test-coverage
```



## Licence

URI Parser REST API is licensed under the GNU General Public License v3.0 (http://www.gnu.org/licenses/gpl-3.0.html).
