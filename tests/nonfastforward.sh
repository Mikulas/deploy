git clone git@vagrant:testing &> /dev/null
cd testing

date > test_file
git add test_file
git commit -m "`date`"
../../client/deploy master
echo

date > test_file
git add test_file
git commit -m "amended `date`" --amend
../../client/deploy master --force

cd ..
rm -rf testing
