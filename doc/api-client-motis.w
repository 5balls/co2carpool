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

\subsubsection{Motis API}

@O ../src/api-client-motis.h -d
@{
#include <string>
#include <vector>

namespace motis {

struct Place {
    std::string name;
    std::string stopId;
    double lat;
    double lon;
    double level;
    long int arrivalDelay;
    long int departureDelay;
    long int arrival;
    long int departure;
    std::string scheduledTrack;
    std::string track;
    std::string vertexType;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(Place, name, stopId, lat, lon, level, arrivalDelay, departureDelay, arrival, departure, scheduledTrack, track, vertexType);
};

struct EncodedPolyline{
    std::string points;
    long int length;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(EncodedPolyline, points, length);
};

struct LevelEncodedPolyline {
    double fromLevel;
    double toLevel;
    long int osmWay;
    EncodedPolyline polyline;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(LevelEncodedPolyline, fromLevel, toLevel, osmWay, polyline);
};

struct StepInstruction {
    std::string relativeDirection;
    std::string absoluteDirection;
    double distance;
    std::string streetName;
    std::string exit;
    bool stayOn;
    bool area;
    double lon;
    double lat;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(StepInstruction, relativeDirection, absoluteDirection, distance, streetName, exit, stayOn, area, lon, lat);
};

struct Leg {
    std::string mode;
    Place from;
    Place to;
    long int duration;
    long int startTime;
    long int endTime;
    long int departureDelay;
    long int arrivalDelay;
    bool realTime;
    double distance;
    bool interlineWithPreviousLeg;
    std::string route;
    std::string headsign;
    std::string agencyName;
    std::string agencyUrl;
    std::string routeColor;
    std::string routeTextColor;
    std::string routeType;
    std::string routeId;
    std::string agencyId;
    std::string tripId;
    std::string serviceDate;
    std::string routeShortName;
    std::string source;
    std::vector<Place> intermediateStops;
    EncodedPolyline legGeometry;
    std::vector<LevelEncodedPolyline> legGeometryWithLevels;
    std::vector<StepInstruction> steps;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(Leg, mode, from, to, duration, startTime, endTime, departureDelay, arrivalDelay, realTime, distance, interlineWithPreviousLeg, route, headsign, agencyName, agencyUrl, routeColor, routeTextColor, routeType, routeId, agencyId, tripId, serviceDate, routeShortName, source, intermediateStops, legGeometry, legGeometryWithLevels, steps);
};

struct Itinerary {
    long int duration;
    long int startTime;
    long int endTime;
    long int walkTime;
    long int transitTime;
    long int waitingTime;
    long int walkDistance;
    long int transfers;
    std::vector<Leg> legs;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(Itinerary, duration, startTime, endTime, walkTime, transitTime, waitingTime, walkDistance, transfers, legs);
};

struct planReply {
    std::string requestParameters;
    std::string debugOutput;
    Place from;
    Place to;
    std::vector<Itinerary> itineraries;
    std::string previousPageCursor;
    std::string nextPageCursor;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(planReply, requestParameters, debugOutput, from, to, itineraries, previousPageCursor, nextPageCursor);
};

};
@}
