% Copyright 2022 Florian Pesth
%
% This file is part of co2carpool.
%
% co2carpool is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as
% published by the Free Software Foundation version 3 of the
% License.
%
% co2carpool is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

\section{Core program}

\subsection{task class}

The task class shall be used as a basis for other classes to schedule tasks.

@O ../src/task.h -d
@{
#ifndef TASK_CLASS
#define TASK_CLASS

class task
{
public:
    virtual bool isCompleted(void) const = 0;
    virtual unsigned int priority(void) const = 0;
    virtual void execute(void) = 0;
};
#endif // TASK_CLASS
@}

\subsection{CMakeLists.txt}
@O ../src/CMakeLists.txt
@{
cmake_minimum_required(VERSION 3.14)
project(co2carpool)

# libpq from PostgreSQL:
# There seems to be something broken about cmake PostgreSQL module on debian:
find_package(PostgreSQL REQUIRED)
if (PostgreSQL_TYPE_INCLUDE_DIR)
else (PostgreSQL_TYPE_INCLUDE_DIR)
set (PostgreSQL_TYPE_INCLUDE_DIR ${PostgreSQL_INCLUDE_DIR})
endif (PostgreSQL_TYPE_INCLUDE_DIR)

# libcurl
find_package(CURL REQUIRED)

# nlohmann json
find_package(nlohmann_json 3.9.1 REQUIRED)

add_executable(co2carpool main.cpp database.cpp rest.cpp route.cpp sumo/emissions/PollutantsInterface.cpp sumo/emissions/HelpersHBEFA4.cpp)
target_link_libraries(co2carpool PRIVATE PostgreSQL::PostgreSQL ${CURL_LIBRARIES} nlohmann_json::nlohmann_json)
@}

\subsection{main}
Shouldn't be exciting.

@O ../src/main.h -d
@{
#include <cstdlib>
#include <iostream>
#include <memory>

#include "database.h"
#include "rest.h"
#include "locations.h"
#include "route.h"

@}

@O ../src/main.cpp -d
@{
#include "main.h"

int main(){
    std::cout << "CO2 carpool\n";
    database maindb = database();
    std::shared_ptr<rest> restApi = std::make_shared<rest>();
    std::shared_ptr<task> cologne_gss_route = std::make_shared<route>(restApi, locations::cologne_central_station, locations::tuebingen_gss_school);
    cologne_gss_route->execute();
    return EXIT_SUCCESS;
}
@}

\subsection{database class}

This should manage all queries to the PostGIS database.

We use ``libpq'' for talking to the PostGIS database. Probably not all of those dependencies are needed:

\begin{lstlisting}
apt-get install libpq5 libpq-dev postgresql-server-dev-all postgresql-all
\end{lstlisting}

@O ../src/database.h -d
@{
#ifndef DATABASE_CLASS
#define DATABASE_CLASS

#include <iostream>
#include "libpq-fe.h"

class database {
public:
    database(void);
    ~database(void);
private:
    PGconn *connection;
    PGresult *result;
};

#endif
@}

@O ../src/database.cpp -d
@{
#include "database.h"

database::database(void){
    std::cout << "Connecting to database...";
    connection = PQconnectdb("dbname = co2carpool");
    if(PQstatus(connection) != CONNECTION_OK){
        std::cout << " failed:\n  " << PQerrorMessage(connection) << "\n";
        return;
    }
    std::cout << " ok!\n";
    std::cout << "Securing database...";
    result = PQexec(connection,
            "SELECT pg_catalog.set_config('search_path', '', false)");
    if (PQresultStatus(result) != PGRES_TUPLES_OK)
    {
        std::cout << " failed:\n  " << PQerrorMessage(connection) << "\n";
        return;
    }
    PQclear(result);
    std::cout << " ok!\n";
}

database::~database(void){
    std::cout << "Closing database...\n";
    PQfinish(connection);
}
@}

\subsection{rest class}

The rest class uses libcurl to send rest requests to graphhopper.

\begin{lstlisting}
apt-get install libcurl4
\end{lstlisting}

