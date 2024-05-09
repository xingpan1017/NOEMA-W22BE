!! Script for mapping
! uv table file name = w22be001-searchdisk-250kHz-LSB-CygX-N30-MM2.uvt

! Read header of the uv table
header w22be001-searchdisk-250kHz-LSB-CygX-N30-MM2.uvt

! Get observation setup and resolution info
let name w22be001-searchdisk-250kHz-LSB-CygX-N30-MM2
go setup

! Plot uv coverage
let name w22be001-searchdisk-250kHz-LSB-CygX-N30-MM2
go uvcov

! Get basic information of the observation
let name w22be001-searchdisk-250kHz-LSB-CygX-N30-MM2
go uvstat header

I-MOSAIC,  Already in NORMAL mode
 
Input file: Interferometer (15m)  w22be001-searchdisk-250kHz-LSB-CygX-N30-MM2.uvt
 
   Single field observation (8600 visibilities)
 
   Observed rest frequency       231.5 GHz
   Half power primary beam       21.8 arcsec
   Phase center RA and Dec       20:38:36.425 42:37:34.619
   Field of view / Largest Scale 21.8 x 21.8 arcsec
 
                                Recommended        Used
   Spectral axis size              32511            32511 channels
   Map size                      2048 x 2048       2048 x 2048 pixels
   Map cell                     0.032 x 0.032     0.032 x 0.032 arcsec
   Image size                  65.7 x 65.7   65.7 x 65.7 arcsec
   Cube size                        507.9            507.9 GiB
   WARNING! Desired cube size exceeds 25% of the total RAM size
 
   Still to be imaged
   Still to be cleaned
I-UV_STAT,  Observed rest frequency         217.759614 GHz
I-UV_STAT,  Found         8600 Visibilities, **** channels
I-UV_STAT,  Baselines      45.2 -    1662.6 meters
I-UV_STAT,  Baselines      32.8 -    1207.7 kiloWavelength
I-UV_STAT,  Found telescope NOEMA from data
I-UV_STAT,  Half power primary beam               21.8 arcsec
I-UV_STAT,  Recommended Field of view / Largest Scale         16.3 x         16.3 "
I-UV_STAT,  Recommended Image size        17.3 x        17.3"
I-UV_STAT,  Recommended Map size 576 x 576
I-UV_STAT,  Recommended Pixel size    0.030 x    0.030 "
File :                                                               REAL*4
Size        Reference Pixel           Value                  Increment
     97540   71211.9218750000       231500.000000000      0.250000002254505
      8600   0.00000000000000       0.00000000000000       1.00000000000000
Blanking value and tolerance      1.23455997E+34   0.0000000
Source name         CYGX-N30-MM2
Map unit            Jy
Axis type           UV-DATA      RANDOM
Coordinate system   EQUATORIAL          Velocity    LSR
Right Ascension   20:38:36.42500        Declination       42:37:34.6190
Lii        0.000000000000000            Bii       0.000000000000000
Equinox            2000.0000
Projection type     AZIMUTHAL           Angle     0.000000000000000
Axis 0     A0     20:38:36.42500        Axis 0     D0     42:37:34.6190
Baselines              45.2    1662.6
Axis 1 Line Name                        Rest Frequency   231500.0000000000
Resolution in Velocity  -0.32375193     in Frequency         0.25000152
Offset in Velocity        6.5000000     Doppler Velocity      4.6797536
Beam                   21.8                0.00                 0.00
NO Noise level
NO Proper motion
Tel: NOEMA         05:54:28.50   44:38:02.0 Alt.   2560.0 Diam   15.0
UV Data    Channels:  32511, Stokes: 1 NONE        Visibilities:        8600
Column            1 (Size 1) contains U           
Column            2 (Size 1) contains V           
Column            4 (Size 1) contains DATE        
Column            5 (Size 1) contains TIME        
Column            6 (Size 1) contains IANT        
Column            7 (Size 1) contains JANT        
Column            3 (Size 1) contains SCAN        
Summary of observations
 32511 Channels,  1 Stokes,   Rest Frequency    217759.614 MHz
