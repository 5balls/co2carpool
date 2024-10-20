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

\subsection{Configuration}

The configuration is a json file which parts of should be directly usable by the classes. Edit according to your settings and rename to \verb|config.json|.

@O ../src/build/config.json.template
@{
{
  "rest": {
    "urls":{
      "car_router": "http://localhost:8989/route",
      "pt_router": "http://localhost:8080/api/v1/plan"
    }
  }
}
@}

