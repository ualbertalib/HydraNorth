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
 * Solr 4.10.2
 * Fedora 4.0
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

To Restart Components
---
* Jetty
 * ```cd /var/www/sites/hydranorth && rake jetty:restart```
* Resque/Redis
 * ```service resque-pool restart```
* Rails/Passenger/Httpd
 * ```service httpd restart```

To Reset Components
---
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
