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
  # Replace "no data" entries with `NA`
  data <- replace_non_numeric(raw_data, "no data")
  
  # Remove invalid countries
  
  data <- data[which(!is.na(data[, 1])), ] # select only non NA country names
  
  # Rename `country_name` 
  data <- data |> rename(country_name = `Central Government Debt (Percent of GDP)`)
  
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
  
}
