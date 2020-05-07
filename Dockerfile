FROM node:current-alpine

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ v0.10.0
RUN apk --update add jq git && \
rm -rf /var/lib/apt/lists/* && \
rm /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
COPY package.json yarn.lock /npm/

RUN cd /npm
RUN yarn config set "@rentpath:registry" https://npm.pkg.github.com
RUN yarn install

ENTRYPOINT ["/entrypoint.sh"]
