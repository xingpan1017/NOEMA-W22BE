!! Script for mapping
! uv table file name = w22be001-searchdisk-250kHz-LSB-CygX-NW14.uvt

! Read header of the uv table
header w22be001-searchdisk-250kHz-LSB-CygX-NW14.uvt

! Get observation setup and resolution info
let name w22be001-searchdisk-250kHz-LSB-CygX-NW14
go setup

! Plot uv coverage
let name w22be001-searchdisk-250kHz-LSB-CygX-NW14
go uvcov

! Get basic information of the observation
let name w22be001-searchdisk-250kHz-LSB-CygX-NW14
go uvstat header

!! #########################################################################
!! ###########################Basic information#############################
I-MOSAIC,  Already in NORMAL mode
Input file: Interferometer (15m)  w22be001-searchdisk-250kHz-LSB-CygX-NW14.uvt
 
   Single field observation (8630 visibilities)
 
   Observed rest frequency       231.5 GHz
   Half power primary beam       21.8 arcsec
   Phase center RA and Dec       20:24:31.680 42:04:22.508
   Field of view / Largest Scale 21.8 x 21.8 arcsec
 
                                Recommended        Used
   Spectral axis size              32511            32511 channels
   Map size                      2048 x 2048       2048 x 2048 pixels
   Map cell                     0.032 x 0.032     0.032 x 0.032 arcsec
   Image size                  65.9 x 65.9   65.9 x 65.9 arcsec
   Cube size                        507.9            507.9 GiB
   WARNING! Desired cube size exceeds 25% of the total RAM size
 
   Still to be imaged
   Still to be cleaned
I-UV_STAT,  Observed rest frequency         217.760907 GHz
I-UV_STAT,  Found         8630 Visibilities, **** channels
I-UV_STAT,  Baselines      42.9 -    1657.0 meters
I-UV_STAT,  Baselines      31.1 -    1203.6 kiloWavelength
I-UV_STAT,  Found telescope NOEMA from data
I-UV_STAT,  Half power primary beam               21.8 arcsec
I-UV_STAT,  Recommended Field of view / Largest Scale         17.2 x         17.2 "
I-UV_STAT,  Recommended Image size        17.3 x        17.3"
I-UV_STAT,  Recommended Map size 576 x 576
I-UV_STAT,  Recommended Pixel size    0.030 x    0.030 "
File :                                                               REAL*4
Size        Reference Pixel           Value                  Increment
     97540   71211.9218750000       231500.000000000      0.249999997522038
      8630   0.00000000000000       0.00000000000000       1.00000000000000
Blanking value and tolerance      1.23455997E+34   0.0000000
Source name         CYGX-NW14
Map unit            Jy
Axis type           UV-DATA      RANDOM
Coordinate system   EQUATORIAL          Velocity    LSR
Right Ascension   20:24:31.68000        Declination       42:04:22.5080
Lii        0.000000000000000            Bii       0.000000000000000
Equinox            2000.0000
Projection type     AZIMUTHAL           Angle     0.000000000000000
Axis 0     A0     20:24:31.68000        Axis 0     D0     42:04:22.5080
Baselines              42.9    1657.0
Axis 1 Line Name                        Rest Frequency   231500.0000000000
Resolution in Velocity  -0.32375011     in Frequency         0.25000012
Offset in Velocity        6.5000000     Doppler Velocity      6.3534585
Beam                   21.8                0.00                 0.00
NO Noise level
NO Proper motion
Tel: NOEMA         05:54:28.50   44:38:02.0 Alt.   2560.0 Diam   15.0
UV Data    Channels:  32511, Stokes: 1 NONE        Visibilities:        8630
Column            1 (Size 1) contains U           
Column            2 (Size 1) contains V           
Column            4 (Size 1) contains DATE        
Column            5 (Size 1) contains TIME        
Column            6 (Size 1) contains IANT        
Column            7 (Size 1) contains JANT        
Column            3 (Size 1) contains SCAN        
Summary of observations
 32511 Channels,  1 Stokes,   Rest Frequency    217760.907 MHz
