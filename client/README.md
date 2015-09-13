# -----------------------------
# install
# -----------------------------

# assumes rvm/rub/rails installed

# assumes install postgresql

# OPTIONAL for postgres app
# build pg with pgapp // make sure version match
bundle config build.pg -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/9.4/bin/pg_config

# get code
git clone git@github.com:eyecuelab/powur.git
cd powur

# install bundle/gems
bundle install

# installs bower local
npm install

# install bower libs local
bower install

#------ src area / front end

# installed dev dependencies for gulp
# cd powur/client
cd client
npm install

# install front libs
# cd powur/client
bower install

# install typescript compiler globally
npm install typescript -g

# install typings package globally
npm install tsd -g

# recommended to install visual studio code



# MAC ONLY
# install brew
brew update
brew upgrade
brew install 

# -----------------------------
# structure
# -----------------------------
client/
    index.html          # main html page # includes partials
client/app/
    init.js.ts          # angular app modules
    root-controller.js.ts       # root controller / base

# install gulp
npm install -g gulp

# start gulp watch for ts
# cd powur/client
gulp

# start local server / dev (another terminal)
# cd powur/client
npm install -g local-web-server
ws

# go to
http://localhost:8000/#/

# install cordova
npm install -g cordova
