!! Script for mapping
! uv table file name = w22be001-searchdisk-250kHz-LSB-CygX-N68.uvt

! Read header of the uv table
header w22be001-searchdisk-250kHz-LSB-CygX-N68.uvt

! Get observation setup and resolution info
let name w22be001-searchdisk-250kHz-LSB-CygX-N68
go setup

! Plot uv coverage
let name w22be001-searchdisk-250kHz-LSB-CygX-N68
go uvcov

! Get basic information of the observation
let name w22be001-searchdisk-250kHz-LSB-CygX-N68
go uvstat header

!! #########################################################################
!! ###########################Basic information#############################
I-MOSAIC,  Already in NORMAL mode
 
Input file: Interferometer (15m)  w22be001-searchdisk-250kHz-LSB-CygX-N68.uvt
 
   Single field observation (7970 visibilities)
 
   Observed rest frequency       231.5 GHz
   Half power primary beam       21.8 arcsec
   Phase center RA and Dec       20:40:33.574 41:59:01.072
   Field of view / Largest Scale 21.8 x 21.8 arcsec
 
                                Recommended        Used
   Spectral axis size              32511            32511 channels
   Map size                      2048 x 2048       2048 x 2048 pixels
   Map cell                     0.033 x 0.033     0.033 x 0.033 arcsec
   Image size                  68.2 x 68.2   68.2 x 68.2 arcsec
   Cube size                        507.9            507.9 GiB
   WARNING! Desired cube size exceeds 25% of the total RAM size
 
   Still to be imaged
   Still to be cleaned
I-UV_STAT,  Observed rest frequency         217.759384 GHz
I-UV_STAT,  Found         7970 Visibilities, **** channels
I-UV_STAT,  Baselines      42.9 -    1605.6 meters
I-UV_STAT,  Baselines      31.2 -    1166.3 kiloWavelength
I-UV_STAT,  Found telescope NOEMA from data
I-UV_STAT,  Half power primary beam               21.8 arcsec
I-UV_STAT,  Recommended Field of view / Largest Scale         17.2 x         17.2 "
I-UV_STAT,  Recommended Image size        18.0 x        18.0"
I-UV_STAT,  Recommended Map size 450 x 450
I-UV_STAT,  Recommended Pixel size    0.040 x    0.040 "
File :                                                               REAL*4
Size        Reference Pixel           Value                  Increment
     97540   71211.9218750000       231500.000000000      0.249999991975042
      7970   0.00000000000000       0.00000000000000       1.00000000000000
Blanking value and tolerance      1.23455997E+34   0.0000000
Source name         CYGX-N68
Map unit            Jy
Axis type           UV-DATA      RANDOM
Coordinate system   EQUATORIAL          Velocity    LSR
Right Ascension   20:40:33.57400        Declination       41:59:01.0720
Lii        0.000000000000000            Bii       0.000000000000000
Equinox            2000.0000
Projection type     AZIMUTHAL           Angle     0.000000000000000
Axis 0     A0     20:40:33.57400        Axis 0     D0     41:59:01.0720
Baselines              42.9    1605.6
Axis 1 Line Name                        Rest Frequency   231500.0000000000
Resolution in Velocity  -0.32375222     in Frequency         0.25000176
Offset in Velocity        6.5000000     Doppler Velocity      4.3812807
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
 32511 Channels,  1 Stokes,   Rest Frequency    217759.384 MHz
Has fine Doppler correction
   Dates      Visibilities     Minimun    & Maximum Baselines
                              (m)  (kWave)    (m)    (kWave)
 05-JAN-2023       3190      56.3    40.9    1605.6  1166.3
 23-JAN-2023         90     269.1   195.5    1323.0   961.0
 12-FEB-2023       3460      56.4    40.9    1554.1  1128.8
 13-FEB-2023       1230      42.9    31.2    1087.1   789.6
  12 Antennas,  in range    1  12
   1   2   3   4   5   6   8   9  10  11   7  12


!! ########################################################################################################################################################################################
!! ########################################################################################################################################################################################
!! ############################# Image Procedure ##########################################################################################################################################
!!
!! # For lower sideband
read uv w22be001-searchdisk-250kHz-LSB-CygX-N68.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv N68-LSB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name N68-LSB-comp

let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-LSB-CygX-N68.uvt

uv_filter /frequency 221633.17 217985.17 217761.17 217537.17 213889.17 /width 10 velo 
write uv N68-LSB-filter

!! ###### Generate LSB continuum uv table #############
read uv N68-LSB-filter.uvt
uv_filter /frequency 221584 217984 217764 217109 /width 20 velo !! set 20 km/s channels around the frequency list to zero
write uv N68-LSB-linefree

