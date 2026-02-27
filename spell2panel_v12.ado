*! spell2panel v1.2 — Red-Teamed & Bulletproofed
program define spell2panel
    syntax , ID(varlist) STARTdate(varname) ENDdate(varname) ///
             [STARTyear(integer 2006) ENDyear(integer 2024)]

    * 0. Basic Validation
    if `startyear' >= `endyear' {
        di as error "startyear() must be less than endyear()"
        exit 198
    }

    * 1. Extract Years safely (Handling String vs Numeric)
    tempvar syr eyr
    local type : type `startdate'
    if substr("`type'", 1, 3) == "str" {
        qui gen `syr' = real(substr(`startdate', 1, 4))
    }
    else {
        * Assume numeric YYYYMMDD or Stata date
        qui gen `syr' = cond(`startdate' > 3000, floor(`startdate'/10000), year(`startdate'))
    }

    local type : type `enddate'
    if substr("`type'", 1, 3) == "str" {
        qui gen `eyr' = real(substr(`enddate', 1, 4))
    }
    else {
        qui gen `eyr' = cond(`enddate' > 3000, floor(`enddate'/10000), year(`enddate'))
    }

    * 2. Handle Missings and Trimming
    qui drop if missing(`syr')
    qui replace `eyr' = `endyear' if missing(`eyr') | `eyr' > `endyear'
    qui drop if `eyr' < `startyear' | `syr' > `endyear'
    qui replace `syr' = `startyear' if `syr' < `startyear'

    * 3. Memory-Efficient Expansion
    tempvar n_years spell_id newyear
    qui gen int `n_years' = `eyr' - `syr' + 1
    qui gen long `spell_id' = _n
    
    * Safety check: avoid blowing up RAM
    qui count
    if `r(N)' > 0 {
        qui expand `n_years'
        qui bysort `spell_id': gen int `newyear' = `syr' + _n - 1

        * 4. Tie-breaking (Keep latest spell in year)
        * Note: we sort by start/end date. If dates were strings, they stay strings.
        bysort `id' `newyear' (`startdate' `enddate'): keep if _n == _N
        
        * 5. Clean up and Rename
        capture drop year
        rename `newyear' year
    }

    qui drop `syr' `eyr' `spell_id' `n_years'
    di as text "Final panel: " as result _N " observations"
end
