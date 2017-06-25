# OpenTTD alpine docker image

Docker image to run a dedicated openTTD server on Alpine Linux.

## Why

When using Alpine Linux for Docker images, the image size will be a lot less in comparison when using Debian as base image.

## Current status

- Install via generic linux binary didn't work ✅
- Compiling and installing works ✅
- Starting the dedicated server works ✅
- When connecting with a client the dedicated server immediately crashes with a segmentation fault. ❌

## Todo

- Check debug message via gdb, OpenTTD has to be compiled with a DEBUG flag.

## Commands

### Build
```
docker build -t openttd-alpine .
```

### Run
```
# run 'openttd -D'
docker run --rm openttd-alpine

# start shell
docker run -it --rm openttd-alpine sh
```