Has fine Doppler correction
   Dates      Visibilities     Minimun    & Maximum Baselines
                              (m)  (kWave)    (m)    (kWave)
 05-JAN-2023       3190      56.2    40.8    1607.4  1167.6
 23-JAN-2023         90     269.6   195.8    1322.0   960.3
 12-FEB-2023       4120      56.5    41.0    1657.0  1203.6
 13-FEB-2023       1230      42.9    31.1    1084.8   788.0
  12 Antennas,  in range    1  12
   1   2   3   4   5   6   8   9  10  11   7  12



!! ########################################################################################################################################################################################
!! ###########################################################################
!! ############################# Image Procedure #############################
!!
!! # For lower sideband
read uv w22be001-searchdisk-250kHz-LSB-CygX-NW14.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv NW14-LSB-comp

!! # Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name NW14-LSB-comp
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean
!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-LSB-CygX-NW14.uvt

uv_filter /frequency 221634 213887 /width 50 velo 
write uv NW14-LSB-filter

!! ###### Generate LSB continuum uv table #############
read uv NW14-LSB-filter.uvt
uv_filter /zero /frequency 221628 221387 221268 220736 220594 220405 220086 219932 219814 219731 218993 218908 218765 218471 218327 218235 217982 217890 217795 216942 215310 215234 214688 214365 213883 /width 100 velo !! set 20 km/s channels around the frequency list to zero
write uv NW14-LSB-linefree

read uv NW14-LSB-linefree
uv_cont
write uv NW14-LSB-cont


!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name NW14-LSB-linefree
!! transfer gain solution to 
!! Number of self-calibration loop 4
!! List of integration times 120 100 80 60
!! List of number of iterations 20 20 20 20
!! make deeper clean for the continuum uv table
let name NW14-LSB-cont-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

vector\fits NW14-LSB-cont-selfcal.fits from NW14-LSB-cont-selfcal.lmv-clean /overwrite
vector\fits NW14-LSB-cont-selfcal-res.fits from NW14-LSB-cont-selfcal.lmv-res /overwrite

!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv NW14-LSB-filter.uvt

uv_base 0 /frequency 221628 221387 221268 220736 220594 220405 220086 219932 219814 219731 218993 218908 218765 218471 218327 218235 217982 217890 217795 216942 215310 215234 214688 214365 213883 /width 100 velo !! set 20 km/s channels around the frequency list to zero

write uv NW14-LSB-line

!! Extract line emissions
!! CH3CN 12-11 K=6
read uv NW14-LSB-line-selfcal
uv_extract /frequency 220580 /width 100 velo
write uv NW14-CH3CN-12-11-k-6

modify NW14-CH3CN-12-11-k-6.uvt /freq CH3CN-12-11-k-6 220594.42310 /specunit frequency !! unit MHz

!! CH3CN 12-11 K=4
read uv NW14-LSB-line-selfcal
uv_extract /frequency 220674.53 /width 40 velo
write uv NW14-CH3CN-12-11-k4-selfcal

modify NW14-CH3CN-12-11-k4-selfcal.uvt /freq CH3CN-k4 220679.2869 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-CH3CN-12-11-k4-selfcal
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
vector\fits NW14-CH3CN-12-11-k4-selfcal.fits from NW14-CH3CN-12-11-k4-selfcal.lmv-clean /overwrite
vector\fits NW14-CH3CN-12-11-k4-selfcal-res.fits from NW14-CH3CN-12-11-k4-selfcal.lmv-res /overwrite

!! CH3CN 12-11 K=3
read uv NW14-LSB-line-selfcal
uv_extract /frequency 220705 /width 50 velo
write uv NW14-CH3CN-12-11-k3-selfcal

