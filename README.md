# ss-local-with-conf-dir
Docker image for ss-local running with conf dir

[![](https://images.microbadger.com/badges/version/maxduke/ss-local-with-conf-dir.svg)](https://microbadger.com/images/maxduke/ss-local-with-conf-dir "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/maxduke/ss-local-with-conf-dir.svg)](https://microbadger.com/images/maxduke/ss-local-with-conf-dir "Get your own image badge on microbadger.com")

[![Docker Pulls](https://img.shields.io/docker/pulls/maxduke/ss-local-with-conf-dir.svg)](https://hub.docker.com/r/maxduke/ss-local-with-conf-dir/ "Docker Pulls")
[![Docker Stars](https://img.shields.io/docker/stars/maxduke/ss-local-with-conf-dir.svg)](https://hub.docker.com/r/maxduke/ss-local-with-conf-dir/ "Docker Stars")
[![Docker Automated](https://img.shields.io/docker/automated/maxduke/ss-local-with-conf-dir.svg)](https://hub.docker.com/r/maxduke/ss-local-with-conf-dir/ "Docker Automated")

## Usage

0. Prepare config and download directories with following commands.

    ```bash
    # Create config dir
    mkdir /storage/ss-local/conf
    ```
0. Put all you ss-local conf file in that floder.

    ```bash
	copy *.conf /storage/ss-local/conf
    ```
0. Run following command to start ss-local instances

    ```bash
    docker run \
      -d \
	  --network host \
      --name ss-local \
      -v /storage/ss-local/conf:/ss-local/conf \
      maxduke/ss-local-with-conf-dir
    ```

Note:
* Learn more about `config.json`: [Config sample](https://raw.githubusercontent.com/shadowsocks/shadowsocks-libev/master/config.json)

## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
`http://192.168.x.x:8080` would show you what's running INSIDE the container on port 80.


* `--network host` - run as host mode, so that port mapping is not needed
* `-v /storage/ss-local/conf:/ss-local/conf` - where ss-local config files that ss-local should run with

It is based on alpine linux, for shell access whilst the container is running do `docker exec -it maxduke/ss-local-with-conf-dir /bin/sh`.

