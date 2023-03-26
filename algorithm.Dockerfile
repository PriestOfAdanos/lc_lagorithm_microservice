# Use the official Ubuntu image as the base
FROM ubuntu:20.04 as compile

# Set the working directory
WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    libboost-all-dev
    
RUN apt-get update && \
    apt-get install -y g++ make cmake libboost-all-dev libeigen3-dev libflann-dev libvtk7-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN apt update && \
    apt install -y libpcl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/CrowCpp/Crow.git

# Build and install Crow
RUN cd Crow && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install
    
COPY microservice.cpp /app/
RUN mkdir build

# Compile the code
RUN g++ -std=c++14 -O2 -Wall -Wextra -pthread -o microservice microservice.cpp -lboost_filesystem -lboost_system -lcrow -lpcl_common -lpcl_io -lpcl_surface -lpcl_search -lpcl_kdtree

FROM ubuntu:20.04 as runtime
COPY --from=compile /app/microservice .
# Expose the port used by the microservice
EXPOSE 8080
# Start the microservice
CMD ["./microservice"]
