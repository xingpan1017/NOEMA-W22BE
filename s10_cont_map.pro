!! Script for mapping
! uv table file name = w22be001-searchdisk-250kHz-LSB-CygX-S10.uvt

! Read header of the uv table
header w22be001-searchdisk-250kHz-LSB-CygX-S10.uvt

! Get observation setup and resolution info
let name w22be001-searchdisk-250kHz-LSB-CygX-S10
go setup

! Plot uv coverage
let name w22be001-searchdisk-250kHz-LSB-CygX-S10
go uvcov

! Get basic information of the observation
let name w22be001-searchdisk-250kHz-LSB-CygX-S10
go uvstat header

!! #########################################################################
!! ###########################Basic information#############################
I-MOSAIC,  Already in NORMAL mode
 
Input file: Interferometer (15m)  w22be001-searchdisk-250kHz-LSB-CygX-S10.uvt
 
   Single field observation (8000 visibilities)
 
   Observed rest frequency       231.5 GHz
   Half power primary beam       21.8 arcsec
   Phase center RA and Dec       20:20:44.647 39:35:20.108
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
I-UV_STAT,  Observed rest frequency         217.761153 GHz
I-UV_STAT,  Found         8000 Visibilities, **** channels
I-UV_STAT,  Baselines      39.4 -    1663.3 meters
I-UV_STAT,  Baselines      28.6 -    1208.2 kiloWavelength
I-UV_STAT,  Found telescope NOEMA from data
I-UV_STAT,  Half power primary beam               21.8 arcsec
I-UV_STAT,  Recommended Field of view / Largest Scale         18.8 x         18.8 "
I-UV_STAT,  Recommended Image size        18.0 x        18.0"
I-UV_STAT,  Recommended Map size 600 x 600
I-UV_STAT,  Recommended Pixel size    0.030 x    0.030 "
File :                                                               REAL*4
Size        Reference Pixel           Value                  Increment
     97540   71211.9218750000       231500.000000000      0.249999995329417
      8000   0.00000000000000       0.00000000000000       1.00000000000000
Blanking value and tolerance      1.23455997E+34   0.0000000
Source name         CYGX-S10
Map unit            Jy
Axis type           UV-DATA      RANDOM
Coordinate system   EQUATORIAL          Velocity    LSR
Right Ascension   20:20:44.64700        Declination       39:35:20.1080
Lii        0.000000000000000            Bii       0.000000000000000
Equinox            2000.0000
Projection type     AZIMUTHAL           Angle     0.000000000000000
Axis 0     A0     20:20:44.64700        Axis 0     D0     39:35:20.1080
Baselines              39.4    1663.3
Axis 1 Line Name                        Rest Frequency   231500.0000000000
Resolution in Velocity  -0.32374975     in Frequency         0.24999985
Offset in Velocity        6.5000000     Doppler Velocity      6.6721387
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
 32511 Channels,  1 Stokes,   Rest Frequency    217761.153 MHz
Has fine Doppler correction
   Dates      Visibilities     Minimun    & Maximum Baselines
                              (m)  (kWave)    (m)    (kWave)
 05-JAN-2023       3220      53.4    38.8    1663.3  1208.2
 23-JAN-2023         90     271.0   196.9    1313.4   954.0
 12-FEB-2023       3460      55.0    40.0    1564.7  1136.6
 13-FEB-2023       1230      39.4    28.6    1004.2   729.4
  12 Antennas,  in range    1  12
   1   2   3   4   5   6   8   9  10  11   7  12
   
!! ########################################################################################################################################################################################
!! ###########################################################################
!! ############################# Image Procedure #############################
!!
!! # For lower sideband
read uv w22be001-searchdisk-250kHz-LSB-CygX-S10.uvt
uv_compress 20 !! Get a spectral resolution of 5 km/s to reduce data size
write uv S10-LSB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name S10-LSB-comp
let uv_cell 7.5 0.5
let map_size 600
let map_cell 0.03
let weight_mode robust
input uvmap

go uvmap

let niter 100
let fres 0.0125
input clean

go clean

vector\fits S10-LSB-comp.fits from S10-LSB-comp.lmv-clean /overwrite
!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-LSB-CygX-S10.uvt