read uv N68-LSB-linefree
uv_cont
write uv N68-LSB-cont


!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name N68-LSB-linefree
!!
!! Number of self-calibration loop 4
!! List of integration times 120 100 80 60
!! List of number of iterations 20 20 20 20
!!
!! transfer gain solution to 
!! make deeper clean for the continuum uv table
let name N68-LSB-cont-selfcal
let uv_cell 7.5 0.5
let map_cell 0.03
let map_size 1600
let weight_mode robust
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

vector\fits N68-LSB-cont-selfcal.fits from N68-LSB-cont-selfcal.lmv-clean /overwrite
vector\fits N68-LSB-cont-selfcal-res.fits from N68-LSB-cont-selfcal.lmv-res /overwrite

!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv N68-LSB-filter.uvt

uv_base 0 /frequency 221584 217984 217764 217109 /width 20 velo !! set 100 km/s channels around the frequency list to zero

write uv N68-LSB-line

!! Extract line emissions
!! CH3CN 12-11
read uv N68-LSB-line-selfcal
uv_extract /frequency 220700 /width 300 velo
write uv N68-CH3CN-12-11-selfcal

modify N68-CH3CN-12-11-selfcal.uvt /freq CH3CN 220747.26120 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-CH3CN-12-11-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 3.0
let weight_mode robust
input uvmap

go uvmap

let niter 800
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N68-CH3CN-12-11-selfcal.fits from N68-CH3CN-12-11-selfcal.lmv-clean /overwrite
vector\fits N68-CH3CN-12-11-selfcal-res.fits from N68-CH3CN-12-11-selfcal.lmv-res /overwrite

!! CH3CN 12-11 K=3
read uv N68-LSB-line-selfcal
uv_extract /frequency 220712 /width 60 velo
write uv N68-CH3CN-12-11-k3-selfcal

modify N68-CH3CN-12-11-k3-selfcal.uvt /freq CH3CN-k3 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-CH3CN-12-11-k3-selfcal
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
vector\fits N68-CH3CN-12-11-k3-selfcal.fits from N68-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits N68-CH3CN-12-11-k3-selfcal-res.fits from N68-CH3CN-12-11-k3-selfcal.lmv-res /overwrite


!! 13CO 2-1
read uv N68-LSB-line-selfcal
uv_extract /frequency 220402 /width 80 velo
write uv N68-13CO-2-1-selfcal

modify N68-13CO-2-1-selfcal.uvt /freq 13CO2-1 220398.6195 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N68-13CO-2-1-selfcal
let uv_cell 7.5 3.0
let weight_mode robust
let map_size 1600
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean
go clean

!! # export .fits file
vector\fits N68-13CO-2-1-selfcal-rob3.fits from N68-13CO-2-1-selfcal.lmv-clean /overwrite
vector\fits N68-13CO-2-1-selfcal-res-rob3.fits from N68-13CO-2-1-selfcal.lmv-res /overwrite

!! C18O 2-1
read uv N68-LSB-line
uv_extract /frequency 219560 /width 60 velo
write uv N68-C18O-2-1

modify N68-C18O-2-1.uvt /freq C18O2-1 219560.358 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N68-C18O-2-1-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits N68-C18O-2-1-selfcal.fits from N68-C18O-2-1-selfcal.lmv-clean /overwrite
vector\fits N68-C18O-2-1-selfcal-res.fits from N68-C18O-2-1-selfcal.lmv-res /overwrite


!! CH3OH 5-4
read uv N68-LSB-line-selfcal
uv_extract /frequency 216950.04 /width 60 velo
write uv N68-CH3OH-5-4-selfcal

modify N68-CH3OH-5-4-selfcal.uvt /freq CH3OH5-4 216945.521 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N68-CH3OH-5-4-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
let map_size 800
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean
go clean

!! # export .fits file
vector\fits N68-CH3OH-5-4-selfcal.fits from N68-CH3OH-5-4-selfcal.lmv-clean /overwrite
vector\fits N68-CH3OH-5-4-selfcal-res.fits from N68-CH3OH-5-4-selfcal.lmv-res /overwrite


!! Outflow red- and blue-lobe velocity range: blue 7.5~10 km/s red 

!! SiO 5-4
read uv N68-LSB-line-selfcal
uv_extract /frequency 217110 /width 120 velo
write uv N68-SiO-5-4-selfcal

modify N68-SiO-5-4-selfcal.uvt /freq SiO5-4 217104.919 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-SiO-5-4-selfcal
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
vector\fits N68-SiO-5-4-selfcal.fits from N68-SiO-5-4-selfcal.lmv-clean /overwrite
vector\fits N68-SiO-5-4-selfcal-res.fits from N68-SiO-5-4-selfcal.lmv-res /overwrite


