!! #########################################################################
!! Script for mapping
! uv table file name = w22be001-searchdisk-250kHz-USB-CygX-N63.uvt

! Read header of the uv table
header w22be001-searchdisk-250kHz-USB-CygX-N63.uvt

! Get observation setup and resolution info
let name w22be001-searchdisk-250kHz-USB-CygX-N63
go setup

! Plot uv coverage
let name w22be001-searchdisk-250kHz-USB-CygX-N63
go uvcov

! Get basic information of the observation
let name w22be001-searchdisk-250kHz-USB-CygX-N63
go uvstat header

!! #########################################################################
!! ###########################Basic information#############################
I-MOSAIC,  Already in NORMAL mode
 
Input file: Interferometer (15m)  w22be001-searchdisk-250kHz-USB-CygX-N63.uvt
 
   Single field observation (8000 visibilities)
 
   Observed rest frequency       231.5 GHz
   Half power primary beam       21.8 arcsec
   Phase center RA and Dec       20:40:05.393 41:32:13.020
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
I-UV_STAT,  Observed rest frequency         233.247396 GHz
I-UV_STAT,  Found         8000 Visibilities, **** channels
I-UV_STAT,  Baselines      43.4 -    1663.0 meters
I-UV_STAT,  Baselines      33.8 -    1293.9 kiloWavelength
I-UV_STAT,  Found telescope NOEMA from data
I-UV_STAT,  Half power primary beam               21.8 arcsec
I-UV_STAT,  Recommended Field of view / Largest Scale         15.9 x         15.9 "
I-UV_STAT,  Recommended Image size        15.4 x        15.4"
I-UV_STAT,  Recommended Map size 512 x 512
I-UV_STAT,  Recommended Pixel size    0.030 x    0.030 "
File :                                                               REAL*4
Size        Reference Pixel           Value                  Increment
     97540   9259.92382812500       231500.000000000      0.250000005572425
      8000   0.00000000000000       0.00000000000000       1.00000000000000
Blanking value and tolerance      1.23455997E+34   0.0000000
Source name         CYGX-N63
Map unit            Jy
Axis type           UV-DATA      RANDOM
Coordinate system   EQUATORIAL          Velocity    LSR
Right Ascension   20:40:05.39300        Declination       41:32:13.0200
Lii        0.000000000000000            Bii       0.000000000000000
Equinox            2000.0000
Projection type     AZIMUTHAL           Angle     0.000000000000000
Axis 0     A0     20:40:05.39300        Axis 0     D0     41:32:13.0200
Baselines              43.4    1663.0
Axis 1 Line Name                        Rest Frequency   231500.0000000000
Resolution in Velocity  -0.32375222     in Frequency         0.25000176
Offset in Velocity        6.5000000     Doppler Velocity      4.3984084
Beam                   21.8                0.00                 0.00
NO Noise level
NO Proper motion
Tel: NOEMA         05:54:28.50   44:38:02.0 Alt.   2560.0 Diam   15.0
UV Data    Channels:  32511, Stokes: 1 NONE        Visibilities:        8000
Column            1 (Size 1) contains U           
Column            2 (Size 1) contains V           
Column            4 (Size 1) contains DATE        
Column            5 (Size 1) contains TIME        
Column            6 (Size 1) contains IANT        
Column            7 (Size 1) contains JANT        
Column            3 (Size 1) contains SCAN        
Summary of observations
 32511 Channels,  1 Stokes,   Rest Frequency    233247.396 MHz
Has fine Doppler correction
   Dates      Visibilities     Minimun    & Maximum Baselines
                              (m)  (kWave)    (m)    (kWave)
 05-JAN-2023       3220      57.4    44.6    1663.0  1293.9
 23-JAN-2023         90     266.0   207.0    1328.6  1033.7
 12-FEB-2023       3460      55.8    43.4    1536.0  1195.1
 13-FEB-2023       1230      43.4    33.8    1107.4   861.6
  12 Antennas,  in range    1  12
   1   2   3   4   5   6   8   9  10  11   7  12
!! #########################################################################


!! ###########################################################################
!! ###########################################################################
!! ############################# Image Procedure #############################
!!
!! # For lower sideband
read uv w22be001-searchdisk-250kHz-LSB-CygX-N63.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv N63-LSB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name N63-LSB-comp
let uv_cell 7.5 0.5
let weight_mode robust

