This is a proof of concept
--------------------------
**This deploy setup is bound to included Vagrant box. The provisioning scripts and included docs will probably work for your setup, but there is currently no simple installer for generic IRL OSes.**

Key points
----------

This deploy setup is agnostic to what languages your project is based on.

Deploy is done with a simple one liner, similar to traditional Github/remote repo push:
```sh
git push deploy master:production
```

Every project is configured separately in `deploy.json` file located in each project. It lists deployable branches, target locations and hooks to be run server-side before and after the deploy. These hooks allow you to purge cache, update composer dependencies or announce deploy to your app monitoring service.

You might also have more than one deploy branch, for example a staging branch that you check production ready code on:
```sh
git push deploy master:staging
```

By default, this deploy setup prevents you from pushing production before staging. This check is completely server side and intentionally cannot be bypassed without tampering with the deploy hooks on server.
```sh
touch new_file
git add new_file
git commit -am "commiting changes"
git push deploy master:production

## Results in:
# Warning: deploy to `production` denied - branches master, staging are behind.
# master is at ece75bc
#     2013-04-15 17:55:00 Mikulas update readme [Closes #24]
# staging is at 574131e
# 	2013-04-15 15:23:00 Mikulas update deploy.json
```

Additionally, force pushes (non-fast-forward) are denied as it could prevent successful deploy
```sh
git config --system receive.denyNonFastForwards true
git config --system receive.denyDeletes true

touch new_file
git add new_file
git commit -am "fast-forward commit"
git push deploy master:master

date > new_file
git commit -am "NON-fast-forward commit" --amend
git push deploy master:master --force

## Results in:
# Force push (non-fast-forward) denied.
```

On every push to a branch that is not `master` or a branch deletion, `deploy.json` is validated both for correct json syntax and against an expected schema. This helps ensure you don't accidentally make your project undeployable.

Server-side setup
-----------------

This deployment system runs on [gitolite](https://github.com/sitaramc/gitolite) and enjoys immense configuration capatibilites.

1. **See [Gitolite Setup](https://github.com/sitaramc/gitolite/blob/master/README.txt#L49) and [Gitolite Docs](http://gitolite.com/gitolite/admin.html#conf).**

2. Add `deploy_hook` to `gitolite.conf` as

```sh
git clone git@vagrant:gitolite-admin
cd gitolite-admin

### edit and add the following snippet to conf/gitolite.conf
#
# @deployers = alice bob catherine
# repo @all
#    -    VREF/deploy_hook   =   @deployers
#

git commit -am "added deploy_hook"
git push origin master
```

3. Add new projects to `gitolite.conf`

```
# asuming the gitolite-admin repo from previous step

### edit and add the following snippet to conf/gitolite.conf
#   remember to change Alice to your name (or to a group of developers)
#
# repo project_name
#    RW+     =   Alice
#

git commit -am "added project_name config"
git push origin master
```

(See [gitolite docs](http://gitolite.com/gitolite/admin.html#conf) for how to customize the `gitolite.conf` file.)

Project (client-side) setup
---------------------------
Add `deploy.json` to root of your project (along the `.git` directory). It should contain `targets` key with at least one branch and it's target location. Optionally, you might add `pre-update` and `post-update` commands to be run on the server before and after deploy. Note this may also trigger external bash scripts you include as separate files in your repository.

Sample `deploy.json`:
```json
{
    "targets": {
    	"staging": "/var/www/staging.testing",
		"production": "/var/www/testing"
	},
	"pre-update": ["echo \"server is going to update!\""],
	"post-update": ["chmod ugo+r index.html", "composer install"]
}
```

Optionally, you might want to add the `deploy` remote. (Or keep it simply `origin` if you have no other remotes)
```
git remote add deploy git@your_host:project_name
```

Finally, deploy with
```
git push deploy master:master && git push deploy master:staging

# First check if everything runs smooth
# and then, after all the hard work, run:

git push deploy master:production
```

Notes
-----

Every update enforces previous branches in the deployment cycle to be up-to-date. For example, if you specify `staging` and `production` targets in this order, deploying `production` without deploying `staging` before refuses the push. Branch `master` is always expected to be first in the deployment cycle (meaning you can't push to any deployment branch without having up-to-date `master`).


Hook ideas
----------

`pre-update`:

* show maintenance page (hide on `post-update`)

`post-update`:

* fix privileges
* composer install (from `composer.lock`)
* purge cache
* repopulate cache or static resources
* run database migrations
* announce deploy to your monitoring service ([NewRelic](http://newrelic.com/))



Deploy developer setup
----------------------

Prereqs: Install [Vagrant](http://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).

Setup and run the virtual machine
```
vagrant up
```

Add the following snippet to yours ~/.ssh/config
```
Host vagrant
    IdentityFile /Volumes/Cifrita/Projects/deploy/keys/alice
```

Add vagrant and testing hosts ips to your DNS (add following snippet to `/etc/hosts`)
```
192.168.200.200 vagrant
192.168.200.200 testing.l
192.168.200.200 staging.testing.l
```

Test your setup
```
sh test_vm.sh
cd tests
./deploy_test.sh # open url testing.l in your browser
./deploy_test.sh # refresh the testing.l page and enjoy new deployed version
```

How does it work internally
---------------------------

There two hooks: `deploy_hook`, which is registered as `VREF`, and `post-update` which is traditional `hooks/common`. The `VREF` has to be registered in `gitolite-admin.git/conf/gitolite.conf`.

Vagrant provisioning sets up `.gitolite.rc` to have
```perl
LOCAL_CODE => "/vagrant/local-code",
```
so that `/local-code` files are synced automatically.
