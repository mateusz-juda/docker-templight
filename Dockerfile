FROM ubuntu:16.04

ARG workdir="/tmp"
ARG cpu_cores="$(cat /proc/cpuinfo | grep -c '^processor')"


RUN apt-get update && apt-get install -yy  make gcc g++ python cmake zip zlib1g-dev subversion git
RUN cd $workdir && svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm \
    && cd $workdir/llvm/tools && svn co http://llvm.org/svn/llvm-project/cfe/trunk clang && cd ../.. \
    && cd $workdir/llvm/tools/clang/tools && mkdir templight && git clone https://github.com/mikael-s-persson/templight \
    && cd $workdir/llvm/tools/clang && svn patch tools/templight/templight_clang_patch.diff \
    && echo "add_subdirectory(templight)" >> $workdir/llvm/tools/clang/tools/CMakeLists.txt \
    && cd $workdir && mkdir build && cd build && cmake ../llvm/ && make -j ${cpu_cores}

#    && $workdir/build/bin/templight
