This is a proof of concept
--------------------------
**This deploy setup is bound to included Vagrant box. The provisioning scripts and included docs will probably work for your setup, but there is currently no simple installer for generic IRL OSes.**

General
-------

This deployment system runs on [gitolite](https://github.com/sitaramc/gitolite) and thus enjoys immense configuration capatibilites:

Deployment hook may be set to be triggered only by certain users:

```
@deployers = alice bob catherine

repo @all
    -    VREF/deploy_hook   =   @deployers
```
(see [gitolite docs](http://gitolite.com/gitolite/admin.html#conf))

In the vagrant provisioning `@deployers` defaults to `@all`.

This deploy setup is agnostic to what languages your project is based on.

Every update enforses previous branches in the deployment cycle to be up-to-date. For example, if you specify `staging` and `production` targets in this order, deploying `production` without deploying `staging` before refuses the push. Branch `master` is always expected to be first in the deployment cycle (meaning you can't push to any deployment branch without having up-to-date `master`).

Vagrant setup prevents you from force-pushes (non-fast-forward) and branch deletion:
```bash
git config --system receive.denyNonFastForwards true
git config --system receive.denyDeletes true
```
Successful deploy:

![Successful deploy](http://31.31.72.76/deploy_1.jpg)

Lower branch not up-to-date:

![Previous branch not up-to-date](http://31.31.72.76/deploy_2.jpg)

Trying to force a non-fast-forward push:

![Non-fast-forward push declined](http://31.31.72.76/deploy_3.jpg)

Usage
-----

Add `deploy.json` to root of your repository. It states where should given branches be deployed to and lists commands to be executed immediately before and after deploy.

Then set up gitolite to handle new repository
```bash
git clone git@vagrant:gitolite-admin
cd gitolite-admin

echo "\nrepo new_project\n\tRW+     =   @all" >> conf/gitolite.conf
git commit -am "added new_project privileges"
git push origin master

cd ..
rm -rf gitolite-admin
```

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

Deploy
```bash
cd project_path

$DEPLOY/client/deploy master && $DEPLOY/client/deploy staging
# check if staging is ok, if so proceed

$DEPLOY/client/deploy production
```


Use cases
---------

* show maintenance page on `pre-update`, hide on `post-update`
* `post-update` fix privileges
* `post-update` composer install
* `post-update` purge cache
* `post-update` run migrations
* `post-update` announce deploy to your monitoring service ([NewRelic](http://newrelic.com/))



Dev Setup
-----

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

The `/client` directory features a simple script that wraps the standard git push command. It removes dull technical info about transfer and highlights deploy-related output (prefixed with `remote:`).
