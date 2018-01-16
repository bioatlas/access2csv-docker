FROM openjdk:8-jre-alpine

RUN apk add --update --no-cache tini

RUN mkdir -p /usr/local/access2csv && cd /usr/local/access2csv
WORKDIR /usr/local/access2csv

COPY commons_cli_ex/target/access2csv-jar-with-dependencies.jar .

ENTRYPOINT ["/sbin/tini", "--", "java", "-jar", "access2csv-jar-with-dependencies.jar"]

CMD [""]

