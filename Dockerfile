# Build Stage
FROM ubuntu:22.04 AS builder
RUN set -xeu && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    apt-get autoremove -y --purge && \
    apt-get -y autoclean

RUN set -xeu && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl \
        clang \
        libclang-dev \
        wget \
        unzip \
        build-essential \
        cmake \
        git \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb12 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libopenjp2-7-dev \
        libavformat-dev \
        libpq-dev \
        libgstreamer-plugins-base1.0-dev \
        libavcodec-dev

RUN set -xeu && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile=minimal

ENV PATH="${PATH}:/root/.cargo/bin"

ENV OPENCV_VERSION="4.8.1"
ENV OPENCV_PREFIX="/root/opencv4/"
RUN wget -q https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip && unzip -qq opencv.zip -d /opt/

RUN cmake \
        -D BUILD_CUDA_STUBS=OFF \
        -D BUILD_DOCS=OFF \
        -D BUILD_EXAMPLES=OFF \
        -D BUILD_IPP_IW=OFF \
        -D BUILD_JASPER=OFF \
        -D BUILD_JAVA=OFF \
        -D BUILD_JPEG=OFF \
        -D BUILD_OPENEXR=OFF \
        -D BUILD_OPENJPEG=OFF \
        -D BUILD_PERF_TESTS=OFF \
        -D BUILD_PNG=OFF \
        -D BUILD_SHARED_LIBS=ON \
        -D BUILD_TBB=OFF \
        -D BUILD_TESTS=OFF \
        -D BUILD_TIFF=OFF \
        -D BUILD_WEBP=OFF \
        -D BUILD_WITH_DEBUG_INFO=OFF \
        -D BUILD_WITH_DYNAMIC_IPP=OFF \
        -D BUILD_ZLIB=OFF \
        -D BUILD_opencv_apps=OFF \
        -D BUILD_opencv_python2=OFF \
        -D BUILD_opencv_python3=OFF \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=/usr \
        -D CV_DISABLE_OPTIMIZATION=OFF \
        -D CV_ENABLE_INTRINSICS=ON \
        -D ENABLE_CONFIG_VERIFICATION=OFF \
        -D ENABLE_FAST_MATH=OFF \
        -D ENABLE_LTO=OFF \
        -D ENABLE_PIC=ON \
        -D ENABLE_PRECOMPILED_HEADERS=OFF \
        -D INSTALL_CREATE_DISTRIB=OFF \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D INSTALL_TESTS=OFF \
        -D OPENCV_ENABLE_MEMALIGN=OFF \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_FORCE_3RDPARTY_BUILD=OFF \
        -D OPENCV_GENERATE_PKGCONFIG=OFF \
        -D PROTOBUF_UPDATE_FILES=OFF \
        -D WITH_1394=OFF \
        -D WITH_ADE=ON \
        -D WITH_ARAVIS=OFF \
        -D WITH_CLP=OFF \
        -D WITH_CUBLAS=OFF \
        -D WITH_CUDA=OFF \
        -D WITH_CUFFT=OFF \
        -D WITH_EIGEN=OFF \
        -D WITH_FFMPEG=OFF \
        -D WITH_GDAL=ON \
        -D WITH_GDCM=OFF \
        -D WITH_GIGEAPI=OFF \
        -D WITH_GPHOTO2=ON \
        -D WITH_GSTREAMER=ON \
        -D WITH_GSTREAMER_0_10=OFF \
        -D WITH_GTK=OFF \
        -D WITH_GTK_2_X=OFF \
        -D WITH_HALIDE=OFF \
        -D WITH_IMGCODEC_HDcR=ON \
        -D WITH_IMGCODEC_PXM=ON \
        -D WITH_IMGCODEC_SUNRASTER=ON \
        -D WITH_INF_ENGINE=OFF \
        -D WITH_IPP=ON \
        -D WITH_ITT=ON \
        -D WITH_JASPER=OFF \
        -D WITH_JPEG=ON \
        -D WITH_LAPACK=ON \
        -D WITH_MATLAB=OFF \
        -D WITH_MFX=OFF \
        -D WITH_OPENCL=OFF \
        -D WITH_OPENCLAMDBLAS=OFF \
        -D WITH_OPENCLAMDFFT=OFF \
        -D WITH_OPENCL_SVM=OFF \
        -D WITH_OPENEXR=OFF \
        -D WITH_OPENMP=ON \
        -D WITH_OPENNI2=OFF \
        -D WITH_OPENNI=OFF \
        -D WITH_OPENVX=OFF \
        -D WITH_PNG=ON \
        -D WITH_PROTOBUF=OFF \
        -D WITH_PTHREADS_PF=ON \
        -D WITH_PVAPI=OFF \
        -D WITH_QT=OFF \
        -D WITH_QUIRC=OFF \
        -D WITH_TBB=ON \
        -D WITH_TIFF=ON \
        -D WITH_UNICAP=OFF \
        -D WITH_VA=ON \
        -D WITH_VA_INTEL=ON \
        -D WITH_VTK=ON \
        -D WITH_WEBP=ON \
        -D WITH_XIMEA=OFF \
        -D WITH_XINE=OFF \
        -D BUILD_JPEG=ON \
        -D BUILD_OPENJPEG=ON \
        -D BUILD_PNG=ON \
        -D BUILD_SHARED_LIBS=OFF \
        -D WITH_TBB=ON \
        -D BUILD_TIFF=ON \
        -D BUILD_WEBP=ON \
        -D BUILD_ZLIB=ON \
        -D WITH_EIGEN=ON \
        -D WITH_V4L=OFF \
        -D BUILD_TIFF=ON \
        -D BUILD_opencv_java=OFF \
        -D WITH_CUDA=OFF \
        -D WITH_OPENGL=OFF \
        -D WITH_OPENCL=ON \
        -D BUILD_TESTS=OFF \
        -D BUILD_PERF_TESTS=OFF \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D BUILD_opencv_apps=OFF \
        -D BUILD_opencv_python2=OFF \
        -D BUILD_opencv_python3=OFF \
        -D CMAKE_INSTALL_PREFIX=${OPENCV_PREFIX} \
        /opt/opencv-${OPENCV_VERSION} && make -j$(nproc) && make install