go uvmap

let niter 500
let fres 0.0125
go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-LSB-CygX-N63.uvt

uv_filter /frequency 221633.17 217985.17 217761.17 217537.17 213889.17 /width 10 velo 
write uv N63-LSB-filter

!! ###### Generate LSB continuum uv table #############
read uv N63-LSB-filter.uvt
uv_filter /zero /frequency 221635 220744 220403 219966 218451 218221 217112 215232 213889 /width 20 velo !! set 20 km/s channels around the frequency list to zero
write uv N63-LSB-linefree

read uv N63-LSB-linefree
uv_cont
write uv N63-LSB-cont


!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name N63-LSB-linefree
!!
!! Number of self-calibration loop 4
!! List of integration times 120 60 40 40
!! List of number of iterations 20 20 20 20
!!
!! transfer gain solution to 
!! make deeper clean for the continuum uv table
let name N63-LSB-cont-selfcal
let uv_cell 7.5 0.5
let map_cell 0.03
let map_size 1600
let weight_mode robust
input uvmap

go uvmap

let niter 1500
let fres 0.0125
input clean

go clean

vector\fits N63-LSB-cont-selfcal.fits from N63-LSB-cont-selfcal.lmv-clean /overwrite
vector\fits N63-LSB-cont-selfcal-res.fits from N63-LSB-cont-selfcal.lmv-res /overwrite


!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv N63-LSB-filter.uvt

uv_base 0 /frequency 221635 220744 220403 219966 218451 218221 217112 215232 213889 /width 20 velo !! set 20 km/s channels around the frequency list to zero

write uv N63-LSB-line

!! Extract line emissions
!! CH3OH 8(0,8)-7(1,6)
read uv N63-LSB-line-selfcal
uv_extract /frequency 220082 /width 60 velo
write uv N63-CH3OH-8-08-7-16-selfcal

modify N63-CH3OH-8-08-7-16-selfcal.uvt /freq CH3OH-87 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3OH-8-08-7-16-selfcal
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
vector\fits N63-CH3OH-8-08-7-16-selfcal.fits from N63-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits N63-CH3OH-8-08-7-16-selfcal-res.fits from N63-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite

!! CH3CN 12-11 K=4
read uv N63-LSB-line
uv_extract /frequency 220680 /width 40 velo
write uv N63-CH3CN-12-11-k-4

modify N63-CH3CN-12-11-k-4.uvt /freq CH3CN-k4 220679.2869 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3CN-12-11-k-4-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 500
go clean

!! # export .fits file
vector\fits N63-CH3CN-12-11-k-4-selfcal.fits from N63-CH3CN-12-11-k-4-selfcal.lmv-clean /overwrite
vector\fits N63-CH3CN-12-11-k-4-selfcal-res.fits from N63-CH3CN-12-11-k-4-selfcal.lmv-res /overwrite


!! CH3CN 12-11 K=3
read uv N63-LSB-line-selfcal
uv_extract /frequency 220713.2 /width 40 velo
write uv N63-CH3CN-12-11-k3-selfcal

modify N63-CH3CN-12-11-k3-selfcal.uvt /freq CH3CN-k3 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3CN-12-11-k3-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

input clean
let niter 1000
let fres 0.0125
go clean
!! # export .fits file
vector\fits N63-CH3CN-12-11-k3-selfcal.fits from N63-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits N63-CH3CN-12-11-k3-selfcal-res.fits from N63-CH3CN-12-11-k3-selfcal.lmv-res /overwrite


!! CH3CN 12-11
read uv N63-LSB-line-selfcal
uv_extract /frequency 220670 /width 300 velo
write uv N63-CH3CN-12-11-selfcal

modify N63-CH3CN-12-11-selfcal.uvt /freq CH3CN-k0-8 220747.2612 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3CN-12-11-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

input clean
let niter 500
let fres 0.0125
go clean

!! # export .fits file
vector\fits N63-CH3CN-12-11-selfcal.fits from N63-CH3CN-12-11-selfcal.lmv-clean /overwrite
vector\fits N63-CH3CN-12-11-selfcal-res.fits from N63-CH3CN-12-11-selfcal.lmv-res /overwrite

!! 13CO 2-1
read uv N63-LSB-line-selfcal
uv_extract /frequency 220402 /width 80 velo
write uv N63-13CO-2-1-selfcal