!! H2CO 3-2
read uv N68-LSB-line-selfcal
uv_extract /frequency 218227.29 /width 50 velo
write uv N68-H2CO-3-03-2-02-selfcal

modify N68-H2CO-3-03-2-02-selfcal.uvt /freq H2CO 218222.192 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-H2CO-3-03-2-02-selfcal
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
vector\fits N68-H2CO-3-03-2-02-selfcal.fits from N68-H2CO-3-03-2-02-selfcal.lmv-clean /overwrite
vector\fits N68-H2CO-3-03-2-02-selfcal-res.fits from N68-H2CO-3-03-2-02-selfcal.lmv-res /overwrite

!! H2CO 3-2 line total
read uv N68-LSB-line-selfcal
uv_extract /frequency 218450 /width 1000 velo
write uv N68-H2CO-3-2-selfcal

modify N68-H2CO-3-2-selfcal.uvt /freq H2CO-3-2 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-H2CO-3-2-selfcal
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
vector\fits N68-H2CO-3-2-selfcal.fits from N68-H2CO-3-2-selfcal.lmv-clean /overwrite
vector\fits N68-H2CO-3-2-selfcal-res.fits from N68-H2CO-3-2-selfcal.lmv-res /overwrite




!! DCN 3-2
read uv N68-LSB-line-selfcal
uv_extract /frequency 217243.35 /width 40 velo
write uv N68-DCN-3-2-selfcal

modify N68-DCN-3-2-selfcal.uvt /freq DCN3-2 217238.63070 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-DCN-3-2-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
let map_size 800
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N68-DCN-3-2-selfcal.fits from N68-DCN-3-2-selfcal.lmv-clean /overwrite
vector\fits N68-DCN-3-2-selfcal-res.fits from N68-DCN-3-2-selfcal.lmv-res /overwrite


!! CH3OH 8-08-7-16
read uv N68-LSB-line-selfcal
uv_extract /frequency 220083.28 /width 60 velo
write uv N68-CH3OH-8-08-7-16-selfcal

modify N68-CH3OH-8-08-7-16-selfcal.uvt /freq CH3OH8-7 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-CH3OH-8-08-7-16-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
let map_size 800
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

!! # export .fits file

vector\fits N68-CH3OH-8-08-7-16-selfcal.fits from N68-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits N68-CH3OH-8-08-7-16-selfcal-res.fits from N68-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite


!! # Apply selfcal and make deeper clean
let name N68-CH3OH-8-08-7-16-selfcal
let map_cell 0.03
let map_size 600
let uv_cell 7.5 3.0
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean


!! # export .fits file

vector\fits N68-CH3OH-8-08-7-16-selfcal-rob3.fits from N68-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits N68-CH3OH-8-08-7-16-selfcal-res-rob3.fits from N68-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite


!! CH3OH 4-2-3-1
read uv N68-LSB-line-selfcal
uv_extract /frequency 218445.04 /width 40 velo
write uv N68-CH3OH-4-2-3-1-selfcal

modify N68-CH3OH-4-2-3-1-selfcal.uvt /freq CH3OH4-3 218440.063 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-CH3OH-4-2-3-1-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
let map_size 800
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

!! # export .fits file

vector\fits N68-CH3OH-4-2-3-1-selfcal.fits from N68-CH3OH-4-2-3-1-selfcal.lmv-clean /overwrite
vector\fits N68-CH3OH-4-2-3-1-selfcal-res.fits from N68-CH3OH-4-2-3-1-selfcal.lmv-res /overwrite


!! # Apply selfcal and make deeper clean
let name N68-CH3OH-4-2-3-1-selfcal
let uv_cell 7.5 3.0
let weight_mode robust
let map_size 1600
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

!! # export .fits file

vector\fits N68-CH3OH-4-2-3-1-selfcal-rob3.fits from N68-CH3OH-4-2-3-1-selfcal.lmv-clean /overwrite
vector\fits N68-CH3OH-4-2-3-1-selfcal-res-rob3.fits from N68-CH3OH-4-2-3-1-selfcal.lmv-res /overwrite


!! SO-6-5
read uv N68-LSB-line
uv_extract /frequency 219950 /width 40 velo
write uv N68-SO-6-5

modify N68-SO-6-5.uvt /freq CH3OH8-7 219949.442 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N68-SO-6-5-selfcal
let map_cell 0.05
let map_size 800
let niter 500
go uvmap

go clean

!! # export .fits file