@O ../src/rest.h -d
@{
#ifndef REST_CLASS
#define REST_CLASS

#include <iostream>

#include <curl/curl.h>
#include <nlohmann/json.hpp>

class rest{
public:
    rest(void);
    ~rest(void);
    nlohmann::json post(const char* url, const char* options);
    nlohmann::json get(const char* url, const char* options);
private:
    CURL* curl;
    CURLcode result;
    struct curl_slist *headers;
};

#endif
@}

@O ../src/rest.cpp -d
@{

#include "rest.h"

rest::rest(void):
    headers(NULL)
{
    std::cout << "Initializing CURL...";
    curl_global_init(CURL_GLOBAL_ALL);
    curl = curl_easy_init();
    if(!curl){
        std::cout << " failed!\n";
    }
    std::cout << " ok!\n";
    std::cout << "Set headers to json...";
    headers = curl_slist_append(headers, "Accept: application/json");  
    headers = curl_slist_append(headers, "Content-Type: application/json");
    headers = curl_slist_append(headers, "charset: utf-8"); 
    result = curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    if(result != CURLE_OK){
        std::cout << " failed, error by curl is \"" << curl_easy_strerror(result) << "\"\n";
        return;
    }
    std::cout << " ok!\n";
}

rest::~rest(void){
    std::cout << "Cleaning up CURL...\n";
    curl_easy_cleanup(curl);
    curl_global_cleanup();
}

size_t writeIntoStdString(void* ptr, size_t size, size_t nmemb, void* str) {
    std::string* stdString = static_cast<std::string*>(str);
    stdString->erase(std::find(stdString->begin(), stdString->end(), '\0'), stdString->end());
    stdString->erase(std::find(stdString->begin(), stdString->end(), '\r'), stdString->end());
    std::copy((char*)ptr, (char*)ptr + (size + nmemb), std::back_inserter(*stdString));
    return size * nmemb;
}

nlohmann::json rest::post(const char* url, const char* options){
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, options);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeIntoStdString); 
    std::string resultString;
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &resultString);
    result = curl_easy_perform(curl);
    if(result != CURLE_OK)
        std::cout << "Error in post request for url \"" << url << "\", options \"" << options << "\", error by curl is \"" << curl_easy_strerror(result) << "\"\n";
    nlohmann::json resultJson = nlohmann::json::parse(resultString);
    return resultJson;
}

nlohmann::json rest::get(const char* url, const char* options){
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);
    //curl_easy_setopt(curl, CURLOPT_GETFIELDS, options);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeIntoStdString); 
    std::string resultString;
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &resultString);
    result = curl_easy_perform(curl);
    if(result != CURLE_OK)
        std::cout << "Error in get request for url \"" << url << "\", options \"" << options << "\", error by curl is \"" << curl_easy_strerror(result) << "\"\n";
    nlohmann::json resultJson = nlohmann::json::parse(resultString);
    return resultJson;
}


@}

\subsection{route class}

This provides a wrapper for the rest calls of ``graphhopper'' for the route calculation. If needed the routing engine can be replaced here.

@O ../src/route.h -d
@{
#ifndef ROUTE_CLASS
#define ROUTE_CLASS

#include <memory>

#include "task.h"
#include "rest.h"
#include "sumo/emissions/PollutantsInterface.h"

class route : public task{
public:
    struct coordinate {
        double lat;
        double lon;
    };
    struct instruction {
        double distance;
        std::vector<unsigned int> interval;
        int sign;
        std::string street_name;
        std::string text;
        unsigned int time;
        double co2;
        NLOHMANN_DEFINE_TYPE_INTRUSIVE(instruction, distance, interval, sign, street_name, text, time);
    };
    route(std::shared_ptr<rest> restApi, const coordinate& from, const coordinate& to);

    virtual bool isCompleted(void) const override;
    virtual unsigned int priority(void) const override;
    virtual void execute(void) override;
    void carRouting(void);
    void publicTransportRouting(void);
    double co2(std::string carClass);
    void isoemission(void);
private:
    coordinate from;
    coordinate to;
    bool routeCalculated;
    unsigned int prio;
    std::shared_ptr<rest> restApi;
    std::vector<coordinate> routePath;
    std::vector<instruction> instructions;
};

#endif
@}