Has fine Doppler correction
   Dates      Visibilities     Minimun    & Maximum Baselines
                              (m)  (kWave)    (m)    (kWave)
 05-JAN-2023       3220      58.8    42.7    1662.6  1207.7
 23-JAN-2023         90     265.0   192.5    1331.9   967.4
 12-FEB-2023       4060      56.5    41.0    1636.5  1188.7
 13-FEB-2023       1230      45.2    32.8    1147.3   833.4
  12 Antennas,  in range    1  12
   1   2   3   4   5   6   8   9  10  11   7  12

 ########################################################################################################################################################################################
!! ###########################################################################
!! ############################# Image Procedure #############################
!!
!! # For lower sideband
read uv w22be001-searchdisk-250kHz-LSB-CygX-N30-MM2.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv N30-LSB-comp

!! # Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name N30-LSB-comp
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

vector\fits N30-LSB-comp.fits from N30-LSB-comp.lmv-clean /overwrite
vector\fits N30-LSB-comp-res.fits from N30-LSB-comp.lmv-res /overwrite


!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-LSB-CygX-N30-MM2.uvt

uv_filter /frequency 221606 /width 100 velo
uv_filter /frequency 213879.5 /width 50 velo 
write uv N30-LSB-filter

!! ###### Generate LSB continuum uv table #############
read uv N30-LSB-filter.uvt
uv_filter /zero /frequency 213884 214346 214709 215210 216673 216956 217106 217293 218323 218458 218862 218991 219171 219262 219348 219468 219765 219944 220591 220749 221645 /width 30 velo !! set 40 km/s channels around the frequency list to zero
write uv N30-LSB-linefree

read uv N30-LSB-linefree
uv_cont
write uv N30-LSB-cont


!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name N30-LSB-linefree
!! Number of self-calibration loop 4
!! List of integration times 80 60 40 20
!! List of number of iterations 20 20 20 20
!! transfer gain solution to 
!! make deeper clean for the continuum uv table
let name N30-LSB-cont-selfcal
let map_cell 0.03
let map_size 2048
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

vector\fits N30-LSB-cont-selfcal.fits from N30-LSB-cont-selfcal.lmv-clean /overwrite
vector\fits N30-LSB-cont-selfcal-res.fits from N30-LSB-cont-selfcal.lmv-res /overwrite


!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv N30-LSB-filter.uvt

uv_base 0 /frequency 213884 214346 214709 215210 216673 216956 217106 217293 218323 218458 218862 218991 219171 219262 219348 219468 219765 219944 220591 220749 221645 /width 30 velo !! set 50 km/s channels around the frequency list to zero

write uv N30-LSB-line

!! Extract line emissions

!! CH3OH 8(0,8)-7(1,6)
read uv N30-LSB-line-selfcal
uv_extract /frequency 220078 /width 60 velo
write uv N30-CH3OH-8-08-7-16-selfcal

modify N30-CH3OH-8-08-7-16-selfcal.uvt /freq CH3OH-87 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3OH-8-08-7-16-selfcal
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
vector\fits N30-CH3OH-8-08-7-16-selfcal.fits from N30-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits N30-CH3OH-8-08-7-16-selfcal-res.fits from N30-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite


!! CH3CN 12-11 K=3
read uv N30-LSB-line-selfcal
uv_extract /frequency 220708 /width 60 velo
write uv N30-CH3CN-12-11-k3-selfcal

modify N30-CH3CN-12-11-k3-selfcal.uvt /freq CH3CN-k3 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3CN-12-11-k3-selfcal
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
vector\fits N30-CH3CN-12-11-k3-selfcal.fits from N30-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits N30-CH3CN-12-11-k3-selfcal-res.fits from N30-CH3CN-12-11-k3-selfcal.lmv-res /overwrite

