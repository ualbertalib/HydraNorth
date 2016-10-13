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

To Do Development Outside The Vagrant
--

Developers not wanting to have to ssh into the Vagrant to work on the application can mount the code from the host operating system by doing the following:

1. ssh into the vagrant and back up the existing Hydranorth installation: ```mv /var/www/sites/hydranorth /var/www/sites/hydranorth.bak```
1. exit the vagrant and add the following to the Vagrant file above the provider line:
  ```ruby

  config.vm.define "hydranorth", primary: true do |hydranorth|

    #...

    hydranorth.vm.synced_folder "<path to host's hydranorth repo directory>", "/var/www/sites/hydranorth"

    hydranorth.vm.provider "virtualbox" do |v|

      #...
  ```
1. reboot the vagrant
1. ssh into the vagrant and symlink the jetty directory on the vagrant into place (java does not like it when the jetty directory is mounted on the Host's share):
  ```
  cd /var/www/sites/hydranorth

  ln -s /var/www/sites/hydranorth.bak/jetty jetty
  ```
1. restart jetty & httpd

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
- **batch:ingest_csv** is used by ERA Admin and ERA Assistants to batch ingest from a csv file. Takes the csv file and a directory where the referenced files exist. use: ```rake batch:ingest_csv['batchData.csv','directory_where_batchFiles_lives','investigation_id','ingest_mode']```
  - **note: collections and communities dependencies must exist.**
  - **note: manifest file is batchData.csv created by the ERA Support team. PDFs will be in batchFiles directory. The location (parent dir) of batchFiles is used in the rake task. Both need to be copied to the app server. Investigation id is the id number used by the ERA Support team for reporting purpose. Ingest mode include 'ingest' and 'update'. Ingest mode will generate new object. Update mode will update existing objects. The manifest should include 'noid'***

Ingest Dataverse Metadata
---

- **migration:clean_up_withdrawn[old_dir,new_dir]**: compare the last ingest directory and the current ingest directory, detect and clean any study that has been withdrawn from Dataverse.
  - **note: The Dataverse metadata export only includes current published studies, and doesn't include any information about withdrawn studies. Ingest directories are always named with timestamps.**
- **migration:dataverse_objects[dir]**: ingest the metadata for dc term files in the given directory. It will create new objects for new studies, and update metadata for existing studies.
  - use: ```rake migration:dataverse_objects['spec/fixtures/migration/test-metadata/dataverse/']```


Generate Sitemap
---
** for Google Scholar **
- use: ```rake sitemap:generate```

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

EZID DOI Configuration
---
For hydranorth to successfully create and maintain DOI's you must configure the environmental variables for EZID's API. For more details on these environmental variables see the secrets file at:  `config/secrets.yml`. For non-production environments you can use the `apitest` test account provided by EZID by configuring it's password using the `EZID_PASSWORD` environment variable.
