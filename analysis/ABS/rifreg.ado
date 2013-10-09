*! rifreg version 0.1.1  Sept12-07, Mike Gevaert
program rifreg, eclass sort byable(recall) //sort prop(sw)
   version 9, missing
   syntax [varlist] [if] [in] [aw fw iw] [, ///
      /* Models */            ///
      GIni		      ///
      VARiance		      ///
      MEan	  	      /// only calculate the mean, this is a normal reg
      Quantile(real 0.0)      ///
      /* Quantile Options */  ///
      KErnop(string)	      /// which kernel to use
      Width(real 0.0) 	      /// kernel width
      REtain(string)	      /// keep the estimated
      NORobust		      ///
      GENerate(string)        /// save the eval1 and dens variables, so they can be reused 
      ESTWgt(varname)         /// we have an estimated weight (dflweight?) adjust stderr's
      ESTName(name)           /// saved from the logit/probit, for now
      /* Display Options */   ///
      Level(cilevel)	      ///
      BOotstrap		      ///
      reps(integer 50)        ///
      ]

   if !replay() {
      //check to see if we're computing something
      if "`gini'`variance'`quantile'`mean'" == "0" {
	 di in red "must specify statistic to compute (gini, variance, mean or quantile)"
	 exit 198
      }

      //can't calculate both var and gini
      if ("`variance'" == "variance" & "`gini'" == "gini" ) {
	 di in red "variance and gini options can't be used at the same time"
	 exit 198
      }

      if ("`estwgt'" != "" & "`estname'" == "") | ///
         ("`estwgt'" == "" & "`estname'" != "") {
	 di in red "must use both estwgt() and estname() together"
	 exit 198
      }

      //options don't mix for gini and variance stats
      if ("`variance'" == "variance" | "`gini'" == "gini" ) ///
	 & "`norobust'`generate'`kernop'`quantile'`width'" != "00" { //00 since default values
	 di in red "variance and gini options do not allow options"
	 exit 198
      }
      //generate and retain options don't mix for bootstrap 
      if ("`bootstrap'" == "bootstrap") ///
	 & "`norobust'`retain'`generate'" != "" {
	 di in red "can't use norobust, generate or retain options with bootstrap"
	 exit 198
      }

      if ("`bootstrap'" != "" & "`estwgt'" != ""){
	 di in red "can't use both bootstrap and estwgt"
	 exit 198
      }

      if ("`norobust'" == "norobust") {
	 loc robust = ""
      }
      else {
	 loc robust = "robust"
      }
      
      //get the dependent variable
      tokenize `varlist'
      local y `1'
      //get the rest of the vars
      macro shift
      local rest `*'

      //deal with weights, if set as blank, generate a column of 1's
      if "`weight'" == "" {
	 tempvar eweight
         gen `eweight' = 1.0
         local weight "aweight"
         local exp "=`eweight'"
      }

      //get the weight expression without '=' sign
      local exp_no_eq = regexr("`exp'", "=", "")

      //pick which samples we want to use
      marksample touse
      //do not use any samples that are blank
      markout `touse' `varlist' `exp_no_eq'
      //remove colinear explanatory variables
      _rmcoll `varlist' if `touse'
      local varlist `r(varlist)'

      //we want more than 25 samples
      qui count if `touse'
      if r(N) < 25 {
	 error cond(_n,2001,2000) 
      }

      //see if they want variance
      if "`variance'" == "variance" {
	 tempname b v  

	 if "`retain'" != "" { //they want to choose a name
	    local regname `retain'
	 }
	 else{
	    local regname rifvar
	 }

	 variance "`regname'" "`y'" "`rest'" "`weight'`exp'" "`touse'"
	 mat `b' = e(b)
	 mat `v' = e(V) //may get overwritten if bootstrap
	 if "`retain'" == "" { //they want to choose a name
	    drop `regname'
	 }

	 if "`bootstrap'" == "bootstrap" {
	    doBootstrap "Bootstrap Variance" "`reps'" "`v'"  "`regname'" "`touse'" ///
	       `"variance "`regname'" "`y'" "`rest'" "`weight'`exp'" "`touse'""' ""
	    eret loc vcetype "Bootstrap"
	 }
	 eret loc cmd    = "rifvariance"
	 eret loc title  = "RIF Regression"
	 //post important matrices, this destroys b, V and touse
	 eret post `b' `v', noclear esample(`touse')
	 RIF_out `level'  //print
	 exit
      }

      //see if they want gini
      if "`gini'" == "gini" {
	 //can only use aweight, until further notice
	 if "`weight'" != "aweight"{
	    di in red "Must use aweight for gini option"
	    exit 198
	 }

	 if "`retain'" != "" { //they want to choose a name
	    local regname `retain'
	 }
	 else{
	    local regname rifgini
	 }

	 tempname b v  
	 gini "`regname'" "`y'" "`rest'" "`weight'`exp'" "`exp_no_eq'" "`touse'"
	 mat `b' = e(b)
	 mat `v' = e(V) //may get overwritten if bootstrap
	 if "`retain'" == "" { //they want to choose a name
	    drop `regname'
	 }

	 if "`bootstrap'" == "bootstrap" {
	    doBootstrap "Bootstrap GINI" "`reps'" "`v'"  "`regname'" "`touse'" ///
	       `"gini `regname' `y' "`rest'" "`weight'`exp'" `exp_no_eq' `touse'"' ""
	    eret loc vcetype "Bootstrap"
	 }
	 eret loc cmd    = "rifgini"
	 eret loc title  = "RIF Regression"
	 //post important matrices, this destroys b, V and touse
	 eret post `b' `v', noclear esample(`touse')
	 RIF_out `level' //print
	 exit
      }

      if "`mean'" == "mean" {
	 ////calculate the quantile at which the mean occurs
	 //sum `y' [`weightexp'] if `touse', mean
	 //tempname N
	 //loc `N' = r(N)
	 //sum `y' [`weightexp'] if `touse' & `y' < r(mean), mean
	 //loc quantile = r(N)/``N''

	 ////d: dis "N: ``N'', r(N): `r(N)'"
	 ////carry only 2 significant digits
	 //loc quantile = round(`quantile' * 100)

	 qui reg `y' `rest' [`weight'`exp'] if `touse'

	 tempname b v  
	 mat `b' = e(b)
	 mat `v' = e(V) //may get overwritten if bootstrap
	 //deal with estimated weights
	 if "`estwgt'" != "" {
	    useEstWgts "`y'" "`rest'" "`estname'" "`estwgt'" "`v'" "`exp_no_eq'"
	       //post important matrices, this destroys b, V and touse
	       eret post `b' `v', noclear esample(`touse')
	 }
	 
	 RIF_out `level' //print
	 exit
      }

      //we're doing a quantile regression now
      //make the default kernel gaussian
      if "`kernop'" == "" {
	 local kernop = "gaussian"
      }

      //check quantile options
      if `quantile' > 1 & `quantile' < 100 {
	 local quantile = `quantile' / 100
      }

      local qt "`quantile'"
      if `quantile' > 0 & `quantile' < 1 {
	 local steps 10
	 local qt = `qt' * 10
	 //now see how many steps we need in pctile
	 while(mod(float(`qt'),1) != 0){
	    //dis "steps: `=mod(float(`qt'),1)'"
	    local steps = `steps' * 10
	    local qt = float(`qt' * 10)
	 }
      } 
      else {
	    di in red "quantiles(`quantile') out of range, should be a lie between 0 and 1"
	    exit 198
      }

      //choose a good name for rif, depending on whether retain is set
      if "`retain'" != "" { //they want to choose a name
	 local regname `retain'
      }
      else { //make our own name up
	 local fmt = regexr(string(`quantile'), "\.", "")
	 if length(string(`quantile')) == 2 { //getting .5, want 0.50
	    local fmt = `fmt'0
	 }
	 local regname rif_`fmt'
      }

      //check to see if we want to save the kernel density estimates, to save on recalculation
      if "`generate'" != "" {
	 tokenize `generate'
	 local wc : word count `generate'
	 if `wc' {
	    if `wc' != 2 {
	       di in red "Need two arguments for generate option"
	       exit 198
	    }
	    else{
	       genRIF `width' `kernop' `y' `regname' `1' `2' `steps' `qt' "`weight'`exp'" `touse'
	    }
	 }
      }
      else{
	 tempvar eval1 dens1
	 genRIF `width' `kernop' `y' `regname' `eval1' `dens1' `steps' `qt' "`weight'`exp'" `touse'
      }

      //do regression on full sample set
      qui reg `regname' `rest' [`weight'`exp'] if `touse' , `robust'

      tempname b v  
      mat `b' = e(b)
      mat `v' = e(V) //may get overwritten if bootstrap
      if "`bootstrap'" == "bootstrap" {
	 capture drop `regname' `eval1' `dens1'
	 doBootstrap "Bootstrap rifreg" "`reps'" "`v'"  "`regname' `eval1' `dens1'" "`touse'" ///
	    `" genRIF "`width'" "`kernop'" "`y'" "`regname'" "`eval1'" "`dens1'" "`steps'" "`qt'" "`weight'`exp'" "`touse'" "' ///
	    `" qui reg `regname' `rest' [`weight'`exp'] if `touse' "'
	 eret loc vcetype "Bootstrap"
      }

      if "`retain'" == "" { //they didn't want to choose a name
         capture drop `regname'
      }
      else{ //they picked a retain name, lets set all the other values to missing
         replace `regname' = . if !`touse'
      }

      eret loc title  "RIF Regression"
      eret loc cmd    "rifreg"
      eret loc depvar "`regname'"
      
      //deal with estimated weights
      if "`estwgt'" != "" {
	 useEstWgts "`y'" "`rest'" "`estname'" "`estwgt'" "`v'" "`exp_no_eq'"
      }

      //post important matrices, this destroys b, V and touse
      eret post `b' `v', noclear depname("`regname'") esample(`touse')

      //clean up weight, if we generated it
      if "`exp'" == "=`eweight'" {
	 eret loc wexp  = ""
         eret loc wtype = ""
      }
   }
   RIF_out `level'
end

program RIF_out
  args level
  loc tss  = e(rss)  + e(mss)
  loc df_t = e(df_m) + e(df_r)

  #delimit ;
  di ;
  di in gr "      Source {c |}       SS       df       MS" _c;
  di in gr _col(56) "Number of obs = " in ye %7.0f e(N) ;
  di in gr "{hline 13}{c +}{hline 30}" _c;
  di in gr _col(56) "F(" %3.0f e(df_m) "," %6.0f e(df_r) 
	  ") = " in ye %7.2f e(F) ;
  di in gr "       Model {c |} " in ye %11.0g e(mss) 
	 " " %5.0f e(df_m) " " %11.0g e(mss)/e(df_m) _c;
  di in gr _col(56) "Prob > F      = " 
	  in ye %7.4f Ftail(e(df_m),e(df_r),e(F)) ;
  di in gr "    Residual {c |} " in ye %11.0g e(rss) " " 
   	 %5.0f e(df_r) " " %11.0g e(rss)/e(df_r) _c;
  di in gr _col(56) "R-squared     = " in ye %7.4f e(r2)    ;
  di in gr "{hline 13}{c +}{hline 30}" _c;
  di in gr _col(56) "Adj R-squared = " in ye %7.4f e(r2_a) ;
  di in gr "       Total {c |} " in ye %11.0g `tss' 
	 " " %5.0f `df_t' " " %11.0g `tss'/`df_t' _c;
  di in gr _col(56) "Root MSE      = " in ye %7.5g e(rmse) ;
  #delimit cr
  //display table 
  _coef_table, level(`level')
end

//from stderr_reg.do
//augmented to use weights, as described by stderr_wgt_reg.do
program useEstWgts
   args	        ///
      y	        /// dependent var
      rest      /// names of regressors
      dflstored /// stored logistic/probit regression, so I can extract parameters
      WC        /// estimated weight
      estVar    /// estimated variance
      eweight   //  incoming actual weighting of observations

   //dis "y: `y', rest: `rest', dflstored: `dflstored', WC: `WC', estVar: `estVar', eweight:`eweight'"
   
   tempvar T1 N1 W1 NW1 NWC uC ephiC XCP SC dflvarnames esthold

   qui _estimates hold `esthold'

   qui estimates restore `dflstored'
   //todo: should check if we're using the right kind of regression: 
   //ie, logistic?, and the weighting scheme
   qui gen `T1' = `e(depvar)'
   
   qui sum `T1'
   qui gen `N1' = r(mean)*r(N)
   qui gen `W1' = `T1' / `N1'

   qui sum `WC' [aweight=`eweight']
   qui replace `WC'=`WC' / r(sum)

   //calc NW1, NWC
   //depends on N1, W1, Wc
   qui gen `NW1' = `N1'*`W1'
   qui gen `NWC' = `N1'*`WC'

   //get XPC
   //depends on NWC
   mat accum `XCP' = `rest' [iw=`NWC'*`eweight']

   //get uC
   //depends on WC
   qui reg `y' `rest' [aw=`WC'*`eweight'], robust
   predict `uC', residual

   //get ephiC
   //depends on uC
   local `dflvarnames' : colnames e(b)
   local `dflvarnames' : subinstr local `dflvarnames' "_cons" "", word
   qui reg `uC' ``dflvarnames'' [aw=`eweight'] if `T1' == 0
   predict `ephiC', xb

   //get SC
   //depends on NW1, NWC, uC, ephiC
   mat accum `SC' = `rest' [iw=(`eweight'*`NWC'*(`uC'-`ephiC')+`NW1'*`ephiC')^2]

   //calculate variance, finally
   //depends on XCP, and SC
   mat `estVar' = syminv(`XCP')*`SC'*syminv(`XCP')

*********
//   //calculate proper stderr's and covariance matrix
//   //get NWC from dflweight estimate
//   //get the weight expression without '=' sign
//   //VNx is the new variances
//   tempname NW0 NW1 NW2 names_nocons
//   local `names_nocons': subinstr local `rest' "_cons" "", word
//
//   //loc `dflweight' = regexr("``dflweight''", "[= ]", "")
//   qui gen `W1' = `estwgt'
//   //normalize W1 sum to 1
//   qui summ `W1', mean
//   qui replace `W1'= `W1'/r(sum)
//
//   //figure out what the choice variable was, from the dfl, 
//   //this includes all the cross variables
//   tempvar choice dflvarnames
//   qui estimates restore `dflstored'
//   //todo: should check if we're using the right kind of regression: 
//   //ie, logistic?, and the weighting scheme
//   qui gen `choice' = `e(depvar)'
//   local `dflvarnames' : colnames e(b)
//   local `dflvarnames' : subinstr local `dflvarnames' "_cons" "", word
//   local `dflvarnames' "`e(depvar)' ``dflvarnames''"
//
//   qui reg `y' `rest' [aweight=`WC'], robust
//   tempname uC
//   //need the residuals for stderr computation
//   predict `uC', residual
//
//   //todo: check whether the variable names match up??
//
//   //compute regressions, to get projection matrices
//   qui gen `W0' = `choice' / ``N0''
//   qui gen `W2' = `choice' / ``N2''
//   qui gen `NW0' = `W0' * ``N0''
//   qui gen `NW1' = `W1' * ``N1''
//   qui gen `NW2' = `W2' * ``N1''
//
//   //forvalues i = 0/2 {
//   //   tempname X`i'P VN`i' S`i'
//   //   qui mat accum `X`i'P' = ``names_nocons'' [iweight=`NW`i'']
//   //   qui mat accum `S`i''  = ``names_nocons'' [iweight=(`NW`i''*`u`i'')^2]
//   //   qui mat `VN`i'' = syminv(`X`i'P')*`S`i''*syminv(`X`i'P')
//   //}
//
//   //perform regression, but include all the cross variables
//   //todo: should this be equal to 1? it depends on how the choice var is setup
//   //todo: needs to at least be documented
//   qui reg `u1' ``dflvarnames'' if `choice' != 0
//
//   tempname ephiC
//   qui predict `ephiC', xb
//
//   tempname SC SE0 SE2 SE_np V_np //np is SE1 non-parametric
//   qui mat accum `SC' = ``names_nocons'' ///
//      [iweight=(`NW1'*(`u1'-`ephiC') + `NW2'*`ephiC')^2]
//   qui mat `estVar' = syminv(`X1P')*`SC'*syminv(`X1P')
//
//   //todo: not sure if we need these sometime in the future?
//   //mat `SE0'= vecdiag(cholesky(diag(vecdiag(`VN0'))))'
//   //mat `SE2'= vecdiag(cholesky(diag(vecdiag(`VN2'))))'
//   //mat `SE_np'= vecdiag(cholesky(diag(vecdiag(`VN_np'))))'

   _estimates unhold `esthold'
end

program variance
   args	        ///
      rifvar    /// 
      y         ///
      rest      ///
      weightexp ///
      touse

   //tempvar mlwage varlwge
   qui sum `y' [`weightexp'] if `touse'
   //gen `varlwge' = r(sd)^2
   gen `rifvar' = (`y' - r(mean) )^2 if `touse'
   qui reg `rifvar' `rest' [`weightexp'] if `touse'
end

program gini, eclass sort
   args	        ///
      rifgini   ///
      y         ///
      rest      ///
      weightexp ///
      exp_no_eq ///
      touse     

   gsort `y'   /*sort in ascending order */

   tempvar a2 b2x c2x
   tempname cum_wt tot_wt cumwy glp pvar rf gini mean twovm rfvar 
   qui{
      sum `y' [`weightexp'] if `touse'
      sca `tot_wt'=r(sum_w)
      sca `mean'= r(mean)
      sca `twovm'=2/`mean'
      gen `cum_wt' = sum(`exp_no_eq') if `touse'

      gen double `cumwy' = sum(`y'*`exp_no_eq') if `touse'
      gen double `glp'=`cumwy'/`tot_wt' if `touse'
      gen double `pvar' = `cum_wt'/`tot_wt'  if `touse'
      integ `glp' `pvar' if `touse', gen(`rfvar')
      qui sum `rfvar' if `touse'
      sca `rf'=r(max)
      gen `a2'=`twovm'*`rf' if `touse'
      sca `gini'=1-`a2'
      gen `b2x'=`a2'*`y'/`mean' if `touse'
      gen `c2x'=`twovm'*(`y'*(`pvar'-1)-`glp') if `touse'
      gen `rifgini' = `b2x'+`c2x'+1 if `touse'
   }

   qui reg `rifgini' `rest' [`weightexp'] if `touse'
   eret sca gini = `gini'

end

program genRIF
   args          ///
      width      ///
      kernop     ///
      y          ///
      regname    ///
      eval1      ///
      dens1      ///
      steps      ///
      qt         ///
      weightexp  ///
      touse      ///

   tempvar eval
   //local eval "eval"

   //see if the variables already exists
   capture confirm v `eval1' `dens1'
   //if not, compute them
   if _rc {
      pctile `eval'=`y' [`weightexp'] if `touse', nq(`steps')
      kdensity `y' [`weightexp'] if `touse', `kernop' at(`eval') gen(`eval1' `dens1') width(`width') nograph
   }
   else { //check to see if we have the right step count:
      //could be a problem if we have 0.25 and 0.5, as 
      //they'll have 100 and 10 steps(respectively), need 
      //to convert 0.5 to have 100 steps
      qui sum `eval1'
      //we have more steps than are needed, convert steps and qt to higher
      if r(N)+1 > `steps' {
	 loc qt = `qt' * ((r(N)+1)/`steps')
	 loc steps = r(N)+1
      }
      else if r(N)+1 < `steps'{
	 di in red "can't use less steps (`=r(N)+1') than are needed with generate option (`steps')"
	 exit 198
      }
   }

   local qc = `qt'/`steps'
   qui gen     `regname' = `eval1'[`qt'] + `qc'/`dens1'[`qt']    if `y' >= `eval1'[`qt']
   qui replace `regname' = `eval1'[`qt']- (1-`qc')/`dens1'[`qt'] if `y' <  `eval1'[`qt']
