#### Build translation #########################################################

# Load libraries ----------------------------------------------------------

library(dplyr)
library(qs)
if (is.null(get0("stories"))) {
  stories <- qs::qread("data/stories.qs")
}
if (is.null(get0("variables"))) {
  variables <- qs::qread("data/variables.qs")
}
if (is.null(get0("modules"))) {
  modules <- qs::qread("data/modules.qs")
}
if (is.null(get0("regions_dictionary"))) {
  regions_dictionary <- qs::qread("data/regions_dictionary.qs")
}
if (is.null(get0("scales_dictionary"))) {
  scales_dictionary <- qs::qread("data/scales_dictionary.qs")
}

# From a CSV to code to create tibbles ------------------------------------
# form_translation_tibble <- function(df) {
# 
#   df <- df[!is.na(df$fr), ]
# 
#   en <- gsub("(.{55})", '\\1",\n"', df$en)
#   fr <- gsub("(.{55})", '\\1",\n"', df$fr)
# 
#   # If it's too long, not all lines are printed. So save in a file!
#   if (nrow(df) < 200) {
#     writeLines(paste0('tibble(en = character(), fr = character()) |>\n',
# 
#                       paste0('add_row(en = paste0("', en, '"), \nfr = paste0("', fr, '"))',
#                              collapse = ' |> \n'))
#     )
#   } else {
# 
#     iter_size <- ceiling(length(en) / ceiling(length(en)/250))
#     translation_tibbles_list <-
#       lapply(seq_len(round(length(en)/250)), \(x) {
#         en1 <- en[((x - 1) * iter_size + 1):(x * iter_size)]
#         fr1 <- fr[((x - 1) * iter_size + 1):(x * iter_size)]
#         en1 <- en1[!is.na(en1) & !is.na(fr1)]
#         fr1 <- fr1[!is.na(en1) & !is.na(fr1)]
# 
#         paste0('RENAME_TKTK <- \n',
#                if (x != 1) 'RENAME_TKTK |>\n',
#                if (x == 1) 'tibble(en = character(), fr = character()) |>\n',
#                paste0('add_row(en = paste0("', en1, '"), \nfr = paste0("', fr1, '"))',
#                       collapse = ' |> \n')) |> paste0("\n\n")
#       })
# 
#     reduce(translation_tibbles_list, paste0) |>
#       writeLines("translated_tb.txt")
#     message(
#       paste0("File `translated_tb.txt` created in the root of the directory. ",
#              "Rename RENAME_TKTK"))
#   }
# 
# }

# .t <- \(x) deeplr::toFrench2(x, auth_key = .deepl_key)
# split_string <- function (input_string, split_length = 70) {
#   num_chunks <- ceiling(nchar(input_string) / split_length)
#   split_strings <- character(num_chunks)
#   for (i in 1:num_chunks) {
#     start_index <- (i - 1) * split_length + 1
#     end_index <- min(i * split_length, nchar(input_string))
#     split_strings[i] <- substr(input_string, start_index, end_index)
#   }
#   # Concatenating strings using paste0, ensuring no row exceeds 70 characters
#   result <- paste0("paste0(\n\"", paste0(split_strings, collapse = "\", \n\""), "\")")
#   return(result)
# }
# 
t_max <- function(en) {
  # Assuming .t function is defined elsewhere
  fr <- sapply(en, .t, USE.NAMES = FALSE)
  # Creating output strings
  out <- character(length(en))
  for (i in 1:length(en)) {
    en_str <- en[i]
    fr_str <- fr[i]
    out[i] <- paste0('add_row(en = "', en_str, '", \nfr = "', fr_str, '")')
  }
  # Writing lines with collapse to ensure proper formatting
  writeLines(paste0(out, collapse = ' |> \n'))
}


