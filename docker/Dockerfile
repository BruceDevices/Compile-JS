# Compiles Bruce .js scripts into mquickjs bytecode (.bin) for ESP32.
#
# The mquickjs ref below MUST match the one pinned in platformio.ini
# (`mquickjs=https://github.com/BruceDevices/mquickjs#<ref>`), otherwise the
# bytecode this container produces may not be compatible with the engine
# actually compiled into the firmware.
FROM debian:bookworm-slim

ARG MQUICKJS_REF=0.0.6

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --branch "${MQUICKJS_REF}" --depth 1 \
        https://github.com/BruceDevices/mquickjs.git /opt/mquickjs \
    && make -C /opt/mquickjs mqjs

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /work
ENTRYPOINT ["/entrypoint.sh"]
