FROM node:current-alpine

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ v0.9.13
RUN apk --update add jq git && \
rm -rf /var/lib/apt/lists/* && \
rm /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

WORKDIR /npm

COPY package.json yarn.lock /npm

RUN yarn install

ENTRYPOINT ["/entrypoint.sh"]
