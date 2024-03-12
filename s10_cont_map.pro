! Script for mapping
! uv table file name = w22be001-searchdisk-250kHz-USB-CygX-S10.uvt

! Read header of the uv table
header w22be001-searchdisk-250kHz-USB-CygX-S10.uvt

! Get observation setup and resolution info
let name w22be001-searchdisk-250kHz-USB-CygX-S10
go setup

! Plot uv coverage
let name w22be001-searchdisk-250kHz-USB-CygX-S10
go uvcov

! Making a continuum image
read uv w22be001-searchdisk-250kHz-USB-CygX-S10

! Transform  the  (presumably spectral line) UV data set loaded by READ UV
! into a "continuum" data set.
! Note: not average all line-free channels, need to be done later

uv_cont
write uv S10-USB-cont

! Plot uv coverage again for continuum map
let name S10-USB-cont
go uvcov

! Make dirty map and dirty beam for continuum map and clean
let name S10-USB-cont

let map_size 800 ! [pixels] 800*0.05=40" 20" is enough
let map_cell 0.05 ! [arcsec]
let map_weight robust
let map_robust 3

go uvmap

go clean

! export lmv to fits file
vector\fits S10_USB_cont_rob3.fits from S10-USB-cont.lmv-clean

!! ########################################################
!! Merge the lower side and upper side continuum tables
!! You should get continuum uv table for each sideband first

go uv_merge

! Input the required filename
! Then you will get a combined uv table: N30-cont-combine 
! Go get the cleaned map of the combined continuum data

let name S10-cont-comb

let map_cell 0.05
let map_size 800
let map_weight robust
let map_robust 3

go uvmap
go clean
go plot

! Save the combine continuum uv tables to .fits file
vector\fits S10_cont_comb_rob3.fits from S10-cont-comb.lmv-clean


!! ################################################################
!! ############ Appply Selfacl For Strong sources #################
!! ################################################################

!! The selfcal procedure should be used with caution
!! We can compress the dataset to reduce the data size

!! USB data

read uv w22be001-searchdisk-250kHz-USB-CygX-S10.uvt
uv_compress 10 !! Rechunk the data in 10
write uv S10-USB-comp

!! Because the bad channels have very bright emissions
!! we have to flag them first to make the results of selfcal better

read uv S10-USB-comp
uv_filter /zero /frequency 237115 230541 229376 /width 200 velo !! Flag the bad channels
write uv S10-USB-comp-flagbad

!! NOW GO SELFCAL with caution

let name S10-USB-comp-flagbad-selfcal
go plot !! to check the line and bad channels

!! For USB
!! read uv S10-USB-comp-flagbad-selfcal
!! uv_filter /zero /frequency 230541 /width 100 velo !! set 100 km/s channels around the frequency list to zero
!! write uv S10-USB-comp-filter-selfcal

!! Write the continuum uv table
read uv S10-USB-comp-flagbad-selfcal
uv_cont

write uv S10-USB-comp-filter-cont-selfcal

!! Make the continuum map
let name S10-USB-comp-filter-cont-selfcal
let map_cell 0
let map_size 0
let niter 5000

go uvmap
go clean

!! ################################################
!! LSB data

read uv w22be001-searchdisk-250kHz-LSB-CygX-S10.uvt
uv_compress 10 !! Rechunk the data in 10
write uv S10-LSB-comp

!! Because the bad channels have very bright emissions
!! we have to flag them first to make the results of selfcal better

read uv S10-LSB-comp
uv_filter /zero /frequency 221654 221811 213890 217771 213711 /width 200 velo !! Flag the bad channels
write uv S10-LSB-comp-flagbad


!! NOW GO SELFCAL with caution

let name S10-LSB-comp-flagbad-selfcal
go plot !! to check the line and bad channels

!! For LSB
read uv S10-LSB-comp-flagbad-selfcal
!! uv_filter /zero /frequency /width 100 velo !! set 100 km/s channels around the frequency list to zero

!! Write the continuum uv table
!! read uv S10-LSB-comp-filter-selfcal

uv_cont
write uv S10-LSB-comp-filter-cont-selfcal

