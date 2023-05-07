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

\section{Calculate Isoemission lines}

This is a preprocessing step to estimate areas around car routes to see which people could be picked up to save $CO_2$ in sum. By saving the $CO_2$ of the person picked up, the car driver can take a longer route and there can be still total savings. In general it would probably be better if everyone uses public transport but this depends on the particular case.

It is hard to find reliable data on $CO_2$ emissions, particular for the trains in germany as it is a highly political topic. I'm going to use the following values (apparently from TREMOD 6.14):

\begin{itemize}
\item[$29 \frac{g}{km}$] Long distance trains
\item[$55 \frac{g}{km}$] Local trains
\end{itemize}

If we assume a third of the route by local train and two thirds by long distance trains that gives an emission factor of around 38 g/km.

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
\item[$n$] Number of passengers (apart from the driver)
\end{itemize}
\caption{Symbol definitions used in this section.}
\end{figure}

\begin{figure}[ht]
\include{isoemissions}
\caption{Example for pickup zones which save $CO_2$ for up to four passengers for a trip of $377 km$ and an assumed emission of the car of $160 \frac{g}{km}$ and of the public transport of $38 \frac{g}{km}$.}
\end{figure}

We can now get an equation for $d'(d'')$ by setting the total $CO_2$ emissions for the seperate travel by car and public transport to the total $CO_2$ emissions for the car driver picking someone up at the pickup position:

\begin{equation}d_\mathrm{car} e_\mathrm{car} + d_\mathrm{car} e_\mathrm{pt} \left(n - 1\right) - e_\mathrm{car} \underbrace{\sqrt{d'^{2} + d''^{2}}}_{\text{Driver to passenger}} - e_\mathrm{car} \underbrace{\sqrt{d'^{2} + \left(- d'' + d_\mathrm{car}\right)^{2}}}_{\text{Passenger to target}} + e_\mathrm{pt} \sqrt{d'^{2} + \left(- d'' + d_\mathrm{car}\right)^{2}} = 0\end{equation}

Solving this for $d'$ gives us the following solutions:

\begin{equation}
\begin{split}
d'=&- \frac{1}{e_\mathrm{pt}} \left\{- \frac{1}{4 e_\mathrm{car}^{2} - 4 e_\mathrm{car} e_\mathrm{pt} + e_\mathrm{pt}^{2}} \left(4 d''^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} - 4 d''^{2} e_\mathrm{car} e_\mathrm{pt}^{3} + d''^{2} e_\mathrm{pt}^{4} + 4 d'' d_\mathrm{car} e_\mathrm{car}^{3} e_\mathrm{pt} - 10 d'' d_\mathrm{car} e_\mathrm{car}^{2} e_\mathrm{pt}^{2}\right.\right. \\
& \left. \left. + 8 d'' d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt}^{3} - 2 d'' d_\mathrm{car} e_\mathrm{pt}^{4} \right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{3} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n}\right. \right. \\
& \left. \left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right. \right. \\
& \left. \left. - 4 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right. \right. \\
& \left. \left. - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car} e_\mathrm{pt}^{2} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right. \right. \\
& \left. \left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car} e_\mathrm{pt}^{2} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right. \right. \\
& \left. \left. - 2 d_\mathrm{car}^{2} e_\mathrm{car}^{4} - 4 d_\mathrm{car}^{2} e_\mathrm{car}^{3} e_\mathrm{pt} n + 4 d_\mathrm{car}^{2} e_\mathrm{car}^{3} e_\mathrm{pt} - 2 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} + 8 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n - 2 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} + 2 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{2} \right. \right. \\
& \left. \left. - 6 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n - d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n^{2} + 2 d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n\right)\right\}^\frac{1}{2} \\
\end{split}\label{eq:iso1}
\end{equation}

