FROM lsiobase/alpine.python:3.8

# set version label
ARG BUILD_DATE
ARG VERSION
ARG TAUTULLI_COMMIT
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs,thelamer"

# Inform app this is a docker env
ENV TAUTULLI_DOCKER=True

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	jq \
	make \
	python-dev && \
 apk add --no-cache \
        git && \
 echo "**** install pip packages ****" && \
 pip install --no-cache-dir -U \
	plexapi \
	pycryptodomex && \
 echo "**** install app ****" && \
 mkdir -p /app/tautulli && \
 if [ -z ${TAUTULLI_COMMIT+x} ]; then \
        TAUTULLI_COMMIT=$(curl -sX GET https://api.github.com/repos/Tautulli/Tautulli/commits/master \
        | jq -r '. | .sha'); \
 fi && \
 git clone https://github.com/Tautulli/Tautulli.git /app/tautulli && \
 cd /app/tautulli && \
 git checkout ${TAUTULLI_COMMIT} && \
 echo "**** Hard Coding versioning ****" && \
 echo "None" > /app/tautulli/version.txt && \
 echo "None" > /app/tautulli/version.lock && \
 echo ${TAUTULLI_COMMIT} > /app/tautulli/release.lock && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /logs
EXPOSE 8181
