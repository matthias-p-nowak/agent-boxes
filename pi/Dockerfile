FROM node:22-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
COPY --from=golang:1.27.3-bookworm /usr/local/go /usr/local/go

ARG PI_UID=1000
ARG PI_GID=1000
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        sudo \
    && npm install -g npm@12.2.2 \
    && npm install -g @earendil-works/pi-coding-agent \
    && userdel node \
    && rm -rf /home/node \
    && groupadd --gid "${PI_GID}" pi \
    && useradd --uid "${PI_UID}" --gid pi -m -s /bin/bash pi \
    && install -d -o pi -g pi /home/pi/.pi \
    && echo "ok all done"

COPY --chown=pi:pi scripts/ /home/pi/bin/
COPY sudoers-pi /etc/sudoers.d/pi
RUN chmod 755 /home/pi/bin/*
RUN chmod 440 /etc/sudoers.d/pi
ENV PATH="/home/pi/bin:/usr/local/go/bin:${PATH}"

USER pi
ENV HOME=/home/pi
WORKDIR /workspace
ENTRYPOINT ["bash"]
