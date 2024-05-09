!! Script for mapping
! uv table file name = w22be001-searchdisk-250kHz-LSB-CygX-N56.uvt

! Read header of the uv table
header w22be001-searchdisk-250kHz-LSB-CygX-N56.uvt

! Get observation setup and resolution info
let name w22be001-searchdisk-250kHz-LSB-CygX-N56
go setup

! Plot uv coverage
let name w22be001-searchdisk-250kHz-LSB-CygX-N56
go uvcov

! Get basic information of the observation
let name w22be001-searchdisk-250kHz-LSB-CygX-N56
go uvstat header


!! #########################################################################
!! ###########################Basic information#############################
I-MOSAIC,  Already in NORMAL mode
 
Input file: Interferometer (15m)  w22be001-searchdisk-250kHz-LSB-CygX-N56.uvt
 
   Single field observation (7970 visibilities)
 
   Observed rest frequency       231.5 GHz
   Half power primary beam       21.8 arcsec
   Phase center RA and Dec       20:39:16.745 42:16:09.314
   Field of view / Largest Scale 21.8 x 21.8 arcsec
 
                                Recommended        Used
   Spectral axis size              32511            32511 channels
   Map size                      2048 x 2048       2048 x 2048 pixels
   Map cell                     0.033 x 0.033     0.033 x 0.033 arcsec
   Image size                  67.8 x 67.8   67.8 x 67.8 arcsec
   Cube size                        507.9            507.9 GiB
   WARNING! Desired cube size exceeds 25% of the total RAM size
 
   Still to be imaged
   Still to be cleaned
I-UV_STAT,  Observed rest frequency         217.759525 GHz
I-UV_STAT,  Found         7970 Visibilities, **** channels
I-UV_STAT,  Baselines      42.6 -    1614.0 meters
I-UV_STAT,  Baselines      31.0 -    1172.3 kiloWavelength
I-UV_STAT,  Found telescope NOEMA from data
I-UV_STAT,  Half power primary beam               21.8 arcsec
I-UV_STAT,  Recommended Field of view / Largest Scale         17.3 x         17.3 "
I-UV_STAT,  Recommended Image size        18.0 x        18.0"
I-UV_STAT,  Recommended Map size 450 x 450
I-UV_STAT,  Recommended Pixel size    0.040 x    0.040 "
File :                                                               REAL*4
Size        Reference Pixel           Value                  Increment
     97540   71211.9218750000       231500.000000000      0.249999995799003
      7970   0.00000000000000       0.00000000000000       1.00000000000000
Blanking value and tolerance      1.23455997E+34   0.0000000
Source name         CYGX-N56
Map unit            Jy
Axis type           UV-DATA      RANDOM
Coordinate system   EQUATORIAL          Velocity    LSR
Right Ascension   20:39:16.74500        Declination       42:16:09.3140
Lii        0.000000000000000            Bii       0.000000000000000
Equinox            2000.0000
Projection type     AZIMUTHAL           Angle     0.000000000000000
Axis 0     A0     20:39:16.74500        Axis 0     D0     42:16:09.3140
Baselines              42.6    1614.0
Axis 1 Line Name                        Rest Frequency   231500.0000000000
Resolution in Velocity  -0.32375205     in Frequency         0.25000161
Offset in Velocity        6.5000000     Doppler Velocity      4.5644316
Beam                   21.8                0.00                 0.00
NO Noise level
NO Proper motion
Tel: NOEMA         05:54:28.50   44:38:02.0 Alt.   2560.0 Diam   15.0
UV Data    Channels:  32511, Stokes: 1 NONE        Visibilities:        7970
Column            1 (Size 1) contains U           
Column            2 (Size 1) contains V           
Column            4 (Size 1) contains DATE        
Column            5 (Size 1) contains TIME        
Column            6 (Size 1) contains IANT        
Column            7 (Size 1) contains JANT        
Column            3 (Size 1) contains SCAN        
Summary of observations
 32511 Channels,  1 Stokes,   Rest Frequency    217759.525 MHz
Has fine Doppler correction
   Dates      Visibilities     Minimun    & Maximum Baselines
                              (m)  (kWave)    (m)    (kWave)
 05-JAN-2023       3190      55.6    40.4    1614.0  1172.3
 23-JAN-2023         90     271.0   196.9    1318.5   957.7
 12-FEB-2023       3460      56.8    41.2    1565.2  1136.9
 13-FEB-2023       1230      42.6    31.0    1074.8   780.7
  12 Antennas,  in range    1  12
   1   2   3   4   5   6   8   9  10  11   7  12

