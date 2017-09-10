# nginx-alt image #

This is a base image for the nginx server. It is based on the official
nginx Alipine image and provides an entry point that can tweak a
`nginx.conf.tmpl` into the final version.

This allows you, for example, to adjust the listening port dynamically,
or to use a different document root.

Your child images can add a customized `nginx.conf.tmpl` and still
benefit from ENV-based customisation.

# How to use #

## Quick start ##

To use this image:

1. create a Dockerfile on your project and use `FROM melopt/nginx-alt`;
2. copy your project `nginx.conf` into `/etc/nginx/nginx.conf.tmpl`: the
   default `ENTRYPOINT` script will do the variable substitution on that
   file and place it in `/etc/nginx/nginx.conf`;
3. if needed, copy your static assets to the document root, defaults to
   `/usr/share/nginx/html` but you can tweak it, see below.

Build your image and profit.


## Variable substituition ##

The script used for entry point supports two type of substitutions:

* `${VAR_NAME}`: plain replace with ENV `VAR_NAME` value. This is a
  required parameter;
* `${VAR_NAME:-default_value}`: same as above but use `default_value` if
  no ENV VAR_NAME is found.


## Default nginx.conf.tmpl ##

The default `nginx.conf.tmpl` is the same as the upstream default
`nginx.conf` from the nginx alpine image.

Three configurations were added, via ENV, or `docker run -e`:

* `PORT` (defaults to 80): the port where to listen to. Useful if you
  want to use multiple docker containers on the same host with `--
  net=host`. You can start each nginx on a different port, and bypass
  the docker networking logic. If you want to use the Docker networking,
  the image still EXPOSE'es port 80, so skip `PORT` and you can use the
  usual Docker networking trickery;
* `DOCROOT` (default `/usr/share/nginx/html`): location inside the
  container that will be used as document root;
* `INDEX_FILE` (default `index.html`): name of the default file used for
  directory listings.


## Custom nginx.conf.tmpl ##

You can use your own `nginx.conf.tmpl`. During your own image build,
copy it over to `/etc/nginx/nginx.conf.tmpl`. For example, you could use
this Dockerfile:

```
FROM melopt/nginx-alt

COPY nginx.conf.tmpl /etc/nginx/nginx.conf.tmpl
```

Alternatively, if you don't want to create your own Dockerfile just
to update the configuration template, you can also use a `docker
run` mount:

    docker run -v my.nginx.conf.tmpl:/etc/nginx/nginx.conf.tmpl melopt/nginx-alt
