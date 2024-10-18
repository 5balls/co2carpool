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

