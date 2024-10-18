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


