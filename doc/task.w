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

\subsection{task class}

The task class shall be used as a basis for other classes to schedule tasks.

@O ../src/task.h -d
@{
#ifndef TASK_CLASS
#define TASK_CLASS

class task
{
public:
    virtual bool isCompleted(void) const = 0;
    virtual unsigned int priority(void) const = 0;
    virtual void execute(void) = 0;
};
#endif // TASK_CLASS
@}