\begin{equation}
\begin{split}
d'=& \frac{1}{e_\mathrm{pt}} \left\{\frac{1}{4 e_\mathrm{car}^{2} - 4 e_\mathrm{car} e_\mathrm{pt} + e_\mathrm{pt}^{2}} \left(- 4 d''^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} + 4 d''^{2} e_\mathrm{car} e_\mathrm{pt}^{3} - d''^{2} e_\mathrm{pt}^{4} - 4 d'' d_\mathrm{car} e_\mathrm{car}^{3} e_\mathrm{pt} + 10 d'' d_\mathrm{car} e_\mathrm{car}^{2} e_\mathrm{pt}^{2}\right. \right. \\
& \left.\left. - 8 d'' d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt}^{3} + 2 d'' d_\mathrm{car} e_\mathrm{pt}^{4} \right.\right.\\
& \left.\left. - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{3} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. + 4 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car} e_\mathrm{pt}^{2} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n}\right.\right.\\
& \left.\left. - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car} e_\mathrm{pt}^{2} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n}\right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{4} + 4 d_\mathrm{car}^{2} e_\mathrm{car}^{3} e_\mathrm{pt} n - 4 d_\mathrm{car}^{2} e_\mathrm{car}^{3} e_\mathrm{pt} + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 8 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} - 2 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{2} \right.\right.\\
& \left.\left. + 6 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n + d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n^{2} - 2 d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n\right)\right\}^\frac{1}{2}
\end{split}\label{eq:iso2}
\end{equation}

\begin{equation}
\begin{split}
d'=& - \frac{1}{e_\mathrm{pt}} \left\{\frac{1}{4 e_\mathrm{car}^{2} - 4 e_\mathrm{car} e_\mathrm{pt} + e_\mathrm{pt}^{2}} \left(- 4 d''^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} + 4 d''^{2} e_\mathrm{car} e_\mathrm{pt}^{3} - d''^{2} e_\mathrm{pt}^{4} - 4 d'' d_\mathrm{car} e_\mathrm{car}^{3} e_\mathrm{pt} + 10 d'' d_\mathrm{car} e_\mathrm{car}^{2} e_\mathrm{pt}^{2}\right.\right.\\
& \left.\left. - 8 d'' d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt}^{3} + 2 d'' d_\mathrm{car} e_\mathrm{pt}^{4} \right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{3} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n}\right.\right.\\
& \left.\left. - 4 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n}\right.\right.\\
& \left.\left. - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car} e_\mathrm{pt}^{2} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n}\right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car} e_\mathrm{pt}^{2} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n}\right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{4} + 4 d_\mathrm{car}^{2} e_\mathrm{car}^{3} e_\mathrm{pt} n - 4 d_\mathrm{car}^{2} e_\mathrm{car}^{3} e_\mathrm{pt} + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 8 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} - 2 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{2} \right.\right.\\
& \left.\left. + 6 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n + d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n^{2} - 2 d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n\right)\right\}^\frac{1}{2}
\end{split}\label{eq:iso3}
\end{equation}

\begin{equation}
\begin{split}
d'=& \frac{1}{e_\mathrm{pt}} \left\{\frac{1}{4 e_\mathrm{car}^{2} - 4 e_\mathrm{car} e_\mathrm{pt} + e_\mathrm{pt}^{2}} \left(- 4 d''^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} + 4 d''^{2} e_\mathrm{car} e_\mathrm{pt}^{3} - d''^{2} e_\mathrm{pt}^{4} - 4 d'' d_\mathrm{car} e_\mathrm{car}^{3} e_\mathrm{pt} + 10 d'' d_\mathrm{car} e_\mathrm{car}^{2} e_\mathrm{pt}^{2}\right.\right.\\
& \left.\left. - 8 d'' d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt}^{3} + 2 d'' d_\mathrm{car} e_\mathrm{pt}^{4} \right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{3} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. - 4 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car} e_\mathrm{pt}^{2} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car} e_\mathrm{pt}^{2} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} + 2 d'' e_\mathrm{pt}^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n + d_\mathrm{car} e_\mathrm{pt}^{2} n^{2} - 2 d_\mathrm{car} e_\mathrm{pt}^{2} n} \right.\right.\\
& \left.\left. + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{4} + 4 d_\mathrm{car}^{2} e_\mathrm{car}^{3} e_\mathrm{pt} n - 4 d_\mathrm{car}^{2} e_\mathrm{car}^{3} e_\mathrm{pt} + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 8 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} - 2 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{2} \right.\right.\\
& \left.\left. + 6 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n + d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n^{2} - 2 d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n\right)\right\}^\frac{1}{2}
\end{split}\label{eq:iso4}
\end{equation}

