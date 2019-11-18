# Sharelatex Community Edition (sharelatex/sharelatex)
# Modified to be Omega in stead

FROM sharelatex/sharelatex-base

ENV baseDir .

# Install sharelatex settings file
ADD ${baseDir}/settings.coffee /etc/sharelatex/settings.coffee
ENV SHARELATEX_CONFIG /etc/sharelatex/settings.coffee

ADD ${baseDir}/runit            /etc/service

RUN rm /etc/nginx/sites-enabled/default
ADD ${baseDir}/nginx/nginx.conf /etc/nginx/nginx.conf
# ADD ${baseDir}/nginx/sharelatex.conf /etc/nginx/sites-enabled/sharelatex.conf

ADD ${baseDir}/logrotate/sharelatex /etc/logrotate.d/sharelatex

COPY ${baseDir}/init_scripts/  /etc/my_init.d/

# Install ShareLaTeX
RUN git clone https://github.com/sharelatex/sharelatex.git /var/www/sharelatex

ADD ${baseDir}/services.js /var/www/sharelatex/config/services.js
ADD ${baseDir}/package.json /var/www/package.json
ADD ${baseDir}/git-revision.js /var/www/git-revision.js
# ADD ${baseDIr}/install-services /var/www/sharelatex/bin/install-services
RUN cd /var/www && npm install; \
        cd /var/www/sharelatex/; \
	npm install; \
        grunt install; \
        bash -c 'source ./bin/install-services'; \
        bash -c 'source ./bin/compile-services';
	# bash -c 'source ./bin/install-services';

# ADD ${baseDir}/main.js /var/www/sharelatex/web/public/src/
# ADD ${baseDir}/ide.js /var/www/sharelatex/web/public/src/

RUN cd /var/www/sharelatex/web; \
	npm install; \
        npm install bcrypt; \
        mkdir modules; \
        ### We're going to skip launchpad. It doesn't want to work like this
	# cd modules; \
	# git clone https://github.com/sharelatex/launchpad-web-module.git launchpad; \
        # cd ..; \
        make compile_full;

RUN cd /var/www && node git-revision > revisions.txt

# Minify js assets
RUN cd /var/www/sharelatex/web; \
        # grunt compile:minify; \
        make minify; \
        npm run webpack:production; \
	chown -R www-data:www-data /var/www/sharelatex;

        # This one didn't survive when they decaffinated web. Maybe it'll be fixed upstream at some point.
        # You should maybe check up on that, if you are reading this.
ADD --chown=www-data ./tasks/CreateAndDestoryUsers.coffee /var/www/sharelatex/tasks/CreateAndDestoryUsers.coffee

        # Temporary ...!
RUN cd /var/www/sharelatex; \
        rm tags/.nvmrc; \
        rm notifications/.nvmrc;

EXPOSE 80 443

WORKDIR /

ENTRYPOINT ["/sbin/my_init"]

