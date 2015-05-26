![HydraNorth Logo](/app/assets/images/hydranorth.png)

Dependencies:
--
(see https://code.library.ualberta.ca/hg/ansible-dev/hydranorth.yml for authoritative list)
* Rails application stack
  * ruby (2.1.5) /rails (4.1.8) /bundler (1.6.0)
  * httpd
  * passenger
* microservices
 * fits
 * redis
 * resque
 * ImageMagick/GraphicsMagick
 * libreoffice
 * poppler
 * clamav
* backing store
 * Solr 4.10.3
 * Fedora 4.1 with authorization
 * MySQL

To Install Application:
--
(see https://code.library.ualberta.ca/hg/ansible-dev/hydranorth.yml to apply Ansible playbook)

```
ansible-playbook hydranorth.yml
```
This assumes that you've created a hosts inventory with a hydranorth group.  If not consider
 using the vagrant or dev inventories that exist

 ```ansible-playbook -i vagrant hydranorth.yml```

If you're using Vagrant the easiest path is to

```vagrant up hydranorth```

To Run Tests:
--
(see http://cardiff.library.ualberta.ca/job/HydraNorth/)

```rake spec```

To View Logs:
--
Relative to the application directory

* **Application** ```log/<RAILS_ENV>.log```
* **Jetty** ```jetty/jettywrapper.log```
* **Solr/Fedora** ```jetty/logs```
* **Resque** ```log/resque-pool.std[err|out].log```

To Restart Components
---
The shell script `bin/restart-all` runs these commands:
* Jetty
 * ```cd /var/www/sites/hydranorth && rake jetty:restart```
* Resque/Redis
 * ```service resque-pool restart```
* Rails/Passenger/Httpd
 * ```service httpd restart```

To Reset Components
---
The shell script `bin/reset-all` runs these commands:
 * Jetty

```
  rake jetty:stop
  rake jetty:clean
  rake sufia:jetty:config
  rake jetty:start
```
 * Resque/Redis
```
  redis-cli
  $ FLUSHALL
  $ exit
```
```
  kill -9  `ps aux | grep [r]esque | grep -v grep | cut -c 10-16` # another way to stop all resque workers
  service resque-pool start
```
 * MySQL
```
 rake db:reset
```

Batch ingest
---

- **migration:user_migration** which migrates users in the user files (data derived from ERA mysql tables user and author) use: ```rake migration:user_migration['lib/tasks/migration/test-metadata/users.txt']``` 
  - **note: this has only been tested with small dataset - need to proceed with caution due to the potential for sending emails to migrated users** 
  - TO-DO: migrate user avator/profile images 
- **migration:era_collection_community** which migrates collections and communities in the metadata directory use (run community migration first then collection migration): ```rake migration:era_collection_community['lib/tasks/migration/test-metadata/community']```
```rake migration:era_collection_community['lib/tasks/migration/test-metadata/collection']```
- **migration:eraitem** which migrates active/non-deleted items from the metadata directory (argument from the rake task) use: ```rake migration:eraitem['lib/tasks/migration/test-metadata']```
  - **note: migration has to happen in the following order: communities, collections, then eraitems.**
  - **note: file name should start with "uuid_", only those files will be selected.**
- ```rake hydranorth:update_special_itemtype``` will update the resource type "report" to "computing science technical report" if this item is a member of "technical report". In order for the rake task to work, the collection has to be migrated already and exist in the system.
