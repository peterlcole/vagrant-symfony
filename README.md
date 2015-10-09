Creates a pre-configured Vagrant environment for Symfony 2.6.x, Apache and MySQL.

# Install

```
curl -L  https://github.com/peterlcole/vagrant-symfony/archive/master.tar.gz | tar zx
mv vagrant-symfony-master <project name>
cd <project name>
vagrant up
```

Note: Vagrant and VirtualBox are required.

Note: By default traffic on port 8000 is forwarded to the guest machine's port 80. If you are running multiple Vagrant instances based on this project, you will need to edit the *Vagrantfile* and change the host port.

# Use
After running `vagrant up`, Fire up ye ol' web browser and navigate to *http://localhost:8000* or *https://localhost:8000*. Save your code on the host machine in the *code/* directory.
