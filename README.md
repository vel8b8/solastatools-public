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

MySQL
```
# background:
brew services start mysql
# or
mysql.server start
# or foreground:
/usr/local/opt/mysql/bin/mysqld_safe --datadir=/usr/local/var/mysql
```

Redis and Sidekiq
```
redis-server
bundle exec sidekiq -q monitoring -q default
```

Rails
```
bundle exec rails server
```

Dev Tips
==============
One liner console test:

```u = CampaignUpload.last; w = CampaignUploadWorker.new; c = w.execute!(u.id); v = CampaignValidator.new; r = v.validate(c)```

Fight Club and Solasta Blueprints
====================================

How to recreate the marshaled encoded zip of the Solasta monster blueprints.
```
alias be=bundle exec
mkdir tmp/solasta_mods && cd tmp/solasta_mods
git clone https://github.com/SolastaMods/SolastaBlueprints
cd ../.. # cd solastatools
be rails runner scripts/extract_monster_blueprints.rb tmp/solasta_mods/SolastaBlueprints --pretty
be rails runner scripts/extract_monster_blueprints.rb tmp/solasta_mods/SolastaBlueprints > tmp/blueprints.marshaled
cd tmp && /bin/rm blueprints.marshaled.zip && zip blueprints.marshaled.zip blueprints.marshaled && /bin/cp blueprints.marshaled.zip ../config/solastadata/ && cd ..

Fight club test scripts.
```
be rails runner scripts/fight_club_runner.rb
be rails runner scripts/custom_monster_fight_club.rb
be rails runner "FightClubWorker.new.execute!(CampaignUpload.last.id)"
```

