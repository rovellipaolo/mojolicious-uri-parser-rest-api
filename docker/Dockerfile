FROM perl:5.40-slim-bullseye

ENV URIPARSER_HOME=/opt/uriparser
ENV URIPARSER_USER=uriparser

RUN apt update

# Install URI Parser REST API

RUN useradd -ms /bin/bash ${URIPARSER_USER} \
    && mkdir -p ${URIPARSER_HOME}

COPY Makefile ${URIPARSER_HOME}/Makefile
COPY app.pl ${URIPARSER_HOME}
COPY app.conf ${URIPARSER_HOME}
COPY openapi.json ${URIPARSER_HOME}
COPY lib/ ${URIPARSER_HOME}/lib/

RUN cd ${URIPARSER_HOME} \
    && make build \
    #&& make build-dev \
    && chown uriparser:uriparser ${URIPARSER_HOME}

EXPOSE 3000

USER uriparser
WORKDIR ${URIPARSER_HOME}

# Run URI Parser REST API

CMD ["hypnotoad", "app.pl", "--foreground", "2>&1"]
