ARG CORE_VERSION=0.3.24

FROM ghcr.io/pixelaw/core:${CORE_VERSION} AS builder

WORKDIR /pixelaw

RUN  --mount=type=cache,mode=0777,target=/pixelaw/p_war_client_build/node_modules \
    shopt -s dotglob && \
    git clone  https://github.com/pixelaw/p_war_client.git && \
    mv p_war_client/* p_war_client_build/ && \
    cd p_war_client_build && \
    ls -la && \
    yarn && \
    yarn build

# TODO deploy the contracts


FROM ghcr.io/pixelaw/core:${CORE_VERSION} AS done

RUN rm -rf /pixelaw/web/*
COPY --from=builder /pixelaw/p_war_client_build/dist /pixelaw/web





