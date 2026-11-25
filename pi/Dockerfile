FROM node:22-slim

ARG PI_UID=1000
ARG PI_GID=1000
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        tmux \
        procps \
        sudo \
        curl \
        ca-certificates \
        git \
    && npm install -g --allow-scripts=@google/genai,protobufjs \
    npm@12.2.3 \
    @earendil-works/pi-coding-agent \
    @openai/codex@latest \
    @anthropic-ai/claude-code@latest \
    && pi install npm:pi-llama-cpp \
    && pi install npm:pi-web-access \
    && userdel node \
    && rm -rf /home/node \
    && groupadd --gid "${PI_GID}" pi \
    && useradd --uid "${PI_UID}" --gid pi -m -s /bin/bash pi \
    && install -d -o pi -g pi /home/pi/.pi \
    && install -d -o pi -g pi /cache \
    && mkdir -pv /home/pi/.pi/agent/extensions \
    && update-ca-certificates \
    && echo "ok all done"

COPY sudoers-pi /etc/sudoers.d/pi
RUN chmod 440 /etc/sudoers.d/pi
ENV PATH="/home/pi/.local/bin:/home/pi/bin:/usr/local/go/bin:${PATH}"
COPY settings.json /home/pi/.pi/agent/settings.json
COPY finish.ts /home/pi/.pi/agent/extensions/finish.ts
RUN chown -Rv pi:pi /home/pi

USER pi
ENV HOME=/home/pi
# Global git identity for the pi user (written to /home/pi/.gitconfig)
RUN git config --global user.email "none@reply.com" \
    && git config --global user.name "me dots"
WORKDIR /workspace
ENTRYPOINT ["bash"]
