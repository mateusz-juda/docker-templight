FROM debian:8

RUN apt-get update && apt-get install -yy  make gcc g++ python cmake zip zlib1g-dev
