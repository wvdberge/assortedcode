*! spell2panel v1.3 — Maximum Memory Efficiency (Year-by-Year)
program define spell2panel
    syntax , ID(varlist) STARTdate(varname) ENDdate(varname) ///
             [STARTyear(integer 2006) ENDyear(integer 2024)]

    * 0. Validation
    if `startyear' >= `endyear' {
        di as error "startyear() must be less than endyear()"
        exit 198
    }

    * 1. Prepare the source spells (once)
    tempvar syr eyr
    local type : type `startdate'
    if substr("`type'", 1, 3) == "str" {
        qui gen int `syr' = real(substr(`startdate', 1, 4))
    }
    else {
        qui gen int `syr' = cond(`startdate' > 3000, floor(`startdate'/10000), year(`startdate'))
    }

    local type : type `enddate'
    if substr("`type'", 1, 3) == "str" {
        qui gen int `eyr' = real(substr(`enddate', 1, 4))
    }
    else {
        qui gen int `eyr' = cond(`enddate' > 3000, floor(`enddate'/10000), year(`enddate'))
    }

    * Basic cleaning
    qui drop if missing(`syr')
    qui replace `eyr' = `endyear' if missing(`eyr') | `eyr' > `endyear'
    qui drop if `eyr' < `startyear' | `syr' > `endyear'
    
    * Save prepared spells to a tempfile
    tempfile master_spells
    qui save `master_spells'
    
    * 2. Iterate through each year
    local filelist ""
    forval y = `startyear'/`endyear' {
        di as text "Processing year: " as result `y' "..." _continue
        
        * Efficiently load only spells active in year 'y'
        qui use `master_spells', clear
        qui keep if `syr' <= `y' & `eyr' >= `y'
        
        if _N > 0 {
            * Keep the latest spell for this ID in this specific year
            qui bysort `id' (`startdate' `enddate'): keep if _n == _N
            
            qui gen int year = `y'
            
            tempfile f`y'
            qui save `f`y''
            local filelist `filelist' `f`y''
            di as text " [" as result _N " rows]"
        }
        else {
            di as text " [Empty]"
        }
    }

    * 3. Assemble the final panel
    clear
    if "`filelist'" != "" {
        qui append using `filelist'
        label variable year "Panel Year"
    }
    
    di as text "Final panel assembly complete. Total rows: " as result _N
end