!! Make the continuum map
let name S10-LSB-comp-filter-cont-selfcal
let map_cell 0
let map_size 0
let niter 5000

go uvmap
go clean


!! ########################################################################################################################################################################################
!! ###########################################################################
!! ############################# Image Procedure #############################
!!
!! # For lower sideband
read uv w22be001-searchdisk-250kHz-LSB-CygX-S10.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv S10-LSB-comp

!! # Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name S10-LSB-comp
let map_size 800
let map_cell 0.05

go uvmap

let niter 50
go clean

go plot

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-LSB-CygX-S10.uvt

uv_filter /frequency 221627 213890 /width 100 velo 
write uv S10-LSB-filter

!! ###### Generate LSB continuum uv table #############
read uv S10-LSB-filter.uvt
uv_filter /zero /frequency 221654 221811 213890 217771 213711 /width 50 velo !! set 100 km/s channels around the frequency list to zero
write uv S10-LSB-linefree

uv_cont
write uv S10-LSB-cont


!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name NW56-LSB-linefree
!! transfer gain solution to 
!! make deeper clean for the continuum uv table
let name S10-LSB-cont-selfcal
let map_size 800
let map_cell 0.05
go uvmap

let niter 500
go clean


!! #######################################################################################
!! ################# Apply selfcal to the line uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! Substract continuum emissions
!! For LSB band
read uv S10-LSB-filter.uvt

uv_base 0 /frequency 221654 221811 213890 217771 213711  /width 50 velo !! set 100 km/s channels around the frequency list to zero

write uv S10-LSB-line

!! Extract line emissions
!! CH3CN 12-11 K=6
read uv S10-LSB-line
uv_extract /frequency 220580 /width 100 velo
write uv S10-CH3CN-12-11-k-6

modify N56-CH3CN-12-11-k-6.uvt /freq CH3CN-12-11-k-6 220594.42310 /specunit frequency !! unit MHz

!! CH3CN 12-11 K=4
read uv N56-LSB-line
uv_extract /frequency 220680 /width 40 velo
write uv N56-CH3CN-12-11-k-4

modify N56-CH3CN-12-11-k-4.uvt /freq CH3CN-k4 220679.2869 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-CH3CN-12-11-k-4-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 500
go clean

!! # export .fits file
vector\fits N56-CH3CN-12-11-k-4-selfcal.fits from N56-CH3CN-12-11-k-4-selfcal.lmv-clean /overwrite
vector\fits N56-CH3CN-12-11-k-4-selfcal-res.fits from N56-CH3CN-12-11-k-4-selfcal.lmv-res /overwrite


!! CH3CN 12-11 K=3
read uv N63-LSB-line
uv_extract /frequency 220712 /width 40 velo
write uv N63-CH3CN-12-11-k3

modify N63-CH3CN-12-11-k3.uvt /freq CH3CN-k3 220709.0165 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N63-CH3CN-12-11-k3-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits N56-CH3CN-12-11-k3-selfcal.fits from N56-CH3CN-12-11-k3-selfcal.lmv-clean /overwrite
vector\fits N56-CH3CN-12-11-k3-selfcal-res.fits from N56-CH3CN-12-11-k3-selfcal.lmv-res /overwrite


!! CH3OH 4(2,2)-3(1,2)
read uv N56-LSB-line
uv_extract /frequency 218430 /width 40 velo
write uv N56-CH3OH-4-22-3-12

modify N56-CH3OH-4-22-3-12.uvt /freq CH3OH-4-3 218440.0630 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-CH3OH-4-22-3-12-selfcal
let map_cell 0.05
let map_size 600
go uvmap

let niter 500
go clean
!! # export .fits file
vector\fits N56-CH3OH-4-22-3-12-selfcal.fits from N56-CH3OH-4-22-3-12-selfcal.lmv-clean /overwrite
vector\fits N56-CH3OH-4-22-3-12-selfcal-res.fits from N56-CH3OH-4-22-3-12-selfcal.lmv-res /overwrite


!! 13CO 2-1
read uv S10-LSB-line
uv_extract /frequency 220398 /width 60 velo
write uv S10-13CO-2-1