Equations \ref{eq:iso1} (page \pageref{eq:iso1}) and \ref{eq:iso3} (page \pageref{eq:iso3}) are not solutions we are interested in as we look for a positive solution. Equation \ref{eq:iso4} (page \pageref{eq:iso4}) does not seem to be valid, but equation \ref{eq:iso2} (page \pageref{eq:iso2}) seems to be a valid solution.

The solution was created by the following python script:

@d Solve isoemission equation
@{dpt = sqrt((dcar-ddd)**2+dd**2)
dcpt = sqrt(ddd**2+dd**2)
n = Symbol('n', positive=True, integer=True, nonzero=True)
solutions = solve(ecar*dcar+ept*dpt+(n-1)*ept*dcar-ecar*dcpt-ecar*dpt,dd)
@}

@d Isoemission symbols for \LaTeX
@{
dcar = Symbol('d_\mathrm{car}', positive=True, finite=True, real=True)
ecar = Symbol('e_\mathrm{car}', positive=True, finite=True, real=True)
ept = Symbol('e_\mathrm{pt}', positive=True, finite=True, real=True)
dd = Symbol('d\'', positive=True, finite=True, real=True)
ddd = Symbol('d\'\'', finite=True, real=True)
@}

@d Isoemission symbols for C++ and fortran
@{
dcar = Symbol('d_car', positive=True, finite=True, real=True)
ecar = Symbol('e_car', positive=True, finite=True, real=True)
ept = Symbol('e_pt', positive=True, finite=True, real=True)
dd = Symbol('d_dash', positive=True, finite=True, real=True)
ddd = Symbol('d_doubledash', finite=True, real=True)
@}

@O ../bin/scripts/isocalc_latex.py
@{#!/usr/bin/env python3
from sympy import *
@<Isoemission symbols for \LaTeX@>
@<Solve isoemission equation@>
print(latex(ecar*dcar+ept*dpt+(n-1)*ept*dcar-ecar*dcpt-ecar*dpt,long_frac_ratio=2,mode='equation'))
for solution in solutions:
  ssolution = simplify(solution)
  print("")
  print(latex(ssolution,long_frac_ratio=2,mode='equation'))
@}

@O ../bin/scripts/isocalc_null_latex.py
@{#!/usr/bin/env python3
from sympy import *
@<Isoemission symbols for C++ and fortran@>
@<Solve isoemission equation@>
ssolution = simplify(solutions[1])
print(latex(ssolution,long_frac_ratio=2,mode='equation'))
solution_null = solve(ssolution,ddd)
ssolution_null = simplify(solution_null)
print("")
print(latex(ssolution,long_frac_ratio=2,mode='equation'))
@}


@O ../bin/scripts/isocalc_cxx.py
@{#!/usr/bin/env python3
from sympy import *
@<Isoemission symbols for C++ and fortran@>
@<Solve isoemission equation@>
for solution in solutions:
  ssolution = simplify(solution)
  print("")
  print(cxxcode(ssolution))
@}

@O ../bin/scripts/isocalc_fortran.py
@{#!/usr/bin/env python3
from sympy import *
@<Isoemission symbols for C++ and fortran@>
@<Solve isoemission equation@>
for solution in solutions:
  ssolution = simplify(solution)
  print("")
  print(fcode(ssolution,source_format='free'))
@}



