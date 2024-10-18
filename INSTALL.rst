Short installation guide
========================

This is all work in progress, just a few pointers:

Create source code
------------------

The code is written in a literal programming language nuweb, which needs to be compiled by running the nuweb executable on the co2carpool.w file in the doc directory. nuweb can be obtained from https://nuweb.sourceforge.net/

.. code::

   nuweb -lr co2carpool.w

This will generate the source files and a latex file. If you have installed all dependencies you can also generate the documentation with

.. code::

   pdflatex co2carpool.tex

although that is not necessary to just compile the program.

Create make file
----------------

We use cmake to create the makefiles. Just enter the build dir and run

.. code::

   cd src/build
   cmake ..

Build code
----------

A simple call of make should do if all dependencies are installed.


