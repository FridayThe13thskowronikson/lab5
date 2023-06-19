FROM scratch as dev_stage

ARG VERSION

ADD alpine-minirootfs-3.17.3-x86_64.tar.gz /

RUN apk update && \
	apk upgrade && \
	apk add --no-cache nodejs=18.14.2-r0 \
	npm=9.1.2-r0 && \
	rm -rf /etc/apk/cache
	
RUN npx create-react-app lab5

WORKDIR /lab5

COPY App.js ./src
ENV REACT_APP_VERSION=${VERSION}
RUN  npm install
RUN npm run build

FROM httpd:2.4
ARG VERSION 
LABEL org.opencontainers.image.authors="s95567@pollub.edu.pl"
LABEL org.opencontainers.image.version="$VERSION"

COPY --from=dev_stage /lab5/build/. /usr/local/apache2/htdocs
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=1s \
 CMD curl -f http://localhost:80/ || exit 1
CMD ["httpd", "-D", "FOREGROUND"]