#Build script
gfortran -c OpenAIApi.f90 -I/usr/local/Cellar/json-fortran/8.3.0_1/include -L/usr/local/Cellar/json-fortran/8.3.0_1/lib
gfortran -c FortranSong.f90 -I/usr/local/Cellar/json-fortran/8.3.0_1/include -L/usr/local/Cellar/json-fortran/8.3.0_1/lib
gfortran OpenAIApi.o FortranSong.o -o Song -I/usr/local/Cellar/json-fortran/8.3.0_1/include -L/usr/local/Cellar/json-fortran/8.3.0_1/lib -ljsonfortran
