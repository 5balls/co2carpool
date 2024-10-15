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

\section{Configuring PostGIS database}

First a role ``co2carpool'' for accessing the database needs to be created.

@O ../bin/scripts/setup_postgis.sql
@{CREATE ROLE co2carpool LOGIN CREATEDB;
@}

(On debian you need to be user ``postgres'' to start psql and execute this command).

After this it is most easy to create a user ``co2carpool'' as well. With this user on the command line enter:

\begin{lstlisting}
createdb
\end{lstlisting}

and this will create the database co2carpool.

This will create a database with the name ``co2carpool''.


Install the postgis extension by
\begin{lstlisting}
apt-get install postgis
\end{lstlisting}

and enable the extension (in psql):

As database superuser (postgres on debian) open the database:

\begin{lstlisting}
psql -d co2carpool
\end{lstlisting}

\begin{lstlisting}
co2carpool=# create extension postgis;
\end{lstlisting}

In the database:

\begin{lstlisting}
CREATE TABLE participants (
    id smallint primary key,
    name varchar(50),
    driver boolean,
    start geometry(POINT,4326)
);
CREATE TABLE routesegment (
    id smallint primary key,
    from_id smallint,
    to_id smallint,
    route geometry,
    constraint fk_from foreign key(from_id) references participants(id),
    constraint fk_to foreign key(to_id) references participants(id)
);
CREATE TABLE isoemission (
    id smallint primary key,
    driver_id smallint,
    capacity smallint,
    isoemissionzone geometry,
    constraint fk_driver_id foreign key (driver_id) references participants(id)
);
\end{lstlisting}

@O ../bin/scripts/setup_postgis_db.sh
@{#!/usr/bin/env bash
createdb 
@}