WORKDIR /root/rust/src/
COPY . .
ENV OPENCV_LINK_LIBS=opencv_highgui,opencv_objdetect,opencv_dnn,opencv_calib3d,opencv_features2d,opencv_stitching,opencv_flann,opencv_videoio,opencv_video,opencv_ml,opencv_imgcodecs,opencv_imgproc,opencv_core,tbb,liblibwebp,liblibpng,liblibopenjp2
ENV OPENCV_LINK_PATHS=/root/opencv4/lib,/usr/lib/x86_64-linux-gnu
ENV OPENCV_INCLUDE_PATHS=/root/opencv4/include/opencv4
RUN cargo build --release


## Bundle Stage
#FROM ubuntu:22.04
#WORKDIR /code
#COPY --from=builder /root/opencv4/ /root/opencv4/
#COPY --from=builder /root/rust/src/sample-mp4-file-small.mp4 /code/
#COPY --from=builder /root/rust/src/target/release/test_opencv .
#
#ENV OPENCV_PREFIX="/root/opencv4/"
#ENV OPENCV_LINK_LIBS=opencv_highgui,opencv_objdetect,opencv_dnn,opencv_calib3d,opencv_features2d,opencv_stitching,opencv_flann,opencv_videoio,opencv_video,opencv_ml,opencv_imgcodecs,opencv_imgproc,opencv_core,tbb,liblibwebp,liblibtiff,liblibjpeg-turbo,liblibpng,liblibopenjp2
#ENV OPENCV_LINK_PATHS=/root/opencv4/lib,/usr/lib/x86_64-linux-gnu
#ENV OPENCV_INCLUDE_PATHS=/root/opencv4/include/opencv4
#CMD ["./test_opencv"]
