
# download landregistry data from http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-2017.csv
mkdir data
wget http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-2017.csv -P ./data

# install virtualenv
pip3 install virtualenv

virtualenv DAGRise
source DAGRise/bin/activate

pip3 install -r requirements.txt