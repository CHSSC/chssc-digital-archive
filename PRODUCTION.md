Vagrant Curate Server
=====================

Create Vagrant Work Area

    $ mkdir vagrant
    $ cd vagrant

Clone Curate App

    $ git clone git@github.com:CHSSC/chssc-digital-archive.git
    $ cd chssc-digital-archive

Make this a vagrant work area

    $ vagrant init precise64

Update the Vagrantfile configuration.  Add access to Fedora and Rails ports

    config.vm.network :forwarded_port, guest: 3000, host: 3000
    config.vm.network :forwarded_port, guest: 8993, host: 8983

Update .git.info.exclude (don't want to include development environment specific files)

    $ echo "Vagrantfile" >> .git.info.exclude
    $ echo ".ruby-version" >> .git.info.exclude
    $ echo ".ruby-gemset" >> .git.info.exclude
    $ echo "*.swp" >> .git.info.exclude

Start up the Vagrant server

    $ vagrant up

Log onto the Vagrant server

    $ vagrant ssh

Update and install dependencies

    $ sudo apt-get update
    $ sudo apt-get install build-essential zlib1g-dev git-core sqlite3 libsqlite3-dev libtool libyaml-dev curl unzip python-software-properties
    $ sudo apt-get install openjdk-7-jre
    $ sudo apt-get install mysql-server
    # prepare a root password for mysql
    $ sudo apt-get install nodejs



Install transcoders

    $ sudo apt-get install imagemagick
    $ sudo apt-get install graphicsmagick-libmagick-dev-compat
    $ sudo apt-get -y install autoconf automake build-essential git libass-dev libgpac-dev \
    libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libx11-dev \
    libxext-dev libxfixes-dev pkg-config texi2html zlib1g-dev
    $ cd /usr/local/src
    $ sudo mkdir ffmpeg_sources
    $ cd ffmpeg_sources
    $ sudo git clone --depth 1 git://source.ffmpeg.org/ffmpeg
    $ cd ffmpeg
    $ PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
    $ export PKG_CONFIG_PATH
    $ sudo ./configure --prefix="$HOME/ffmpeg_build" \
      --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
      --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl \
      --enable-x11grab --disable-yasm
    sudo make
    sudo make install
    sudo make distclean
    sudo hash -r
    . ~/.profile


Install and configure RVM

    $ \curl -sSL https://get.rvm.io | bash -s stable --ruby
    $ source /home/vagrant/.rvm/scripts/rvm
    $ rvm gemset create curate
    $ cd /vagrant
    $ rvm use 2.0.0@curate --default

Or Install Ruby

    $ cd /vagrant
    $ mkdir build
    $ cd build
    $ wget http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz
    $ tar -zxv ruby-2.0.0-p353.tar.gz
    $ cd ruby-2.0.0-p353
    $ ./configure
    $ make
    $ make test
    $ sudo make install

Install bundler

    $ sudo gem install bundler

Complete Curate installation

Install Sufia dependencies

# Install fits.sh
Download the latest version from https://code.google.com/p/fits/downloads/list. In the example below for fits-0.6.2

From /opt

    $ sudo wget https://fits.googlecode.com/files/fits-0.6.2.zip
    $ sudo unzip fits-0.6.2.zip
    $ cd fits
    $ sudo chmod +x fits.sh

# Install redis

    $ cd /usr/local/src
    $ sudo wget http://download.redis.io/releases/redis-2.8.3.tar.gz
    $ sudo tar -zxf redis-2.8.3.tar.gz
    $ cd redis-2.8.3
    $ sudo make
    $ sudo make install
    # confirm Redis is installed
    $ ls /usr/local/bin

Install CHSSC Digital Archive
-----------------------------

    $ cd /opt
    $ sudo wget https://github.com/CHSSC/chssc-digital-archive/archive/master.zip
    $ sudo unzip master.zip
    $ sudo mv chssc-digital-archive-master chssc-digital-archive
    $ cd chssc-digital-archive

Add Ubuntu specific gems to the gem file

    gem "execjs"
    gem "therubyracer"

Install the gems

Add the following to config/initializers/sufia.rb

    config.fits_path = "/usr/local/bin/fits/fits.sh"

Install rails application

    $ rails generate curate
    Overwrite config/initializers/curate_config.rb? (enter "h" for help) [Ynaqdh] n
    $ git checkout -- config/routes.rb app/controllers/application_controller.rb
    $ rake db:migrate
    $ rails g hydra:jetty

Start Resque
    $ sudo redis-server &
    $ sudo QUEUE=* rake environment resque:work &

Start rails application
    $ rails s &


Install as production
---------------------

Go to the redis build directory

    $ cd /usr/local/src/redis-2.8.3
    $ cd utils/
    $ sudo ./install_server.sh
    Welcome to the redis service installer
    This script will help you easily set up a running redis server
    
    
    Please select the redis port for this instance: [6379]
    Selecting default: 6379
    Please select the redis config file name [/etc/redis/6379.conf]
    Selected default - /etc/redis/6379.conf
    Please select the redis log file name [/var/log/redis_6379.log]
    Selected default - /var/log/redis_6379.log
    Please select the data directory for this instance [/var/lib/redis/6379]
    Selected default - /var/lib/redis/6379
    Please select the redis executable path [/usr/local/bin/redis-server]
    s#^port [0-9]{4}$#port 6379#;s#^logfile .+$#logfile /var/log/redis_6379.log#;s#^dir .+$#dir /var/lib/redis/6379#;s#^pidfile .+$#pidfile /var/run/redis_6379.pid#;s#^daemonize no$#daemonize yes#;
    Copied /tmp/6379.conf => /etc/init.d/redis_6379
    Installing service...
    update-rc.d: warning: /etc/init.d/redis_6379 missing LSB information
    update-rc.d: see <http://wiki.debian.org/LSBInitScripts>
     Adding system startup for /etc/init.d/redis_6379 ...
       /etc/rc0.d/K20redis_6379 -> ../init.d/redis_6379
       /etc/rc1.d/K20redis_6379 -> ../init.d/redis_6379
       /etc/rc6.d/K20redis_6379 -> ../init.d/redis_6379
       /etc/rc2.d/S20redis_6379 -> ../init.d/redis_6379
       /etc/rc3.d/S20redis_6379 -> ../init.d/redis_6379
       /etc/rc4.d/S20redis_6379 -> ../init.d/redis_6379
       /etc/rc5.d/S20redis_6379 -> ../init.d/redis_6379
    Success!
    Starting Redis server...
    Installation successful!

Start resque on startup

    $ cd /srv/chssc-digital-archive
    $ sudo gem install foreman
    $ sudo foreman export upstart /etc/init --user steven

Install Nginx

    $ sudo add-apt-repository ppa:nginx/stable
    $ sudo apt-get update && apt-get install nginx
    $ cd /etc/nginx/sites-enabled
    $ sudo rm default
    $ sudo ln -s /srv/chssc-digital-archive/config/nginx.conf archive
    $ sudo service nginx restart

Test Nginx installation. Visit a known page in the rails application's public directory by visitng http://<site>/404.html or 500.html

Configure Unicorn

    $ cd /srv/chssc-digital-archive
    $ bundle exec unicorn -c config/unicorn.rb -D

Get and customize the Unicorn init shell script

    $ wget --no-check-certificate https://github.com/defunkt/unicorn/raw/master/examples/init.sh -O unicorn_init.sh

Add Unicorn to bin directory

    $ bundle binstubs unicorn

Customize the config/unicorn_init.sh to conform to your production server setup. Make sure it's executable

    $ chmod +x config/unicorn_init.sh

Add it to init.d:

    $ sudo ln -s /srv/chssc-digital-archive/config/unicorn_init.sh /etc/init.d/unicorn

Start nginx and unicorn

    $ sudo service nginx restart
    $ sudo service unicorn restart

If necessary start fedora server. If in development,

   $ rake jetty:start

Verify connection to services.

Reboot system

## Install Production Fedora

Follow [Fedora installation instructions](https://wiki.duraspace.org/display/FEDORA37/Installation+and+Configuration)

Remember to use a more secure password for MySQL and Fedora server admin accounts

Tomcat server is accessible at [http://localhost:8080/](http://localhost:8080/)
Fedora server is accessible at [http://localhost:8080/fedora](http://localhost:8080/fedora)
Solr server is accessible at [http://localhost:8080/solr](http://localhost:8080/solr)

## Prepare system for fedora server

### Modify linux environment

Edit `/etc/environment`. Prepend the path to Fedora executables to the PATH and add the Fedora environment variables:

    PATH="/usr/local/fedora/server/bin:usr/local/fedora/client/bin:[original path]"
    FEDORA_HOME="/usr/local/fedora"
    CATALINA_HOME="$FEDORA_HOME:tomcat"

Log back into server and start up production Fedora server

    $ CATALINE_HOME/bin/startup.sh

Visit `http://localhost:8080/fedora` and verify "Fedora Repository Information View"

### Run production Rails server

    $ rails server -e production

### Install Solr

Download the latest version of Solr

    $ cd $HOME
    $ wget http://mirrors.ibiblio.org/apache/lucene/solr/4.6.0/solr-4.6.0.tgz
    $ tar -zxf solr-4.6.0.tgz
    $ cd solr-4.6.0
    $ sudo ln -s $HOME/solr-4.6.0/example/solr /srv/bl_solr
    $ mkdir -p /var/bl_solr/data
    $ mkdir /srv/bl_solr/conf
    $ echo '<dataDir>${solr.data.dir:/var/bl_solr/fedora/data}</dataDir>' >> /srv/bl_solr/conf/solrconfig.xml

Edit `/etc/environment`. add `-Dsolr.solr.home=/srv/solr` to JAVA_OPTS, e.g.:

    JAVA_OPTS="-Dsolr.solr.home=/srv/solr"

Create a Tomcat Context fragment to point docBase to the $SOLR_HOME/solr.war file and solr/home to $SOLR_HOME

    <?xml version="1.0" encoding="utf-8"?>
    <Context docBase="/srv/bl_solr/solr.war" debug="0" crossContext="true">
      <Environment name="bl_solr/home" type="java.lang.String" value="/bl_srv/solr" override="true"/>
    </Context>

Add the Solr libraries to Tomcat

    cp $HOME/solr-4.6.0/example/lib/ext/* $CATALINA_HOME/lib
