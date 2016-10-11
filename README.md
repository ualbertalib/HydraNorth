![HydraNorth Logo](/app/assets/images/hydranorth.png)

The Stack:
--
![HydraNorth Stack](/hydranorth-stack.jpg)

Dependencies:
--
(see https://code.library.ualberta.ca/hg/ansible-dev/hydranorth.yml for authoritative list)
* Rails application stack
  * ruby (2.1.5) /rails (4.1.11) /bundler (1.6.0)
  * httpd
  * passenger
  * shibboleth-sp
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
  - to load the metadata without the content datastreams use: ```rake migration:eraitem['lib/tasks/migration/test-metadata',false]```
  - **note: migration has to happen in the following order: communities, collections, then eraitems.**
  - **note: file name should start with "uuid_", only those files will be selected.**
- ```rake hydranorth:update_special_itemtype``` will update the resource type "report" to "computing science technical report" if this item is a member of "technical report". In order for the rake task to work, the collection has to be migrated already and exist in the system.
- ```rake hydranorth:characterize``` will push all the items to the characterize resque pool for characterization, and thumbnail creation. This should be done after a complete fresh migration - as currently the migration job disables the resque jobs for faster completion.
  - **note: ```rake hydranorth:characterize_some['filename']``` will push the items in the given list to the characterize resque job. **
- **batch:ingest_csv** is used by ERA Admin and ERA Assistants to batch ingest from a csv file. Takes the csv file and a directory where the referenced files exist. use: ```rake batch:ingest_csv['lib/tasks/batch/ERA_batch_ingest.csv','lib/tasks/batch/files_and_metadata/']```
  - **note: collections and communities dependencies must exist.**

Generate Sitemap
---
** for Google Scholar
- use: rake sitemap:generate

Populating Local Geonames Authority
---
- **hydranorth:harvest:geonames_cities** which downloads the latest list of cities1000 file from geonames.org, and populates the data into local database tables: local_authorities, and local_authority_entries.
  - use: ```rake hydranorth:harvest:geonames_cities```
  - file downloaded: http://download.geonames.org/export/dump/cities1000.zip
  - scope for authority entries: contains all cities with a population >1000 or seats of adm div (ca 80.000)
  - local_authority_entries includes labels and URIs. Currently labels are used for autocompletion and saved in the record.

Configuring Shibboleth
---
* assuming that you have installed and [configured a Shibboleth Service Provider (SP)](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLinuxRPMInstall)
* visit '/Shibboleth.sso/Metadata' to download and review the metadata, rename to a filename of your preference
* upload the SP metadata to http://testshib.org/register.html or your Identiy Provider (IdP)
* login by clicking on 'Sign into Shibboleth' and choosing one of the available identities

Audit Fix
---
* To fix data with triple files:
```RAILS_ENV = {{RAILS_ENV}} bundle exec ruby bin/fix/fix-audit.rb 'triples','sample-sparql.txt'```
* To remove irrelevant theses dates:
```RAILS_ENV = {{RAILS_ENV}} bundle exec ruby bin/fix/fix-audit.rb 'thesis' <pair tree prefix|id>```
* To fix reindex:
```RAILS_ENV = {{RAILS_ENV}} bundle exec ruby bin/fix/fix-audit.rb 'reindex' <pair tree prefix|id>```

A set of rake tasks is also added for index jobs:
* ```rake hydranorth:solr:index[id]```         Index a single object with ID
* ```rake hydranorth:solr:index_pairtree[input]```   Index with a pairtree structure
* ```rake hydranorth:solr:batch_index[directory|file]``` Index from a list of noids, usually from a solr csv output that just contains noids.
* ```rake hydranorth:solr:reindex_all```	Complete reindex of the repository

A shell script will update namespace uris
* ```/bin/fix/fix.rb``` is to update all the namespace uris. Requires user to replace @server with the Fedora server location before using.
* ```/bin/fix/run.sh``` is to run script through all the pairtree combinations. Requires being run from the bin/fix directory.
