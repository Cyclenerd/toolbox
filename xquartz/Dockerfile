FROM ubuntu:jammy

ENV XDG_RUNTIME_DIR="/root/.xdg-runtime-root"
ENV XAUTHORITY="/tmp/.Xauthority"

# Ubuntu 22.04, Debian Bookworm and above
RUN apt-get update && apt-get install -y \
	neofetch \
	konsole \
	breeze-icon-theme \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p $XDG_RUNTIME_DIR \
	&& chmod 700 $XDG_RUNTIME_DIR

ENTRYPOINT [ "konsole" ]