FROM alpine:3
RUN apk --update add curl bash tar openrc buildah podman

# Install Nixpacks
# https://github.com/railwayapp/nixpacks/issues/1141 Fixed to 1.24.5 to avoid issues with required version
ENV NIXPACKS_VERSION=1.24.5
RUN curl -sSL https://nixpacks.com/install.sh | bash

# Install pack for buildpacks
# (not installed since it is not possible to run pack inside a kubernetes cluster)
#RUN curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.35.1/pack-v0.35.1-linux.tgz" | tar -C /usr/local/bin/ --no-same-owner -xzv pack