modify S10-13CO-2-1.uvt /freq 13CO2-1 220398.6195 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-13CO-2-1-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 300
go clean
!! # export .fits file
vector\fits S10-13CO-2-1-selfcal.fits from S10-13CO-2-1-selfcal.lmv-clean /overwrite
vector\fits S10-13CO-2-1-selfcal-res.fits from S10-13CO-2-1-selfcal.lmv-res /overwrite

!! C18O 2-1
read uv S10-LSB-line
uv_extract /frequency 219560 /width 60 velo
write uv S10-C18O-2-1

modify S10-C18O-2-1.uvt /freq C18O2-1 219560.358 !! unit MHz
!! # Apply selfcal and make deeper clean
let name S10-C18O-2-1-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 300
go clean
!! # export .fits file
vector\fits N56-C18O-2-1-selfcal.fits from N56-C18O-2-1-selfcal.lmv-clean /overwrite
vector\fits N56-C18O-2-1-selfcal-res.fits from N56-C18O-2-1-selfcal.lmv-res /overwrite



!! Outflow red- and blue-lobe velocity range: blue 7.5~10 km/s red 

!! SiO 5-4
read uv N56-LSB-line
uv_extract /frequency 217102 /width 80 velo
write uv N56-SiO-5-4

modify N56-SiO-5-4.uvt /freq SiO5-4 217104.919 !! unit MHz

!! # Apply selfcal and make deeper clean
let name N56-SiO-5-4-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 200
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
read uv S10-LSB-line
uv_extract /frequency 217238 /width 40 velo

$rm -rf S10-DCN-3-2.uvt
write uv S10-DCN-3-2

modify S10-DCN-3-2.uvt /freq DCN-3-2 217238.6307 !! unit MHz

!! # Apply selfcal and make deeper clean
let name S10-DCN-3-2-selfcal
let map_cell 0.05
let map_size 800
let niter 200
go uvmap

go clean

!! # export .fits file

vector\fits N56-DCN-3-2-selfcal.fits from N56-DCN-3-2-selfcal.lmv-clean /overwrite
vector\fits N56-DCN-3-2-selfcal-res.fits from N56-DCN-3-2-selfcal.lmv-res /overwrite


#######################################################################################################
###########################################################################################################
!!
!! # For upper sideband
read uv w22be001-searchdisk-250kHz-USB-CygX-S10.uvt
uv_compress 100 !! Get a spectral resolution of 25 km/s to reduce data size
write uv S10-USB-comp

# Make a quick map and clean for the compressed uv table to check bad channels and line-free channels
let name S10-USB-comp
let map_size 800
let map_cell 0.05
go uvmap

let niter 50
go clean

!! ###### Flag the bad channels ##############
read uv w22be001-searchdisk-250kHz-USB-CygX-S10.uvt

uv_filter /frequency 237121 229365 /width 200 velo 
write uv S10-USB-filter

!! ###### Generate USB continuum uv table #############
read uv S10-USB-filter.uvt
uv_filter /zero /frequency 237115 230541 229376 /width 100 velo !! set 100 km/s channels around the frequency list to zero
write uv S10-USB-linefree

uv_cont
write uv S10-USB-cont

!! #######################################################################################
!! ################# Apply selfcal to the continuum uv table #############################
!! ################ and trasnfer gain solution to another uv table #######################
!! #######################################################################################
!! name S10-USB-linefree
!! transfer gain solution to S10-USB-cont
!! make deeper clean for the continuum uv table
let name S10-USB-cont-selfcal
let map_size 800
let map_cell 0.05
go uvmap

let niter 500
go clean

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

uv_base 0 /frequency 237115 230541 229376 /width 100 velo !! set 100 km/s channels around the frequency list to zero

write uv N56-USB-line

!! CO 2-1
read uv N56-USB-line
uv_extract /frequency 230535 /width 100 velo
write uv N56-CO-2-1

modify N56-CO-2-1.uvt /freq CO2-1 230538.0 !! unit MHz
!! # Apply selfcal and make deeper clean
let name N56-CO-2-1-selfcal
let map_cell 0.05
let map_size 800
go uvmap

let niter 500
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

