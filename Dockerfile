FROM alpine:3.20

RUN apk add --no-cache bash iputils procps

COPY app/ /app/

RUN chmod +x /app/app.sh

WORKDIR /app

ENTRYPOINT ["/app/app.sh"]
CMD ["help"]
