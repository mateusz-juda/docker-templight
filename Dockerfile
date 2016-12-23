FROM ubuntu:16.04

RUN apt-get update && apt-get install -yy  make gcc g++ python cmake zip zlib1g-dev subversion git libboost-all-dev

ARG workdir="/usr/local/src/templight"
ARG llvm_rev=290370
ARG clang_rev=290373
ARG templight_rev=0738fa15ef7e24c5864c95e02d53c6f2e98f160b
ARG templight_tools_rev=cd3828bbc85faa3de5a05a9ccfc9ea27518af7d5


RUN mkdir -p $workdir # separated step, somehow it is a problem to have it bellow (no sync because -p?)

RUN cd $workdir && pwd && svn co -r ${llvm_rev} http://llvm.org/svn/llvm-project/llvm/trunk llvm \
    && pwd && cd $workdir/llvm/tools && svn co -r ${clang_rev} http://llvm.org/svn/llvm-project/cfe/trunk clang \
    && echo "Cloning templight" \
    && cd $workdir/llvm/tools/clang/tools && mkdir templight && git clone https://github.com/mikael-s-persson/templight && cd templight && git reset --hard ${templight_rev} \
    && echo "Patching ..." \
    && cd $workdir/llvm/tools/clang && svn patch tools/templight/templight_clang_patch.diff \
    && echo "Add to cmake" \
    && echo "add_subdirectory(templight)" >> $workdir/llvm/tools/clang/tools/CMakeLists.txt \
    && cd $workdir && mkdir build && cd build && echo "Cmake in ${PWD}" && cmake -DCMAKE_BUILD_TYPE=Release ../llvm/ && make -j "$(cat /proc/cpuinfo | grep -c '^processor')" check install \
    && rm -fr $workdir/*

RUN cd $workdir && git clone https://github.com/mikael-s-persson/templight-tools && cd templight-tools && git reset --hard ${templight_tools_rev} \
    && cd $workdir/templight-tools && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release ../ && make -j "$(cat /proc/cpuinfo | grep -c '^processor')" install \
    && rm -fr $workdir/*
