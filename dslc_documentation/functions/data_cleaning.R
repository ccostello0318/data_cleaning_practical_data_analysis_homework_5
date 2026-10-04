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