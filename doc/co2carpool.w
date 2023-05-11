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

\documentclass[a4paper]{article}
\usepackage[colorlinks=true]{hyperref}
\usepackage{listings}
\usepackage[margin=2cm]{geometry}
\usepackage{tikz}
\usepackage{gnuplot-lua-tikz}
\usepackage{mathtools}
\usetikzlibrary{quotes,angles,positioning}

\title{$CO_2$ Carpool planner}
\author{Florian Pesth}
\date{2023}

\begin{document}

\maketitle
\tableofcontents

\section{Overview}

The aim of this experimental tool is to provide a carpool planner for participants of a juggling convention by suggesting pickups of other people minimizing the total amount of emitted $CO_2$ assuming some people will drive with a car for sure (currently maximum number is 200 people but I will try to make it scalable).

@i isoemission.w

@i postgis.w

@i core.w

@i graphhopper.w

\end{document}