modify N63-13CO-2-1-selfcal.uvt /freq 13CO2-1 220398.6195 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N63-13CO-2-1-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N63-13CO-2-1-selfcal.fits from N63-13CO-2-1-selfcal.lmv-clean /overwrite
vector\fits N63-13CO-2-1-selfcal-res.fits from N63-13CO-2-1-selfcal.lmv-res /overwrite

!! C18O 2-1
read uv N63-LSB-line-selfcal
uv_extract /frequency 219560 /width 60 velo
write uv N63-C18O-2-1-selfcal

modify N63-C18O-2-1-selfcal.uvt /freq C18O2-1 219560.358 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N63-C18O-2-1-selfcal
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

!! # export .fits file
vector\fits N63-C18O-2-1-selfcal.fits from N63-C18O-2-1-selfcal.lmv-clean /overwrite
vector\fits N63-C18O-2-1-selfcal-res.fits from N63-C18O-2-1-selfcal.lmv-res /overwrite



!! Outflow red- and blue-lobe velocity range: blue 7.5~10 km/s red 

!! SiO 5-4
read uv N63-LSB-line-selfcal
uv_extract /frequency 217108.7 /width 120 velo
write uv N63-SiO-5-4-selfcal

modify N63-SiO-5-4-selfcal.uvt /freq SiO5-4 217104.919 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-SiO-5-4-selfcal
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
vector\fits N63-SiO-5-4-selfcal.fits from N63-SiO-5-4-selfcal.lmv-clean /overwrite
vector\fits N63-SiO-5-4-selfcal-res.fits from N63-SiO-5-4-selfcal.lmv-res /overwrite


!! H2CO 3-2
read uv N63-LSB-line
uv_extract /frequency 218222 /width 40 velo
write uv N63-H2CO-3-03-2-02

modify N63-H2CO-3-03-2-02.uvt /freq H2CO 218222.192 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-H2CO-3-03-2-02-selfcal
let map_cell 0.05
let map_size 600
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits N63-H2CO-3-03-2-02-selfcal.fits from N63-H2CO-3-03-2-02-selfcal.lmv-clean /overwrite
vector\fits N63-H2CO-3-03-2-02-selfcal-res.fits from N63-H2CO-3-03-2-02-selfcal.lmv-res /overwrite

!! H2CO 3-2 line total
read uv N63-LSB-line-selfcal
uv_extract /frequency 218450 /width 1000 velo
write uv N63-H2CO-3-2-selfcal

modify N63-H2CO-3-2-selfcal.uvt /freq H2CO-3-2 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-H2CO-3-2-selfcal
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
vector\fits N63-H2CO-3-2-selfcal.fits from N63-H2CO-3-2-selfcal.lmv-clean /overwrite
vector\fits N63-H2CO-3-2-selfcal-res.fits from N63-H2CO-3-2-selfcal.lmv-res /overwrite

!! CH3OCHO 17-16 E
read uv N63-LSB-line-selfcal
uv_extract /frequency 218284.7 /width 50 velo
write uv N63-CH3OCHO-17-3-14-16-3-13E-selfcal

modify N63-CH3OCHO-17-3-14-16-3-13E-selfcal.uvt /freq CH3OCHO 	218280.9 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3OCHO-17-3-14-16-3-13E-selfcal
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
vector\fits N63-CH3OCHO-17-3-14-16-3-13E-selfcal.fits from N63-CH3OCHO-17-3-14-16-3-13E-selfcal.lmv-clean /overwrite
vector\fits N63-CH3OCHO-17-3-14-16-3-13E-selfcal-res.fits from N63-CH3OCHO-17-3-14-16-3-13E-selfcal.lmv-res /overwrite

!! CH3OCHO 17-16 A
read uv N63-LSB-line-selfcal
uv_extract /frequency 218301.4 /width 50 velo
write uv N63-CH3OCHO-17-3-14-16-3-13A-selfcal

modify N63-CH3OCHO-17-3-14-16-3-13A-selfcal.uvt /freq CH3OCHO  218297.866 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3OCHO-17-3-14-16-3-13A-selfcal
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
vector\fits N63-CH3OCHO-17-3-14-16-3-13A-selfcal.fits from N63-CH3OCHO-17-3-14-16-3-13A-selfcal.lmv-clean /overwrite
vector\fits N63-CH3OCHO-17-3-14-16-3-13A-selfcal-res.fits from N63-CH3OCHO-17-3-14-16-3-13A-selfcal.lmv-res /overwrite

