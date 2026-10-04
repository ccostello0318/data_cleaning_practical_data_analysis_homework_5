replace_non_numeric <- function(data, value) {
  data |> mutate(
    across(
      # Exclude first column
      -1,
      
      # If entry reads "no data," replace with NA, otherwise keep the same. Turn numeric.
      ~ as.numeric(ifelse(.x == value, NA, .x))
    )
  )
}

clean_debt_data <- function(raw_data) {
  # Ignore final column
  data <- raw_data |> select(-`Estimates start after`)
  
  # Hard coded: first 240 rows correspond to countries
  data <- data[1:240, ]
  
  # Replace "no data" entries with `NA`
  data <- replace_non_numeric(data, "no data")
  
  # Remove invalid countries
  
  data <- data[which(!is.na(data[, 1])), ] # select only non NA country names
  
  # Rename `country_name` 
  data <- data |> rename(country_name = `Central Government Debt (Percent of GDP)`)
  
  # Move text after the comma to the front
  data <- data |> mutate(
    country_name = sub("^(.*), (.*)$", "\\2 \\1", country_name)
  )
  
  # Pivot longer
  data <- data |> pivot_longer(
    cols = -1, # Ignore first column
    names_to = "year",
    values_to = "debt_pct_gdp"
  )
  
  # Change year column to a numeric
  
  data <- data |> mutate(
    year = as.numeric(year)
  )
  
  return(data)
}

clean_growth_data <- function(raw_data) {
  # Deselect columns
  data <- raw_data |> select(-Country.Code, -Indicator.Name, -Indicator.Code, -X)
  
  # Rename `country_name`
  data <- data |> rename(country_name = `Country.Name`)
  
  # Listing non country names in data set
  non_country_names_indicies <- c(2, 4, 8, 37, 50, 62, 63, 64, 65, 66, 69,
                                  74, 95, 98, 102, 103, 104, 105, 107, 110, 128,
                                  134, 135, 136, 139, 140, 142, 147, 153,
                                  156, 161, 170, 181, 183, 191, 197, 198, 204, 215, 217,
                                  218, 225, 230, 231, 236, 238, 240, 241, 249, 259)
  
  # Remove non country entities
  data <- data[-non_country_names_indicies, ]

  
  # Move text after the comma to the front
  data <- data |> mutate(
    country_name = sub("^(.*), (.*)$", "\\2 \\1", country_name)
  )
  
  # Rename table
  new_country_name <- data.frame(
    from = c("China", "Cote d'Ivoire", "Dem. Rep. Congo",
             "Rep. Congo", "Czechia", "Arab Rep. Egypt",
             "Faroe Islands", "Fed. Sts. Micronesia", "China Hong Kong SAR",
             "Islamic Rep. Iran", "St. Kitts and Nevis", "Rep. Korea",
             "Lao PDR", "St. Lucia", "China Macao SAR",
             "Naoero", "Puerto Rico (US)", "Dem. People's Rep. Korea",
             "Fed. Rep. Somalia", "South Sudan", "Sao Tome and Principe",
             "Syrian Arab Republic", "Turkiye", "St. Vincent and the Grenadines",
             "RB Venezuela", "Virgin Islands (U.S.)", "Viet Nam", "Rep. Yemen"
    ),
    new = c("People's Republic of China", "Côte d'Ivoire", "Dem. Rep. of the Congo",
            "Republic of Congo", "Czech Republic", "Egypt",
            "Faeroe Islands", "Fed. States of Micronesia", "Hong Kong SAR",
            "Iran", "Saint Kitts and Nevis", "Republic of Korea",
            "Lao P.D.R.", "Saint Lucia", "Macao SAR",
            "Nauru", "Puerto Rico", "Dem. People's Rep. of Korea",
            "Somalia", "Republic of South Sudan", "São Tomé and Príncipe",
            "Syria", "Republic of Türkiye", "Saint Vincent and the Grenadines",
            "Venezuela", "United States Virgin Islands", "Vietnam", "Yemen"
    )
  )
  
  # Rename countries using lookup table
  data <- data |>
    left_join(new_country_name, by = c("country_name" = "from")) |>
    mutate(
      country_name = coalesce(new, country_name)
    ) |>
    select(-new)
  
  

  
  
  # Pivot longer
  data <- data |> pivot_longer(
    cols = -1, # Ignore first column
    names_to = "year",
    values_to = "growth_pct_gdp"
  )
  
  # Remove X at front of year, then make numeric
  data <- data |> mutate(
    year = as.numeric(substring(year, 2))
  )
  
  
  return(data)
}

join_country_data_sets <- function(debt_raw, gdp_raw) {
  debt <- clean_debt_data(debt_raw)
  growth <- clean_growth_data(gdp_raw)
  
  combine <- debt |> inner_join(growth, by = c("country_name", "year"))
  return(combine)
}
