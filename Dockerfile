ARG CORE_VERSION=0.3.25

FROM ghcr.io/pixelaw/core:${CORE_VERSION} AS builder

WORKDIR /pixelaw

RUN git clone https://github.com/pixelaw/p_war_client.git

RUN  --mount=type=cache,mode=0777,target=/pixelaw/p_war_client_build/node_modules \
    shopt -s dotglob && \
    mv p_war_client/* p_war_client_build/ && \
    cd p_war_client_build && \
    yarn && \
    yarn build


COPY docker/build.sh /pixelaw/scripts/
COPY . /pixelaw/build/

RUN /pixelaw/scripts/build.sh

FROM ghcr.io/pixelaw/core:${CORE_VERSION} AS done

RUN rm -rf /pixelaw/web/*
COPY --from=builder /pixelaw/storage_init /pixelaw/storage_init
COPY --from=builder /pixelaw/p_war_client_build/dist /pixelaw/web





