git clone git@192.168.240.240:testing
cd testing
date > test_file
git add test_file
git commit -m "`date`"
git push origin master