!! ########################################################################################################################################################################################
!! ###########################################################################
!! ############################# Image Procedure #############################
!!
!! # For lower sideband
read uv w22be001-searchdisk-250kHz-LSB-CygX-N56.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv N56-LSB-comp

!! # Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name N56-LSB-comp
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-LSB-CygX-N56.uvt

uv_filter /frequency 221627 213890 /width 50 velo 
write uv N56-LSB-filter

!! ###### Generate LSB continuum uv table #############
read uv N56-LSB-filter.uvt
uv_filter /zero /frequency 221622 220386 219928 215199 213885 /width 20 velo !! set 100 km/s channels around the frequency list to zero
write uv N56-LSB-linefree

read uv N56-LSB-linefree
uv_cont
write uv N56-LSB-cont


!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name NW56-LSB-linefree
!! transfer gain solution to 
!! make deeper clean for the continuum uv table
let name N56-LSB-cont-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

vector\fits N56-LSB-cont-selfcal.fits from N56-LSB-cont-selfcal.lmv-clean /overwrite
vector\fits N56-LSB-cont-selfcal-res.fits from N56-LSB-cont-selfcal.lmv-res /overwrite
!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv N56-LSB-filter.uvt

uv_base 0 /frequency 221622 220386 219928 215199 213885  /width 20 velo !! set 100 km/s channels around the frequency list to zero

write uv N56-LSB-line

!! Extract line emissions
!! CH3OH 8(0,8)-7(1,6)
read uv N56-LSB-line-selfcal
uv_extract /frequency 220070 /width 60 velo
write uv N56-CH3OH-8-08-7-16-selfcal

modify N56-CH3OH-8-08-7-16-selfcal.uvt /freq CH3OH-87 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-CH3OH-8-08-7-16-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 800
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N56-CH3OH-8-08-7-16-selfcal.fits from N56-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits N56-CH3OH-8-08-7-16-selfcal-res.fits from N56-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite


!! CH3CN 12-11 K=3
read uv N56-LSB-line-selfcal
uv_extract /frequency 220693.2 /width 50 velo
write uv N56-CH3CN-12-11-k3-selfcal

modify N56-CH3CN-12-11-k3-selfcal.uvt /freq CH3CN-k3 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-CH3CN-12-11-k3-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N56-CH3CN-12-11-k3-selfcal.fits from N56-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits N56-CH3CN-12-11-k3-selfcal-res.fits from N56-CH3CN-12-11-k3-selfcal.lmv-res /overwrite

!! CH3CN 12-11 total
read uv N56-LSB-line-selfcal
uv_extract /frequency 220660 /width 300 velo
write uv N56-CH3CN-12-11-selfcal

modify N56-CH3CN-12-11-selfcal.uvt /freq CH3CN-k3 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-CH3CN-12-11-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N56-CH3CN-12-11-selfcal.fits from N56-CH3CN-12-11-selfcal.lmv-clean /overwrite
vector\fits N56-CH3CN-12-11-selfcal-res.fits from N56-CH3CN-12-11-selfcal.lmv-res /overwrite


!! CH3OH 4(2,2)-3(1,2)
read uv N56-LSB-line-selfcal
uv_extract /frequency 218430 /width 50 velo
write uv N56-CH3OH-4-22-3-12-selfcal

modify N56-CH3OH-4-22-3-12-selfcal.uvt /freq CH3OH-43 218440.0630 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-CH3OH-4-22-3-12-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 3.0
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N56-CH3OH-4-22-3-12-selfcal.fits from N56-CH3OH-4-22-3-12-selfcal.lmv-clean /overwrite
vector\fits N56-CH3OH-4-22-3-12-selfcal-res.fits from N56-CH3OH-4-22-3-12-selfcal.lmv-res /overwrite


!! 13CO 2-1
read uv N56-LSB-line-selfcal
uv_extract /frequency 220390 /width 80 velo
write uv N56-13CO-2-1-selfcal

modify N56-13CO-2-1-selfcal.uvt /freq 13CO2-1 220398.6195 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N56-13CO-2-1-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N56-13CO-2-1-selfcal.fits from N56-13CO-2-1-selfcal.lmv-clean /overwrite
vector\fits N56-13CO-2-1-selfcal-res.fits from N56-13CO-2-1-selfcal.lmv-res /overwrite

!! C18O 2-1
read uv N56-LSB-line-selfcal
uv_extract /frequency 219556 /width 60 velo
write uv N56-C18O-2-1-selfcal

modify N56-C18O-2-1-selfcal.uvt /freq C18O2-1 219560.358 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N56-C18O-2-1-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N56-C18O-2-1-selfcal.fits from N56-C18O-2-1-selfcal.lmv-clean /overwrite
vector\fits N56-C18O-2-1-selfcal-res.fits from N56-C18O-2-1-selfcal.lmv-res /overwrite



