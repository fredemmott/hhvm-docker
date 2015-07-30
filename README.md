HHVM is installed and running as a web server (via Proxygen).

 - it listens on port 80
 - both the default document and 404 document are `index.php`
 - it expects your site to be in `/var/www/public`
 - additional ini settings can be specified by replacing `/etc/hhvm/site.ini`

Development Usage
================

```
$ cd mysite
# with a randomly assigned port...
$ docker run --name=my_container -v $(pwd):/var/www/public -d -P fredemmott/hhvm-proxygen:latest
$ docker port my_container 80 # to find out what port was allocated
# ... or, on port 12345
$ docker run --name=my_container -v $(pwd):/var/www/public -d -p 12345:80 fredemmott/hhvm-proxygen:latest
```

Production Usage
==============

I recommend building your own Docker image derived from this by specifying a new Dockerfile:

```
FROM fredemmott/hhvm-proxygen:latest

RUN apt-get update -y
RUN apt-get install -y curl
# Install composer
RUN mkdir /opt/composer
RUN curl -sS https://getcomposer.org/installer | hhvm --php -- --install-dir=/opt/composer

# Install app
RUN rm -rf /var/www/public
ADD . /var/www/public
RUN cd /var/www/public && hhvm /opt/composer/composer.phar install

# Reconfigure HHVM
ADD hhvm.prod.ini /etc/hhvm/site.ini

EXPOSE 80
```

Deploy the image with your preferred hosting solution; this has been tested with AWS Elastic Beanstalk - simply `eb config; eb init; eb create; eb deploy` (see http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-getting-started.html)

Warning: If you are using AWS Elastic Beanstalk to build and deploy the images, it will build your images on the same instances used for serving the site. While a t1.micro is sufficient for running the image, it is not sufficient for both running and building an image: it's typical for even 'apt-get update' to run out of memory.

Disabling The Typechecker
-------------------------------

HHVM automatically runs the typechecker - this is useful in development, but assuming you have it running in your development workflow and in your CI system, there is not much additional benefit to running it in production, and the increased memory usage can be costly in production. To disable it, add the following to `/etc/hhvm/site.ini`:

```
hhvm.hack.lang.auto_typecheck=0
hhvm.hack.lang.look_for_typechecker=0
```

Error Logs
========

Errors are written to `stderr`, so can be accessed with `docker logs my-container`, or `docker logs -f my_container` to keep watching.

Versions/Tags
===========

- specific versions of HHVM are tagged, eg `3.8.0`.
- `latest` points at the latest stable release
- additional tags will be added for future LTS releases of HHVM with Proxygen support, eg `3.9-lts-latest`

About /var/www/public
==================

Most popular projects have `index.php` in the top level of their source tree, so should be deployed to `/var/www/public` - unfortunately, this is generally considered bad practice nowadays because having the root of your webapp publically accessible makes it very easy to
accidentally make things public that you do not mean to - for example, configuration files with database credentials, or your .git directory.

If you are working on a new project, consider a structure like:

```
myapp/composer.json
myapp/composer.lock
myapp/vendor/
myapp/public/index.php
myapp/src/ # if you don't like PSR-4
myapp/mynamespace/mysubnamespace/ # if you do like PSR-4
````

Then map `myapp/` to `/var/www` instead of `/var/www/public`.

If you agree in principle but dislike the name, you can override the `hhvm.server.source_root` path in `/etc/hhvm/site.ini` in your container.

But I Want FastCGI!
-----------------------

Sorry, not yet; I hope to add this soon as `fredemmott/hhvm-fastcgi`.

Source Please
============

https://github.com/fredemmott/hhvm-docker
