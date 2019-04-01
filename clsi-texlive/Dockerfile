FROM node:lts as app

RUN git clone https://github.com/sharelatex/clsi-sharelatex.git
        # But look at
        # https://github.com/theunbound/clsi-sharelatex/tree/theunbound-local-synctex
        # if synctex keeps crashing the container.

WORKDIR /clsi-sharelatex
RUN npm install --quiet; \
    npm run compile:all

RUN wget ftp://tug.org/historic/systems/texlive/2018/install-tl-unx.tar.gz
ADD ./texlive.profile texlive.profile
RUN tar xzvf install-tl-unx.tar.gz \
        && ./install-tl-*/install-tl -profile texlive.profile

FROM node:lts

COPY --from=app /usr/local/texlive /usr/local/texlive
COPY --from=app /clsi-sharelatex /app

WORKDIR /app
# RUN chmod 0755 ./install_deps.sh && ./install_deps.sh
RUN apt-get update && apt-get install poppler-utils vim ghostscript --yes
RUN npm rebuild
RUN ln -s /app/bin/synctex /opt/synctex

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]

ENV PATH="/usr/local/texlive/2018/bin/x86_64-linux:${PATH}"

ADD ./tmp /usr/local/texlive/texmf-local/tex/latex
RUN mktexlsr

EXPOSE 3013

CMD ["node", "--expose-gc", "app.js"]