uv_filter /frequency 221654 /width 150 velo
uv_filter /frequency 213884 217754 /width 50 velo

write uv S10-LSB-filter

!! ###### Generate LSB continuum uv table #############
read uv S10-LSB-filter.uvt

uv_cont
write uv S10-LSB-cont


!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name S10-LSB-linefree
!! transfer gain solution to 
!! Number of self-calibration loop 4
!! List of integration times 120 100 80 60
!! List of number of iterations 40 40 40 40
!! make deeper clean for the continuum uv table
let name S10-LSB-cont
let uv_cell 7.5 3.0
let map_cell 0.03
let map_size 800
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

vector\fits S10-LSB-cont-selfcal.fits from S10-LSB-cont-selfcal.lmv-clean /overwrite
vector\fits S10-LSB-cont-selfcal-res.fits from S10-LSB-cont-selfcal.lmv-res /overwrite


let name S10-comb-cont
let uv_cell 7.5 3.0
let map_cell 0.03
let map_size 800
let weight_mode robust
input uvmap

go uvmap

let niter 1500
let fres 0.0125
input clean

go clean

vector\fits S10-comb-cont.fits from S10-comb-cont.lmv-clean /overwrite
vector\fits S10-comb-cont-res.fits from S10-comb-cont.lmv-res /overwrite

!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv S10-LSB-filter.uvt

uv_base 0 /frequency 221654 221811 213890 217771 213711 /width 50 velo !! set 20 km/s channels around the frequency list to zero

write uv S10-LSB-line

!! Extract line emissions
!! CH3CN 12-11 K=6
read uv S10-LSB-line-selfcal
uv_extract /frequency 220580 /width 100 velo
write uv S10-CH3CN-12-11-k-6

modify S10-CH3CN-12-11-k-6.uvt /freq CH3CN-12-11-k-6 220594.42310 /specunit frequency !! unit MHz

!! CH3CN 12-11 K=4
read uv S10-LSB-line-selfcal
uv_extract /frequency 220674.53 /width 40 velo
write uv S10-CH3CN-12-11-k4-selfcal

modify S10-CH3CN-12-11-k4-selfcal.uvt /freq CH3CN-k4 220679.2869 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-CH3CN-12-11-k4-selfcal
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
vector\fits S10-CH3CN-12-11-k4-selfcal.fits from S10-CH3CN-12-11-k4-selfcal.lmv-clean /overwrite
vector\fits S10-CH3CN-12-11-k4-selfcal-res.fits from S10-CH3CN-12-11-k4-selfcal.lmv-res /overwrite

!! CH3CN 12-11 K=3
read uv S10-LSB-line-selfcal
uv_extract /frequency 220705 /width 50 velo
write uv S10-CH3CN-12-11-k3-selfcal

modify S10-CH3CN-12-11-k3-selfcal.uvt /freq CH3CN 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-CH3CN-12-11-k3-selfcal
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
vector\fits S10-CH3CN-12-11-k3-selfcal.fits from S10-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits S10-CH3CN-12-11-k3-selfcal-res.fits from S10-CH3CN-12-11-k3-selfcal.lmv-res /overwrite


!! CH3CN 12-11
read uv S10-LSB-line-selfcal
uv_extract /frequency 220670 /width 300 velo
write uv S10-CH3CN-12-11-selfcal

modify S10-CH3CN-12-11-selfcal.uvt /freq CH3CN-k0-8 220747.2612 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-CH3CN-12-11-selfcal
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
vector\fits S10-CH3CN-12-11-selfcal.fits from S10-CH3CN-12-11-selfcal.lmv-clean /overwrite
vector\fits S10-CH3CN-12-11-selfcal-res.fits from S10-CH3CN-12-11-selfcal.lmv-res /overwrite


!! CH3CN 12-11 K=3
read uv S10-LSB-line
uv_extract /frequency 220712 /width 40 velo
write uv S10-CH3CN-12-11-k3

modify S10-CH3CN-12-11-k3.uvt /freq CH3CN-k3 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-CH3CN-12-11-k3-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits S10-CH3CN-12-11-k3-selfcal.fits from S10-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits S10-CH3CN-12-11-k3-selfcal-res.fits from S10-CH3CN-12-11-k3-selfcal.lmv-res /overwrite


