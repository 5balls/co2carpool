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

\begin{equation}d_\mathrm{car} e_\mathrm{car} - e_\mathrm{car} \sqrt{d'^{2} + d''^{2}} - e_\mathrm{car} \sqrt{d'^{2} + \left(- d'' + d_\mathrm{car}\right)^{2}} + e_\mathrm{pt} \sqrt{d'^{2} + \left(- d'' + d_\mathrm{car}\right)^{2}} \left(n - 1\right) + e_\mathrm{pt} \sqrt{d'^{2} + \left(- d'' + d_\mathrm{car}\right)^{2}}=0\end{equation}

Solving this for $d'$ gives us the following solutions:

\begin{equation}- \frac{1}{e_\mathrm{pt} n} \sqrt{- \frac{1}{4 e_\mathrm{car}^{2} - 4 e_\mathrm{car} e_\mathrm{pt} n + e_\mathrm{pt}^{2} n^{2}} \left(\splitfrac{4 d''^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 4 d''^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} + d''^{2} e_\mathrm{pt}^{4} n^{4} + 4 d'' d_\mathrm{car} e_\mathrm{car}^{3} e_\mathrm{pt} n - 10 d'' d_\mathrm{car} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2}}{ + 8 d'' d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} - 2 d'' d_\mathrm{car} e_\mathrm{pt}^{4} n^{4} + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{3} \sqrt{\splitfrac{- 4 d'' e_\mathrm{car} e_\mathrm{pt} n + 2 d'' e_\mathrm{pt}^{2} n^{2}}{ \splitfrac{+ d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n}{ - d_\mathrm{car} e_\mathrm{pt}^{2} n^{2}}}} - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} n + 2 d'' e_\mathrm{pt}^{2} n^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n - d_\mathrm{car} e_\mathrm{pt}^{2} n^{2}} - 2 d_\mathrm{car}^{2} e_\mathrm{car}^{4} + 4 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 4 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} + d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n^{4}}\right)}\end{equation}

\begin{equation}\frac{1}{e_\mathrm{pt} n} \sqrt{\frac{1}{4 e_\mathrm{car}^{2} - 4 e_\mathrm{car} e_\mathrm{pt} n + e_\mathrm{pt}^{2} n^{2}} \left(- 4 d''^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} + 4 d''^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} - d''^{2} e_\mathrm{pt}^{4} n^{4} - 4 d'' d_\mathrm{car} e_\mathrm{car}^{3} e_\mathrm{pt} n + 10 d'' d_\mathrm{car} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 8 d'' d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} + 2 d'' d_\mathrm{car} e_\mathrm{pt}^{4} n^{4} - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{3} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} n + 2 d'' e_\mathrm{pt}^{2} n^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n - d_\mathrm{car} e_\mathrm{pt}^{2} n^{2}} + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} n + 2 d'' e_\mathrm{pt}^{2} n^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n - d_\mathrm{car} e_\mathrm{pt}^{2} n^{2}} + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{4} - 4 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} + 4 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} - d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n^{4}\right)}\end{equation}

\begin{equation}- \frac{1}{e_\mathrm{pt} n} \sqrt{- \frac{1}{4 e_\mathrm{car}^{2} - 4 e_\mathrm{car} e_\mathrm{pt} n + e_\mathrm{pt}^{2} n^{2}} \left(4 d''^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 4 d''^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} + d''^{2} e_\mathrm{pt}^{4} n^{4} + 4 d'' d_\mathrm{car} e_\mathrm{car}^{3} e_\mathrm{pt} n - 10 d'' d_\mathrm{car} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} + 8 d'' d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} - 2 d'' d_\mathrm{car} e_\mathrm{pt}^{4} n^{4} - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{3} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} n + 2 d'' e_\mathrm{pt}^{2} n^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n - d_\mathrm{car} e_\mathrm{pt}^{2} n^{2}} + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} n + 2 d'' e_\mathrm{pt}^{2} n^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n - d_\mathrm{car} e_\mathrm{pt}^{2} n^{2}} - 2 d_\mathrm{car}^{2} e_\mathrm{car}^{4} + 4 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 4 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} + d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n^{4}\right)}\end{equation}