@d Isoemission C++ equation 1
@{
std::sqrt((-2*std::pow(d_car, 3.0/2.0)*std::pow(e_car, 3)*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) - 2*std::pow(d_car, 3.0/2.0)*std::pow(e_car, 2)*e_pt*n*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) + 4*std::pow(d_car, 3.0/2.0)*std::pow(e_car, 2)*e_pt*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) + 2*std::pow(d_car, 3.0/2.0)*e_car*std::pow(e_pt, 2)*n*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) - 2*std::pow(d_car, 3.0/2.0)*e_car*std::pow(e_pt, 2)*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) + 2*std::pow(d_car, 2)*std::pow(e_car, 4) + 4*std::pow(d_car, 2)*std::pow(e_car, 3)*e_pt*n - 4*std::pow(d_car, 2)*std::pow(e_car, 3)*e_pt + 2*std::pow(d_car, 2)*std::pow(e_car, 2)*std::pow(e_pt, 2)*std::pow(n, 2) - 8*std::pow(d_car, 2)*std::pow(e_car, 2)*std::pow(e_pt, 2)*n + 2*std::pow(d_car, 2)*std::pow(e_car, 2)*std::pow(e_pt, 2) - 2*std::pow(d_car, 2)*e_car*std::pow(e_pt, 3)*std::pow(n, 2) + 6*std::pow(d_car, 2)*e_car*std::pow(e_pt, 3)*n + std::pow(d_car, 2)*std::pow(e_pt, 4)*std::pow(n, 2) - 2*std::pow(d_car, 2)*std::pow(e_pt, 4)*n - 4*d_car*d_doubledash*std::pow(e_car, 3)*e_pt + 10*d_car*d_doubledash*std::pow(e_car, 2)*std::pow(e_pt, 2) - 8*d_car*d_doubledash*e_car*std::pow(e_pt, 3) + 2*d_car*d_doubledash*std::pow(e_pt, 4) - 4*std::pow(d_doubledash, 2)*std::pow(e_car, 2)*std::pow(e_pt, 2) + 4*std::pow(d_doubledash, 2)*e_car*std::pow(e_pt, 3) - std::pow(d_doubledash, 2)*std::pow(e_pt, 4))/(4*std::pow(e_car, 2) - 4*e_car*e_pt + std::pow(e_pt, 2)))/e_pt
@}


@d Isoemission C++ equation 2
@{
std::sqrt((2*std::pow(d_car, 3.0/2.0)*std::pow(e_car, 3)*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) + 2*std::pow(d_car, 3.0/2.0)*std::pow(e_car, 2)*e_pt*n*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) - 4*std::pow(d_car, 3.0/2.0)*std::pow(e_car, 2)*e_pt*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) - 2*std::pow(d_car, 3.0/2.0)*e_car*std::pow(e_pt, 2)*n*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) + 2*std::pow(d_car, 3.0/2.0)*e_car*std::pow(e_pt, 2)*std::sqrt(d_car*std::pow(e_car, 2) + 2*d_car*e_car*e_pt*n + d_car*std::pow(e_pt, 2)*std::pow(n, 2) - 2*d_car*std::pow(e_pt, 2)*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*std::pow(e_pt, 2)) + 2*std::pow(d_car, 2)*std::pow(e_car, 4) + 4*std::pow(d_car, 2)*std::pow(e_car, 3)*e_pt*n - 4*std::pow(d_car, 2)*std::pow(e_car, 3)*e_pt + 2*std::pow(d_car, 2)*std::pow(e_car, 2)*std::pow(e_pt, 2)*std::pow(n, 2) - 8*std::pow(d_car, 2)*std::pow(e_car, 2)*std::pow(e_pt, 2)*n + 2*std::pow(d_car, 2)*std::pow(e_car, 2)*std::pow(e_pt, 2) - 2*std::pow(d_car, 2)*e_car*std::pow(e_pt, 3)*std::pow(n, 2) + 6*std::pow(d_car, 2)*e_car*std::pow(e_pt, 3)*n + std::pow(d_car, 2)*std::pow(e_pt, 4)*std::pow(n, 2) - 2*std::pow(d_car, 2)*std::pow(e_pt, 4)*n - 4*d_car*d_doubledash*std::pow(e_car, 3)*e_pt + 10*d_car*d_doubledash*std::pow(e_car, 2)*std::pow(e_pt, 2) - 8*d_car*d_doubledash*e_car*std::pow(e_pt, 3) + 2*d_car*d_doubledash*std::pow(e_pt, 4) - 4*std::pow(d_doubledash, 2)*std::pow(e_car, 2)*std::pow(e_pt, 2) + 4*std::pow(d_doubledash, 2)*e_car*std::pow(e_pt, 3) - std::pow(d_doubledash, 2)*std::pow(e_pt, 4))/(4*std::pow(e_car, 2) - 4*e_car*e_pt + std::pow(e_pt, 2)))/e_pt
@}

