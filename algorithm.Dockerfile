# Use the official Ubuntu image as the base
FROM ubuntu:20.04 as compile

# Set the working directory
WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y g++ make cmake libboost-all-dev libeigen3-dev libflann-dev libvtk7-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PCL from source
RUN apt-get update && \
    apt-get install -y git && \
    git clone https://github.com/PointCloudLibrary/pcl.git && \
    cd pcl && \
    git checkout pcl-1.12.0 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j1 && \
    make install && \
    cd ../.. && \
    rm -rf pcl && \
    apt-get remove -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the source code into the container
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