modify NW14-CH3CN-12-11-k3-selfcal.uvt /freq CH3CN 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-CH3CN-12-11-k3-selfcal
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
vector\fits NW14-CH3CN-12-11-k3-selfcal.fits from NW14-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits NW14-CH3CN-12-11-k3-selfcal-res.fits from NW14-CH3CN-12-11-k3-selfcal.lmv-res /overwrite


!! CH3CN 12-11
read uv NW14-LSB-line-selfcal
uv_extract /frequency 220670 /width 300 velo
write uv NW14-CH3CN-12-11-selfcal

modify NW14-CH3CN-12-11-selfcal.uvt /freq CH3CN-k0-8 220747.2612 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-CH3CN-12-11-selfcal
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
vector\fits NW14-CH3CN-12-11-selfcal.fits from NW14-CH3CN-12-11-selfcal.lmv-clean /overwrite
vector\fits NW14-CH3CN-12-11-selfcal-res.fits from NW14-CH3CN-12-11-selfcal.lmv-res /overwrite


!! SiS 12-11 
read uv NW14-LSB-line-selfcal
uv_extract /frequency 217818 /width 50 velo
write uv NW14-SiS-12-11-selfcal

modify NW14-SiS-12-11-selfcal.uvt /freq SiS 217818 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-SiS-12-11-selfcal
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
vector\fits NW14-SiS-12-11-selfcal.fits from NW14-SiS-12-11-selfcal.lmv-clean /overwrite
vector\fits NW14-SiS-12-11-selfcal-res.fits from NW14-SiS-12-11-selfcal.lmv-res /overwrite


!! 13CO 2-1
read uv NW14-LSB-line
uv_extract /frequency 220402 /width 60 velo
write uv NW14-13CO-2-1

modify NW14-13CO-2-1.uvt /freq 13CO2-1 220398.6195 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-13CO-2-1-selfcal
let map_cell 0.05
let map_size 800
!!go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits NW14-13CO-2-1-selfcal.fits from NW14-13CO-2-1-selfcal.lmv-clean /overwrite
vector\fits NW14-13CO-2-1-selfcal-res.fits from NW14-13CO-2-1-selfcal.lmv-res /overwrite

!! C18O 2-1
read uv NW14-LSB-line
uv_extract /frequency 219558 /width 60 velo
write uv NW14-C18O-2-1

modify NW14-C18O-2-1.uvt /freq C18O2-1 219560.358 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-C18O-2-1-selfcal
let map_cell 0.05
let map_size 800
!!go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits NW14-C18O-2-1-selfcal.fits from NW14-C18O-2-1-selfcal.lmv-clean /overwrite
vector\fits NW14-C18O-2-1-selfcal-res.fits from NW14-C18O-2-1-selfcal.lmv-res /overwrite


!! DCN 3-2
read uv NW14-LSB-line
uv_extract /frequency 217234.14 /width 50 velo
write uv NW14-DCN-3-2-selfcal

modify NW14-DCN-3-2-selfcal.uvt /freq DCN3-2 217238.6307 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-DCN-3-2-selfcal
let map_size 800
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean!! # export .fits file
vector\fits NW14-DCN-3-2-selfcal.fits from NW14-DCN-3-2-selfcal.lmv-clean /overwrite
vector\fits NW14-DCN-3-2-selfcal-res.fits from NW14-DCN-3-2-selfcal.lmv-res /overwrite



!! HC3N 24-23
read uv NW14-LSB-line
uv_extract /frequency 219170.59 /width 40 velo
write uv NW14-HC3N-24-23

modify NW14-HC3N-24-23.uvt /freq HC3N24-23 219173.7567 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-HC3N-24-23-selfcal
let map_cell 0.05
let map_size 800
!!go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits NW14-HC3N-24-23-selfcal.fits from NW14-HC3N-24-23-selfcal.lmv-clean /overwrite
vector\fits NW14-HC3N-24-23-selfcal-res.fits from NW14-HC3N-24-23-selfcal.lmv-res /overwrite


!! Outflow red- and blue-lobe velocity range: blue 7.5~10 km/s red 