vector\fits N68-SO-6-5-selfcal.fits from N68-SO-6-5-selfcal.lmv-clean /overwrite
vector\fits N68-SO-6-5-selfcal-res.fits from N68-SO-6-5-selfcal.lmv-res /overwrite


#######################################################################################################
###########################################################################################################
!!
!! # For upper sideband
read uv w22be001-searchdisk-250kHz-USB-CygX-N68.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv N68-USB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name N68-USB-comp
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-USB-CygX-N68.uvt

uv_filter /frequency 229377.17 233025.17 233249.17 233473.17 237121.17 /width 10 velo 
write uv N68-USB-filter

!! ###### Generate LSB continuum uv table #############
read uv N68-USB-filter.uvt
uv_filter /zero /frequency 230553 /width 100 velo !! set 100 km/s channels around the frequency list to zero
uv_filter /zero /frequency 237117 231252 229367 /width 20 velo !! set 100 km/s channels around the frequency list to zero
write uv N68-USB-linefree

read uv N68-USB-linefree
uv_cont
write uv N68-USB-cont

!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name N68-USB-linefree
!! transfer gain solution to N68-USB-cont
!! make deeper clean for the continuum uv table
let name N68-USB-cont-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 1600
let fres 0.0125
input clean

go clean

vector\fits N68-USB-cont-selfcal.fits from N68-USB-cont-selfcal.lmv-clean /overwrite
vector\fits N68-USB-cont-selfcal-res.fits from N68-USB-cont-selfcal.lmv-res /overwrite

go uv_merge

let name N68-comb-cont-selfcal
let uv_cell 7.5 0.5
let map_cell 0.03
let map_size 1600
let weight_mode robust
input uvmap

go uvmap

let niter 2000
let fres 0.01
input clean

go clean

vector\fits N68-comb-cont-selfcal.fits from N68-comb-cont-selfcal.lmv-clean /overwrite
vector\fits N68-comb-cont-selfcal-res.fits from N68-comb-cont-selfcal.lmv-res /overwrite


!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For USB band
read uv N68-USB-filter.uvt
uv_base 0 /frequency 230544 /width 100 velo !! set 100 km/s channels around the frequency list to zero
uv_base 0 /frequency 237115 236013 229776 229376 /width 20 velo !! set 100 km/s channels around the frequency list to zero

write uv N68-USB-line

!! CO 2-1
read uv N68-USB-line-selfcal
uv_extract /frequency 230540 /width 120 velo
write uv N68-CO-2-1-selfcal

modify N68-CO-2-1-selfcal.uvt /freq CO2-1 230538.0 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N68-CO-2-1-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 3.0
let weight_mode robust
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N68-CO-2-1-selfcal.fits from N68-CO-2-1-selfcal.lmv-clean /overwrite
vector\fits N68-CO-2-1-selfcal-res.fits from N68-CO-2-1-selfcal.lmv-res /overwrite

!! CH3OH 8--1-7-0
read uv N68-USB-line-selfcal
uv_extract /frequency 229764 /width 60 velo
write uv N68-CH3OH-8--1-7-0-selfcal

modify N68-CH3OH-8--1-7-0-selfcal.uvt /freq CH3OH8-7 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N68-CH3OH-8--1-7-0-selfcal
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
vector\fits N68-CH3OH-8--1-7-0-selfcal.fits from N68-CH3OH-8--1-7-0-selfcal.lmv-clean /overwrite
vector\fits N68-CH3OH-8--1-7-0-selfcal-res.fits from N68-CH3OH-8--1-7-0-selfcal.lmv-res /overwrite

!! N2D+ 3-2
read uv N68-USB-line
uv_extract /frequency 231320 /width 40 velo
write uv N68-N2D+-3-2

modify N68-N2D+-3-2.uvt /freq N2D+ 231319.97970 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N68-N2D+-3-2-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits N68-N2D+-3-2-selfcal.fits from N68-N2D+-3-2-selfcal.lmv-clean /overwrite
vector\fits N68-N2D+-3-2-selfcal-res.fits from N68-N2D+-3-2-selfcal.lmv-res /overwrite

!! 13CS  5-4
read uv N68-USB-line-selfcal
uv_extract /frequency 231226.6 /width 50 velo
write uv N68-13CS-5-4-selfcal

modify N68-13CS-5-4-selfcal.uvt /freq 13CS 231220.67 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N68-13CS-5-4-selfcal
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
vector\fits N68-13CS-5-4-selfcal.fits from N68-13CS-5-4-selfcal.lmv-clean /overwrite
vector\fits N68-13CS-5-4-selfcal-res.fits from N68-13CS-5-4-selfcal.lmv-res /overwrite