!! CH3CN 12-11 K=4
read uv N30-LSB-line-selfcal
uv_extract /frequency 220680 /width 60 velo
write uv N30-CH3CN-12-11-k4-selfcal

modify N30-CH3CN-12-11-k4-selfcal.uvt /freq CH3CN-k4 220679.2869 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3CN-12-11-k4-selfcal
let map_cell 0.03
let map_size 2048
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-CH3CN-12-11-k4-selfcal.fits from N30-CH3CN-12-11-k4-selfcal.lmv-clean /overwrite
vector\fits N30-CH3CN-12-11-k4-selfcal-res.fits from N30-CH3CN-12-11-k4-selfcal.lmv-res /overwrite



!! CH3CN 12-11 K=7
read uv N30-LSB-line-selfcal
uv_extract /frequency 220538.9 /width 60 velo
write uv N30-CH3CN-12-11-k7-selfcal

modify N30-CH3CN-12-11-k7-selfcal.uvt /freq CH3CN-k7 220539.32350 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3CN-12-11-k7-selfcal
let map_cell 0.03
let map_size 2048
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-CH3CN-12-11-k7-selfcal.fits from N30-CH3CN-12-11-k7-selfcal.lmv-clean /overwrite
vector\fits N30-CH3CN-12-11-k7-selfcal-res.fits from N30-CH3CN-12-11-k7-selfcal.lmv-res /overwrite



!! CH3CN 12-11
read uv N30-LSB-line-selfcal
uv_extract /frequency 220670 /width 300 velo
write uv N30-CH3CN-12-11-selfcal

modify N30-CH3CN-12-11-selfcal.uvt /freq CH3CN-k0-8 220747.2612 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3CN-12-11-selfcal
let map_cell 0.03
let map_size 1000
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-CH3CN-12-11-selfcal.fits from N30-CH3CN-12-11-selfcal.lmv-clean /overwrite
vector\fits N30-CH3CN-12-11-selfcal-res.fits from N30-CH3CN-12-11-selfcal.lmv-res /overwrite


!! CH3CN 12-11 K=3
read uv N30-LSB-line
uv_extract /frequency 220712 /width 40 velo
write uv N30-CH3CN-12-11-k3

modify N30-CH3CN-12-11-k3.uvt /freq CH3CN-k3 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3CN-12-11-k3-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits N30-CH3CN-12-11-k3-selfcal.fits from N30-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits N30-CH3CN-12-11-k3-selfcal-res.fits from N30-CH3CN-12-11-k3-selfcal.lmv-res /overwrite


!! 13CO 2-1
read uv N30-LSB-line-selfcal
uv_extract /frequency 220402 /width 100 velo
write uv N30-13CO-2-1-selfcal

modify N30-13CO-2-1-selfcal.uvt /freq 13CO 220398.6195 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-13CO-2-1-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N30-13CO-2-1-selfcal.fits from N30-13CO-2-1-selfcal.lmv-clean /overwrite
vector\fits N30-13CO-2-1-selfcal-res.fits from N30-13CO-2-1-selfcal.lmv-res /overwrite

!! C18O 2-1
read uv N30-LSB-line
uv_extract /frequency 219558 /width 60 velo
write uv N30-C18O-2-1-selfcal

modify N30-C18O-2-1-selfcal.uvt /freq C18O 219560.358 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-C18O-2-1-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N30-C18O-2-1-selfcal.fits from N30-C18O-2-1-selfcal.lmv-clean /overwrite
vector\fits N30-C18O-2-1-selfcal-res.fits from N30-C18O-2-1-selfcal.lmv-res /overwrite


!! DCN 3-2
read uv N30-LSB-line-selfcal
uv_extract /frequency 217234.14 /width 50 velo
write uv N30-DCN-3-2-selfcal

