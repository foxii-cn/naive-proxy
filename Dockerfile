FROM ubuntu:latest as builder
WORKDIR /workspace
RUN apt-get update -qq && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing jq wget curl xz-utils ca-certificates && \
wget -t5 -T10 -O naiveproxy-linux-x64.tar.xz \
$(curl --retry 10 --connect-timeout 60 --silent 'https://api.github.com/repos/klzgrad/naiveproxy/releases/latest' | jq -r '.assets[].browser_download_url' | grep linux | grep x64) && \
tar xvf naiveproxy-linux-x64.tar.xz --strip-components 1

FROM scratch
COPY --from=builder /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=builder /usr/lib/x86_64-linux-gnu/libc.so.6 /usr/lib/x86_64-linux-gnu/libgcc_s.so.1 /usr/lib/x86_64-linux-gnu/libm.so.6 /usr/lib/x86_64-linux-gnu/libdl.so.2 /usr/lib/x86_64-linux-gnu/libpthread.so.0 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=builder /workspace/naive /usr/bin/naive
VOLUME ["/etc/naive"]
ENTRYPOINT ["/usr/bin/naive"]
CMD ["/etc/naive/config.json"]