# Apache container

The container starts an apache with a connection to PHP via php-fpm

If you change the docroot you have to change the DocumentRoot *and* 
ProxyPassMatch definition!

```
DocumentRoot ##DOCROOT##
// and
ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://php:9000/##DOCROOT##/$1
```

The container needs access to the app-data volume to deliver assets and 
delegate requests to php service in case it is a php file. Note that is may need to folow symlinks to other folders, too
