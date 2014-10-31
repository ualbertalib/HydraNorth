![HydraNorth Logo](/app/assets/images/hydranorth.png)

Dependencies:
--
(see https://code.library.ualberta.ca/hg/ansible-dev/hydranorth.yml for authoritative list)
* Rails application stack
  * ruby (2.1.0) /rails (4.0.4) /bundler (1.6.0)
  * nginx
  * unicorn
* microservices
 * fits
 * redis
 * resque
 * ImageMagick/GraphicsMagick
 * libreoffice
 * poppler
 * clamav
* backing store
 * Solr
 * Fedora 3.7
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

```rake test```

