% Copyright 2023 Florian Pesth
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

\section{Graphhopper setup}

\subsection{Car routing}
@O ../etc/graphhopper/config-car-dach.yml
@{
graphhopper:
  datareader.file: "dach-latest.osm.pbf"
  graph.location: graphs/de-car

  profiles:
    - name: car
      vehicle: car
      weighting: custom
      custom_model:
        distance_influence: 70
  custom_models.directory: custom_models

  profiles_ch:
    - profile: car

  profiles_lm: []


  prepare.min_network_size: 200
  prepare.subnetworks.threads: 1

  routing.non_ch.max_waypoint_distance: 1000000


  import.osm.ignored_highways: footway,cycleway,path,pedestrian,steps # typically useful for motorized-only routing
  graph.dataaccess.default_type: MMAP_STORE
  datareader.preferred_language: de

server:
  application_connectors:
  - type: http
    port: 8989
    bind_host: localhost
    max_request_header_size: 50k
  request_log:
      appenders: []
  admin_connectors:
  - type: http
    port: 8990
    bind_host: localhost
logging:
  appenders:
    - type: file
      time_zone: UTC
      current_log_filename: logs/graphhopper.log
      log_format: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"
      archive: true
      archived_log_filename_pattern: ./logs/graphhopper-%d.log.gz
      archived_file_count: 30
      never_block: true
    - type: console
      time_zone: UTC
      log_format: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"
  loggers:
    "com.graphhopper.osm_warnings":
      level: DEBUG
      additive: false
      appenders:
        - type: file
          currentLogFilename: logs/osm_warnings.log
          archive: false
          logFormat: '[%level] %msg%n'
@}

\subsection{Public transit}
@O ../etc/graphhopper/config-db-ic_ice.yml
@{
graphhopper:
  datareader.file: dach-latest.osm.pbf
  gtfs.file: gtfs-db-ic_ice.zip
  graph.location: graphs/de-with-transit-ic_ice

  profiles:
    - name: foot
      vehicle: foot
      weighting: fastest
  import.osm.ignored_highways: #motorway,trunk # typically useful for non-motorized routing

  graph.dataaccess.default_type: MMAP_STORE

server:
  application_connectors:
    - type: http
      port: 8989
      bind_host: localhost
  admin_connectors:
    - type: http
      port: 8990
      bind_host: localhost
@}