@O ../src/route.cpp -d
@{

#include "route.h"
#include "locations.h"

route::route(std::shared_ptr<rest> l_restApi, const coordinate& l_from, const coordinate& l_to):
    restApi(l_restApi), from(l_from), to(l_to), routeCalculated(false), prio(1)
{
    std::cout << "Init route\n";
}

bool route::isCompleted(void) const{
    return routeCalculated;
}

unsigned int route::priority(void) const{
    return prio;
}

void route::execute(void){
    publicTransportRouting();
} 

void route::carRouting(void) {
    std::cout << "Car routing\n";
    nlohmann::json request;
    request["points"] = {{from.lon, from.lat}, {to.lon, to.lat}};
    request["profile"] = "car";
    request["instructions"] = true;
    request["points_encoded"] = false;
    request["debug"] = true;
    //request["details"] = {"max_speed", "distance", "time"};
    request["locale"] = "de";
    nlohmann::json result;
    result = restApi->post("http://localhost:8989/route", request.dump().c_str()); 
    for(const auto& coordinate: result["paths"][0]["points"]["coordinates"]){
        routePath.push_back({coordinate[1],coordinate[0]});
    }
    instructions = result["paths"][0]["instructions"].get<std::vector<instruction> >();
    std::cout << "Read in " << routePath.size() << " coordinates and " << instructions.size() << " instructions \n";
    co2("HBEFA4/PC_petrol_Euro-4");
}

void route::publicTransportRouting(void){
    std::cout << "Public Transport routing\n";
    nlohmann::json request;
    coordinate from_pt = locations::berlin_central_station;
    coordinate to_pt = locations::berlin_east_station;
    request["points"] = {{from_pt.lon, from_pt.lat}, {to_pt.lon, to_pt.lat}};
    request["profile"] = "foot";
    request["instructions"] = true;
    request["points_encoded"] = false;
    request["debug"] = true;
    //request["details"] = {"max_speed", "distance", "time"};
    request["locale"] = "de";
    nlohmann::json result;
    result = restApi->get("http://localhost:8989/route-pt", request.dump().c_str()); 
    std::cout << "Route result:\n" << result.dump(4) << "\n";
    for(const auto& coordinate: result["paths"][0]["points"]["coordinates"]){
        routePath.push_back({coordinate[1],coordinate[0]});
    }
    instructions = result["paths"][0]["instructions"].get<std::vector<instruction> >();
    std::cout << "Read in " << routePath.size() << " coordinates and " << instructions.size() << " instructions \n";
    co2("HBEFA4/PC_petrol_Euro-4");
}

void route::isoemission(void) {
    nlohmann::json request;
}
    
double route::co2(std::string carClass){
    SUMOEmissionClass emissionClass = PollutantsInterface::getClassByName(carClass);
    double total_co2 = 0;
    double total_distance = 0;
    for(auto& instruction: instructions){
        if(instruction.time == 0) continue;
        // distance is in m, time in msec
        // speed in km/h
        double speed = (instruction.distance / ((double)instruction.time / 1000.0)) * 3.6;
        // FIXME acceleration
        // compute gives CO2 in mg/s
        instruction.co2 = (PollutantsInterface::compute(emissionClass,PollutantsInterface::EmissionType::CO2 , speed, 0, 0) / 1000.0) * ((double)instruction.time / 1000.0);
        total_co2 += instruction.co2;
        total_distance += instruction.distance;
    }
    std::cout << "Total CO2: " << total_co2/1000.0 << "kg\n";
    std::cout << "Total distance: " << total_distance/1000.0 << "km\n";
    return total_co2;

}
@}

\subsection{locations}

This is just a list of locations for debugging purposes.

@O ../src/locations.h -d
@{
#ifndef LOCATIONS_HEADER
#define LOCATIONS_HEADER

#include "route.h"

namespace locations{
    const route::coordinate cologne_central_station = {50.9427839, 6.9590705};
    const route::coordinate tuebingen_gss_school = {48.5425790, 9.0571074};
    const route::coordinate berlin_central_station = {52.5249451, 13.3696614};
    const route::coordinate berlin_east_station = {52.5103817, 13.4349112};
};

#endif
@}
