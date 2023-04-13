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

\section{Calculate Isoemission lines}

This is a preprocessing step to estimate areas around car routes to see which people could be picked up to save $CO_2$ in sum. By saving the $CO_2$ of the person picked up, the car driver can take a longer route and there can be still total savings. In general it would probably be better if everyone uses public transport but this depends on the particular case.

\begin{figure}[ht]
\begin{center}
\begin{tikzpicture}
\coordinate (start) at (0,0);
\coordinate (stop) at (0,-5cm);
\coordinate (pickup) at (-30:2cm);
\coordinate (pickupprojection) at (-90:1cm);
\draw (start) -- (stop) -- (pickup) -- (start);
\draw[dotted] (pickup) -- (pickupprojection);
\draw[<->] ([xshift=-0.2cm]start) -- ([xshift=-0.2cm]stop) node[midway, left]{$d_\text{car}$};
\draw[<->] ([xshift=-0.4cm]start) -- ([xshift=-0.4cm]pickupprojection) node[midway, left]{$d''$};
\draw[<->] ([yshift=-0.2cm]pickupprojection) -- ([yshift=-0.2cm]pickup) node[midway, below]{$d'$};
\node[label={90:Driver start}] at (start) {};
\node[label={0:Pickup position}] at (pickup) {};
\node[label={-90:Destination position}] at (stop) {};
\end{tikzpicture}
\end{center}
\caption{Graphic to show geometry when modifying original car route to pick up someone who would have used public transport otherwise.}
\end{figure}

\begin{figure}[ht]
\begin{itemize}
\item[$d_\text{car}$] Distance from start to stop point for simple car route of driver.
\item[$d'$] Maximal deviation from original path which will lead to the same $CO_2$ use when picking up participant who would have used public transport otherwise.
\item[$d''$] Distance from start of route which is perpendiculat to pickup place.
\item[$e_\text{car}$] Emission factor for the car in $\left[\frac{\text{g}}{\text{km}}\right]$.
\item[$e_\text{pt}$] Emission factor for the public transport in $\left[\frac{\text{g}}{\text{km}}\right]$.
\end{itemize}
\caption{Symbol definitions used in this section.}
\end{figure}

We can now get an equation for $d'(d'')$ by setting the total $CO_2$ emissions for the seperate travel by car and public transport to the total $CO_2$ emissions for the car driver picking someone up at the pickup position:

\begin{eqnarray}
& e_\text{car}d_\text{car} + e_\text{pt} \sqrt{\left(d_\text{car}-d''\right)^2+{d'}^2} \\
= & e_\text{car} \sqrt{{d''}^2+{d'}^2} + e_\text{car}\sqrt{\left(d_\text{car}-d''\right)^2+{d'}^2}
\end{eqnarray}

The form for $d'(d'')$ is obtained via an CAS program and yields to a long expression:

\begin{eqnarray}
{d'}^2 & = & \frac{1}{4e_\text{car}^2e_\text{pt}^2-4e_\text{car}e_\text{pt}^3+e_\text{pt}^4}\left(\right.\\
& & - 4{d''}^2e_\text{car}^2e_\text{pt}^2 + 4{d''}^2e_\text{car}e_\text{pt}^3\\
& & - 4{d''}^2e_\text{pt}^4 - 4{d''}d_\text{car}e_\text{car}^3e_\text{pt}
\end{eqnarray}

... equation incomplete, to be continued