!! Outflow red- and blue-lobe velocity range: blue 7.5~10 km/s red 

!! SiO 5-4
read uv N56-LSB-line-selfcal
uv_extract /frequency 217090.2 /width 120 velo
write uv N56-SiO-5-4-selfcal

modify N56-SiO-5-4-selfcal.uvt /freq SiO 217104.919 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-SiO-5-4-selfcal
let map_cell 0.03
let map_size 1000
let uv_cell 7.5 3.0
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean


!! # export .fits file
vector\fits N56-SiO-5-4-selfcal.fits from N56-SiO-5-4-selfcal.lmv-clean /overwrite
vector\fits N56-SiO-5-4-selfcal-res.fits from N56-SiO-5-4-selfcal.lmv-res /overwrite

!! H2CO 3-2
read uv N56-LSB-line
uv_extract /frequency 218220 /width 40 velo
write uv N56-H2CO-3-03-2-02

modify N56-H2CO-3-03-2-02.uvt /freq H2CO 218222.192 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-H2CO-3-03-2-02-selfcal
let map_cell 0.05
let map_size 800
let niter 500
go uvmap

go clean

!! # export .fits file
vector\fits N56-H2CO-3-03-2-02-selfcal.fits from N56-H2CO-3-03-2-02-selfcal.lmv-clean /overwrite
vector\fits N56-H2CO-3-03-2-02-selfcal-res.fits from N56-H2CO-3-03-2-02-selfcal.lmv-res /overwrite



!! H2CO 3-2 line total
read uv N56-LSB-line-selfcal
uv_extract /frequency 218450 /width 1000 velo
write uv N56-H2CO-3-2-selfcal

modify N56-H2CO-3-2-selfcal.uvt /freq H2CO-3-2 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-H2CO-3-2-selfcal
let map_cell 0.03
let map_size 600
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N56-H2CO-3-2-selfcal.fits from N56-H2CO-3-2-selfcal.lmv-clean /overwrite
vector\fits N56-H2CO-3-2-selfcal-res.fits from N56-H2CO-3-2-selfcal.lmv-res /overwrite

!! CH3O13CHO 9-5-9-3
read uv N56-LSB-line-selfcal
uv_extract /frequency 218309.2 /width 50 velo
write uv N56-CH3O13CHO-9-5-9-3-selfcal

modify N56-CH3O13CHO-9-5-9-3-selfcal.uvt /freq CH3O13CHO 218323.894 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-CH3O13CHO-9-5-9-3-selfcal
let map_cell 0.03
let map_size 600
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N56-CH3O13CHO-9-5-9-3-selfcal.fits from N56-CH3O13CHO-9-5-9-3-selfcal.lmv-clean /overwrite
vector\fits N56-CH3O13CHO-9-5-9-3-selfcal-res.fits from N56-CH3O13CHO-9-5-9-3-selfcal.lmv-res /overwrite



!! CH3OH 8-08-7-16
read uv N56-LSB-line
uv_extract /frequency 220076 /width 40 velo
write uv N56-CH3OH-8-08-7-16

modify N56-CH3OH-8-08-7-16.uvt /freq CH3OH8-7 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-CH3OH-8-08-7-16-selfcal
let map_cell 0.05
let map_size 800
let niter 500
go uvmap

go clean

!! # export .fits file

vector\fits N56-CH3OH-8-08-7-16-selfcal.fits from N56-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits N56-CH3OH-8-08-7-16-selfcal-res.fits from N56-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite

!! SO-6-5
read uv N56-LSB-line
uv_extract /frequency 219948 /width 80 velo

$rm -rf N56-SO-6-5
write uv N56-SO-6-5

modify N56-SO-6-5.uvt /freq SO6-5 219949.442 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-SO-6-5-selfcal
let map_cell 0.05
let map_size 800
let niter 500
go uvmap

go clean

!! # export .fits file

vector\fits N56-SO-6-5-selfcal.fits from N56-SO-6-5-selfcal.lmv-clean /overwrite
vector\fits N56-SO-6-5-selfcal-res.fits from N56-SO-6-5-selfcal.lmv-res /overwrite

!! DCN-3-2
read uv N56-LSB-line-selfcal
uv_extract /frequency 217224 /width 60 velo

$rm -rf N56-DCN-3-2-selfcal.uvt
write uv N56-DCN-3-2-selfcal

modify N56-DCN-3-2-selfcal.uvt /freq DCN-3-2 217238.6307 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-DCN-3-2-selfcal
let uv_cell 7.5 0.5
let map_cell 0.03
let map_size 600