!! NH2CHO
read uv N63-LSB-line-selfcal
uv_extract /frequency 218453.7 /width 50 velo
write uv N63-NH2CHO-10-9-selfcal

modify N63-NH2CHO-10-9-selfcal.uvt /freq NH2CHO 218459.205 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-NH2CHO-10-9-selfcal
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
vector\fits N63-NH2CHO-10-9-selfcal.fits from N63-NH2CHO-10-9-selfcal.lmv-clean /overwrite
vector\fits N63-NH2CHO-10-9-selfcal-res.fits from N63-NH2CHO-10-9-selfcal.lmv-res /overwrite


!! CH3CH2CHO 38-38
read uv N63-LSB-line-selfcal
uv_extract /frequency 218678.5 /width 50 velo
write uv N63-CH3CH2CHO-38-9-38-7-selfcal

modify N63-CH3CH2CHO-38-9-38-7-selfcal.uvt /freq CH3CH2CHO 218684.432 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3CH2CHO-38-9-38-7-selfcal
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
vector\fits N63-CH3CH2CHO-38-9-38-7-selfcal.fits from N63-CH3CH2CHO-38-9-38-7-selfcal.lmv-clean /overwrite
vector\fits N63-CH3CH2CHO-38-9-38-7-selfcal-res.fits from N63-CH3CH2CHO-38-9-38-7-selfcal.lmv-res /overwrite


!! CH213CHCN 23-22
read uv N63-LSB-line-selfcal
uv_extract /frequency 218327.0 /width 50 velo
write uv N63-CH213CHCN-23-3-22-3-selfcal

modify N63-CH213CHCN-23-3-22-3-selfcal.uvt /freq CH213CHCN 218325.5366 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH213CHCN-23-3-22-3-selfcal
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
vector\fits N63-CH213CHCN-23-3-22-3-selfcal.fits from N63-CH213CHCN-23-3-22-3-selfcal.lmv-clean /overwrite
vector\fits N63-CH213CHCN-23-3-22-3-selfcal-res.fits from N63-CH213CHCN-23-3-22-3-selfcal.lmv-res /overwrite




!! CH3OH 8-08-7-16
read uv N63-LSB-line
uv_extract /frequency 220082 /width 40 velo
write uv N63-CH3OH-8-08-7-16

modify N63-CH3OH-8-08-7-16.uvt /freq CH3OH8-7 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3OH-8-08-7-16-selfcal
let map_cell 0.05
let map_size 600
let niter 500
go uvmap

go clean

!! # export .fits file

vector\fits N63-CH3OH-8-08-7-16-selfcal.fits from N63-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits N63-CH3OH-8-08-7-16-selfcal-res.fits from N63-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite

!! SO-6-5
read uv N63-LSB-line-selfcal
uv_extract /frequency 219950 /width 40 velo
write uv N63-SO-6-5-selfcal

modify N63-SO-6-5-selfcal.uvt /freq CH3OH8-7 219949.442 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-SO-6-5-selfcal
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

vector\fits N63-SO-6-5-selfcal.fits from N63-SO-6-5-selfcal.lmv-clean /overwrite
vector\fits N63-SO-6-5-selfcal-res.fits from N63-SO-6-5-selfcal.lmv-res /overwrite


!! DCN 3-2
read uv N63-LSB-line-selfcal
uv_extract /frequency 217241.70 /width 50 velo
write uv N63-DCN-3-2-selfcal

modify N63-DCN-3-2-selfcal.uvt /freq CH3OH8-7 217238.6307 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-DCN-3-2-selfcal
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

vector\fits N63-DCN-3-2-selfcal.fits from N63-DCN-3-2-selfcal.lmv-clean /overwrite
vector\fits N63-DCN-3-2-selfcal-res.fits from N63-DCN-3-2-selfcal.lmv-res /overwrite

!! HC3N
read uv N63-LSB-line-selfcal
uv_extract /frequency 218327.20 /width 50 velo
write uv N63-HC3N-24-23-selfcal

modify N63-HC3N-24-23-selfcal.uvt /freq HC3N 218324.723 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-HC3N-24-23-selfcal
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

