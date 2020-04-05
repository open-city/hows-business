all : permits.js licenses.js unemployment.js


.PHONY: install/R
install/R: ## Install R dependencies (usually only required once) 
	Rscript install.R


permits.js :
	Rscript building_permits_stl.R


business_permits.csv :
	wget -O $@ 'https://data.cityofchicago.org/api/views/r5kz-chrr/rows.csv?accessType=DOWNLOAD'

daily_count.csv : business_permits.csv
	python business_licenses.py

licenses.js : daily_counts.csv
	Rscript business_licenses_stl.R

unemployment.js :
	Rscript chicago_unemployment_stl.R

foreclosures.js :
	Rscript foreclosure.R
