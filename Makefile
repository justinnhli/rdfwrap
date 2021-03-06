.INTERMEDIATE: color-survey.sqlite mainsurvey_sqldump.txt colorsurvey.tar.gz

.PHONY: results

results: static-pilot-latest.csv static-latest.csv dynamic-pilot-latest.csv

dynamic-pilot-latest.csv: dynamic-pilot-*-collated.csv
	cp $(shell ls $^ | tail -n 1) $@

static-latest.csv: static-2*-collated.csv
	cp $(shell ls $^ | tail -n 1) $@

static-pilot-latest.csv: static-pilot-*-collated.csv
	cp $(shell ls $^ | tail -n 1) $@

color-centroids.tsv: create_tsv.py color-survey.sqlite
	python3 create_tsv.py

color-survey.sqlite: mainsurvey_sqldump.txt
	cat mainsurvey_sqldump.txt | sqlite3 color-survey.sqlite

mainsurvey_sqldump.txt: colorsurvey.tar.gz
	tar -xf colorsurvey.tar.gz
	rm -f satfaces_sqldump.txt

colorsurvey.tar.gz:
	wget 'https://xkcd.com/color/colorsurvey.tar.gz'

clean:
	rm -f color-survey.sqlite mainsurvey_sqldump.txt colorsurvey.tar.gz

distclean: clean
	rm -f color-centroids.tsv
