git clone git@vagrant:testing
echo

cd testing

date > test_file
git add test_file
#git commit -m "`date`"
#echo

echo '{
	"targets": {
		"staging": "/srv/virtual_hosts/staging.testing",
		"production": "/srv/virtual_hosts/testing"
	},
	"post-update": ["echo \"custom post-update script\""],
	"debug": "20"
}' > deploy.json
git add deploy.json
git commit -m "update deploy.json `date`"

../../client/deploy master
../../client/deploy staging

cd ..
rm -rf testing
