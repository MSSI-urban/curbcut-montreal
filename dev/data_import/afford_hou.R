## BUILD AND APPEND AFFORD DATA ################################################

build_and_append_afford_hou <- function(scales_variables_modules, scales_sequences, crs,
                                        overwrite = FALSE,inst_prefix) {
  
  # Read and prepare data ---------------------------------------------------
# 
#   # Read the data placed in the centraide folder
#   csvs <- list.files("dev/data/centraide/afford/hou", full.names = TRUE)
#   csvs_2016 <- stringr::str_subset(csvs, "2016_CO")
#   csvs_2021 <- stringr::str_subset(csvs, "2021_CO")
# 
# 
#   # 2016 data --------------------------------------------------------------
# 
#   data <- lapply(csvs_2016, read.csv, header = FALSE, sep = ";")
#   data <- lapply(data, tibble::as_tibble)
#   # Check if header are all the same
#   data_check <- lapply(data, \(x) x[1:4, 2:ncol(x)])
#   data_check <- sapply(seq_along(data_check), \(x) {
#     if (x == 1) return(TRUE)
#     identical(data_check[[x - 1]], data_check[[x]])
#   })
#   if (!all(data_check)) {
#     stop("The data you are going to rbind is not arranged the same way.")
#   }
# 
#   data_init <- data[[1]]
#   data_rest <- lapply(data[2:length(data)], \(x) x[5:nrow(x), ])
#   data_2016 <- Reduce(rbind, data_rest, init = data_init)
# 
#   # data_2016 <- data_2016[c(1:4, 6:nrow(data_2016)), ]
# 
#   # Clean up the table
#   data_2016[1,] <- lapply(data_2016[1,], \(x) {
#     if (x == "") return("ID")
#     x <- stringr::str_trim(x)
#     if (grepl("^Total", x)) return("tot")
#     if (grepl("^Propriétaire", x)) return("owner")
#     if (grepl("^Locataire", x)) return("tenant")
#     "FILTEROUT"
#   })
# 
#   data_2016[2,] <- lapply(data_2016[2,], \(x) {
#     if (x == "") return("ID")
#     x <- stringr::str_trim(x)
#     if (grepl("^Total", x)) return("tot")
#     if (grepl("^30 % ou plus du revenu est consacré aux frais de logement", x)) return("sc30")
#     if (grepl("^50 % au plus du revenu est consacré aux frais de logement", x)) return("sc50")
#     if (grepl("^80 % ou plus du revenu est consacré aux frais de logement", x)) return("sc80")
#     "FILTEROUT"
#   })
# 
#   data_2016[3,] <- lapply(data_2016[3,], \(x) {
#     if (x == "") return("ID")
#     x <- stringr::str_trim(x)
#     if (grepl("^Total – Genre de ménage", x)) return("tot")
#     if (grepl("^Ménages composés d'une seule famille de", x)) return("fam")
#     if (grepl("^Avec enfants", x)) return("wchldrn")
#     if (grepl("^Une famille de recensement monoparentale", x)) return("monop")
#     if (grepl("^Total – Ménages composés d’une personne seule (18 ans et plus)", x)) return("livaln")
#     "FILTEROUT"
#   })
# 
#   data_2016[4,] <- lapply(data_2016[4,], \(x) {
#     if (x == "Géographie") return("ID")
#     x <- stringr::str_trim(x)
#     if (grepl("^Total - Taille convenable du logement", x)) return("tot")
#     if (grepl("^De taille insuffisante", x)) return("unsuit")
#     if (grepl("^Réparations majeures requises", x)) return("majorrep")
#     "FILTEROUT"
#   })
# 
#   # Change the name
#   names(data_2016) <-
#     sapply(seq_len(ncol(data_2016)), \(x) {
#       # Grab the right column
#       dt <- data_2016[1:4, x]
#       # Glue together spaced by an underscore
#       paste0(unlist(dt), collapse = "_")
#     })
# 
#   # Filter out
#   data_2016 <- data_2016[!grepl("FILTEROUT", names(data_2016))]
# 
#   # Clean up
#   data_2016 <- data_2016[5:nrow(data_2016), ]
#   names(data_2016)[1] <- "ID"
#   data_2016$ID <- gsub(" (.*)$", "", data_2016$ID)
#   data_2016[, -1] <- suppressWarnings(sapply(data_2016[, -1], as.numeric))
# 
#   # Add the Laval secteur number
#   data_2016$ID[data_2016$ID == "Secteur"] <-
#     paste0("Secteur ", 1:6)
# 
#   # Les deux centre-ville
#   data_2016$ID[data_2016$ID == "2031"] <-
#     c("2031 | Centre-ville : Faubourg Saint- Laurent",
#       "2031 | Centre-ville : Peter-McGill")
# 
#   # Aggregate territories
#   agg <- data_2016[data_2016$ID %in% c(710, 708), 2:ncol(data_2016)] |>
#     colSums()
#   agg <- mapply(\(n, v) {
#     out <- tibble::tibble(v)
#     names(out) <- n
#     out
#   }, names(agg), agg, SIMPLIFY = FALSE) |> (\(x) Reduce(cbind, x))() |>
#     tibble::as_tibble()
#   new_1 <- cbind(tibble::tibble(ID = as.character(716)), agg) |> tibble::as_tibble()
# 
#   agg <- data_2016[data_2016$ID %in% c(706, 707), 2:ncol(data_2016)] |>
#     colSums()
#   agg <- mapply(\(n, v) {
#     out <- tibble::tibble(v)
#     names(out) <- n
#     out
#   }, names(agg), agg, SIMPLIFY = FALSE) |> (\(x) Reduce(cbind, x))() |>
#     tibble::as_tibble()
#   new_2 <- cbind(tibble::tibble(ID = as.character(715)), agg) |> tibble::as_tibble()
# 
#   data_2016 <- rbind(data_2016[!data_2016$ID %in% c(710, 708, 706, 707), ],
#                      new_1, new_2) |> tibble::as_tibble()
# 
#   # Add geometries so we can interpolate data to 2021 geometries
#   census_2016 <- cancensus::get_census("CA16", regions = list(CMA = 24462),
#                                        level = "CT", geo_format = "sf")
#   census_2021 <- cancensus::get_census("CA21", regions = list(CMA = 24462),
#                                        level = "CT", geo_format = "sf")
# 
#   census_2016 <- census_2016["GeoUID"]
#   names(census_2016)[1] <- "ID"
#   census_2021 <- census_2021["GeoUID"]
#   names(census_2021)[1] <- "ID"
# 
#   census_2016 <- merge(census_2016, data_2016, by = "ID")
# 
#   ct_data_2016 <- cc.buildr::interpolate_from_area(to = census_2021, from = census_2016,
#                                                    round_additive = TRUE,
#                                                    additive_vars = names(data_2016)[2:ncol(data_2016)],
#                                                    crs = crs)
#   ct_data_2016 <- dplyr::mutate(ct_data_2016,
#                                 dplyr::across(dplyr::where(is.numeric), ~round(.x/5)*5))
# 
#   centraide_data_2016 <- data_2016[!data_2016$ID %in% census_2016$ID, ]
# 
#   data_2016 <- rbind(sf::st_drop_geometry(ct_data_2016), centraide_data_2016)
# 
#   # 2021 data ---------------------------------------------------------------
# 
#   data <- lapply(csvs_2021, read.csv, header = FALSE, sep = ";")
#   data <- lapply(data, tibble::as_tibble)
#   # Check if header are all the same
#   data_check <- lapply(data, \(x) x[1:4, 2:ncol(x)])
#   data_check <- sapply(seq_along(data_check), \(x) {
#     if (x == 1) return(TRUE)
#     identical(data_check[[x - 1]], data_check[[x]])
#   })
#   if (!all(data_check)) {
#     stop("The data you are going to rbind is not arranged the same way.")
#   }
# 
#   data_init <- data[[1]]
#   data_rest <- lapply(data[2:length(data)], \(x) x[5:nrow(x), ])
#   data_2021 <- Reduce(rbind, data_rest, init = data_init)
# 
#   # Clean up the table
#   data_2021[1,] <- lapply(data_2021[1,], \(x) {
#     if (x == "") return("ID")
#     x <- stringr::str_trim(x)
#     if (grepl("^Total", x)) return("tot")
#     if (grepl("^Propriétaire", x)) return("owner")
#     if (grepl("^Locataire", x)) return("tenant")
#     "FILTEROUT"
#   })
# 
#   data_2021[2,] <- lapply(data_2021[2,], \(x) {
#     if (x == "") return("ID")
#     x <- stringr::str_trim(x)
#     if (grepl("^Total", x)) return("tot")
#     if (grepl("^30 % ou plus du revenu est consacré aux frais de logement", x)) return("sc30")
#     if (grepl("^50 % ou plus du revenu est consacré aux frais de logement", x)) return("sc50")
#     if (grepl("^80 % ou plus du revenu est consacré aux frais de logement", x)) return("sc80")
#     "FILTEROUT"
#   })
# 
#   data_2021[3,] <- lapply(data_2021[3,], \(x) {
#     if (x == "") return("ID")
#     x <- stringr::str_trim(x)
#     if (grepl("^Total – Genre de ménage incluant", x)) return("tot")
#     # Census families
#     if (grepl("^Ménages composés d'une seule famille de", x)) return("fam")
#     if (grepl("^Avec enfants", x)) return("wchldrn")
#     if (grepl("^Une famille de recensement monoparentale", x)) return("monop")
#     if (grepl("^Total – Ménages composés d’une personne seule (18 ans et plus)", x)) return("livaln")
#     "FILTEROUT"
#   })
# 
#   data_2021[4,] <- lapply(data_2021[4,], \(x) {
#     if (x == "Géographie") return("ID")
#     x <- stringr::str_trim(x)
#     if (grepl("^Total", x)) return("tot")
#     if (grepl("^Logement de taille non convenable", x)) return("unsuit")
#     if (grepl("^Réparations majeures requises", x)) return("majorrep")
#     "FILTEROUT"
#   })
# 
#   # Change the name
#   names(data_2021) <-
#     sapply(seq_len(ncol(data_2021)), \(x) {
#       # Grab the right column
#       dt <- data_2021[1:4, x]
#       # Glue together spaced by an underscore
#       paste0(unlist(dt), collapse = "_")
#     })
# 
#   # Filter out
#   data_2021 <- data_2021[!grepl("FILTEROUT", names(data_2021))]
# 
#   # Clean up
#   data_2021 <- data_2021[5:nrow(data_2021), ]
#   names(data_2021)[1] <- "ID"
#   data_2021$ID <- gsub(" (.*)$", "", data_2021$ID)
#   data_2021[, -1] <- suppressWarnings(sapply(data_2021[, -1], as.numeric))
# 
#   # Add the Laval secteur number
#   data_2021$ID[data_2021$ID == "Secteur"] <-
#     paste0("Secteur ", 1:6)
# 
#   data_2021$ID[data_2021$ID == "2031"] <-
#     c("2031 | Centre-ville : Faubourg Saint- Laurent",
#       "2031 | Centre-ville : Peter-McGill")
# 
#   # Aggregate territories
#   agg <- data_2021[data_2021$ID %in% c(710, 708), 2:ncol(data_2021)] |>
#     colSums()
#   agg <- mapply(\(n, v) {
#     out <- tibble::tibble(v)
#     names(out) <- n
#     out
#   }, names(agg), agg, SIMPLIFY = FALSE) |> (\(x) Reduce(cbind, x))() |>
#     tibble::as_tibble()
#   new_1 <- cbind(tibble::tibble(ID = as.character(716)), agg) |> tibble::as_tibble()
# 
#   agg <- data_2021[data_2021$ID %in% c(706, 707), 2:ncol(data_2021)] |>
#     colSums()
#   agg <- mapply(\(n, v) {
#     out <- tibble::tibble(v)
#     names(out) <- n
#     out
#   }, names(agg), agg, SIMPLIFY = FALSE) |> (\(x) Reduce(cbind, x))() |>
#     tibble::as_tibble()
#   new_2 <- cbind(tibble::tibble(ID = as.character(715)), agg) |> tibble::as_tibble()
# 
#   data_2021 <- rbind(data_2021[!data_2021$ID %in% c(710, 708, 706, 707), ],
#                      new_1, new_2) |> tibble::as_tibble()
# 
# 
#   # Add normalization -------------------------------------------------------
# 
#   names(data_2016)[2:ncol(data_2016)] <-
#     paste0(names(data_2016)[2:ncol(data_2016)], "_count")
#   result <- lapply(data_2016[, 2:ncol(data_2016)], \(x) {
#     x / data_2016$tot_tot_tot_tot_count
#   })
#   names(result) <- gsub("_count$", "_pct", names(result))
#   result <- tibble::as_tibble(as.data.frame(result))
#   data_2016 <- cbind(tibble::tibble(ID = data_2016$ID), result) |>
#     merge(data_2016, by = "ID")
# 
#   names(data_2021)[2:ncol(data_2021)] <-
#     paste0(names(data_2021)[2:ncol(data_2021)], "_count")
#   result <- lapply(data_2021[, 2:ncol(data_2021)], \(x) {
#     x / data_2021$tot_tot_tot_tot_count
#   })
#   names(result) <- gsub("_count$", "_pct", names(result))
#   result <- tibble::as_tibble(as.data.frame(result))
#   data_2021 <- cbind(tibble::tibble(ID = data_2021$ID), result) |>
#     merge(data_2021, by = "ID")
# 
# 
#   # Merge the two years -----------------------------------------------------
# 
#   names(data_2016)[2:ncol(data_2016)] <-
#     paste0(names(data_2016)[2:ncol(data_2016)], "_2016")
# 
#   names(data_2021)[2:ncol(data_2021)] <-
#     paste0(names(data_2021)[2:ncol(data_2021)], "_2021")
# 
#   data <- merge(data_2016, data_2021, by = "ID")
#   names(data)[2:ncol(data)] <- paste0("affordhou_", names(data)[2:ncol(data)])
# 
#   qs::qsave(data, "dev/data/centraide/afford_hou.qs")
  data <- qs::qread("dev/data/centraide/afford_hou.qs")
  
  # Get list of data variables ----------------------------------------------
  
  average_vars <- names(data)[grepl("_pct_\\d{4}$", names(data))]
  additive_vars <- names(data)[grepl("_count_\\d{4}$", names(data))]
  vars <- c(average_vars, additive_vars)
  
  # This will be used to inform which methods to use to calculate breaks and
  # the region values. Percentages, dollars, index, ... get treated differently.
  # See the `add_variable`'s documentation to see possible types.
  time_regex <- "_\\d{4}$"
  unique_vars <- unique(gsub(time_regex, "", vars))
  
  average_vars <- unique(gsub(time_regex, "", average_vars))
  additive_vars <- unique(gsub(time_regex, "", additive_vars))
  
  types_avg <- lapply(rep("pct", length(average_vars)), c)
  names(types_avg) <- average_vars
  types_count <- lapply(rep("count", length(additive_vars)), c)
  names(types_count) <- additive_vars
  types <- c(types_avg, types_count)
  
  # Make a parent string the same way as the types
  parent_strings <- lapply(unique_vars, \(x) "affordhou_tot_tot_tot_tot_count")
  names(parent_strings) <- unique_vars
  parent_strings[grepl("_count$", names(parent_strings))] <- "households"
  
  
  
  # Interpolate data to all possible scales ---------------------------------
  
  only_scales <- names(scales_variables_modules$scales)[
    !names(scales_variables_modules$scales) %in% c("DA", "DB",
                                                   "grd600", "grd250", "grd100", "grd50",
                                                   "grd30", "grd60", "grd120", "grd300",
                                                   "grd25", "building")
  ]
  
  only_scales_exc <- exclude_processed_scales(unique_vars = unique_vars,
                                              scales = only_scales,
                                              overwrite = overwrite,
                                              inst_prefix = inst_prefix)
  
  if (length(only_scales_exc) != 0) {
    
    names(data)[1] <- "CT_ID"
    average_vars <- names(data)[grepl("_pct_\\d{4}$", names(data))]
    additive_vars <- names(data)[grepl("_count_\\d{4}$", names(data))]
    vars <- c(average_vars, additive_vars)
    
    data_interpolated <-
      interpolate_from_census_geo(
        data = data[grepl("\\d{7}\\.\\d{2}", data$CT_ID), ],
        base_scale = "CT",
        all_scales = scales_variables_modules$scales,
        weight_by = "households",
        average_vars = average_vars,
        additive_vars = additive_vars, 
        # All region except Centraide
        only_scales = only_scales_exc[!only_scales_exc %in% c("centraide", "CT")],
        crs = crs,
        overwrite = overwrite,
        time_regex = "_\\d{4}$",
        inst_prefix = inst_prefix
      )
    
    # Other scales
    data_interpolated$scales <- c(data_interpolated$scales[!names(data_interpolated$scales) %in% c("centraide", "CT")], 
                                  scales_variables_modules$scales[c("centraide", "CT")])
    
    # Construct manually the Centraide data
    centraide_raw <- sf::st_read("dev/data/geometry/centraide_2023_raw.shp")
    # centraide_raw$UID[centraide_raw$Quartier == "Pierrefonds-Roxboro"] <- "707"
    # centraide_raw$UID[centraide_raw$Quartier == "L'Île-Bizard–Sainte-Geneviève"] <- "710"
    
    centraide_auto <- merge(centraide_raw, data, by.x = "UID", by.y = "CT_ID")
    fb_stl <- cbind(centraide_raw[centraide_raw$Quartier == "Faubourg Saint-Laurent", ],
                    data[data$CT_ID == "2031 | Centre-ville : Faubourg Saint- Laurent", ]) |> 
      tibble::as_tibble()
    fb_stl <- fb_stl[names(fb_stl) != "CT_ID"]
    petr_mc <- cbind(centraide_raw[centraide_raw$Quartier == "Peter McGill", ],
                     data[data$CT_ID == "2031 | Centre-ville : Peter-McGill", ]) |> 
      tibble::as_tibble()
    petr_mc <- petr_mc[names(petr_mc) != "CT_ID"]
    
    # Laval secteur
    lvl <- data[grepl("Secteur", data$CT_ID), ]
    lvl$CT_ID <- c("101", "102", "103", "104", "105", "106")
    lvl <- merge(centraide_raw[centraide_raw$UID %in% c("101", "102", "103", "104", "105", "106"), ],
                 lvl, by.x = "UID", by.y = "CT_ID") |> 
      tibble::as_tibble()
    
    # Bind all
    centraide_dat <- rbind(centraide_auto, sf::st_as_sf(fb_stl), sf::st_as_sf(petr_mc),
                           sf::st_as_sf(lvl))
    centraide_dat <- dplyr::bind_rows(centraide_raw[centraide_raw$Quartier == "Kahnawake", ],
                                      centraide_dat) |> 
      tibble::as_tibble()
    centraide_dat <- centraide_dat[2:ncol(centraide_dat)]
    names(centraide_dat)[1] <- "name"
    
    # Merge to the data interpolated
    data_interpolated$scales$centraide$name[
      data_interpolated$scales$centraide$name == "L'Île-Bizard?Sainte-Geneviève"
    ] <- "L'Île-Bizard–Sainte-Geneviève"
    data_interpolated$scales$centraide <- 
      dplyr::left_join(data_interpolated$scales$centraide,
                       centraide_dat[names(centraide_dat) != "geometry"], by = "name")
    
    # Merge the data to the CT centraide scale
    names(data)[1] <- "ID"
    data_interpolated$scales$CT <- 
      dplyr::left_join(data_interpolated$scales$CT,
                       data, by = "ID")
    
    # Rewrite NO interpolation for Centraide region 
    data_interpolated$interpolated_ref <- 
      rbind(data_interpolated$interpolated_ref,
            tibble::tibble(scale = c("centraide", "CT"),
                           interpolated_from = c("FALSE", "FALSE")))
    
    # Adding CT and Centraide to available scales
    data_interpolated$avail_scale <- c("CT", "centraide", data_interpolated$avail_scale)
    
    
    # Data tibble -------------------------------------------------------------
    
    data_construct(scales_data = data_interpolated$scales,
                   unique_var = unique_vars,
                   time_regex = time_regex,
                   inst_prefix = inst_prefix)
    
  }
  
  
  # Variables table ---------------------------------------------------------
  
  interpolated_df <- tibble::tibble(scale = only_scales,
                                    interpolated_from = "CT")
  interpolated_df <- rbind(interpolated_df,
                           tibble::tibble(scale = c("centraide", "CT"),
                                          interpolated_from = c(FALSE, FALSE)))
  
  only_scales <- unique(c(only_scales, "CT", "centraide"))
  
  variables <- lapply(unique_vars, \(var) {
    
    # All characteristics
    characteristics <- (\(x) {
      out <- list()
      
      if (grepl("_owner_", var)) out <- c(out, "are owners")
      if (grepl("_tenant_", var)) out <- c(out, "are tenants")
      
      if (grepl("_sc30_", var)) out <- c(out, "are spending more than 30% of their income on shelter")
      if (grepl("_sc50_", var)) out <- c(out, "are spending more than 50% of their income on shelter")
      if (grepl("_sc80_", var)) out <- c(out, "are spending more than 80% of their income on shelter")
      
      if (grepl("_unsuit_", var)) out <- c(out, "live in unsuitable accommodations (not enough bedrooms for the size and composition of the households)")
      if (grepl("_majorrep_", var)) out <- c(out, "live in dwellings needing major repairs (defective plumbing or electrical wiring; needing structural repairs to walls, floors or ceilings)")
      
      if (grepl("_family_", var)) out <- c(out, "are census families in private households")
      if (grepl("_monop_", var)) out <- c(out, "are one-parent families")
      if (grepl("_withchildren_", var)) out <- c(out, "are families with children")
      if (grepl("_livingalone_", var)) out <- c(out, "live alone")

      return(out)
    })()
    
    # Titles
    title <- (\(x) {
      out <- list()
      
      if (grepl("_owner_", var)) out <- c(out, "Owners")
      if (grepl("_tenant_", var)) out <- c(out, "Tenants")
      
      if (grepl("_sc30_", var)) out <- c(out, "Spending > 30% of income on shelter")
      if (grepl("_sc50_", var)) out <- c(out, "Spending > 50% of income on shelter")
      if (grepl("_sc80_", var)) out <- c(out, "Spending > 80% of income on shelter")
      
      if (grepl("_unsuit_", var)) out <- c(out, "Unsuitable accommodations")
      if (grepl("_majorrep_", var)) out <- c(out, "Dwellings needing major repairs")
      
      if (grepl("_family_", var)) out <- c(out, "Census families in private households")
      if (grepl("_monop_", var)) out <- c(out, "One-parent families")
      if (grepl("_withchildren_", var)) out <- c(out, "Families with children")
      if (grepl("_livingalone_", var)) out <- c(out, "Individuals living alone")

      if (length(out) == 0) return({
        if (grepl("_pct", var)) return("All households")
        return("Households")
      })
      stringr::str_to_sentence(paste0(out, collapse = ", "))
    })()
    
    short_title <- (\(x) {
      out <- list()
      
      if (grepl("_owner_", var)) out <- c(out, "Own.")
      if (grepl("_tenant_", var)) out <- c(out, "Ten.")
      
      if (grepl("_sc30_", var)) out <- c(out, ">30%.")
      if (grepl("_sc50_", var)) out <- c(out, ">50%.")
      if (grepl("_sc80_", var)) out <- c(out, ">80%.")
      
      if (grepl("_unsuit_", var)) out <- c(out, "Unsuit.")
      if (grepl("_majorrep_", var)) out <- c(out, "Maj.")
      
      if (grepl("_family_", var)) out <- c(out, "Fam.")
      if (grepl("_monop_", var)) out <- c(out, "1-p fam.")
      if (grepl("_withchildren_", var)) out <- c(out, "With child.")
      if (grepl("_livingalone_", var)) out <- c(out, "Alone.")

      if (length(out) == 0) return({
        if (grepl("_pct", var)) return("All hou.")
        return("Hou.")
      })
      paste0(out, collapse = " ")
    })()
    
    # Explanation
    explanation <- if (length(characteristics) > 1) {
      exp <- "the percentage of households that have all of the following characteristics:<ul><li>"
      exp_c <- paste0(characteristics, collapse = "<li>")
      paste0(exp, exp_c, "</ul>") 
    } else if (length(characteristics) == 1) {
      paste0("the percentage of households that ", characteristics[[1]])
    } else {
      "the percentage of all households"
    }
    if (grepl("_count$", var)) explanation <- gsub(" percentage ", " number ", explanation)
    
    # Explanation (for q5)
    exp_q5 <- if (length(characteristics) > 1) {
      exp <- "have all of the following characteristics:<ul><li>"
      exp_c <- paste0(characteristics, collapse = "<li>")
      paste0(exp, exp_c, "</ul>") 
    } else if (length(characteristics) == 1) {
      characteristics[[1]]
    } else {
      "live in the area"
    }
    if (grepl("_count$", var)) exp_q5 <- gsub(" percentage ", " number ", exp_q5)
    
    group_name <- "Households"
    group_diff <- list(
      "Data representation" = (\(x) {
        if (grepl("_count$", var)) "Number" else "Percentage"
      })(),
      
      "Tenure status" = (\(x) {
        if (grepl("_owner_", var)) return("Owners")
        if (grepl("_tenant_", var)) return("Tenants")
        return("Total")
      })(),
      
      "Shelter cost to income ratio" = structure(
        factor(
          (\(x) {
            if (grepl("_sc30_", var)) return(">30%")
            if (grepl("_sc50_", var)) return(">50%")
            if (grepl("_sc80_", var)) return(">80%")
            return(">0%")
          })(), 
          levels = c(">0%", ">30%", ">50%", ">80%")), 
        class = "slider"),
      
      "Suitability and condition" = (\(x) {
        if (grepl("_unsuit_", var)) return("Unsuitable accommodations")
        if (grepl("_majorrep_", var)) return("Dwellings needing major repairs")
        return("Total")
      })(),
      
      "Family composition" = (\(x) {
        if (grepl("_family_", var)) return("Census families in private households")
        if (grepl("_monop_", var)) return("One-parent")
        if (grepl("_withchildren_", var)) return("Families with children")
        if (grepl("_livingalone_", var)) return("Living alone")
        return("Total")
      })()
      
    )
    
    add_variable(
      variables = scales_variables_modules$variables,
      var_code = var,
      type = types[[var]],
      var_title = title,
      var_short = short_title,
      explanation = explanation,
      exp_q5 = exp_q5,
      parent_vec = parent_strings[[var]],
      classification = "sociodemo",
      theme = "Housing",
      private = FALSE,
      group_name = group_name,
      group_diff = group_diff,
      dates = c(2016, 2021),
      avail_scale = only_scales,
      source = "Centraide of Greater Montreal",
      interpolated = interpolated_df,
      # Allow title duplicate so that the parent vector is always 'households'
      # which is an already existing variable title for other parent vectors.
      allow_title_duplicate = TRUE,
      schema = list(time = time_regex)
    ) |> (\(x) x[nrow(x), ])()
  }) |> (\(x) Reduce(rbind, x))()
  
  variables <- rbind(scales_variables_modules$variables, variables)
  
  # Possible sequences ------------------------------------------------------
  
  avail_scale_combinations <-
    get_avail_scale_combinations(scales_sequences = scales_sequences,
                                 avail_scales = only_scales)
  
  
  # Modules table -----------------------------------------------------------
  
  # Facultative. If a page is to be added accompanying this data, add modules
  # description. Read the documentation of `add_module`. If no module is to be
  # created, assign `scales_variables_modules$modules` to modules.
  modules <- scales_variables_modules$modules
  modules <- modules[modules$id != "afford", ]
  
  modules <-
    modules |>
    add_module(
      id = "afford",
      theme = "Housing",
      nav_title = "Housing affordability",
      title_text_title = "Housing affordability",
      title_text_main = paste0(
        "<p><img src='centraide_logo/centraide_logo_en.png' style='width:60%;",
        "margin-left:50px;'><p>Access to affordable housing is ",
        "a fundamental human right, yet it remains a pressing challenge for ",
        "many communities. Housing is often defined as affordable when a ",
        "household spends less than 30% of its income on shelter, but the ",
        "reality for each household is much more complex."
      ),
      title_text_extra = paste0(
        "<p>The datasets visualized on this page come from the 2016 and 2021 Canad",
        "ian Censuses."),
      metadata = TRUE,
      dataset_info = paste0(
        "<p>The census data (2016-2021) on this page comes from custom tabulations ",
        "from Statistics Canada ordered by Centraide of Greater Montreal</p>"
      ),
      var_left = variables[grepl("^affordhou_|^affordpop", variables$var_code), 
                           c("var_code", "group_name", "group_diff")],
      main_dropdown_title = "Unit of analysis",
      dates = c(2016, 2021),
      add_advanced_controls = c("mnd", "Data representation", "Tenure status"),
      default_var = "affordhou_tot_sc30_tot_tot_pct",
      avail_scale_combinations = avail_scale_combinations
    )
   
  # Return ------------------------------------------------------------------
  
  return(list(
    scales = scales_variables_modules$scales,
    variables = variables,
    modules = modules
  ))
  
}
