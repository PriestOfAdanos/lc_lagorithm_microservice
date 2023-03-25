#include <iostream>
#include <fstream>
#include <string>
#include <crow.h>
#include <boost/filesystem.hpp>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/surface/poisson.h>

bool isValidPcdFile(const std::string& filePath) {
    std::ifstream file(filePath);
    std::string line;

    if (std::getline(file, line)) {
        return line.find("VERSION") == 0;
    }

    return false;
}

pcl::PolygonMesh processFile(const std::string& filePath, float scale) {
    if (!isValidPcdFile(filePath)) {
        throw std::runtime_error("Invalid PCD file.");
    }

    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZ>);
    if (pcl::io::loadPCDFile<pcl::PointXYZ>(filePath, *cloud) == -1) {
        throw std::runtime_error("Couldn't read the PCD file.");
    }

    pcl::search::KdTree<pcl::PointXYZ>::Ptr tree(new pcl::search::KdTree<pcl::PointXYZ>);
    tree->setInputCloud(cloud);

    pcl::Poisson<pcl::PointXYZ> poisson;
    poisson.setSearchMethod(tree);
    poisson.setDepth(8);  // You can adjust the depth parameter based on your requirements
    poisson.setInputCloud(cloud);
    pcl::PolygonMesh mesh;
    poisson.reconstruct(mesh);

    // Add your custom processing here, for example, scaling the reconstructed mesh

    return mesh;
}

int main(int argc, char** argv) {
    crow::SimpleApp app;

    CROW_ROUTE(app, "/processFile")
        .methods("POST"_method)
        ([](const crow::request& req) {
            auto scale = std::stof(req.url_params.get("scale"));
            auto fileData = req.body;

            std::string fileName = "uploadedFile.pcd";
            std::ofstream outputFile(fileName);
            outputFile << fileData;
            outputFile.close();

            try {
                pcl::PolygonMesh mesh = processFile(fileName, scale);

                boost::filesystem::remove(fileName);

                // Save the reconstructed mesh to a file, e.g., as a PLY file
                pcl::io::savePLYFile("reconstructed_mesh.ply", mesh);

                crow::json::wvalue response;
                response["status"] = "success";
                response["output_file"] = "reconstructed_mesh.ply";
                return crow::response(200, response);
            } catch (const std::runtime_error& e) {
                boost::filesystem::remove(fileName);

                crow::json::wvalue errorResponse;
                errorResponse["error"] = e.what();
                return crow::response(400, errorResponse);
            }
        });

    app.port(8080).multithreaded().run();

    return 0;
}
