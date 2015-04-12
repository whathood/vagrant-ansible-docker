#!/bin/bash

echo "*      Provisioning virtual machine"


SHARE_DIR="/vagrant"
PROVISION_DIR="$SHARE_DIR/provision"
PROVISION_CONFIG_DIR="$PROVISION_DIR/config"
BASEDIR=$(dirname $0)
apt_cmd='sudo apt-get -y install'

#
echo "*      Updating apt-get"
#
apt-get update > /dev/null

#
echo "*      configuring screen"
#
$apt_cmd screen > /dev/null
cp -f /vagrant/provision/config/screenrc /etc/screenrc

#
echo "*      Adding ubuntugis to apt-repository"
#
add-apt-repository ppa:ubuntugis/ubuntugis-unstable > /dev/null 2>&1
#
echo "*      Running apt-get update"
#
sudo apt-get update -y > /dev/null 2>&1

#
echo "*      installing Nginx"
#
$apt_cmd nginx > /dev/null 2>&1
usermod -G vagrant www-data

misc_progs="git ack-grep"
#
echo "*      installing programs $misc_progs"
#
$apt_cmd $misc_progs > /dev/null 2>&1

#
echo "*      installing Node.js"
#
$apt_cmd nodejs npm build-essential > /dev/null 2>&1
$apt_cmd coffeescript > /dev/null 2>&1

rm -f /usr/bin/node
ln -s /usr/bin/nodejs /usr/bin/node
npm install -g grunt-cli > /dev/null 2>&1

#
echo "*      installing PHP"
#
$apt_cmd git libpq-dev php5-pgsql php5-curl php5-cli php5-fpm php-pear php5-dev > /dev/null 2>&1

#
echo "*      installing PHPUnit"
#
wget https://phar.phpunit.de/phpunit.phar > /dev/null 2>&1
chmod +x phpunit.phar > /dev/null 2>&1
mv -f phpunit.phar /usr/local/bin/phpunit
#
echo "*      installing Ruby"
#
$apt_cmd ruby-full > /dev/null 2>&1

#
echo "*      installing Python"
#
$apt_cmd python-dev python-software-properties > /dev/null 2>&1

#
echo "*      installing PostgreSQL"
#
$apt_cmd postgresql postgresql-client postgresql-contrib > /dev/null 2>&1

#
echo "*      installing PostGIS-2.1"
#
$apt_cmd postgis postgresql-9.3-postgis-2.1 postgresql-9.3-postgis-2.1-scripts > /dev/null 2>&1

#
echo "*      configuring PostGIS"
#
cp -f $SHARE_DIR/provision/config/pg_hba.conf /etc/postgresql/9.3/main
sudo service postgresql restart > /dev/null 2>&1

#
echo "*      configuring Nginx"
#
rm -rf /etc/nginx/sites-available/default > /dev/null 2>&1
# delete the default website
rm -rf /var/www/html
service nginx restart > /dev/null 2>&1

#
echo "*      configuring vim"
#
su - vagrant -c "mkdir -p /home/vagrant/.vim/autoload"
su - vagrant -c "mkdir -p /home/vagrant/.vim/bundle"
su - vagrant -c "curl -LSso /home/vagrant/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim"
su - vagrant -c "echo 'execute pathogen#infect()' >> /home/vagrant/.vimrc"
su - vagrant -c "echo 'syntax on' >> /home/vagrant/.vimrc"
su - vagrant -c "echo 'filetype plugin indent on' >> /home/vagrant/.vimrc"
su - vagrant -c 'git clone https://github.com/kchmck/vim-coffee-script.git /home/vagrant/.vim/bundle/vim-coffee-script/ > /dev/null 2>&1'
su - vagrant -c 'git clone git://github.com/ntpeters/vim-better-whitespace.git /home/vagrant/.vim/bundle/vim-better-whitespace > /dev/null 2>&1'
cp -f $PROVISION_CONFIG_DIR/vimrc /etc/vim/vimrc

#
echo "*      installing Glances"
#
wget -silent https://bootstrap.pypa.io/get-pip.py > /dev/null 2>&1
sudo python get-pip.py > /dev/null 2>&1
sudo pip install Glances > /dev/null 2>&1

#
echo "*       installing perl modules"
#
sudo perl -MCPAN -e 'notest install App::cpanminus' > /dev/null 2>&1

#
echo "*      copying bash_aliases"
#
cp $SHARE_DIR/provision/config/bash_aliases /etc/bash_aliases
echo "source /etc/bash_aliases" >> /etc/bash.bashrc
echo "source /vagrant/provision/config/user_config" >> /etc/bash.bashrc


echo "*      copying over bashrc"
cp -f $SHARE_DIR/provision/config/vagrant_bashrc /home/vagrant/.bashrc