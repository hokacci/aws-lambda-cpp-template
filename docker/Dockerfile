FROM amazonlinux:2

RUN yum update -y && \
	yum install -y --setopt=skip_missing_names_on_install=False \
		autoconf \
		automake \
		curl \
		gcc \
		gcc-c++ \
		git \
		gzip \
		libcurl-devel \
		libtool \
		make \
		openssl-devel \
		openssl-static \
		tar \
		unzip \
		wget \
		zip \
		zlib-devel && \
	rm -rf /var/cache/yum/* && \
	yum clean all

WORKDIR /install

# CMake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-linux-x86_64.sh && \
	/bin/sh cmake-3.23.1-linux-x86_64.sh --prefix=/usr/local --exclude-subdir --skip-license && \
	rm -rf *

# AWS Lambda C++ Runtime
RUN wget https://github.com/awslabs/aws-lambda-cpp/archive/refs/tags/v0.2.7.tar.gz && \
	tar zxf v0.2.7.tar.gz && \
	mv aws-lambda-cpp-0.2.7 aws-lambda-cpp-runtime && \
	mkdir -p aws-lambda-cpp-runtime/build && \
	cd aws-lambda-cpp-runtime/build && \
	cmake .. -DCMAKE_BUILD_TYPE=Release \
		-DBUILD_SHARED_LIBS=OFF && \
	make -j && \
	make install && \
	cd ../.. && \
	rm -rf *

# AWS SDK C++
# You probably need this.
# However AWS SDK C++ install may consume memory and take some time.
# (With my machine, it takes about 4 minutes.)
# You can install the modules you really need anytime.
# The following examples will help you.
# https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/cpp
#
# RUN git clone --recurse-submodules https://github.com/aws/aws-sdk-cpp && \
# 	cd aws-sdk-cpp && \
# 	git checkout --recurse-submodules 1.9.247 && \
# 	mkdir build && \
# 	cd build && \
# 	cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_ONLY="dynamodb;lambda;logs" && \
# 	make -j3 && \
# 	make install && \
# 	make clean && \
# 	cd ../.. && \
#	rm -rf *

# Any libraries you want to use come here.

WORKDIR /workspace

CMD ["ls", "-lFah"]
