FROM node:22-slim

ARG PI_UID=1000
ARG PI_GID=1000
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        tmux \
        sudo \
    && npm install -g npm@12.2.2 \
    && npm install -g @earendil-works/pi-coding-agent \
    && pi install npm:pi-llama-cpp \
    && userdel node \
    && rm -rf /home/node \
    && groupadd --gid "${PI_GID}" pi \
    && useradd --uid "${PI_UID}" --gid pi -m -s /bin/bash pi \
    && install -d -o pi -g pi /home/pi/.pi \
    && echo "ok all done"

COPY sudoers-pi /etc/sudoers.d/pi
RUN chmod 440 /etc/sudoers.d/pi
ENV PATH="/home/pi/bin:/usr/local/go/bin:${PATH}"
COPY --chown=pi:pi settings.json /home/pi/.pi/agent/settings.json

USER pi
ENV HOME=/home/pi
WORKDIR /workspace
ENTRYPOINT ["bash"]
