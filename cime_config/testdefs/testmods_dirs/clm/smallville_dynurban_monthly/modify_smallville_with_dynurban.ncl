; NCL script
; modify_smallville_with_dynurban.ncl
; Keith Oleson, Dec 2021
; Purpose is to create a dynamic urban file for the smallville grid for test
; ERS_Lm25.1x1_smallvilleIA.IHistClm50BgcCropQianRs.cheyenne_gnu.clm-smallville_dynurban_monthly
;**************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

 print ("=========================================")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")

 infile  = "/glade/p/cgd/tss/people/oleson/modify_surfdata/landuse.timeseries_1x1_smallvilleIA_hist_78pfts_simyr1850-1855_c160127.nc"
 outfile = "/glade/p/cgd/tss/people/oleson/modify_surfdata/landuse.timeseries_1x1_smallvilleIA_hist_78pfts_simyr1850-1855_dynUrban_c211206.nc" 

 system("cp " + infile + " " + outfile)

 outf = addfile(outfile,"w")

 numurbl = 3

 pct_crop = outf->PCT_CROP 
 printVarSummary(pct_crop)
 pct_urban = new((/dimsizes(pct_crop(:,0,0)),numurbl,dimsizes(pct_crop(0,:,0)),dimsizes(pct_crop(0,0,:))/),double,"No_FillValue")
 pct_urban!0 = "time"
 pct_urban&time = pct_crop&time
 pct_urban!1 = "numurbl"
 pct_urban!2 = pct_crop!1
 pct_urban!3 = pct_crop!2
 pct_urban@long_name = "percent urban for each density type (tbd, hd, md)"
 pct_urban@units = "unitless"
 printVarSummary(pct_urban)

 hasurban = new((/numurbl,dimsizes(pct_crop(0,:,0)),dimsizes(pct_crop(0,0,:))/),double,"No_FillValue")
 hasurban!0 = pct_urban!1
 hasurban!1 = pct_urban!2
 hasurban!2 = pct_urban!3
 hasurban = 1.d
 printVarSummary(hasurban)

 pct_urban(:,0,0,0) = (/0.d,20.d,10.d,10.d,10.d,10.d/)
 pct_urban(:,1,0,0) = (/0.d,15.d, 8.d, 8.d, 8.d, 8.d/)
 pct_urban(:,2,0,0) = (/0.d,10.d, 5.d, 5.d, 5.d, 5.d/)

 pct_crop(:,0,0) = (/0.,25.,12.,12.,12.,12./)

 outf->HASURBAN  = hasurban
 outf->PCT_URBAN = pct_urban
 outf->PCT_CROP = pct_crop

 outf@history = "This file was created with the following NCL script: /glade/p/cgd/tss/people/oleson/modify_surfdata/modify_smallville_with_dynurban.ncl.  The file used as a template is: /glade/p/cesm/cseg/inputdata/lnd/clm2/surfdata_map/landuse.timeseries_1x1_smallvilleIA_hist_78pfts_simyr1850-1855_c160127.nc.  Key points are that urban area starts as 0, increases after the first year, then decreases after the second year.  PCT_CROP is also changed so that PCT_URBAN + PCT_CROP <= 100. (Here, PCT_CROP increases and decreases at the same time as PCT_URBAN in order to exercise the simultaneous increase or decrease of two landunits, but that isn't a critical part of this test.). Note that the use of this file means that this testmod can only be used with the 1x1_smallvilleIA grid."

 print ("=========================================")
 print ("Finish Time: "+systemfunc("date") )
 print ("=========================================")

end