modify N30-DCN-3-2-selfcal.uvt /freq DCN3-2 217238.6307 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-DCN-3-2-selfcal
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
vector\fits N30-DCN-3-2-selfcal.fits from N30-DCN-3-2-selfcal.lmv-clean /overwrite
vector\fits N30-DCN-3-2-selfcal-res.fits from N30-DCN-3-2-selfcal.lmv-res /overwrite



!! HC3N 24-23
read uv N30-LSB-line
uv_extract /frequency 219170.59 /width 50 velo
write uv N30-HC3N-24-23-selfcal

modify N30-HC3N-24-23-selfcal.uvt /freq HC3N 219173.7567 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-HC3N-24-23-selfcal
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
vector\fits N30-HC3N-24-23-selfcal.fits from N30-HC3N-24-23-selfcal.lmv-clean /overwrite
vector\fits N30-HC3N-24-23-selfcal-res.fits from N30-HC3N-24-23-selfcal.lmv-res /overwrite


!! Outflow red- and blue-lobe velocity range: blue 7.5~10 km/s red 

!! SiO 5-4
read uv N30-LSB-line-selfcal
uv_extract /frequency 217108.7 /width 120 velo
write uv N30-SiO-5-4-selfcal

modify N30-SiO-5-4-selfcal.uvt /freq SiO5-4 217104.919 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-SiO-5-4-selfcal
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
vector\fits N30-SiO-5-4-selfcal.fits from N30-SiO-5-4-selfcal.lmv-clean /overwrite
vector\fits N30-SiO-5-4-selfcal-res.fits from N30-SiO-5-4-selfcal.lmv-res /overwrite


!! H2CO 3-2
read uv N30-LSB-line-selfcal
uv_extract /frequency 218222 /width 80 velo
write uv N30-H2CO-3-03-2-02-selfcal

modify N30-H2CO-3-03-2-02-selfcal.uvt /freq H2CO 218222.192 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-H2CO-3-03-2-02-selfcal
let map_cell 0.03
let map_size 1024
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-H2CO-3-03-2-02-selfcal.fits from N30-H2CO-3-03-2-02-selfcal.lmv-clean /overwrite
vector\fits N30-H2CO-3-03-2-02-selfcal-res.fits from N30-H2CO-3-03-2-02-selfcal.lmv-res /overwrite

!! H2CO 3-2
read uv N30-LSB-line
uv_extract /frequency 218755.95 /width 40 velo
write uv N30-H2CO-3-21-2-20

modify N30-H2CO-3-21-2-20.uvt /freq H2CO 218760.066 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-H2CO-3-21-2-20-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits N30-H2CO-3-21-2-20-selfcal.fits from N30-H2CO-3-21-2-20-selfcal.lmv-clean /overwrite
vector\fits N30-H2CO-3-21-2-20-selfcal-res.fits from N30-H2CO-3-21-2-20-selfcal.lmv-res /overwrite

!! H2CO 3-2
read uv N30-LSB-line
uv_extract /frequency 218471 /width 40 velo
write uv N30-H2CO-3-22-2-21

modify N30-H2CO-3-22-2-21.uvt /freq H2CO 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-H2CO-3-22-2-21-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits N30-H2CO-3-22-2-21-selfcal.fits from N30-H2CO-3-22-2-21-selfcal.lmv-clean /overwrite
vector\fits N30-H2CO-3-22-2-21-selfcal-res.fits from N30-H2CO-3-22-2-21-selfcal.lmv-res /overwrite


!! H2CO 3-2 total
read uv N30-LSB-line-selfcal
uv_extract /frequency 218450 /width 1000 velo
write uv N30-H2CO-3-2-selfcal

modify N30-H2CO-3-2-selfcal.uvt /freq H2CO 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-H2CO-3-2-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-H2CO-3-2-selfcal.fits from N30-H2CO-3-2-selfcal.lmv-clean /overwrite
vector\fits N30-H2CO-3-2-selfcal-res.fits from N30-H2CO-3-2-selfcal.lmv-res /overwrite


