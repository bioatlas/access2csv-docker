#! make

PWD = $(shell pwd)
UID = $(shell id -u)
GID = $(shell id -g)

all: init build-jar build-image

init:
	test -d commons_cli_ex || git clone https://github.com/Inkimar/commons_cli_ex.git
	test -f commons_cli_ex/resources/OcurrenceLit.mdb || \
		make -C commons_cli_ex dl-schema && mkdir -p data && \
		cp commons_cli_ex/resources/OcurrenceLit.mdb data

build-jar:
	docker run -it --rm --name my-maven-project \
		-u $(UID):$(GID) \
		-v $(PWD)/commons_cli_ex:/usr/src/mymaven \
		-v $(PWD)/m2:/root/.m2 \
		-w /usr/src/mymaven \
		maven:3 bash -c "mvn package"
#		-v $(PWD)/settings-docker.xml:/root/.m2/settings.xml \

build-image:
	docker build -t bioatlas/access2csv:latest .

test-man:
	# call without options prints the manual
	docker run -it -v $(PWD)/data/:/tmp -u $(UID):$(GID) \
		bioatlas/access2csv --help

test-convert:
	# call with options converts a mdb file into CSV format
	docker run -it -v $(PWD)/data/:/tmp -u $(UID):$(GID) \
		bioatlas/access2csv -f /tmp/OcurrenceLit.mdb -d /tmp/

test-list:
	# call to list available tables
	docker run -it -v $(PWD)/data/:/tmp -u $(UID):$(GID) \
		bioatlas/access2csv -f /tmp/OcurrenceLit.mdb -list

test-schema:
	# call to list available tables
	docker run -it -v $(PWD)/data/:/tmp -u $(UID):$(GID) \
		bioatlas/access2csv -f /tmp/OcurrenceLit.mdb -s

test-mdbtools:
	# sudo apt install mdbtools
	cd data && mdb-tables OcurrenceLit.mdb
	cd data && mdb-export OcurrenceLit.mdb OCCURRENCELiterature > OCCURRENCELiterature2.csv

clean:
	rm -rf commons_cli_ex data m2

