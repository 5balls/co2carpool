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
    const route::coordinate berlin_south_cross_station = {52.4765716, 13.3660396};
    const route::coordinate stuttgart_central_station = {48.7856099, 9.1833959};
};

#endif
@}
