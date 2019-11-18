#!/bin/bash

if [ $CERTBOT_CERT_MANAGEMENT = "true" ]
then
    
    SHARELATEX_DOMAIN=$(echo $SHARELATEX_SITE_URL | sed -E 's/(https?:\/\/)?(.*)/\2/')
    
    if [ $(grep -c $SHARELATEX_DOMAIN /etc/nginx/nginx.conf) -eq 0 ]
    then if ! [ 0 -eq $(grep -c "server\s*{" /etc/nginx/nginx.conf) ]
            # There is a server block in nginx.conf (hopefully).
            # We'll put the domain name in there, so that certbot can find it.
            
         then
             sed -i "s|^\(\(\s*\)server_name\(\s*\).*\)|\2server_name\3$SHARELATEX_DOMAIN\n\1|" \
                 /etc/nginx/nginx.conf
         fi
    else
        echo "nginx.conf knows about the domain $SHARELATEX_DOMAIN"
    fi

    nginx &
    certbot -n --nginx --agree-tos -m $SHARELATEX_ADMIN_EMAIL -d $SHARELATEX_DOMAIN
    # The phusion base image is set up to renew these automatically

    nginx -s stop
fi