# Run all the translation preparation -------------------------------------
source("dev/translation/variables.R", encoding = "utf-8")
source("dev/translation/dictionaries.R", encoding = "utf-8")
source("dev/translation/custom_pages.R", encoding = "utf-8")
source("dev/translation/authors.R", encoding = "utf-8")
source("dev/translation/access.R", encoding = "utf-8")
source("dev/translation/afford.R", encoding = "utf-8")
source("dev/translation/modules.R", encoding = "utf-8")
source("dev/translation/tenure.R", encoding = "utf-8")
source("dev/translation/home_and_about.R", encoding = "utf-8")
source("dev/translation/stories.R", encoding = "utf-8")
source("dev/translation/predesign_translation.R", encoding = "utf-8")
source("dev/translation/misc.R", encoding = "utf-8")
source("dev/translation/ages.R", encoding = "utf-8")



# Retrieve and bind translated csvs ---------------------------------------

translation_df <- 
  dplyr::bind_rows(curbcut::cc_translation_df,
            translation_variables,
            translation_dictionaries,
            translation_custom_pages,
            translation_authors,
            translation_access,
            translation_afford,
            translation_tenure,
            translation_pages,
            translation_home_and_about,
            translation_stories,
            translation_misc,
            translation_age,
            
            translation_temp) |> 
  dplyr::distinct(en, .keep_all = TRUE)

if (translation_df$fr |> is.na() |> sum() > 0)
  stop("`NA` translations are forbidden (will break some translations), e.g. `get_zoom_code`")


# Test --------------------------------------------------------------------

# Search the whole variables table. Is everything translated?
t_max <- function(en) {
  # Assuming .t function is defined elsewhere
  fr <- sapply(en, .t, USE.NAMES = FALSE)
  # Creating output strings
  out <- character(length(en))
  for (i in 1:length(en)) {
    en_str <- en[i]
    fr_str <- fr[i]
    out[i] <- paste0('add_row(en = "', en_str, '", \nfr = "', fr_str, '")')
  }
  # Writing lines with collapse to ensure proper formatting
  writeLines(paste0(out, collapse = ' |> \n'))
}

is_translated <- function(strings) {
  strings <- strings[!is.na(strings)]
  not_there <- strings[!strings %in% translation_df$en]
  
  if (length(not_there) > 0) {
    warning(sprintf("Following strings not translated: \n%s",
         paste0(unique(not_there), collapse = "\n")))
    t_max(unique(not_there))
  }
}

int_from <- sapply(variables$interpolated, \(x) {
  if (!all(is.na(x))) x$interpolated_from
}) |> unlist() |> unique()
int_from <- int_from[!int_from %in% c("FALSE", scales_dictionary$scale)]

# VARIABLES
is_translated(variables$var_title)
is_translated(variables$var_short)
is_translated(variables$exp_q5)
is_translated(variables$explanation)
is_translated(variables$explanation_nodet)
is_translated(unique(unlist(variables$rankings_chr)))
is_translated(unique(unlist(variables$theme)))
is_translated(unique(variables$source))
is_translated(int_from)

group_diffs <- unique(c(unname(unlist(variables$group_diff)), names(unlist(variables$group_diff))))
group_diffs <- group_diffs[!curbcut:::is_numeric(group_diffs)]
is_translated(unique(variables$group_name))

# PAGES
is_translated(modules$id)
is_translated(modules$theme)
is_translated(modules$nav_title)
is_translated(modules$title_text_title)
is_translated(modules$title_text_main)
is_translated(modules$title_text_extra)
is_translated(modules$dataset_info)
is_translated(modules$main_dropdown_title)

# SCALES DICTIONARY
is_translated(scales_dictionary$sing)
is_translated(scales_dictionary$sing_with_article)
is_translated(scales_dictionary$plur)
is_translated(scales_dictionary$slider_title)
is_translated(scales_dictionary$place_heading)
is_translated(scales_dictionary$place_name)
is_translated(scales_dictionary$subtext)

# REGIONS DICTIONARY
is_translated(regions_dictionary$name)
is_translated(regions_dictionary$to_compare)
is_translated(regions_dictionary$to_compare_determ)
is_translated(regions_dictionary$to_compare_short)

# STORIES
is_translated(unique(unlist(stories$themes)))
is_translated(stories$title)
is_translated(stories$short_title)
is_translated(stories$preview_en)

# Save to the translation files -------------------------------------------

qs::qsave(translation_df, "data/translation_df.qs")