vector\fits N63-HC3N-24-23-selfcal.fits from N63-HC3N-24-23-selfcal.lmv-clean /overwrite
vector\fits N63-HC3N-24-23-selfcal-res.fits from N63-HC3N-24-23-selfcal.lmv-res /overwrite

!! OCS 18-17
read uv N63-LSB-line-selfcal
uv_extract /frequency 218907.58 /width 50 velo
write uv N63-OCS-18-17-selfcal

modify N63-OCS-18-17-selfcal.uvt /freq OCS 218903.3555 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-OCS-18-17-selfcal
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

vector\fits N63-OCS-18-17-selfcal.fits from N63-OCS-18-17-selfcal.lmv-clean /overwrite
vector\fits N63-OCS-18-17-selfcal-res.fits from N63-OCS-18-17-selfcal.lmv-res /overwrite


#######################################################################################################
###########################################################################################################
!!
!! # For upper sideband
read uv w22be001-searchdisk-250kHz-USB-CygX-N63.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv N63-USB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name N63-USB-comp
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-USB-CygX-N63.uvt

uv_filter /frequency 229377.17 233025.17 233249.17 233473.17 237121.17 /width 10 velo 
write uv N63-USB-filter

!! ###### Generate USB continuum uv table #############
read uv N63-USB-filter.uvt
uv_filter /zero /frequency 230544 /width 100 velo !! set 100 km/s channels around the frequency list to zero
uv_filter /zero /frequency 237115 236013 229776 229376 /width 20 velo !! set 100 km/s channels around the frequency list to zero
write uv N63-USB-linefree

read uv N63-USB-linefree
uv_cont
write uv N63-USB-cont

!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!!
!! Number of self-calibration loop 4
!! List of integration times 120 60 40 40
!! List of number of iterations 20 20 20 20
!!
!! name N63-USB-linefree
!! transfer gain solution to N63-USB-cont
!! transfer gain solution to N63-USB-line
!! make deeper clean for the continuum uv table
let name N63-USB-cont-selfcal

let uv_cell 7.5 0.5
let map_cell 0.03
let map_size 1600
let weight_mode robust
input uvmap
go uvmap

let niter 1500
let fres 0.0125
input clean

go clean

vector\fits N63-USB-cont-selfcal.fits from N63-USB-cont-selfcal.lmv-clean /overwrite
vector\fits N63-USB-cont-selfcal-res.fits from N63-USB-cont-selfcal.lmv-res /overwrite

go uv_merge

let name N63-comb-cont-selfcal

let uv_cell 7.5 0.5
let map_cell 0.03
let map_size 1600
let weight_mode robust
input uvmap
go uvmap

let niter 2000
let fres 0.0125
input clean

go clean

vector\fits N63-comb-cont-selfcal.fits from N63-comb-cont-selfcal.lmv-clean /overwrite
vector\fits N63-comb-cont-selfcal-res.fits from N63-comb-cont-selfcal.lmv-res /overwrite

!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For USB band
read uv N63-USB-filter.uvt

uv_base 0 /frequency 230544 /width 100 velo !! set 100 km/s channels around the frequency list to zero
uv_base 0 /frequency 237115 236013 230544 229776 229376 /width 30 velo !! set 30 km/s channels around the frequency list to zero

write uv N63-USB-line

!! CO 2-1
read uv N63-USB-line-selfcal
uv_extract /frequency 230541.8 /width 120 velo
write uv N63-CO-2-1-selfcal

modify N63-CO-2-1-selfcal.uvt /freq CO2-1 230538.0 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N63-CO-2-1-selfcal
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
vector\fits N63-CO-2-1-selfcal.fits from N63-CO-2-1-selfcal.lmv-clean /overwrite
vector\fits N63-CO-2-1-selfcal-res.fits from N63-CO-2-1-selfcal.lmv-res /overwrite

!! CH3OH 8--1-7-0
read uv N63-USB-line
uv_extract /frequency 229780 /width 60 velo
write uv N63-CH3OH-8--1-7-0

modify N63-CH3OH-8--1-7-0.uvt /freq CH3OH8-7 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N63-CH3OH-8--1-7-0-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits N63-CH3OH-8--1-7-0-selfcal.fits from N63-CH3OH-8--1-7-0-selfcal.lmv-clean /overwrite
vector\fits N63-CH3OH-8--1-7-0-selfcal-res.fits from N63-CH3OH-8--1-7-0-selfcal.lmv-res /overwrite












