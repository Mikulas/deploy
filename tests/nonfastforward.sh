git clone git@vagrant:testing
cd testing
git pull origin staging:master
echo

date > test_file
git add test_file
git commit -m "`date`"
../../client/deploy staging
echo

date > test_file
git add test_file
git commit -m "amended `date`" --amend
../../client/deploy staging --force

cd ..
rm -rf testing