!! 13CO 2-1
read uv S10-LSB-line
uv_extract /frequency 220402 /width 60 velo
write uv S10-13CO-2-1

modify S10-13CO-2-1.uvt /freq 13CO2-1 220398.6195 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-13CO-2-1-selfcal
let map_cell 0.05
let map_size 800
!!go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits S10-13CO-2-1-selfcal.fits from S10-13CO-2-1-selfcal.lmv-clean /overwrite
vector\fits S10-13CO-2-1-selfcal-res.fits from S10-13CO-2-1-selfcal.lmv-res /overwrite

!! C18O 2-1
read uv S10-LSB-line
uv_extract /frequency 219558 /width 60 velo
write uv S10-C18O-2-1

modify S10-C18O-2-1.uvt /freq C18O2-1 219560.358 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-C18O-2-1-selfcal
let map_cell 0.05
let map_size 800
!!go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits S10-C18O-2-1-selfcal.fits from S10-C18O-2-1-selfcal.lmv-clean /overwrite
vector\fits S10-C18O-2-1-selfcal-res.fits from S10-C18O-2-1-selfcal.lmv-res /overwrite


!! DCN 3-2
read uv S10-LSB-line
uv_extract /frequency 217239.07 /width 50 velo
write uv S10-DCN-3-2

modify S10-DCN-3-2.uvt /freq DCN 217238.6307 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-DCN-3-2
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
vector\fits S10-DCN-3-2.fits from S10-DCN-3-2.lmv-clean /overwrite
vector\fits S10-DCN-3-2-res.fits from S10-DCN-3-2.lmv-res /overwrite



!! HC3N 24-23
read uv S10-LSB-line
uv_extract /frequency 219170.59 /width 40 velo
write uv S10-HC3N-24-23

modify S10-HC3N-24-23.uvt /freq HC3N24-23 219173.7567 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-HC3N-24-23-selfcal
let map_cell 0.05
let map_size 800
!!go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits S10-HC3N-24-23-selfcal.fits from S10-HC3N-24-23-selfcal.lmv-clean /overwrite
vector\fits S10-HC3N-24-23-selfcal-res.fits from S10-HC3N-24-23-selfcal.lmv-res /overwrite


!! Outflow red- and blue-lobe velocity range: blue 7.5~10 km/s red 

!! SiO 5-4
read uv S10-LSB-line-selfcal
uv_extract /frequency 217099.27 /width 120 velo
write uv S10-SiO-5-4-selfcal

modify S10-SiO-5-4-selfcal.uvt /freq SiO 217104.919 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-SiO-5-4-selfcal
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
vector\fits S10-SiO-5-4-selfcal.fits from S10-SiO-5-4-selfcal.lmv-clean /overwrite
vector\fits S10-SiO-5-4-selfcal-res.fits from S10-SiO-5-4-selfcal.lmv-res /overwrite


!! H2CO 3-2
read uv S10-LSB-line
uv_extract /frequency 218222 /width 40 velo
write uv S10-H2CO-3-03-2-02

modify S10-H2CO-3-03-2-02.uvt /freq H2CO 218222.192 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-H2CO-3-03-2-02-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits S10-H2CO-3-03-2-02-selfcal.fits from S10-H2CO-3-03-2-02-selfcal.lmv-clean /overwrite
vector\fits S10-H2CO-3-03-2-02-selfcal-res.fits from S10-H2CO-3-03-2-02-selfcal.lmv-res /overwrite

!! H2CO 3-2
read uv S10-LSB-line
uv_extract /frequency 218755.95 /width 40 velo
write uv S10-H2CO-3-21-2-20

modify S10-H2CO-3-21-2-20.uvt /freq H2CO 218760.066 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-H2CO-3-21-2-20-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits S10-H2CO-3-21-2-20-selfcal.fits from S10-H2CO-3-21-2-20-selfcal.lmv-clean /overwrite
vector\fits S10-H2CO-3-21-2-20-selfcal-res.fits from S10-H2CO-3-21-2-20-selfcal.lmv-res /overwrite

