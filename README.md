## Load Result

### Install a development environment

1. Install [VirtualBox](https://www.virtualbox.org)
2. Install [Vagrant](https://www.vagrantup.com)
3. Clone the repo https://stash.dnevnik.ru/projects/TF/repos/loadresult/browse
4. `cd` into the cloned folder
5. `cd vagrant`
7. `vagrant up` to download the linux box and install all the necessary software (around 2GB is required) and run the environment. Next time the command will only run the environment
8. `vagrant ssh` to connect to the environment
9. `cd /vagrant` (in a guest session) change directory to the shared folder with the app
10. `rails s -b 0.0.0.0` (in a guest session) to run the app
11. Go to "0.0.0.0:3000" in a browser
12. `vagrant halt` when your work is finished

#### Tips

* `srv` (in a guest session) command is added to .bashrc to quickly run the app
* `screen` is installed. The program allows you to use multiple windows. `screen --help` or `man screen` to get help