!! CH3OCHO 17-16 E
read uv N30-LSB-line-selfcal
uv_extract /frequency 218274.5 /width 50 velo
write uv N30-CH3OCHO-17-3-14-16-3-13E-selfcal

modify N30-CH3OCHO-17-3-14-16-3-13E-selfcal.uvt /freq CH3OCHO17-16E 	218280.9 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3OCHO-17-3-14-16-3-13E-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-CH3OCHO-17-3-14-16-3-13E-selfcal.fits from N30-CH3OCHO-17-3-14-16-3-13E-selfcal.lmv-clean /overwrite
vector\fits N30-CH3OCHO-17-3-14-16-3-13E-selfcal-res.fits from N30-CH3OCHO-17-3-14-16-3-13E-selfcal.lmv-res /overwrite

!! CH3OCHO 17-16 A
read uv N30-LSB-line-selfcal
uv_extract /frequency 218291.5 /width 50 velo
write uv N30-CH3OCHO-17-3-14-16-3-13A-selfcal

modify N30-CH3OCHO-17-3-14-16-3-13A-selfcal.uvt /freq CH3OCHO  218297.866 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3OCHO-17-3-14-16-3-13A-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-CH3OCHO-17-3-14-16-3-13A-selfcal.fits from N30-CH3OCHO-17-3-14-16-3-13A-selfcal.lmv-clean /overwrite
vector\fits N30-CH3OCHO-17-3-14-16-3-13A-selfcal-res.fits from N30-CH3OCHO-17-3-14-16-3-13A-selfcal.lmv-res /overwrite

!! NH2CHO
read uv N30-LSB-line-selfcal
uv_extract /frequency 218453.7 /width 50 velo
write uv N30-NH2CHO-10-9-selfcal

modify N30-NH2CHO-10-9-selfcal.uvt /freq NH2CHO 218459.205 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-NH2CHO-10-9-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-NH2CHO-10-9-selfcal.fits from N30-NH2CHO-10-9-selfcal.lmv-clean /overwrite
vector\fits N30-NH2CHO-10-9-selfcal-res.fits from N30-NH2CHO-10-9-selfcal.lmv-res /overwrite


!! CH3CH2CHO 38-38
read uv N30-LSB-line-selfcal
uv_extract /frequency 218678.5 /width 50 velo
write uv N30-CH3CH2CHO-38-9-38-7-selfcal

modify N30-CH3CH2CHO-38-9-38-7-selfcal.uvt /freq CH3CH2CHO 218684.432 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3CH2CHO-38-9-38-7-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-CH3CH2CHO-38-9-38-7-selfcal.fits from N30-CH3CH2CHO-38-9-38-7-selfcal.lmv-clean /overwrite
vector\fits N30-CH3CH2CHO-38-9-38-7-selfcal-res.fits from N30-CH3CH2CHO-38-9-38-7-selfcal.lmv-res /overwrite


!! CH213CHCN 23-22
read uv N30-LSB-line-selfcal
uv_extract /frequency 218319.0 /width 50 velo
write uv N30-CH213CHCN-23-3-22-3-selfcal

modify N30-CH213CHCN-23-3-22-3-selfcal.uvt /freq CH3CH2CHO 218325.5366 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH213CHCN-23-3-22-3-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N30-CH213CHCN-23-3-22-3-selfcal.fits from N30-CH213CHCN-23-3-22-3-selfcal.lmv-clean /overwrite
vector\fits N30-CH213CHCN-23-3-22-3-selfcal-res.fits from N30-CH213CHCN-23-3-22-3-selfcal.lmv-res /overwrite



!! CH3OH 8-08-7-16
read uv N30-LSB-line
uv_extract /frequency 220080 /width 40 velo
write uv N30-CH3OH-8-08-7-16

modify N30-CH3OH-8-08-7-16.uvt /freq CH3OH8-7 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-CH3OH-8-08-7-16-selfcal
let map_cell 0.05
let map_size 800
let niter 500
!!go uvmap

go clean

!! # export .fits file

