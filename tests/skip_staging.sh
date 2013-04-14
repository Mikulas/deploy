git clone git@vagrant:testing &> /dev/null
cd testing

date > index.html
chmod ugo+r index.html
git add index.html
git commit -m "update `date`" &> /dev/null

#../../client/deploy master $1 &> /dev/null
../../client/deploy production $1

cd ..
rm -rf testing
