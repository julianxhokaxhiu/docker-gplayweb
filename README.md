# docker-gplayweb

GPlayWeb + FDroid Server + Caddy Server on one single Docker

# Why?

Inspired by [fxaguessy/gplayweb](https://github.com/fxaguessy/gplayweb) and [his article](https://fxaguessy.fr/en/articles/2017/02/11/effectively-using-android-without-google-play-services-gplayweb-in-docker/) my goal is to provide one single Docker "as an app" that just works.

## Configuration options

See [Dockerfile](Dockerfile#L7)

# How to use

```
docker run \
    --restart=always \
    -d \
    -e "GMAIL_ADDRESS=foobar@gmail.com" \
    -e "GMAIL_PASSWORD=my-awesome-password" \
    -e "ANDROID_ID=abcd123456789" \
    -e "GPLAYWEB_LANGUAGE=en-us" \
    -p 80:8080 \
    -p 81:8888 \
    -v "/home/user/data:/srv/data" \
    julianxhokaxhiu/docker-gplayweb
```