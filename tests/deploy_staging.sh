git clone git@vagrant:testing
echo

cd testing

date > index.html
chmod ugo+r index.html
git add index.html
git commit -m "update `date`"

echo

../../client/deploy master $1

echo

../../client/deploy staging $1

cd ..
rm -rf testing
