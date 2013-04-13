git clone git@vagrant:testing
cd testing
date > test_file
git add test_file
git commit -m "`date`"
git push origin master
