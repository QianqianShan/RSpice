
<!-- README.md is generated from README.Rmd. Please edit that file -->
RSpice
======

-   RSpice Background
-   Compilation of Ngspice as Shared Library
-   Installation of *RSpice*

Background
----------

The goal of RSpice is to implement an interface to allow users to run Ngspice in R via the shared library of Ngspice. It provides functions to control the simulator and read the feedback from Ngspice to R. By using *RSpice* package, it is possible to save and analyze the outputs from Ngspice in R.

Compilation of Ngspice as Shared Library
----------------------------------------

### Compile from the source code

Refer the <https://sourceforge.net/projects/ngspice/files/ng-spice-rework/28/> of Ngspice and download the source code of Ngspice from **ngspice-28.tar.gz**. We need to compile to source code to generate a shared library of Ngspice with extension *.so* or *.dll* depending on the operating systems. It's recommended to install the released stable version of Ngspice from tarball instead of installing directly from the github repository of Ngspice.

#### Compile the source code for \*unix systems,

-   Unpack the tarball by **tar -zxvf ngspice-28.tar.gz** or some customized commands under your operating system.

-   Change the directory to *ngspice-28* by **cd ngspice-28**.

-   Make a sub directory to work on the compilation, change the directory to the new sub directory and run the *configure* file. For example, if we would like to work on a sub directory *ngspice-shared*, then in terminal, we could do,

1.  $ mkdir ngspice-shared
2.  $ cd ngspice-shared
3.  $ ../configure --enable-xspice --disable-debug --with-ngshared
4.  $ make
5.  $ sudo make install

The default installation path is */usr/local/bin*, */usr/local/man*, etc. The installation prefix could be modified from */usr/local* by giving the *configure* in step 2 an option *--prefix=PATH*. See Section 1 for more details on the options for *configure* from the *INSTALL* file in the unpacked tarball folder.

#### Compile the source code for Windows systems

There are multiple ways to compile the Ngspice source code into a shared library for Windows systems:

1.  If visual studio is installed, go to the directory *visualc* of the unpacked tarball and start the project with double clicking on *sharedspice.vcxproj*, the *.dll* shared library could be built by building the project.
2.  It's also possible to compile the ngspice shared library for Windows on a Linux machine by simply running the script *cross-compile-shared.sh* within the tarball folder.

### Compiled Shared Libraries for Downloading

There are compiled shared library available for use.

-   For Windows 64-bit systems, download the zip file [here](https://github.com/QianqianShan/CompiledNgspice/tree/master/dll64) and unzip it into the C drive.

-   For Windows 32-bit systems, download the zip file [here](https://github.com/QianqianShan/CompiledNgspice/tree/master/dll32) and unzip it into the C drive.

-   For \*unix 62-bit systems, download files and folders from [here](https://github.com/QianqianShan/CompiledNgspice/tree/master/so64). Copy the files in lib folder to */usr/local/lib*, copy the *ngspice* folder to */usr/local/share*.

-   For \*unix 32-bit systems, similar to above, download [here](https://github.com/QianqianShan/CompiledNgspice/tree/master/so32). Copy the files in lib folder to */usr/local/lib*, copy the *ngspice* folder to */usr/local/share*.

Installation
------------

RSpice can be installed with:

``` r
install.packages("RSpice")
```

You can install RSpice from github with:

``` r
# install.packages("devtools")
devtools::install_github("https://github.com/QianqianShan/RSpice")
```

Example
-------

See the vignette for examples.
