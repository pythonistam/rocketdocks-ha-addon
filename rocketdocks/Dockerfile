ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache nginx curl

COPY rootfs /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
