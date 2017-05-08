.INTERMEDIATE: color-survey.sqlite mainsurvey_sqldump.txt colorsurvey.tar.gz

color-distances: color-centroids.tsv
	python3 color.py

color-centroids.tsv: color-survey.sqlite
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