end

//small program to perform bootstrap
program doBootstrap, eclass
   args title /// title of the bootstrap, displayed to user
        reps  /// number of repetitions
	v     /// array that will be overwritten w/ variance
	drops /// variables that are dropped *AFTER* each run of cmds
	touse /// variables that are to be used
	cmd1  /// first command that is run, followed by 2nd
	cmd2
   //see if we have enough matrix space to run all the iterations
   if `reps' > `=c(max_matsize)' {
      di in red "matsize is not large enough for the number of repetitions requested"
      di in red "please increase it (ie: set matsize `reps')"
      exit 198
   }
   tempname bootstrap_est sav
   _estimates hold `bootstrap_est'
   _dots 0, title(`title') reps(`reps')
   forval i=1/`reps' {
      preserve
      bsample if `touse'
      `cmd1'
      `cmd2'
      cap drop `drops'
      mat `sav' = nullmat(`sav') \ e(b)
      restore
      _dots `i' 0
   }
   di
   mata : rifmean_variance("`sav'", "`v'") //overwrite the variance matrix
   mat drop `sav'
   _estimates unhold `bootstrap_est'
end

version 9
mata:
mata set matastrict on

void rifmean_variance(string scalar M, string scalar V) 
{
//   st_matrix(V)
   MV = meanvariance(st_matrix(M), 1)
//   means = MV[1,.]
//   means
   MV = diag(diagonal(MV[|2,1\.,.|])')
   //MV
   st_replacematrix(V, MV)
}
end
* $Id: rifreg.ado,v 1.13 2009/04/08 22:34:13 mgevaert Exp mgevaert $