\begin{equation}\frac{1}{e_\mathrm{pt} n} \sqrt{\frac{1}{4 e_\mathrm{car}^{2} - 4 e_\mathrm{car} e_\mathrm{pt} n + e_\mathrm{pt}^{2} n^{2}} \left(- 4 d''^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} + 4 d''^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} - d''^{2} e_\mathrm{pt}^{4} n^{4} - 4 d'' d_\mathrm{car} e_\mathrm{car}^{3} e_\mathrm{pt} n + 10 d'' d_\mathrm{car} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} - 8 d'' d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} + 2 d'' d_\mathrm{car} e_\mathrm{pt}^{4} n^{4} + 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{3} \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} n + 2 d'' e_\mathrm{pt}^{2} n^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n - d_\mathrm{car} e_\mathrm{pt}^{2} n^{2}} - 2 d_\mathrm{car}^{\frac{3}{2}} e_\mathrm{car}^{2} e_\mathrm{pt} n \sqrt{- 4 d'' e_\mathrm{car} e_\mathrm{pt} n + 2 d'' e_\mathrm{pt}^{2} n^{2} + d_\mathrm{car} e_\mathrm{car}^{2} + 2 d_\mathrm{car} e_\mathrm{car} e_\mathrm{pt} n - d_\mathrm{car} e_\mathrm{pt}^{2} n^{2}} + 2 d_\mathrm{car}^{2} e_\mathrm{car}^{4} - 4 d_\mathrm{car}^{2} e_\mathrm{car}^{2} e_\mathrm{pt}^{2} n^{2} + 4 d_\mathrm{car}^{2} e_\mathrm{car} e_\mathrm{pt}^{3} n^{3} - d_\mathrm{car}^{2} e_\mathrm{pt}^{4} n^{4}\right)}\end{equation}

The solution was created by the following python script:

@O ../src/isocalc_latex.py
@{#!/usr/bin/env python3
from sympy import *
dcar = Symbol('d_\mathrm{car}', positive=True, finite=True, real=True)
ecar = Symbol('e_\mathrm{car}', positive=True, finite=True, real=True)
ept = Symbol('e_\mathrm{pt}', positive=True, finite=True, real=True)
dd = Symbol('d\'', positive=True, finite=True, real=True)
ddd = Symbol('d\'\'', finite=True, real=True)
dpt = sqrt((dcar-ddd)**2+dd**2)
dcpt = sqrt(ddd**2+dd**2)
n = Symbol('n', positive=True, integer=True, nonzero=True)
solutions = solve(ecar*dcar+ept*dpt+(n-1)*ept*dpt-ecar*dcpt-ecar*dpt,dd)
print(latex(ecar*dcar+ept*dpt+(n-1)*ept*dpt-ecar*dcpt-ecar*dpt,long_frac_ratio=2,mode='equation'))
for solution in solutions:
  ssolution = simplify(solution)
  print("")
  print(latex(ssolution,long_frac_ratio=2,mode='equation'))
@}

@O ../src/isocalc_cxx.py
@{#!/usr/bin/env python3
from sympy import *
dcar = Symbol('d_car', positive=True, finite=True, real=True)
ecar = Symbol('e_car', positive=True, finite=True, real=True)
ept = Symbol('e_pt', positive=True, finite=True, real=True)
dd = Symbol('d_dash', positive=True, finite=True, real=True)
ddd = Symbol('d_doubledash', finite=True, real=True)
dpt = sqrt((dcar-ddd)**2+dd**2)
dcpt = sqrt(ddd**2+dd**2)
n = Symbol('n', positive=True, integer=True, nonzero=True)
solutions = solve(ecar*dcar+ept*dpt+(n-1)*ept*dpt-ecar*dcpt-ecar*dpt,dd)

for solution in solutions:
  ssolution = simplify(solution)
  print("")
  print(cxxcode(ssolution))
@}

@O ../src/isocalc_fortran.py
@{#!/usr/bin/env python3
from sympy import *
dcar = Symbol('d_car', positive=True, finite=True, real=True)
ecar = Symbol('e_car', positive=True, finite=True, real=True)
ept = Symbol('e_pt', positive=True, finite=True, real=True)
dd = Symbol('d_dash', positive=True, finite=True, real=True)
ddd = Symbol('d_doubledash', finite=True, real=True)
dpt = sqrt((dcar-ddd)**2+dd**2)
dcpt = sqrt(ddd**2+dd**2)
n = Symbol('n', positive=True, integer=True, nonzero=True)
solutions = solve(ecar*dcar+ept*dpt+(n-1)*ept*dpt-ecar*dcpt-ecar*dpt,dd)

for solution in solutions:
  ssolution = simplify(solution)
  print("")
  print(fcode(ssolution,source_format='free'))
@}