!! H2CO 3-2
read uv S10-LSB-line
uv_extract /frequency 218471 /width 40 velo
write uv S10-H2CO-3-22-2-21

modify S10-H2CO-3-22-2-21.uvt /freq H2CO 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-H2CO-3-22-2-21-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits S10-H2CO-3-22-2-21-selfcal.fits from S10-H2CO-3-22-2-21-selfcal.lmv-clean /overwrite
vector\fits S10-H2CO-3-22-2-21-selfcal-res.fits from S10-H2CO-3-22-2-21-selfcal.lmv-res /overwrite


!! H2CO 3-2 line total
read uv S10-LSB-line-selfcal
uv_extract /frequency 218450 /width 1000 velo
write uv S10-H2CO-3-2-selfcal

modify S10-H2CO-3-2-selfcal.uvt /freq H2CO-3-2 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-H2CO-3-2-selfcal
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
vector\fits S10-H2CO-3-2-selfcal.fits from S10-H2CO-3-2-selfcal.lmv-clean /overwrite
vector\fits S10-H2CO-3-2-selfcal-res.fits from S10-H2CO-3-2-selfcal.lmv-res /overwrite

!! CH213CHCN 23-22
read uv S10-LSB-line-selfcal
uv_extract /frequency 218327.0 /width 50 velo
write uv S10-CH213CHCN-23-3-22-3-selfcal

modify S10-CH213CHCN-23-3-22-3-selfcal.uvt /freq CH213CHCN 218325.5366 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-CH213CHCN-23-3-22-3-selfcal
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
vector\fits S10-CH213CHCN-23-3-22-3-selfcal.fits from S10-CH213CHCN-23-3-22-3-selfcal.lmv-clean /overwrite
vector\fits S10-CH213CHCN-23-3-22-3-selfcal-res.fits from S10-CH213CHCN-23-3-22-3-selfcal.lmv-res /overwrite



!! CH3OH 8-08-7-16
read uv S10-LSB-line
uv_extract /frequency 220080 /width 40 velo
write uv S10-CH3OH-8-08-7-16

modify S10-CH3OH-8-08-7-16.uvt /freq CH3OH8-7 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-CH3OH-8-08-7-16-selfcal
let map_cell 0.05
let map_size 800
let niter 500
!!go uvmap

go clean

!! # export .fits file

vector\fits S10-CH3OH-8-08-7-16-selfcal.fits from S10-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits S10-CH3OH-8-08-7-16-selfcal-res.fits from S10-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite

!! SO-6-5
read uv S10-LSB-line
uv_extract /frequency 219950 /width 80 velo

$rm -rf S10-SO-6-5
write uv S10-SO-6-5

modify S10-SO-6-5.uvt /freq SO6-5 219949.442 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-SO-6-5-selfcal
let map_cell 0.05
let map_size 800
let niter 500
go uvmap

go clean

!! # export .fits file

vector\fits S10-SO-6-5-selfcal.fits from S10-SO-6-5-selfcal.lmv-clean /overwrite
vector\fits S10-SO-6-5-selfcal-res.fits from S10-SO-6-5-selfcal.lmv-res /overwrite

!! DCO+ 3-2
read uv S10-LSB-line
uv_extract /frequency 216110 /width 40 velo
write uv S10-DCO+-3-2

modify S10-DCO+-3-2.uvt /freq DCO+ 216112.58 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-DCO+-3-2-selfcal
let map_cell 0.05
let map_size 800
!!go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits S10-DCO+-3-2-selfcal.fits from S10-DCO+-3-2-selfcal.lmv-clean /overwrite
vector\fits S10-DCO+-3-2-selfcal-res.fits from S10-DCO+-3-2-selfcal.lmv-res /overwrite



#######################################################################################################
###########################################################################################################
!!
!! # For upper sideband
read uv w22be001-searchdisk-250kHz-USB-CygX-S10.uvt
uv_compress 20 !! Get a spectral resolution of 5 km/s to reduce data size
write uv S10-USB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name S10-USB-comp
let uv_cell 7.5 0.5
let map_size 600
let map_cell 0.03
let weight_mode robust
input uvmap

go uvmap

let niter 100
let fres 0.0125
input clean

