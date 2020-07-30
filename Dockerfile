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
RUN mkdir -p /var/www/nginx-cache


