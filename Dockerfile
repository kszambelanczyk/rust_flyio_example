# FROM rust:latest as builder

# WORKDIR /usr/src/app
# COPY . .
# # Will build and cache the binary and dependent crates in release mode
# RUN --mount=type=cache,target=/usr/local/cargo,from=rust:latest,source=/usr/local/cargo \
#     --mount=type=cache,target=target \
#     cargo build --release && mv ./target/release/hello_world ./hello_world

# # Runtime image
# FROM debian:bullseye-slim

# # Run as "app" user
# RUN useradd -ms /bin/bash app

# USER app
# WORKDIR /app

# # Get compiled binaries from builder's cargo install directory
# COPY --from=builder /usr/src/app/hello_world /app/hello_world

# # Run the app
# CMD ./hello_world


# new version -----------------------------------------------------------------

# in `hello-axum/Dockerfile`
# syntax = docker/dockerfile:1.4

FROM rust:1.74.0-slim-bullseye AS builder

WORKDIR /app
COPY . .
RUN --mount=type=cache,target=/app/target \
		--mount=type=cache,target=/usr/local/cargo/registry \
		--mount=type=cache,target=/usr/local/cargo/git \
		--mount=type=cache,target=/usr/local/rustup \
		set -eux; \
		rustup install stable; \
	 	cargo build --release; \
		objcopy --compress-debug-sections target/release/hello_world ./hello_world

################################################################################
FROM debian:11.3-slim

RUN set -eux; \
		export DEBIAN_FRONTEND=noninteractive; \
	  apt update; \
		apt install --yes --no-install-recommends bind9-dnsutils iputils-ping iproute2 curl ca-certificates htop; \
		apt clean autoclean; \
		apt autoremove --yes; \
		rm -rf /var/lib/{apt,dpkg,cache,log}/; \
		echo "Installed base utils!"

WORKDIR /app

COPY --from=builder /app/hello_world ./hello_world
CMD ["./hello_world"]