go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-USB-CygX-S10.uvt

uv_filter /frequency 237117 229365 /width 100 velo 
write uv S10-USB-filter

!! ###### Generate USB continuum uv table #############
read uv S10-USB-filter.uvt

uv_filter /frequency 237117 230538 229365 /width 100 velo !! set 20 km/s channels around the frequency list to zero

write uv S10-USB-linefree

read uv S10-USB-linefree
uv_cont
write uv S10-USB-cont

!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name S10-USB-linefree
!! transfer gain solution to S10-USB-cont
!! make deeper clean for the continuum uv table
let name S10-USB-cont
let map_cell 0.03
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 2000
let fres 0.0125
input clean

go clean

vector\fits S10-USB-cont-selfcal.fits from S10-USB-cont-selfcal.lmv-clean /overwrite
vector\fits S10-USB-cont-selfcal-res.fits from S10-USB-cont-selfcal.lmv-res /overwrite

vector\fits S10-comb-cont.fits from S10-comb-cont.lmv-clean /overwrite
vector\fits S10-comb-cont-res.fits from S10-comb-cont.lmv-res /overwrite

!! #######################################################################################
!! ## Merge both sidebands and generate the continuum map
!! #######################################################################################


!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv S10-USB-filter.uvt

uv_base 0 /frequency 230541  /width 160 velo !! set 80 km/s channels around the frequency list to zero
write uv S10-USB-line

!! CO 2-1
read uv S10-USB-line
uv_extract /frequency 230547 /width 120 velo
write uv S10-CO-2-1

modify S10-CO-2-1.uvt /freq CO 230538.0 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-CO-2-1
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
vector\fits S10-CO-2-1.fits from S10-CO-2-1.lmv-clean /overwrite
vector\fits S10-CO-2-1-res.fits from S10-CO-2-1.lmv-res /overwrite

!! CH3OH 8--1-7-0
read uv S10-USB-line
uv_extract /frequency 229755 /width 40 velo
write uv S10-CH3OH-8--1-7-0

modify S10-CH3OH-8--1-7-0.uvt /freq CH3OH8-7 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-CH3OH-8--1-7-0-selfcal
let map_cell 0.05
let map_size 800
!! go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits S10-CH3OH-8--1-7-0-selfcal.fits from S10-CH3OH-8--1-7-0-selfcal.lmv-clean /overwrite
vector\fits S10-CH3OH-8--1-7-0-selfcal-res.fits from S10-CH3OH-8--1-7-0-selfcal.lmv-res /overwrite

!! D2CO 4-3
read uv S10-USB-line
uv_extract /frequency 229755 /width 60 velo
write uv S10-D2CO-4-04-3-03

modify S10-D2CO-4-04-3-03.uvt /freq D2CO4-3 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-D2CO-4-04-3-03-selfcal
let map_cell 0.05
let map_size 800
!!go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits S10-D2CO-4-04-3-03-selfcal.fits from S10-D2CO-4-04-3-03-selfcal.lmv-clean /overwrite
vector\fits S10-D2CO-4-04-3-03-selfcal-res.fits from S10-D2CO-4-04-3-03-selfcal.lmv-res /overwrite

!! DNC 3-2
read uv S10-USB-line
uv_extract /frequency 228907 /width 40 velo
write uv S10-DNC-3-2

modify S10-DNC-3-2.uvt /freq DNC3-2 228910.489 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-DNC-3-2-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits S10-DNC-3-2-selfcal.fits from S10-DNC-3-2-selfcal.lmv-clean /overwrite
vector\fits S10-DNC-3-2-selfcal-res.fits from S10-DNC-3-2-selfcal.lmv-res /overwrite

!! 13CS 5-4
read uv S10-USB-line
uv_extract /frequency 231218 /width 40 velo
write uv S10-13CS-5-4

modify S10-13CS-5-4.uvt /freq 13CS5-4 231220.6987 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-13CS-5-4-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits S10-13CS-5-4-selfcal.fits from S10-13CS-5-4-selfcal.lmv-clean /overwrite
vector\fits S10-13CS-5-4-selfcal-res.fits from S10-13CS-5-4-selfcal.lmv-res /overwrite