!! SiO 5-4
read uv NW14-LSB-line-selfcal
uv_extract /frequency 217099.27 /width 120 velo
write uv NW14-SiO-5-4-selfcal

modify NW14-SiO-5-4-selfcal.uvt /freq SiO 217104.919 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-SiO-5-4-selfcal
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
vector\fits NW14-SiO-5-4-selfcal.fits from NW14-SiO-5-4-selfcal.lmv-clean /overwrite
vector\fits NW14-SiO-5-4-selfcal-res.fits from NW14-SiO-5-4-selfcal.lmv-res /overwrite


!! H2CO 3-2
read uv NW14-LSB-line
uv_extract /frequency 218222 /width 40 velo
write uv NW14-H2CO-3-03-2-02

modify NW14-H2CO-3-03-2-02.uvt /freq H2CO 218222.192 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-H2CO-3-03-2-02-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits NW14-H2CO-3-03-2-02-selfcal.fits from NW14-H2CO-3-03-2-02-selfcal.lmv-clean /overwrite
vector\fits NW14-H2CO-3-03-2-02-selfcal-res.fits from NW14-H2CO-3-03-2-02-selfcal.lmv-res /overwrite

!! H2CO 3-2
read uv NW14-LSB-line
uv_extract /frequency 218755.95 /width 40 velo
write uv NW14-H2CO-3-21-2-20

modify NW14-H2CO-3-21-2-20.uvt /freq H2CO 218760.066 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-H2CO-3-21-2-20-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits NW14-H2CO-3-21-2-20-selfcal.fits from NW14-H2CO-3-21-2-20-selfcal.lmv-clean /overwrite
vector\fits NW14-H2CO-3-21-2-20-selfcal-res.fits from NW14-H2CO-3-21-2-20-selfcal.lmv-res /overwrite

!! H2CO 3-2
read uv NW14-LSB-line
uv_extract /frequency 218471 /width 40 velo
write uv NW14-H2CO-3-22-2-21

modify NW14-H2CO-3-22-2-21.uvt /freq H2CO 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-H2CO-3-22-2-21-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file
vector\fits NW14-H2CO-3-22-2-21-selfcal.fits from NW14-H2CO-3-22-2-21-selfcal.lmv-clean /overwrite
vector\fits NW14-H2CO-3-22-2-21-selfcal-res.fits from NW14-H2CO-3-22-2-21-selfcal.lmv-res /overwrite


!! H2CO 3-2 line total
read uv NW14-LSB-line-selfcal
uv_extract /frequency 218450 /width 1000 velo
write uv NW14-H2CO-3-2-selfcal

modify NW14-H2CO-3-2-selfcal.uvt /freq H2CO-3-2 218475.632 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-H2CO-3-2-selfcal
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
vector\fits NW14-H2CO-3-2-selfcal.fits from NW14-H2CO-3-2-selfcal.lmv-clean /overwrite
vector\fits NW14-H2CO-3-2-selfcal-res.fits from NW14-H2CO-3-2-selfcal.lmv-res /overwrite

!! CH213CHCN 23-22
read uv NW14-LSB-line-selfcal
uv_extract /frequency 218327.0 /width 50 velo
write uv NW14-CH213CHCN-23-3-22-3-selfcal

modify NW14-CH213CHCN-23-3-22-3-selfcal.uvt /freq CH213CHCN 218325.5366 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-CH213CHCN-23-3-22-3-selfcal
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
vector\fits NW14-CH213CHCN-23-3-22-3-selfcal.fits from NW14-CH213CHCN-23-3-22-3-selfcal.lmv-clean /overwrite
vector\fits NW14-CH213CHCN-23-3-22-3-selfcal-res.fits from NW14-CH213CHCN-23-3-22-3-selfcal.lmv-res /overwrite



!! CH3OH 8-08-7-16
read uv NW14-LSB-line
uv_extract /frequency 220080 /width 40 velo
write uv NW14-CH3OH-8-08-7-16

