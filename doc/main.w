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
#include <fstream>

int main(){
    std::cout << "CO2 carpool\n";
    std::cout << "Load config file...";
    std::ifstream ifs_config("config.json");
    nlohmann::json j_config = nlohmann::json::parse(ifs_config);
    std::cout << " ok!\n";

    database maindb = database();
    std::shared_ptr<rest> restApi = std::make_shared<rest>(j_config["rest"]);
    //*restApi = j_config["rest"];
    std::shared_ptr<task> cologne_gss_route = std::make_shared<route>(restApi, locations::cologne_central_station, locations::tuebingen_gss_school);
    cologne_gss_route->execute();
    return EXIT_SUCCESS;
}
@}

