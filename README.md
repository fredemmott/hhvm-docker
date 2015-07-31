This repository contains the sources for the following docker hub images:

 - [fredemmott/hhvm](https://registry.hub.docker.com/u/fredemmott/hhvm/)
 - [fredemmott/hhvm-proxygen](https://registry.hub.docker.com/u/fredemmott/hhvm-proxygen/)

Building A New Version
======================

When a new version of HHVM is released:

Change The fredemmott/hhvm Version Number
-----------------------------------------

For example, for 3.8.0 => 3.8.1:

```diff
diff --git a/hhvm-latest/Dockerfile b/hhvm-latest/Dockerfile
index 185d896..17644e0 100644
--- a/hhvm-latest/Dockerfile
+++ b/hhvm-latest/Dockerfile
@@ -4,4 +4,4 @@ RUN apt-get update -y
 RUN apt-get install -y software-properties-common
 RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7
 RUN add-apt-repository "deb http://dl.hhvm.com/ubuntu trusty main"
-RUN apt-get update -y && apt-get install -y hhvm=3.8.0~trusty
+RUN apt-get update -y && apt-get install -y hhvm=3.8.1~trusty
```

Build And Tag fredemmott/hhvm
-----------------------------

The ID will not match; be sure to tag your new image ID instead of copying
the one in this example.

```
$ docker build hhvm-latest/
...
Successfully built ba93944aeef2
$ docker tag ba93944aeef2 fredemmott/hhvm:latest
$ docker tag ba93944aeef2 fredemmott/hhvm:3.8.1
```

Change The fredemmott/hhvm-proxy Version Number
-----------------------------------------------

```diff
diff --git a/hhvm-latest-proxygen/Dockerfile b/hhvm-latest-proxygen/Dockerfile
index b632379..a6aa0ee 100644
--- a/hhvm-latest-proxygen/Dockerfile
+++ b/hhvm-latest-proxygen/Dockerfile
@@ -1,4 +1,4 @@
-FROM fredemmott/hhvm:3.8.0
+FROM fredemmott/hhvm:3.8.1

 RUN mkdir -p /var/www/public
```

Build And Tag fredemmott/hhvm-proxygen
--------------------------------------

```
$ docker build hhvm-latest-proxygen/
Sending build context to Docker daemon 3.584 kB
Sending build context to Docker daemon
Step 0 : FROM fredemmott/hhvm:3.8.1
 ---> ba93944aeef2
...
Successfully built b85395df4dc7
$ docker tag b85395df4dc7 fredemmott/hhvm-proxygen:latest
$ docker tag b85395df4dc7 fredemmott/hhvm-proxygen:3.8.1
```

Test
----

Test with an arbitrary website. If you have a site with `index.php` in the root:

```
~/mysite$ docker run --name=3.8.1_test -v $(pwd):/var/www/public -d -P fredemmott/hhvm-proxygen:latest
e6e108f83a7421d6163c27d70bcd0ea7a801546a555e503f1bbb9c055377df87
~/mysite$ docker port 3.8.1_test 80
0.0.0.0:49153
```

Then run your test suite against the port that docker gives you - http://localhost:49153 for the example above.

To clean up your tests:

```
$ docker stop 3.8.1_test
$ docker rm 3.8.1_test
```

Sanity-Check
------------

```
$ docker images | grep fredemmott/hhvm
fredemmott/hhvm-proxygen   3.8.1               b85395df4dc7        12 minutes ago      469.9 MB
fredemmott/hhvm-proxygen   latest              b85395df4dc7        12 minutes ago      469.9 MB
fredemmott/hhvm            3.8.1               ba93944aeef2        16 minutes ago      469.9 MB
fredemmott/hhvm            latest              ba93944aeef2        16 minutes ago      469.9 MB
fredemmott/hhvm-proxygen   3.8.0               78844bf6551e        43 hours ago        470.9 MB
fredemmott/hhvm            3.8.0               53363d5764e8        2 days ago          470.9 MB
```

Check for typos, and make sure that the IDs and timestamps for 'latest' and the new version match.

Push To DockerHub
-----------------

```
$ docker push fredemmott/hhvm
The push refers to a repository [fredemmott/hhvm] (len: 3)
Sending image list
Pushing repository fredemmott/hhvm (3 tags)
...
ba93944aeef2: Image successfully pushed
Pushing tag for rev [ba93944aeef2] on {https://cdn-registry-1.docker.io/v1/repositories/fredemmott/hhvm/tags/3.8.1}
Pushing tag for rev [ba93944aeef2] on {https://cdn-registry-1.docker.io/v1/repositories/fredemmott/hhvm/tags/latest}
$ docker push fredemmott/hhvm-proxygen
The push refers to a repository [fredemmott/hhvm-proxygen] (len: 3)
Sending image list
Pushing repository fredemmott/hhvm-proxygen (3 tags)
...
b85395df4dc7: Image successfully pushed
Pushing tag for rev [b85395df4dc7] on {https://cdn-registry-1.docker.io/v1/repositories/fredemmott/hhvm-proxygen/tags/3.8.1}
Pushing tag for rev [b85395df4dc7] on {https://cdn-registry-1.docker.io/v1/repositories/fredemmott/hhvm-proxygen/tags/latest}
```

Push Updated Sources
--------------------

```
$ git commit -m 'v3.8.1'
$ git push
```
