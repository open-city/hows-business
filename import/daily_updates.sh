export PYTHONPATH=$PYTHONPATH:/home/fgregg/lib64/python2.6/site-packages:/home/fgregg/lib/python2.6/site-packages

cd /home/fgregg/public/scraping-intro
python2.6 direct_example.py
mv taxes.csv /home/fgregg/public/hows-business/import/data

cd /home/fgregg/public/hows-business/import

python2.6 business_licenses.py

rm *.js

R --vanilla < building_permit_stl.R
R --vanilla < business_licenses_stl.R
R --vanilla < foreclosure.R
R --vanilla < chicago_unemployment_stl.R
R --vanilla < taxes.R

scp *.js bunkum.us:www/hb_data

