% Copyright 2022,2023,2024 Florian Pesth
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

\subsection{route class}

This provides a wrapper for the rest calls of ``graphhopper'' for the route calculation. If needed the routing engine can be replaced here.

@i api-client-motis.w

@O ../src/route.h -d
@{
#ifndef ROUTE_CLASS
#define ROUTE_CLASS

# define JSON_DIAGNOSTICS 1
#include <nlohmann/json.hpp>
#include <memory>
#include <list>

#include "task.h"
#include "rest.h"
#include "sumo/emissions/PollutantsInterface.h"
#include "api-client-motis.h"

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
    // Graphhopper request for car only routing
    struct car_request {
        car_request() : points({}), profile("car"), instruction(true), points_encoded(false), debug(true), locale("de"){};
        std::list<std::pair<double,double> > points;
        std::string profile;
        bool instruction;
        bool points_encoded;
        bool debug;
        std::string locale;
        NLOHMANN_DEFINE_TYPE_INTRUSIVE(car_request, points, profile, instruction, points_encoded, debug, locale);
    };
    // Motis request for public transport
    struct pt_request {
        pt_request() : mode("WALK,TRANSIT"){};
        std::string fromPlace;
        std::string toPlace;
        std::string mode;
        std::vector<std::pair<std::string,std::string> > vec(){
            return {
                {"fromPlace",fromPlace},
                {"toPlace",toPlace},
                {"mode",mode}
            };
        }
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
    carRouting();
    publicTransportRouting();
} 
@}

@O ../src/route.cpp -d
@{
void route::carRouting(void) {
    std::cout << "Car routing\n";
    car_request request;
    request.points = {{from.lon, from.lat}, {to.lon, to.lat}};
    nlohmann::json j_request = request;
    nlohmann::json result;
    result = restApi->post("car_router", j_request.dump().c_str()); 
    for(const auto& coordinate: result["paths"][0]["points"]["coordinates"]){
        routePath.push_back({coordinate[1],coordinate[0]});
    }
    instructions = result["paths"][0]["instructions"].get<std::vector<instruction> >();
    std::cout << "Read in " << routePath.size() << " coordinates and " << instructions.size() << " instructions \n";
    co2("HBEFA4/PC_petrol_Euro-4");
}
@}

@O ../src/route.cpp -d
@{
void route::publicTransportRouting(void){
    std::cout << "Public Transport routing\n";
    pt_request request;
    request.fromPlace = std::to_string(from.lat) + "," + std::to_string(from.lon);
    request.toPlace = std::to_string(to.lat) + "," + std::to_string(to.lon);
    try{
        motis::planReply result = restApi->get("pt_router", request.vec());
        std::cout << "  Got " << result.itineraries.size() << " itineraries:\n"; 
        for(const auto& itinerary: result.itineraries){
            static int i=0;
            i++;
            std::cout << "  " << i << " duration: " << itinerary.duration / (60.0*60.0)<< " hours\n";  
            std::cout << "  " << i << " transfers: " << itinerary.transfers << "\n";  
            std::cout << "  " << i << " number of legs: " << itinerary.legs.size() << "\n";  
            int i_leg=0;
            for(const auto& leg: itinerary.legs){
                i_leg++;
                std::cout << "  " << i << " " << i_leg << " mode: " << leg.mode  << "\n";
                std::cout << "  " << i << " " << i_leg << " " << leg.from.name  << "->" << leg.to.name <<  "\n";
                std::cout << "  " << i << " " << i_leg << " headsign: " << leg.headsign  << "\n";
                std::cout << "  " << i << " " << i_leg << " duration: " << leg.duration / 60.0 << " minutes\n";
                std::cout << "  " << i << " " << i_leg << " " << leg.routeShortName << " " << leg.agencyName << "\n";
                std::cout << "  " << i << " " << i_leg << " number of intermediateStops: " << leg.intermediateStops.size() << "\n"; 
                int i_stop = 0;
                for(const auto& intermediateStop: leg.intermediateStops){
                    i_stop++;
                    std::cout << "  " << i << " " << i_leg << " " << i_stop << " " << intermediateStop.name << "\n"; 
                }
            }
        }
    }
    catch (const nlohmann::json::exception& e){
        std::cout << "Could not read back json result from motis:\n  ";
        std::cout << e.what() << "\n";
    }

}
@}

@O ../src/route.cpp -d
@{
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

