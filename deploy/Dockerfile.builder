FROM debian:bookworm-slim

ARG GODOT_VERSION=4.7.1
ARG GODOT_STATUS=stable

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        libasound2 \
        libfontconfig1 \
        libgl1 \
        libx11-6 \
        libxcursor1 \
        libxi6 \
        libxinerama1 \
        libxrandr2 \
        unzip \
    && rm -rf /var/lib/apt/lists/*

ARG GODOT_RELEASE=${GODOT_VERSION}-${GODOT_STATUS}
ARG GODOT_BASENAME=Godot_v${GODOT_VERSION}-${GODOT_STATUS}

RUN curl_base="https://github.com/godotengine/godot-builds/releases/download/${GODOT_RELEASE}" \
    && curl -fsSL "${curl_base}/${GODOT_BASENAME}_linux.x86_64.zip" -o /tmp/godot.zip \
    && curl -fsSL "${curl_base}/${GODOT_BASENAME}_export_templates.tpz" -o /tmp/templates.zip \
    && unzip -q /tmp/godot.zip -d /usr/local/bin \
    && mv "/usr/local/bin/${GODOT_BASENAME}_linux.x86_64" /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && mkdir -p "/opt/godot-data/godot/export_templates/${GODOT_VERSION}.${GODOT_STATUS}" \
    && unzip -q -j /tmp/templates.zip 'templates/web*' \
        -d "/opt/godot-data/godot/export_templates/${GODOT_VERSION}.${GODOT_STATUS}" \
    && chmod -R a+rX /opt/godot-data \
    && rm -f /tmp/godot.zip /tmp/templates.zip

COPY deploy/build-commit.sh /usr/local/bin/build-commit

ENV HOME=/tmp
ENV XDG_DATA_HOME=/opt/godot-data

ENTRYPOINT ["/usr/local/bin/build-commit"]