modify NW14-CH3OH-8-08-7-16.uvt /freq CH3OH8-7 220078.561 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-CH3OH-8-08-7-16-selfcal
let map_cell 0.05
let map_size 800
let niter 500
!!go uvmap

go clean

!! # export .fits file

vector\fits NW14-CH3OH-8-08-7-16-selfcal.fits from NW14-CH3OH-8-08-7-16-selfcal.lmv-clean /overwrite
vector\fits NW14-CH3OH-8-08-7-16-selfcal-res.fits from NW14-CH3OH-8-08-7-16-selfcal.lmv-res /overwrite

!! SO-6-5
read uv NW14-LSB-line
uv_extract /frequency 219950 /width 80 velo

$rm -rf NW14-SO-6-5
write uv NW14-SO-6-5

modify NW14-SO-6-5.uvt /freq SO6-5 219949.442 !! unit MHz

!! # Apply selfcal and make deeper clean
let name NW14-SO-6-5-selfcal
let map_cell 0.05
let map_size 800
let niter 500
go uvmap

go clean

!! # export .fits file

vector\fits NW14-SO-6-5-selfcal.fits from NW14-SO-6-5-selfcal.lmv-clean /overwrite
vector\fits NW14-SO-6-5-selfcal-res.fits from NW14-SO-6-5-selfcal.lmv-res /overwrite

!! DCO+ 3-2
read uv NW14-LSB-line-selfcal
uv_extract /frequency 216110 /width 40 velo
write uv NW14-DCO+-3-2-selfcal

modify NW14-DCO+-3-2-selfcal.uvt /freq DCO+ 216112.58 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-DCO+-3-2-selfcal
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
vector\fits NW14-DCO+-3-2-selfcal.fits from NW14-DCO+-3-2-selfcal.lmv-clean /overwrite
vector\fits NW14-DCO+-3-2-selfcal-res.fits from NW14-DCO+-3-2-selfcal.lmv-res /overwrite



#######################################################################################################
###########################################################################################################
!!
!! # For upper sideband
read uv w22be001-searchdisk-250kHz-USB-CygX-NW14.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv NW14-USB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name NW14-USB-comp
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 500
let fres 0.0125
input clean

go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-USB-CygX-NW14.uvt

uv_filter /frequency 237121 229365 /width 50 velo 
write uv NW14-USB-filter

!! ###### Generate USB continuum uv table #############
read uv NW14-USB-filter.uvt

uv_filter /zero /frequency 230547  /width 80 velo !! set 80 km/s channels around the frequency list to zero
uv_filter /zero /frequency 237120 236932 236727 236529 236363 236220 235999 235371 235150 234673 232418 231969 231271 231055 230376 229864 229751 229590 229380 /width 20 velo 
!! set 20 km/s channels around the frequency list to zero
write uv NW14-USB-linefree

read uv NW14-USB-linefree
uv_cont
write uv NW14-USB-cont

!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name NW14-USB-linefree
!! transfer gain solution to NW14-USB-cont
!! make deeper clean for the continuum uv table
let name NW14-USB-cont-selfcal
let uv_cell 7.5 0.5
let weight_mode robust
input uvmap

go uvmap

let niter 1000
let fres 0.0125
input clean

go clean

vector\fits NW14-USB-cont-selfcal.fits from NW14-USB-cont-selfcal.lmv-clean /overwrite
vector\fits NW14-USB-cont-selfcal-res.fits from NW14-USB-cont-selfcal.lmv-res /overwrite

vector\fits NW14-comb-cont-selfcal.fits from NW14-comb-cont-selfcal.lmv-clean /overwrite
vector\fits NW14-comb-cont-selfcal-res.fits from NW14-comb-cont-selfcal.lmv-res /overwrite

!! #######################################################################################
!! ## Merge both sidebands and generate the continuum map
!! #######################################################################################


!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv NW14-USB-filter.uvt

