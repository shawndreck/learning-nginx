# Using latest version at the time of writing
FROM nginx:1.17

# Overwrite default nginx.conf
COPY my-nginx.conf /etc/nginx/nginx.conf

# Copy our server configurations 
COPY example.com.conf /etc/nginx/conf.d/

# Disable default.conf from configurations
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.disabled

# Creating directory for use as cache
# make sure to add proper configs to use this folder as cache storage
RUN mkdir -p /var/www/nginx-cache \
    mkdir -p /root/certs/example.com


# Copy Certificate/Key pair for use on https
# This is a serlf signed and only good for personal use
COPY MyCertificate.crt /root/certs/example.com/
COPY MyKey.key /root/certs/example.com/



