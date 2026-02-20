  *! spell2panel v1.0 — converts CBS BUS spell data to a yearly panel
  program define spell2panel
      syntax , ID(varlist) STARTdate(varname) ENDdate(varname) ///
               [STARTyear(integer 2006) ENDyear(integer 2024)]

      if `startyear' >= `endyear' {
          di as error "startyear() must be less than endyear()"
          exit 198
      }

      local nyears = `endyear' - `startyear' + 1
      tempvar syr eyr

      * Step 1: trim spells to panel window
      * Dates are YYYYMMDD strings — extract year from first 4 characters
      qui gen     `syr' = real(substr(`startdate', 1, 4))
      qui gen     `eyr' = real(substr(`enddate',   1, 4))
      qui replace `eyr' = `endyear' if `eyr' > `endyear' | missing(`eyr')
      qui drop if `eyr' < `startyear'
      qui replace `syr' = `startyear' if `syr' < `startyear'

      di as text "Spells after trimming: " as result _N

      tempfile spells
      qui save `spells'

      * Step 2: id × year skeleton
      qui keep `id'
      qui duplicates drop
      local nids = _N
      qui expand `nyears'
      qui bysort `id': gen year = `startyear' - 1 + _n

      di as text "Skeleton: " as result `nids' " IDs × " `nyears' " years = " _N " rows"

      * Step 3: join all spells onto skeleton
      qui joinby `id' using `spells'

      * Step 4: drop year-spell combinations outside spell range
      qui keep if year >= `syr' & year <= `eyr'

      * Step 5: multiple spells in same year → keep last
      * YYYYMMDD strings sort chronologically, so string sort works correctly
      qui bysort `id' year (`startdate' `enddate'): keep if _n == _N

      qui drop `syr' `eyr'

      di as text "Final panel: " as result _N " observations"
  end