@d Isoemission gnuplot equation
@{dd1(d_doubledash,n,d_car,e_car,e_pt)=\
sqrt((-2*d_car**(3.0/2.0)*e_car**3*sqrt(d_car*e_car**2 + 2*d_car* \
      e_car*e_pt*n + d_car*e_pt**2*n**2 - 2*d_car*e_pt**2*n - 4* \
      d_doubledash*e_car*e_pt + 2*d_doubledash*e_pt**2) - 2*d_car**( \
      3.0/2.0)*e_car**2*e_pt*n*sqrt(d_car*e_car**2 + 2*d_car*e_car* \
      e_pt*n + d_car*e_pt**2*n**2 - 2*d_car*e_pt**2*n - 4*d_doubledash* \
      e_car*e_pt + 2*d_doubledash*e_pt**2) + 4*d_car**(3.0/2.0)* \
      e_car**2*e_pt*sqrt(d_car*e_car**2 + 2*d_car*e_car*e_pt*n + d_car* \
      e_pt**2*n**2 - 2*d_car*e_pt**2*n - 4*d_doubledash*e_car*e_pt + 2* \
      d_doubledash*e_pt**2) + 2*d_car**(3.0/2.0)*e_car*e_pt**2*n* \
      sqrt(d_car*e_car**2 + 2*d_car*e_car*e_pt*n + d_car*e_pt**2*n**2 - \
      2*d_car*e_pt**2*n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash* \
      e_pt**2) - 2*d_car**(3.0/2.0)*e_car*e_pt**2*sqrt(d_car*e_car \
      **2 + 2*d_car*e_car*e_pt*n + d_car*e_pt**2*n**2 - 2*d_car*e_pt**2 \
      *n - 4*d_doubledash*e_car*e_pt + 2*d_doubledash*e_pt**2) + 2* \
      d_car**2*e_car**4 + 4*d_car**2*e_car**3*e_pt*n - 4*d_car**2*e_car \
      **3*e_pt + 2*d_car**2*e_car**2*e_pt**2*n**2 - 8*d_car**2*e_car**2 \
      *e_pt**2*n + 2*d_car**2*e_car**2*e_pt**2 - 2*d_car**2*e_car*e_pt \
      **3*n**2 + 6*d_car**2*e_car*e_pt**3*n + d_car**2*e_pt**4*n**2 - 2 \
      *d_car**2*e_pt**4*n - 4*d_car*d_doubledash*e_car**3*e_pt + 10* \
      d_car*d_doubledash*e_car**2*e_pt**2 - 8*d_car*d_doubledash*e_car* \
      e_pt**3 + 2*d_car*d_doubledash*e_pt**4 - 4*d_doubledash**2*e_car \
      **2*e_pt**2 + 4*d_doubledash**2*e_car*e_pt**3 - d_doubledash**2* \
      e_pt**4)/(4*e_car**2 - 4*e_car*e_pt + e_pt**2))/e_pt
@}

@O ../bin/scripts/isoemissions.gp
@{
set samples 1000
@<Isoemission gnuplot equation@>
set title "Example of possible pickup zones for a 377km ride"
set tics front
set size ratio -1
set terminal tikz
set out "../../doc/isoemissions.tex"
set xlabel "Distance / km"
set ylabel "Distance / km"
plot [-250:550][-400:400] \
 dd1(x,4,377,160,38) t "Driver and 4 passengers" lt rgb "#00FF00" w filledcurves y1=0,\
 -dd1(x,4,377,160,38) notitle lt rgb "#00FF00" w filledcurves y1=0,\
 dd1(x,3,377,160,38) t "Driver and 3 passengers" lt rgb "#66FF66" w filledcurves y1=0,\
 -dd1(x,3,377,160,38) notitle lt rgb "#66FF66" w filledcurves y1=0,\
 dd1(x,2,377,160,38) t "Driver and 2 passengers" lt rgb "#99FF99" w filledcurves y1=0,\
 -dd1(x,2,377,160,38) notitle lt rgb "#99FF99" w filledcurves y1=0,\
 x>377? NaN : dd1(x,1,377,160,38) t "Driver and 1 passenger" lt rgb "#BBFFBB" w filledcurves y1=0,\
 x>377? NaN : -dd1(x,1,377,160,38) notitle lt rgb "#BBFFBB" w filledcurves y1=0,\
 '+' u (0):(0) t "Start of route" w p ls 3,\
 '+' u (377):(0) t "Destination of route" w p ls 4
@}

