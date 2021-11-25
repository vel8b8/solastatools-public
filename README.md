solastatools
==============
@author vel8b8


Intro
==============
DM tools for the video game Solasta Crown of the Magister.

First Time Setup
==============
```
rvm update
rvm reload
brew install mysql
brew install redis
gem install rails
gem install mysql2 -v '0.5.2' --source 'https://rubygems.org/'
bundle exec bin/rails active_storage:install
bundle exec bin/rails db:create db:migrate
```

Running
================

```
# background:
brew services start mysql
```

```
# foreground:
/usr/local/opt/mysql/bin/mysqld_safe --datadir=/usr/local/var/mysql
redis-server
```

Dev Tips
==============
One liner console test:

```u = CampaignUpload.last; w = CampaignUploadWorker.new; c = w.execute!(u.id); v = CampaignValidator.new; r = v.validate(c)```