let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file

vector\fits N56-DCN-3-2-selfcal.fits from N56-DCN-3-2-selfcal.lmv-clean /overwrite
vector\fits N56-DCN-3-2-selfcal-res.fits from N56-DCN-3-2-selfcal.lmv-res /overwrite

!! HC3N 24-23
read uv N56-LSB-line-selfcal
uv_extract /frequency 218308.98 /width 50 velo
write uv N56-HC3N-24-23-selfcal

modify N56-HC3N-24-23-selfcal.uvt /freq HC3N 218324.723 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-HC3N-24-23-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 3.0
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N56-HC3N-24-23-selfcal.fits from N56-HC3N-24-23-selfcal.lmv-clean /overwrite
vector\fits N56-HC3N-24-23-selfcal-res.fits from N56-HC3N-24-23-selfcal.lmv-res /overwrite

!! SO 6-5
read uv N56-LSB-line-selfcal
uv_extract /frequency 219935.02 /width 50 velo
write uv N56-SO-6-5-selfcal

modify N56-SO-6-5-selfcal.uvt /freq SO 219949.4420 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-SO-6-5-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 3.0
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N56-SO-6-5-selfcal.fits from N56-SO-6-5-selfcal.lmv-clean /overwrite
vector\fits N56-SO-6-5-selfcal-res.fits from N56-SO-6-5-selfcal.lmv-res /overwrite

#######################################################################################################
###########################################################################################################
!!
!! # For upper sideband
read uv w22be001-searchdisk-250kHz-USB-CygX-N56.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv N56-USB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name N56-USB-comp
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-USB-CygX-N56.uvt

uv_filter /frequency 237121 229365 /width 50 velo 
write uv N56-USB-filter

!! ###### Generate USB continuum uv table #############
read uv N56-USB-filter.uvt
uv_filter /zero /frequency 230510 /width 100 velo !! set 100 km/s channels around the frequency list to zero
uv_filter /zero /frequency 237269 237106 235720 229371 229237 /width 20 velo !! set 100 km/s channels around the frequency list to zero
write uv N56-USB-linefree

read uv N56-USB-linefree
uv_cont
write uv N56-USB-cont

!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name N56-USB-linefree
!! transfer gain solution to N56-USB-cont
!! make deeper clean for the continuum uv table
let name N56-USB-cont-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

vector\fits N56-USB-cont-selfcal.fits from N56-LSB-cont-selfcal.lmv-clean /overwrite
vector\fits N56-USB-cont-selfcal-res.fits from N56-USB-cont-selfcal.lmv-res /overwrite

let name N56-comb-cont-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 1500
let fres 0.0125
input clean

go clean


vector\fits N56-comb-cont-selfcal.fits from N56-comb-cont-selfcal.lmv-clean /overwrite
vector\fits N56-comb-cont-selfcal-res.fits from N56-comb-cont-selfcal.lmv-res /overwrite

!! #######################################################################################
!! ## Merge both sidebands and generate the continuum map
!! #######################################################################################


!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv N56-USB-filter.uvt
uv_base 0 /frequency 230510 /width 100 velo !! set 100 km/s channels around the frequency list to zero
uv_base 0 /frequency 237269 237106 235720 229371 229237 /width 20 velo !! set 100 km/s channels around the frequency list to zero

write uv N56-USB-line

!! CO 2-1
read uv N56-USB-line-selfcal
uv_extract /frequency 230524.7 /width 120 velo
write uv N56-CO-2-1-selfcal

modify N56-CO-2-1-selfcal.uvt /freq CO2-1 230538 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N56-CO-2-1-selfcal
let map_cell 0.03
let map_size 1000
let uv_cell 7.5 3.0
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N56-CO-2-1-selfcal.fits from N56-CO-2-1-selfcal.lmv-clean /overwrite
vector\fits N56-CO-2-1-selfcal-res.fits from N56-CO-2-1-selfcal.lmv-res /overwrite

!! CH3OH 8--1-7-0
read uv N56-USB-line
uv_extract /frequency 229755 /width 60 velo
write uv N56-CH3OH-8--1-7-0

modify N56-CH3OH-8--1-7-0.uvt /freq CH3OH8-7 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N56-CH3OH-8--1-7-0-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 400
go clean
!! # export .fits file
vector\fits N56-CH3OH-8--1-7-0-selfcal.fits from N56-CH3OH-8--1-7-0-selfcal.lmv-clean /overwrite
vector\fits N56-CH3OH-8--1-7-0-selfcal-res.fits from N56-CH3OH-8--1-7-0-selfcal.lmv-res /overwrite