vector\fits N30-CH3OH-8-08-7-16-selfcal.fits from N30-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits N30-CH3OH-8-08-7-16-selfcal-res.fits from N30-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite

!! SO-6-5
read uv N30-LSB-line-selfcal
uv_extract /frequency 219950 /width 80 velo

write uv N30-SO-6-5-selfcal
modify N30-SO-6-5-selfcal.uvt /freq SO6-5 219949.442 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N30-SO-6-5-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! # export .fits file

vector\fits N30-SO-6-5-selfcal.fits from N30-SO-6-5-selfcal.lmv-clean /overwrite
vector\fits N30-SO-6-5-selfcal-res.fits from N30-SO-6-5-selfcal.lmv-res /overwrite

!! DCO+ 3-2
read uv N30-LSB-line-selfcal
uv_extract /frequency 216110 /width 50 velo
write uv N30-DCO+-3-2-selfcal

modify N30-DCO+-3-2-selfcal.uvt /freq DCO+ 216112.58 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-DCO+-3-2-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N30-DCO+-3-2-selfcal.fits from N30-DCO+-3-2-selfcal.lmv-clean /overwrite
vector\fits N30-DCO+-3-2-selfcal-res.fits from N30-DCO+-3-2-selfcal.lmv-res /overwrite

!! OCS 18-17
read uv N30-LSB-line-selfcal
uv_extract /frequency 218896.74 /width 50 velo
write uv N30-OCS-18-17-selfcal

modify N30-OCS-18-17-selfcal.uvt /freq OCS 218903.3555 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-OCS-18-17-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N30-OCS-18-17-selfcal.fits from N30-OCS-18-17-selfcal.lmv-clean /overwrite
vector\fits N30-OCS-18-17-selfcal-res.fits from N30-OCS-18-17-selfcal.lmv-res /overwrite

#######################################################################################################
###########################################################################################################
!!
!! # For upper sideband
read uv w22be001-searchdisk-250kHz-USB-CygX-N30.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv N30-USB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name N30-USB-comp
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean


!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-USB-CygX-N30-MM2.uvt

uv_filter /frequency 237121 229365 /width 50 velo 
write uv N30-USB-filter

!! ###### Generate USB continuum uv table #############
read uv N30-USB-filter.uvt
uv_filter /zero /frequency 235991 230538 /width 150 velo !! set 100 km/s channels around the frequency list to zero
uv_filter /zero /frequency 237091 237071 237051 236931 236711 236511 236315 236211 235151 234691 234671 234171 233791 232951 232931 232771 232411 231271 231051 230031 230011 229751 229591  /width 20 velo !! set 20 km/s channels around the frequency list to zero
write uv N30-USB-linefree

read uv N30-USB-linefree
uv_cont
write uv N30-USB-cont

!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name N30-USB-linefree
!! transfer gain solution to N30-USB-cont
!! make deeper clean for the continuum uv table
let name N30-USB-cont-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

vector\fits N30-comb-cont-selfcal.fits from N30-comb-cont-selfcal.lmv-clean /overwrite
vector\fits N30-comb-cont-selfcal-res.fits from N30-comb-cont-selfcal.lmv-res /overwrite


!! #######################################################################################
!! ## Merge both sidebands and generate the continuum map
!! #######################################################################################


!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv N30-USB-filter.uvt

uv_base 0 /frequency 235991 230538 /width 150 velo !! set 100 km/s channels around the frequency list to zero
uv_base 0 /frequency 237091 237071 237051 236931 236711 236511 236315 236211 235151 234691 234671 234171 233791 232951 232931 232771 232411 231271 231051 230031 230011 229751 229591  /width 20 velo !! set 20 km/s channels around the frequency list to zero

write uv N30-USB-line

!! CO 2-1
read uv N30-USB-line-selfcal
uv_extract /frequency 230538 /width 120 velo
write uv N30-CO-2-1-selfcal

