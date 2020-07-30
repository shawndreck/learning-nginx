# Personal notes on learning to use NGINX
With some experience of Apache but wishing to switch to NGINX,
I decided to take a renewed look at NGINX to demystify it for my own
use. 

This is a repository to keep configurations and notes.
I used linux containers in WSL2 for this setup

* DON'T PUT server block inside /etc/nginx/nginc.conf! *
Rather use separate files with the format `example.com.conf` stored in `/etc/nginx/conf.d/`

## Notes
- Set `server_tokens off` in `/etc/nginx/nginx.conf` to disable printing out version number of pages such as default 404 etc.

## Hosting Multiple Websites
In NGINX speak, a Server Block basically equates to a website (same as Virtual Host in Apache terminology). NGINX can host multiple websites, and each site’s configuration should be in its own file, with the name formatted as example.com.conf. That file should be located at /etc/nginx/conf.d/.

How to disable a site
If you then want to disable the site example.com, then rename example.com.conf to example.com.conf.disabled. 

Use separate error logs for each server block
When hosting multiple sites, be sure to separate their access and error logs with specific directives inside each site’s server block

- Use `nginx -s reload` after making changes to config

## ABOUT CACHING
NGINX can cache files served by web applications and frameworks such as WordPress, Drupal and Ruby on Rails. 

Create a folder to store cached content:

    mkdir /var/www/example.com/cache/

Add the proxy_cache_path directive to NGINX’s http block. Make sure the file path references the folder you just created in Step 1.

/etc/nginx/nginx.conf

    proxy_cache_path /var/www/example.com/cache/ keys_zone=one:10m max_size=500m inactive=24h use_temp_path=off;

keys_zone=one:10m sets a 10 megabyte shared storage zone (simply called one, but you can change this for your needs) for cache keys and metadata.

max_size=500m sets the actual cache size at 500 MB.

inactive=24h removes anything from the cache which has not been accessed in the last 24 hours.

use_temp_path=off writes cached files directly to the cache path. This setting is recommended by NGNIX.

Add the following to your site configuration’s server block. If you changed the name of the storage zone in the previous step, change the directive below from one to the zone name you chose.

Replace ip-address and port with the URL and port of the upstream service whose files you wish to cache. For example, you would fill in 127.0.0.1:9000 if using WordPress or 127.0.0.1:2638 with Ghost.

```
    /etc/nginx/conf.d/example.com.conf
        proxy_cache one;
            location / {
            proxy_pass http://ip-address:port;
            }
```
If you need to clear the cache, the easiest way is with the command:
```find /var/www/example.com/cache/ -type f -delete```

If you want more than just a basic cache clear, you can use the proxy_cache_purge directive.

## Disable content sniffing
Add the following to either http block in nginx.conf to disable content sniffing.

    add_header X-Content-Type-Options nosniff;

Content sniffing allows browsers to inspect a byte stream in order to determine the file format of its contents. It is generally used to help sites that do not correctly identify the MIME type of their content, but it also presents a vector for cross-site scripting and other attacks.


## Limit or Disable Content Embedding

Content embedding is when a website renders a 3rd party element (div, img, etc.), or even an entire page from a completely different website, in a <frame>, <iframe>, or <object> HTML block on its own site. 
The X-Frame-Options HTTP header stops content embedding so your site can’t be presented from an embedded frame hosted on someone else’s website, one undesirable outcome being a clickjacking attack

To disallow the embedding of your content from any domain other than your own, add the following line to your configuration:

    add_header X-Frame-Options SAMEORIGIN;

To disallow embedding entirely, even from within your own site’s domain:

    add_header X-Frame-Options DENY;

