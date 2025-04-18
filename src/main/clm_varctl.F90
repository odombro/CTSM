module clm_varctl

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! Module containing run control variables
  !
  ! !USES:
  use shr_kind_mod, only: r8 => shr_kind_r8, SHR_KIND_CL
  use shr_sys_mod , only: shr_sys_abort ! cannot use endrun here due to circular dependency
  !
  ! !PUBLIC MEMBER FUNCTIONS:
  implicit none
  public :: clm_varctl_set    ! Set variables
  public :: cnallocate_carbon_only_set
  public :: cnallocate_carbon_only
  !
  private
  save
  !
  ! !PUBLIC TYPES:
  !
  integer , parameter, public ::  iundef = -9999999
  real(r8), parameter, public ::  rundef = -9999999._r8
  integer , parameter, public ::  fname_len = SHR_KIND_CL   ! max length of file names in this module
  !----------------------------------------------------------
  !
  ! Run control variables
  !
  ! case id
  character(len=256), public :: caseid  = ' '                            

  ! case title
  character(len=256), public :: ctitle  = ' '                            

  ! Type of run
  integer, public :: nsrest                = iundef                         
  logical, public :: is_cold_start         = .false.
  logical, public :: is_interpolated_start = .false. ! True if we're starting from initial conditions that have been run through init_interp

  ! Startup from initial conditions
  integer, public, parameter :: nsrStartup  = 0                          

  ! Continue from restart files
  integer, public, parameter :: nsrContinue = 1                          

  ! Branch from restart files
  integer, public, parameter :: nsrBranch   = 2                          

  ! true => allow case name to remain the same for branch run
  ! by default this is not allowed
  logical, public :: brnch_retain_casename = .false.                     

  ! true => run tests of ncdio_pio
  logical, public :: for_testing_run_ncdiopio_tests = .false.

  ! Hostname of machine running on
  character(len=256), public :: hostname = ' '                           

  ! username of user running program
  character(len=256), public :: username = ' '                           

  ! description of this source
  character(len=256), public :: source   = "Community Terrestrial Systems Model"

  ! version of program
  character(len=256), public :: version  = " "                           

  ! dataset conventions
  character(len=256), public :: conventions = "CF-1.0"                   

  ! component name for filenames (history or restart files)
  character(len=8), public :: compname = 'clm2'

  !----------------------------------------------------------
  ! Unit Numbers
  !----------------------------------------------------------
  !
  integer, public :: iulog = 6        ! "stdout" log file unit number, default is 6

  !----------------------------------------------------------
  ! Output NetCDF files
  !----------------------------------------------------------

  logical, public :: outnc_large_files = .true.         ! large file support for output NetCDF files

  !----------------------------------------------------------
  ! Run input files
  !----------------------------------------------------------

  character(len=fname_len), public :: finidat    = ' '        ! initial conditions file name
  character(len=fname_len), public :: fsurdat    = ' '        ! surface data file name
  character(len=fname_len), public :: paramfile  = ' '        ! ASCII data file with PFT physiological constants
  character(len=fname_len), public :: nrevsn     = ' '        ! restart data file name for branch run
  character(len=fname_len), public :: fsnowoptics  = ' '      ! snow optical properties file name
  character(len=fname_len), public :: fsnowaging   = ' '      ! snow aging parameters file name

  character(len=fname_len), public :: fatmlndfrc = ' '        ! lnd frac file on atm grid
                                                              ! only needed for LILAC and MCT drivers

  !----------------------------------------------------------
  ! Flag to read ndep rather than obtain it from coupler
  !----------------------------------------------------------
  
  logical, public :: ndep_from_cpl = .false.

  !----------------------------------------------------------
  ! Interpolation of finidat if requested
  !----------------------------------------------------------

  logical, public :: bound_h2osoi = .true. ! for debugging 

  ! If finidat_interp_source is non-blank and finidat is blank then interpolation will be
  ! done from finidat_interp_source to finidat_interp_dest. Note that
  ! finidat_interp_source is not read in directly from the namelist - rather, it is set
  ! from finidat if use_init_interp is .true.

  character(len=fname_len), public :: finidat_interp_source = ' '
  character(len=fname_len), public :: finidat_interp_dest   = ''

  !----------------------------------------------------------
  ! Crop & Irrigation logic
  !----------------------------------------------------------

  ! If prognostic crops are turned on
  logical, public :: use_crop = .false.

  ! true => separate crop landunit is not created by default
  logical, public :: create_crop_landunit = .false.     
  
  ! do not irrigate by default
  logical, public :: irrigate = .false.            

  ! set saturated excess runoff to zero for crops
  logical, public :: crop_fsat_equals_zero = .false.
  
  !----------------------------------------------------------
  ! Other subgrid logic
  !----------------------------------------------------------

  ! true => allocate and run urban landunits everywhere where we have valid urban data
  logical, public :: run_zero_weight_urban = .false.

  ! true => make ALL patches, cols & landunits active (even if weight is 0)
  logical, public :: all_active = .false.          

  logical, public :: collapse_urban = .false.  ! true => collapse urban landunits to the dominant urban landunit; default = .false. means "do nothing" i.e. keep all urban landunits as found in the input data
  integer, public :: n_dom_landunits = -1  ! # of dominant landunits; determines the number of active landunits; default = 0 (set in namelist_defaults_ctsm.xml) means "do nothing"
  integer, public :: n_dom_pfts = -1  ! # of dominant pfts; determines the number of active pfts; default = 0 (set in namelist_defaults_ctsm.xml) means "do nothing"

  real(r8), public :: toosmall_soil = -1._r8  ! threshold above which the model keeps the soil landunit; default = 0 (set in namelist_defaults_ctsm.xml) means "do nothing"
  real(r8), public :: toosmall_crop = -1._r8  ! threshold above which the model keeps the crop landunit; default = 0 (set in namelist_defaults_ctsm.xml) means "do nothing"
  real(r8), public :: toosmall_glacier = -1._r8  ! threshold above which the model keeps the glacier landunit; default = 0 (set in namelist_defaults_ctsm.xml) means "do nothing"
  real(r8), public :: toosmall_lake = -1._r8  ! threshold above which the model keeps the lake landunit; default = 0 (set in namelist_defaults_ctsm.xml) means "do nothing"
  real(r8), public :: toosmall_wetland = -1._r8  ! threshold above which the model keeps the wetland landunit; default = 0 (set in namelist_defaults_ctsm.xml) means "do nothing"
  real(r8), public :: toosmall_urban = -1._r8  ! threshold above which the model keeps any urban landunits that are present; default = 0 (set in namelist_defaults_ctsm.xml) means "do nothing"

  !----------------------------------------------------------
  ! BGC logic and datasets
  !----------------------------------------------------------

  ! values of 'prognostic','diagnostic','constant'
  character(len=16), public :: co2_type = 'constant'    

  ! State of the model for the accelerated decomposition (AD) spinup. 
  ! 0 (default) = normal model; 1 = AD SPINUP
  integer, public :: spinup_state = 0 

  ! true => anoxia is applied to heterotrophic respiration also considered in CH4 model
  ! default value reset in controlMod
  logical, public :: anoxia  = .true. 

  ! used to override an error check on reading in restart files
  logical, public :: override_bgc_restart_mismatch_dump = .false. 

  ! Set in CNAllocationInit (TODO - had to move it here to avoid circular dependency)
  logical, private:: carbon_only      

  ! Set in CNNDynamicsInit 
  ! NOTE (mvertens, 2014-9 had to move it here to avoid confusion when carbon data types
  ! wehre split - TODO - should move it our of this module) 
  ! NOTE(bandre, 2013-10) according to Charlie Koven, nfix_timeconst
  ! is currently used as a flag and rate constant. 
  ! Rate constant: time over which to exponentially relax the npp flux for N fixation term
  ! (days) time over which to exponentially relax the npp flux for N fixation term
  ! flag: (if  <=  0. or  >=  365; use old annual method). 
  ! Default value is junk that should always be overwritten by the namelist or init function!
  !
  real(r8), public :: nfix_timeconst = -1.2345_r8 

  !----------------------------------------------------------
  ! Physics
  !----------------------------------------------------------

  ! use subgrid fluxes
  logical,  public :: use_subgrid_fluxes = .true.

  ! which snow cover fraction parameterization to use
  character(len=64), public :: snow_cover_fraction_method

  ! atmospheric CO2 molar ratio (by volume) (umol/mol)
  real(r8), public :: co2_ppmv     = 355._r8            !

  ! ozone vegitation stress method, valid values: unset, stress_lombardozzi2015, stress_falk
  character(len=64), public    :: o3_veg_stress_method = 'unset'

  real(r8), public  :: o3_ppbv = 100._r8

  !----------------------------------------------------------
  ! C isotopes
  !----------------------------------------------------------

  logical, public :: use_c13 = .false.                  ! true => use C-13 model
  logical, public :: use_c14 = .false.                  ! true => use C-14 model

  ! BUG(wjs, 2018-10-25, ESCOMP/ctsm#67) There is a bug that causes incorrect values for C
  ! isotopes if running init_interp from a case without C isotopes to a case with C
  ! isotopes (https://github.com/ESCOMP/ctsm/issues/67). Normally, an error-check prevents
  ! you from doing this interpolation (until we have fixed that bug). However, we
  ! sometimes want to bypass this error-check in system tests. This namelist flag bypasses
  ! this error-check.
  logical, public :: for_testing_allow_interp_non_ciso_to_ciso = .false.

  !----------------------------------------------------------
  !  FATES switches
  !----------------------------------------------------------

  logical, public :: use_fates = .false.            ! true => use fates

  ! These are INTERNAL to the FATES module
  integer, public            :: fates_parteh_mode = -9                 ! 1 => carbon only
                                                                       ! 2 => C+N+P (not enabled yet)
                                                                       ! no others enabled
  integer, public            :: fates_spitfire_mode = 0                
  ! 0 for no fire; 1 for constant ignitions; > 1 for external data (lightning and/or anthropogenic ignitions)
  ! see bld/namelist_files/namelist_definition_clm4_5.xml for details
  logical, public            :: use_fates_logging = .false.            ! true => turn on logging module
  logical, public            :: use_fates_planthydro = .false.         ! true => turn on fates hydro
  logical, public            :: use_fates_cohort_age_tracking = .false. ! true => turn on cohort age tracking
  logical, public            :: use_fates_ed_st3   = .false.           ! true => static stand structure
  logical, public            :: use_fates_ed_prescribed_phys = .false. ! true => prescribed physiology
  logical, public            :: use_fates_inventory_init = .false.     ! true => initialize fates from inventory
  logical, public            :: use_fates_fixed_biogeog = .false.           ! true => use fixed biogeography mode
  logical, public            :: use_fates_nocomp = .false.           ! true => use no comopetition mode
  logical, public            :: use_fates_sp = .false.           ! true => use FATES satellite phenology mode
  character(len=256), public :: fates_inventory_ctrl_filename = ''     ! filename for inventory control

  !----------------------------------------------------------
  !  LUNA switches		
  !----------------------------------------------------------

  logical, public :: use_luna = .false.            ! true => use  LUNA

  !----------------------------------------------------------
  !  flexibleCN
  !----------------------------------------------------------
  !  TODO(bja, 2015-08) some of these need to be moved into the
  !  appropriate module.
  logical, public :: use_flexibleCN = .false.
  logical, public :: MM_Nuptake_opt = .false.
  logical, public :: downreg_opt = .true.
  integer, public :: plant_ndemand_opt = 0
  logical, public :: substrate_term_opt = .true.
  logical, public :: nscalar_opt = .true.
  logical, public :: temp_scalar_opt = .true.
  logical, public :: CNratio_floating = .false.
  logical, public :: lnc_opt = .false.
  logical, public :: reduce_dayl_factor = .false.
  integer, public :: vcmax_opt = 0
  integer, public :: CN_residual_opt = 0
  integer, public :: CN_partition_opt = 0
  integer, public :: CN_evergreen_phenology_opt = 0
  integer, public :: carbon_resp_opt = 0

  !----------------------------------------------------------
  ! prescribed soil moisture streams switch 
  !----------------------------------------------------------

  logical, public :: use_soil_moisture_streams = .false. ! true => use prescribed soil moisture stream

  !----------------------------------------------------------
  ! lai streams switch for Sat. Phenology
  !----------------------------------------------------------

  logical, public :: use_lai_streams = .false. ! true => use lai streams in SatellitePhenologyMod.F90

  !----------------------------------------------------------
  ! biomass heat storage switch
  !----------------------------------------------------------

  logical, public :: use_biomass_heat_storage = .false. ! true => include biomass heat storage in canopy energy budget

  !----------------------------------------------------------
  ! bedrock / soil depth switch
  !----------------------------------------------------------

  logical,           public :: use_bedrock = .false. ! true => use spatially variable soil depth
  character(len=16), public :: soil_layerstruct_predefined = 'UNSET'
  real(r8), public :: soil_layerstruct_userdefined(99) = rundef
  integer, public :: soil_layerstruct_userdefined_nlevsoi = iundef

  !----------------------------------------------------------
  ! plant hydraulic stress switch
  !----------------------------------------------------------

  logical, public :: use_hydrstress = .false. ! true => use plant hydraulic stress calculation

  !----------------------------------------------------------
  ! dynamic root switch
  !----------------------------------------------------------

  logical, public :: use_dynroot = .false. ! true => use dynamic root module

  !----------------------------------------------------------
  ! glacier_mec control variables: default values (may be overwritten by namelist)
  !----------------------------------------------------------

  ! true => CLM glacier area & topography changes dynamically 
  logical , public :: glc_do_dynglacier = .false.           

  ! number of days before one considers the perennially snow-covered point 'land ice'
  integer , public :: glc_snow_persistence_max_days = 7300  

  !
  !----------------------------------------------------------
  ! single column control variables
  !----------------------------------------------------------

  logical,  public :: single_column = .false. ! true => single column mode
  real(r8), public :: scmlat        = rundef  ! single column lat
  real(r8), public :: scmlon        = rundef  ! single column lon

  !----------------------------------------------------------
  ! instance control
  !----------------------------------------------------------

  integer, public :: inst_index
  character(len=16), public :: inst_name
  character(len=16), public :: inst_suffix

  !----------------------------------------------------------
  ! Decomp control variables
  !----------------------------------------------------------

  ! number of segments per clump for decomp
  integer, public :: nsegspc = 20                       

  !----------------------------------------------------------
  ! Derived variables (run, history and restart file)
  !----------------------------------------------------------

  ! directory name for local restart pointer file
  character(len=256), public :: rpntdir = '.'            

  ! file name for local restart pointer file
  character(len=256), public :: rpntfil = 'rpointer.lnd' 

  ! moved hist_wrtch4diag from histFileMod.F90 to here - caused compiler error with intel
  ! namelist: write CH4 extra diagnostic output
  logical, public :: hist_wrtch4diag = .false.         

  ! namelist: write history master list to a file for use in documentation
  logical, public :: hist_master_list_file = .false.

  !----------------------------------------------------------
  ! FATES
  !----------------------------------------------------------
  character(len=fname_len), public :: fates_paramfile  = ' '
  !----------------------------------------------------------
  ! SSRE diagnostic
  !----------------------------------------------------------
  logical, public :: use_SSRE = .false.   ! flag for SSRE diagnostic

  !----------------------------------------------------------
  ! Migration of CPP variables
  !----------------------------------------------------------

  logical, public :: use_lch4            = .true.
  logical, public :: use_nitrif_denitrif = .true.
  logical, public :: use_extralakelayers = .false.
  logical, public :: use_vichydro        = .false.
  logical, public :: use_cn              = .false.
  logical, public :: use_cndv            = .false.
  logical, public :: use_grainproduct    = .false.
  logical, public :: use_fertilizer      = .false.
  logical, public :: use_snicar_frc      = .false.
  logical, public :: use_vancouver       = .false.
  logical, public :: use_mexicocity      = .false.
  logical, public :: use_noio            = .false.

  logical, public :: use_nguardrail      = .false.

  !----------------------------------------------------------
  ! To retrieve namelist
  !----------------------------------------------------------
  character(len=SHR_KIND_CL), public :: NLFilename_in ! Namelist filename
  !
  logical, private :: clmvarctl_isset = .false.
 !-----------------------------------------------------------------------

contains

  !---------------------------------------------------------------------------
  subroutine clm_varctl_set( caseid_in, ctitle_in, brnch_retain_casename_in,    &
       single_column_in, scmlat_in, scmlon_in, nsrest_in, &
       version_in, hostname_in, username_in)
    !
    ! !DESCRIPTION:
    ! Set input control variables.
    !
    ! !ARGUMENTS:
    character(len=256), optional, intent(IN) :: caseid_in                ! case id
    character(len=256), optional, intent(IN) :: ctitle_in                ! case title
    logical,            optional, intent(IN) :: brnch_retain_casename_in ! true => allow case name to remain the 
                                                                         ! same for branch run
    logical,            optional, intent(IN) :: single_column_in         ! true => single column mode
    real(r8),           optional, intent(IN) :: scmlat_in                ! single column lat
    real(r8),           optional, intent(IN) :: scmlon_in                ! single column lon
    integer,            optional, intent(IN) :: nsrest_in                ! 0: initial run. 1: restart: 3: branch
    character(len=256), optional, intent(IN) :: version_in               ! model version
    character(len=256), optional, intent(IN) :: hostname_in              ! hostname running on
    character(len=256), optional, intent(IN) :: username_in              ! username running job
    !-----------------------------------------------------------------------

    if ( clmvarctl_isset )then
       call shr_sys_abort(' ERROR:: control variables already set, cannot call this routine')
    end if

    if ( present(caseid_in       ) ) caseid        = caseid_in
    if ( present(ctitle_in       ) ) ctitle        = ctitle_in
    if ( present(single_column_in) ) single_column = single_column_in
    if ( present(scmlat_in       ) ) scmlat        = scmlat_in
    if ( present(scmlon_in       ) ) scmlon        = scmlon_in
    if ( present(nsrest_in       ) ) nsrest        = nsrest_in
    if ( present(brnch_retain_casename_in) ) brnch_retain_casename = brnch_retain_casename_in
    if ( present(version_in      ) ) version       = version_in
    if ( present(username_in     ) ) username      = username_in
    if ( present(hostname_in     ) ) hostname      = hostname_in

  end subroutine clm_varctl_set

  ! Set module carbon_only flag
  subroutine cnallocate_carbon_only_set(carbon_only_in)
    logical, intent(in) :: carbon_only_in
    carbon_only = carbon_only_in
  end subroutine cnallocate_carbon_only_set

  ! Get module carbon_only flag
  logical function CNAllocate_Carbon_only()
    cnallocate_carbon_only = carbon_only
  end function CNAllocate_Carbon_only

end module clm_varctl