modify N30-CO-2-1-selfcal.uvt /freq CO2-1 230538.0 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-CO-2-1-selfcal
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
vector\fits N30-CO-2-1-selfcal.fits from N30-CO-2-1-selfcal.lmv-clean /overwrite
vector\fits N30-CO-2-1-selfcal-res.fits from N30-CO-2-1-selfcal.lmv-res /overwrite

!! CH3OH 8--1-7-0
read uv N30-USB-line
uv_extract /frequency 229755 /width 40 velo
write uv N30-CH3OH-8--1-7-0

modify N30-CH3OH-8--1-7-0.uvt /freq CH3OH8-7 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-CH3OH-8--1-7-0-selfcal
let map_cell 0.05
let map_size 800
!! go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits N30-CH3OH-8--1-7-0-selfcal.fits from N30-CH3OH-8--1-7-0-selfcal.lmv-clean /overwrite
vector\fits N30-CH3OH-8--1-7-0-selfcal-res.fits from N30-CH3OH-8--1-7-0-selfcal.lmv-res /overwrite

!! D2CO 4-3
read uv N30-USB-line-selfcal
uv_extract /frequency 229755 /width 60 velo
write uv N30-D2CO-4-04-3-03-selfcal

modify N30-D2CO-4-04-3-03-selfcal.uvt /freq D2CO4-3 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-D2CO-4-04-3-03-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N30-D2CO-4-04-3-03-selfcal.fits from N30-D2CO-4-04-3-03-selfcal.lmv-clean /overwrite
vector\fits N30-D2CO-4-04-3-03-selfcal-res.fits from N30-D2CO-4-04-3-03-selfcal.lmv-res /overwrite

!! DNC 3-2
read uv N30-USB-line
uv_extract /frequency 228907 /width 40 velo
write uv N30-DNC-3-2

modify N30-DNC-3-2.uvt /freq DNC3-2 228910.489 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-DNC-3-2-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits N30-DNC-3-2-selfcal.fits from N30-DNC-3-2-selfcal.lmv-clean /overwrite
vector\fits N30-DNC-3-2-selfcal-res.fits from N30-DNC-3-2-selfcal.lmv-res /overwrite

!! 13CS 5-4
read uv N30-USB-line-selfcal
uv_extract /frequency 231218 /width 60 velo
write uv N30-13CS-5-4-selfcal

modify N30-13CS-5-4-selfcal.uvt /freq 13CS5-4 231220.6987 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-13CS-5-4-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N30-13CS-5-4-selfcal.fits from N30-13CS-5-4-selfcal.lmv-clean /overwrite
vector\fits N30-13CS-5-4-selfcal-res.fits from N30-13CS-5-4-selfcal.lmv-res /overwrite

!! N2D+ 3-2
read uv N30-USB-line-selfcal
uv_extract /frequency 231315 /width 60 velo
write uv N30-N2D+-3-2-selfcal

modify N30-N2D+-3-2-selfcal.uvt /freq N2D+ 231321.6650 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-N2D+-3-2-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N30-N2D+-3-2-selfcal.fits from N30-N2D+-3-2-selfcal.lmv-clean /overwrite
vector\fits N30-N2D+-3-2-selfcal-res.fits from N30-N2D+-3-2-selfcal.lmv-res /overwrite

!! CH2CHCN 12-11
read uv N30-USB-line-selfcal
uv_extract /frequency 232026.5 /width 60 velo
write uv N30-CH2CHCN-12-2-11-1-selfcal

modify N30-CH2CHCN-12-2-11-1-selfcal.uvt /freq CH2CHCN 232032.80290 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N30-CH2CHCN-12-2-11-1-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! # export .fits file
vector\fits N30-CH2CHCN-12-2-11-1-selfcal.fits from N30-CH2CHCN-12-2-11-1-selfcal.lmv-clean /overwrite
vector\fits N30-CH2CHCN-12-2-11-1-selfcal-res.fits from N30-CH2CHCN-12-2-11-1-selfcal.lmv-res /overwrite