uv_base 0 /frequency 230547  /width 80 velo !! set 80 km/s channels around the frequency list to zero
uv_base 0 /frequency 237120 236932 236727 236529 236363 236220 235999 235371 235150 234673 232418 231969 231271 231055 230376 229864 229751 229590 229380 /width 20 velo !! set 100 km/s channels around the frequency list to zero

write uv NW14-USB-line

!! CO 2-1
read uv NW14-USB-line-selfcal
uv_extract /frequency 230535.53 /width 180 velo
write uv NW14-CO-2-1-selfcal

modify NW14-CO-2-1-selfcal.uvt /freq CO 230538.0 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-CO-2-1-selfcal
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
vector\fits NW14-CO-2-1-selfcal.fits from NW14-CO-2-1-selfcal.lmv-clean /overwrite
vector\fits NW14-CO-2-1-selfcal-res.fits from NW14-CO-2-1-selfcal.lmv-res /overwrite

!! CH3OH 8--1-7-0
read uv NW14-USB-line
uv_extract /frequency 229755 /width 40 velo
write uv NW14-CH3OH-8--1-7-0

modify NW14-CH3OH-8--1-7-0.uvt /freq CH3OH8-7 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-CH3OH-8--1-7-0-selfcal
let map_cell 0.05
let map_size 800
!! go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits NW14-CH3OH-8--1-7-0-selfcal.fits from NW14-CH3OH-8--1-7-0-selfcal.lmv-clean /overwrite
vector\fits NW14-CH3OH-8--1-7-0-selfcal-res.fits from NW14-CH3OH-8--1-7-0-selfcal.lmv-res /overwrite

!! D2CO 4-3
read uv NW14-USB-line
uv_extract /frequency 229755 /width 60 velo
write uv NW14-D2CO-4-04-3-03-selfcal

modify NW14-D2CO-4-04-3-03-selfcal.uvt /freq D2CO4-3 229758.756 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-D2CO-4-04-3-03-selfcal
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
vector\fits NW14-D2CO-4-04-3-03-selfcal.fits from NW14-D2CO-4-04-3-03-selfcal.lmv-clean /overwrite
vector\fits NW14-D2CO-4-04-3-03-selfcal-res.fits from NW14-D2CO-4-04-3-03-selfcal.lmv-res /overwrite

!! DNC 3-2
read uv NW14-USB-line
uv_extract /frequency 228907 /width 40 velo
write uv NW14-DNC-3-2-selfcal

modify NW14-DNC-3-2-selfcal.uvt /freq DNC3-2 228910.489 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-DNC-3-2-selfcal
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
vector\fits NW14-DNC-3-2-selfcal.fits from NW14-DNC-3-2-selfcal.lmv-clean /overwrite
vector\fits NW14-DNC-3-2-selfcal-res.fits from NW14-DNC-3-2-selfcal.lmv-res /overwrite

!! 13CS 5-4
read uv NW14-USB-line
uv_extract /frequency 231218 /width 40 velo
write uv NW14-13CS-5-4

modify NW14-13CS-5-4.uvt /freq 13CS5-4 231220.6987 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-13CS-5-4-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 200
go clean
!! # export .fits file
vector\fits NW14-13CS-5-4-selfcal.fits from NW14-13CS-5-4-selfcal.lmv-clean /overwrite
vector\fits NW14-13CS-5-4-selfcal-res.fits from NW14-13CS-5-4-selfcal.lmv-res /overwrite


!! N2D+ 3-2
read uv NW14-USB-line
uv_extract /frequency 231315 /width 50 velo
write uv NW14-N2D+-3-2-selfcal

modify NW14-N2D+-3-2-selfcal.uvt /freq N2D+ 231321.6650 !! unit MHz
!! # Apply selfcal and make deeper clean
let name NW14-N2D+-3-2-selfcal
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
vector\fits NW14-N2D+-3-2-selfcal.fits from NW14-N2D+-3-2-selfcal.lmv-clean /overwrite
vector\fits NW14-N2D+-3-2-selfcal-res.fits from NW14-N2D+-3-2-selfcal.lmv-res /overwrite





