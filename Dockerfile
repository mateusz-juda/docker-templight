FROM ubuntu:16.04

RUN apt-get update && apt-get install -yy  make gcc g++ python cmake zip zlib1g-dev subversion git

ARG workdir="/tmp/workdir"
ARG llvm_rev=290370
ARG clang_rev=290373
ARG templight_rev=0738fa15ef7e24c5864c95e02d53c6f2e98f160b

RUN mkdir -p $workdir && sleep 1 \
    && cd $workdir && svn co -r ${llvm_rev} http://llvm.org/svn/llvm-project/llvm/trunk llvm \
    && pwd && cd $workdir/llvm/tools && svn co -r ${clang_rev} http://llvm.org/svn/llvm-project/cfe/trunk clang \
    && cd $workdir/llvm/tools/clang/tools && mkdir templight && git clone https://github.com/mikael-s-persson/templight && cd templight && git reset --hard ${templight_rev} \
    && cd $workdir/llvm/tools/clang && svn patch tools/templight/templight_clang_patch.diff \
    && echo "add_subdirectory(templight)" >> $workdir/llvm/tools/clang/tools/CMakeLists.txt \
    && cd $workdir && mkdir build && cd build && cmake ../llvm/ && make -j "$(cat /proc/cpuinfo | grep -c '^processor')" install

#    && $workdir/build/bin/templight

# RUN rm -fr $workdir
