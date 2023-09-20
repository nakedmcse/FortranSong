#Build script
gfortran -o Song FortranSong.f90 -I/usr/local/Cellar/json-fortran/8.3.0_1/include -L/usr/local/Cellar/json-fortran/8.3.0_1/lib -ljsonfortran
