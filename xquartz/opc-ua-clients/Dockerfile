FROM ubuntu:jammy

ENV APPIMAGE_EXTRACT_AND_RUN=1
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG="C.UTF-8"
ENV LIBGL_ALWAYS_INDIRECT=1
ENV XAUTHORITY="/tmp/.Xauthority"
ENV XDG_RUNTIME_DIR="/root/.xdg-runtime-root"

# Ubuntu 22.04, Debian Bookworm and above
RUN apt-get update && apt-get install -y \
	konsole \
	libfuse2 \
	libgl1-mesa-glx \
	libharfbuzz-icu0 \
	mesa-utils \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p $XDG_RUNTIME_DIR \
	&& chmod 700 $XDG_RUNTIME_DIR

COPY uaexpert-bin-linux-x86_64.AppImage /usr/bin/uaexpert
RUN chmod a+x /usr/bin/uaexpert && \
	sed -i 's|AI\x02|\x00\x00\x00|' /usr/bin/uaexpert

ENTRYPOINT [ "uaexpert" ]