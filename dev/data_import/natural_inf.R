## BUILD AND APPEND NATURAL_INF DATA ###########################################

build_and_append_natural_inf <- function(scales_variables_modules, crs) {

  # Read and prepare data ---------------------------------------------------

  # suppressPackageStartupMessages({
  #   library(raster)
  #   library(stars)
  #   library(furrr)
  #   library(tidyverse)
  #   library(qs)
  # })
  # 
  # 
  # # Convert raster data to grid polygon -------------------------------------
  # 
  # datasets <- c("habitat_qual" = "Fig11a.asc", 
  #               "habitat_con" = "Fig11b.asc", 
  #               "favorable_cc" = "Fig11c.asc",
  #               "c_flood" = "Fig13.tif", 
  #               "c_bio" = "Fig14.asc",
  #               "c_heat" = "Fig15.tif", 
  #               "c_priority" = "Fig16.tif",
  #               "flood" = "Flood_CMM/Flood_CMM.tif",
  #               "heat" = "heatcoolislands/heatislands3.asc",
  #               "cool" = "heatcoolislands/coolislands5.asc")
  # 
  # # # Data used to identify priority areas for conservation
  # # habitat_quality <- 
  # #   read_stars("dev/data/natural_inf/2018_FDS_InfraNat_Conn/Fig11a.asc")
  # # 
  # # habitat_connectivity <- 
  # #   read_stars("dev/data/2018_FDS_InfraNat_Conn/Fig11b.asc")
  # # # The following is: Climatic conditions favorable to the 14 vertebrate species
  # # # selected for analysis in "Maure, F., et al. (2018). Le rôle des 
  # # # infrastructures naturelles dans la prévention des inondations dans la CMM."
  # # favorable_climatic_conditions <- 
  # #   read_stars("dev/data/natural_inf/2018_FDS_InfraNat_Conn/Fig11c.asc")
  # # 
  # # # The following is: pixels are ranked according to their importance in the 
  # # # natural infrastructure network in terms of runoff reduction
  # # ni_contribution_flood_prevention <- 
  # #   read_stars("dev/data/natural_inf/2018_FDS_InfraNat_Conn/Fig13.tif")
  # # 
  # # # The following is: pixels are ranked according to their importance in the 
  # # # natural infrastructure network in terms of biodiversity conservation
  # # ni_contribution_biodiversity_conservation <- 
  # #   read_stars("dev/data/natural_inf/2018_FDS_InfraNat_Conn/Fig14.asc")
  # # 
  # # # The following is: pixels are ranked according to their importance in the 
  # # # natural infrastructure network in terms of urban head island reduction
  # # ni_contribution_heat_island_reduction <- 
  # #   read_stars("dev/data/natural_inf/2018_FDS_InfraNat_Conn/Fig15.tif")
  # # 
  # # # The following is: pixels are ranked according to their importance 
  # # # (conservation prioritization) in the natural infrastructure network in 
  # # # terms of the previous variables:
  # # # - Runoff reduction
  # # # - Biodiversity conservation
  # # # - Urban heat island reduction.
  # # conservation_prioritization <- 
  # #   read_stars("dev/data/natural_inf/2018_FDS_InfraNat_Conn/Fig16.tif")
  # 
  # # plan(multisession, workers = length(datasets))
  # 
  # natural_inf_tiles_raw <- 
  #   future_map2(set_names(names(datasets)), datasets, function(name, path) {
  #     
  #     data <- read_stars(paste0("dev/data/2018_FDS_InfraNat_Conn/", path))
  #     
  #     data <- 
  #       st_as_sf(data, as_points = FALSE, merge = TRUE, crs = st_crs(2950)) |> 
  #       as_tibble() |> 
  #       st_as_sf(crs = st_crs(2950)) |> 
  #       st_make_valid()
  #     
  #     if (name %in% c("heat", "cool")) {
  #       data <- 
  #         data |> 
  #         mutate(area = st_area(geometry)) |> 
  #         filter(area != max(area)) |> 
  #         dplyr::select(-area)
  #     }
  #     
  #     if (name == "flood") {
  #       data <-
  #         data |>
  #         rename(var = 1) |>
  #         mutate(rank = 50) |>
  #         group_by(rank) |>
  #         summarize(.groups = "drop")
  #     } else if (name == "heat") {
  #       data <-
  #         data |>
  #         rename(var = 1) |>
  #         mutate(rank = 50) |>
  #         group_by(rank) |>
  #         summarize(.groups = "drop")
  #     } else if (name == "cool") {
  #       data <-
  #         data |>
  #         rename(var = 1) |>
  #         mutate(rank = 26) |>
  #         group_by(rank) |>
  #         summarize(.groups = "drop")
  #     } else {
  #       data <-
  #         data |>
  #         rename(var = 1) |>
  #         mutate(rank = ntile(var, 25) + 25) |>
  #         group_by(rank) |>
  #         summarize(.groups = "drop")
  #     }
  #     
  #     data <-
  #       st_transform(data, 4326) |>
  #       filter(st_is(geometry, "POLYGON") | st_is(geometry, "MULTIPOLYGON")) |>
  #       st_cast("MULTIPOLYGON") |> 
  #       mutate(ID = seq_len(n()), .before = 1)
  #     
  #     names(data)[2] <- name
  # 
  #     data
  #     
  #   })
  # 
  # qsave(natural_inf_tiles_raw, "dev/data/natural_inf_tiles_raw.qs")
  # 
  # 
  # # To enable unique sets of priorities -------------------------------------
  # 
  # natural_inf_tiles <- 
  #   future_map2(set_names(names(datasets))[4:6], datasets[4:6], \(name, path) {
  #     
  #     data <- read_stars(paste0("dev/data/2018_FDS_InfraNat_Conn/", path))
  #     
  #     data <- 
  #       st_as_sf(data, as_points = FALSE, #merge = TRUE,
  #                crs = st_crs(2950)) |> 
  #       as_tibble() |> 
  #       st_as_sf(crs = st_crs(2950)) |> 
  #       st_make_valid() |> 
  #       st_transform(4326)
  #     
  #     data <-
  #       data |>
  #       rename(var = 1) |>
  #       mutate(rank = ntile(var, 20))
  #     
  #     names(data)[3] <- paste0(name, "_q20")
  #     
  #     data[, paste0(name, "_q20")]
  #     
  #   })
  # 
  # # Change list order
  # natural_inf_tiles <- natural_inf_tiles[c("c_bio", "c_heat", "c_flood")]
  # 
  # natural_inf_tiles[[1]] <- 
  #   natural_inf_tiles[[1]] |> 
  #   mutate(ID = row_number())
  # 
  # natural_inf_tiles_2 <- natural_inf_tiles
  # 
  # natural_inf_tiles_2[[1]] <- 
  #   natural_inf_tiles_2[[1]] |> 
  #   mutate(geometry = st_centroid(geometry))
  # 
  # natural_inf_tiles_2 <- reduce(natural_inf_tiles_2, st_join)
  # 
  # natural_inf_tiles_2 <- 
  #   natural_inf_tiles_2 |> 
  #   st_drop_geometry() |> 
  #   left_join(dplyr::select(natural_inf_tiles[[1]],
  #                    -everything(), ID), by = "ID") |> 
  #   dplyr::select(-ID) |> 
  #   mutate(across(where(is.numeric), ~replace(., is.na(.), 0))) |> 
  #   st_as_sf()
  # 
  # natural_inf_tiles <- 
  #   natural_inf_tiles_2 |> 
  #   group_by(c_bio_q20, c_heat_q20, c_flood_q20) |> 
  #   summarize(.groups = "drop")
  # 
  # natural_inf_tiles <- 
  #   natural_inf_tiles |>
  #   filter(st_is(geometry, "POLYGON") | st_is(geometry, "MULTIPOLYGON")) |>
  #   st_cast("MULTIPOLYGON")
  # 
  # natural_inf_tiles <- 
  #   natural_inf_tiles |> 
  #   mutate(ID = dplyr::row_number(), .before = 1)
  # 
  # natural_inf_tiles <- 
  #   natural_inf_tiles |> 
  #   set_names(c("ID", "biodiversity", "heat_island", "flood", "geometry"))
  # 
  # qsave(natural_inf_tiles, "dev/data/natural_inf_tiles.qs")
  # 
  # rm(natural_inf_tiles_2)
  # 
  # 
  # # Join all pixels into one df ---------------------------------------------
  # 
  # natural_inf <- 
  #   future_map2(set_names(names(datasets)), datasets, function(name, path) {
  #     
  #     data <- read_stars(paste0("dev/data/2018_FDS_InfraNat_Conn/", path))
  #     
  #     data <- 
  #       st_as_sf(data, as_points = FALSE, #merge = TRUE,
  #                crs = st_crs(2950)) |> 
  #       as_tibble() |> 
  #       st_as_sf(crs = st_crs(2950)) |> 
  #       st_make_valid()
  #     
  #     if (name %in% c("heat", "cool")) {
  #       data <- 
  #         data |> 
  #         mutate(area = st_area(geometry)) |> 
  #         filter(area != max(area)) |> 
  #         dplyr::select(-area)
  #     }
  #     
  #     data <- 
  #       st_transform(data, 4326)
  #     
  #     if (name == "flood") {
  #       data <-
  #         data |>
  #         rename(var = 1) |>
  #         mutate(rank = 100)
  #     } else if (name == "heat") {
  #       data <-
  #         data |>
  #         rename(var = 1) |>
  #         mutate(rank = 100)
  #     } else if (name == "cool") {
  #       data <-
  #         data |>
  #         rename(var = 1) |>
  #         mutate(rank = 1)
  #     } else {
  #       data <-
  #         data |>
  #         rename(var = 1) |>
  #         mutate(rank = ntile(var, 100))
  #     }
  #     
  #     names(data)[1] <- name
  #     names(data)[3] <- paste0(name, "_q100")
  #     
  #     data
  #     
  #   })
  # 
  # # Move to centroids for the first dataframe
  # natural_inf[[1]] <- 
  #   natural_inf[[1]] |> 
  #   mutate(geometry = st_centroid(geometry))
  # 
  # natural_inf <- 
  #   natural_inf |> 
  #   reduce(st_join) |> 
  #   st_drop_geometry()
  # 
  # qsave(natural_inf, "dev/data/natural_inf.qs")
  # 
  # 
  # # Pre-computations --------------------------------------------------------
  # 
  # natural_inf_ <- qread("dev/data/natural_inf.qs")
  # 
  # natural_inf <- list()
  # 
  # # Original priorities
  # natural_inf$original_priorities <- map_dfr(0:25, ~{
  #   
  #   con_pct <- .x * 4
  #   dat <- natural_inf_[natural_inf_$c_priority_q100 > 100 - con_pct,]
  #   bio <- sum(dat$c_bio, na.rm = TRUE) / sum(natural_inf_$c_bio, na.rm = TRUE)
  #   heat <- sum(dat$c_heat, na.rm = TRUE) / sum(natural_inf_$c_heat, na.rm = TRUE)
  #   flood <- sum(dat$c_flood, na.rm = TRUE) / sum(natural_inf_$c_flood, 
  #                                                 na.rm = TRUE)
  # 
  #   tibble(slider = .x,
  #          conservation_pct = con_pct,
  #          c_biodiversity = bio,
  #          c_heat_island = heat,
  #          c_flood = flood)
  #   
  # })
  # 
  # # Custom priorities
  # natural_inf_tiles <- qread("dev/data/natural_inf_tiles.qs")
  # 
  # natural_inf_custom <-
  #   natural_inf_tiles |>
  #   mutate(area = units::drop_units(st_area(geometry))) |> 
  #   st_drop_geometry()
  # 
  # # plan(multisession, workers = 10)
  # 
  # slider_values <- c(0, 0.5, 1, 1.5, 2)
  # top_slider <- 0:25
  # all_sliders <-
  #   tibble(
  #     biodiversity = rep(0, 13),
  #     heat_island = c(0, 0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5, 1.5, 2, 2, 2),
  #     flood = c(1, 1.5, 2, 0, 1, 1.5, 2, 0.5, 1, 2, 0.5, 1, 1.5)) |>
  #   add_row(
  #     biodiversity = rep(0.5, 16),
  #     heat_island = c(0, 0, 0.5, 0.5, 1, 1, rep(1.5, 5), rep(2, 5)),
  #     flood = c(1.5, 2, 1.5, 2, 1.5, 2, 0, 0.5, 1, 1.5, 2, 0, 0.5, 1, 1.5, 2)) |>
  #   add_row(
  #     biodiversity = rep(1, 20),
  #     heat_island = c(rep(0, 4), 0.5, 0.5, rep(1, 4), rep(1.5, 5), rep(2, 5)),
  #     flood = c(0, 1, 1.5, 2, 1.5, 2, 0, 1, 1.5, 2, 0, 0.5, 1, 1.5, 2, 0, 0.5, 1, 
  #               1.5, 2)) |>
  #   add_row(
  #     biodiversity = rep(1.5, 22),
  #     heat_island = c(rep(0, 4), rep(0.5, 5), rep(1, 5), rep(1.5, 3), rep(2, 5)),
  #     flood = c(0.5, 1, 1.5, 2, 0, 0.5, 1, 1.5, 2, 0, 0.5, 1, 1.5, 2, 0.5, 1, 2,
  #               0, 0.5, 1, 1.5, 2)) |>
  #   add_row(
  #     biodiversity = rep(2, 21),
  #     heat_island = c(rep(0, 3), rep(0.5, 5), rep(1, 5), rep(1.5, 5), rep(2, 3)),
  #     flood = c(0.5, 1, 1.5, 0, 0.5, 1, 1.5, 2, 0, 0.5, 1, 1.5, 2, 0, 0.5, 1, 1.5, 
  #               2, 0.5, 1, 1.5))
  # 
  # natural_inf$custom <- map_dfr(top_slider, \(x) {
  #   
  #   kept_pct <- x / 25
  #   kept_area <- kept_pct * sum(natural_inf_custom$area)
  #     
  #   map_dfr(seq_len(nrow(all_sliders)), \(y) {
  #     
  #     df <- all_sliders[y,]
  #     
  #     natural_inf_custom |> 
  #       mutate(biodiversity = biodiversity * df$biodiversity,
  #              heat_island = heat_island * df$heat_island,
  #              flood = flood * df$flood) |> 
  #       mutate(score = biodiversity + heat_island + flood) |> 
  #       select(-biodiversity, -heat_island, -flood) |> 
  #       arrange(-score) |> 
  #       mutate(ite_area = slider::slide_dbl(area, sum, .before = n())) |> 
  #       filter(ite_area <= kept_area) |> 
  #       mutate(slider = x,
  #              biodiversity = df$biodiversity,
  #              heat_island = df$heat_island,
  #              flood = df$flood) |> 
  #       # Pre-compute ID/score columns to directly fit in `scale_fill_natural_inf`
  #       rename(group = ID) |> 
  #       mutate(score = as.character(round(score / max(score) * 24) + 26),
  #              group = as.character(group)) |> 
  #       left_join(select(colour_table, group, value), 
  #                 by = c("score" = "group")) |> 
  #       select(-area, -ite_area, -score) |> 
  #       mutate(value = if_else(is.na(value), colour_table$value[
  #         colour_table$group == 26], value))
  #     })
  #   })
  # 
  # # Split for faster retrieval
  # natural_inf$custom <- split(natural_inf$custom, natural_inf$custom$slider)
  # 
  # # Pre-compute values for the explore panel
  # total_areas <- 
  #   natural_inf_custom |> 
  #   mutate(total_biodiversity = biodiversity * area,
  #          total_heat_island = heat_island * area,
  #          total_flood = flood * area) |> 
  #   summarize(total_biodiversity = sum(total_biodiversity),
  #             total_heat_island = sum(total_heat_island),
  #             total_flood = sum(total_flood))
  # 
  # natural_inf$custom_explore <- map_dfr(top_slider[top_slider != 0], function(x) {
  #   
  #   map_dfr(seq_len(nrow(all_sliders)), \(y) {
  # 
  #     df <- all_sliders[y,]
  #     
  #     ids <- 
  #       natural_inf$custom[[x]] |> 
  #       filter(slider == x,
  #              biodiversity == df$biodiversity,
  #              heat_island == df$heat_island,
  #              flood == df$flood) |> 
  #       pull(group)
  #     
  #     perc_protection <- 
  #       natural_inf_custom |> 
  #       filter(ID %in% ids) |> 
  #       mutate(biodiversity = biodiversity * area,
  #              heat_island = heat_island * area,
  #              flood = flood * area) |> 
  #       summarize(
  #         biodiversity = sum(biodiversity) / total_areas$total_biodiversity,
  #         heat_island = sum(heat_island) / total_areas$total_heat_island,
  #         flood = sum(flood) / total_areas$total_flood)
  #     
  #     tibble(slider = x,
  #            conservation_pct = slider * 4,
  #            biodiversity = df$biodiversity,
  #            heat_island = df$heat_island,
  #            flood = df$flood,
  #            c_biodiversity = perc_protection$biodiversity,
  #            c_heat_island = perc_protection$heat_island,
  #            c_flood = perc_protection$flood)
  #   })
  #   
  # })
  # 
  # CSD_area <- 
  #   scales_variables_modules$scales$CMA$CSD |> 
  #   st_transform(32618) |> 
  #   st_area() |> 
  #   units::drop_units() |> 
  #   sum()
  # 
  # natural_inf_tiles_raw <- qread("dev/data/natural_inf_tiles_raw.qs")
  # 
  # natural_inf$explore <- map(natural_inf_tiles_raw, ~{
  #   .x |> 
  #     st_transform(32618) |> 
  #     st_area() |> 
  #     units::drop_units() |> 
  #     sum()}) |> 
  #   enframe() |> 
  #   mutate(value = unlist(value)) |> 
  #   mutate(value_pct = value / CSD_area) |> 
  #   filter(name != "c_priority")
  # 
  # qsavem(natural_inf, natural_inf_custom, 
  #        file = "dev/data/modules_raw_data/natural_inf.qs")
  
  qs::qload("dev/data/built/natural_inf.qs")

  
  # Variables table ---------------------------------------------------------

  # For more information on how to append the information, read the
  # documentation of `add_variable`. Every variable needs to have its own entry
  # in the variables table. The following is an example.

  variables <-
    add_variable(
      variables = scales_variables_modules$variables,
      var_code = "habitat_qual",
      type = "qual",
      var_title = "Habitat quality",
      var_short = "Hab. quality",
      explanation = paste0("the ability of an ecosystem to provide conditions ",
                           "appropriate for individual and population ",
                           "persistence"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "habitat_con",
      type = "qual",
      var_title = "Habitat connectivity",
      var_short = "Hab. connect.",
      explanation = paste0("the degree to which a landscape facilitates or ",
                           "impedes animal movement and other ecological ",
                           "processes"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "favorable_cc",
      type = "qual",
      var_title = "Favourable climatic conditions",
      var_short = "Favourable CC",
      explanation = paste0("the degree to which past and future climatic ",
                           "conditions are favourable to species life"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "c_flood",
      type = "qual",
      var_title = "Contribution to flood prevention",
      var_short = "Flood prev.",
      explanation = paste0("the contribution of natural infrastructure to flood ",
                           "prevention"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "c_bio",
      type = "qual",
      var_title = "Contribution to biodiversity conservation",
      var_short = "Biodiversity cons.",
      explanation = paste0("the contribution of natural infrastructure to ",
                           "biodiversity conservation"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "c_heat",
      type = "qual",
      var_title = "Contribution to heat island reduction",
      var_short = "Heat island reduct.",
      explanation = paste0("the contribution of natural infrastructure to ",
                           "heat-island reduction"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "c_priority",
      type = "qual",
      var_title = "Conservation priority",
      var_short = "Conservation",
      explanation = paste0("the importance of preserving natural ",
                           "infrastructure, based on its total contribution to ",
                           "biodiversity conservation, heat-island reduction, ",
                           "and flood protection"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "flood",
      type = "qual",
      var_title = "Flood risks",
      var_short = "Flood risks",
      explanation = paste0("the land areas at risk of flooding"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "heat",
      type = "qual",
      var_title = "Heat islands",
      var_short = "Heat islands",
      explanation = paste0("the urban areas with a higher air or surface ",
                           "temperature than other areas in the same urban ",
                           "environment"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    ) |>
    add_variable(
      var_code = "cool",
      type = "qual",
      var_title = "Cool islands",
      var_short = "Cool islands",
      explanation = paste0("the urban areas with a lower air or surface ",
                           "temperature than other areas in the same urban ",
                           "environment"),
      exp_q5 = NA,
      parent_vec = NA,
      classification = NA,
      theme = "Ecology",
      private = TRUE,
      pe_include = FALSE,
      dates = NA,
      avail_scale = NA,
      source = "David Suzuki Foundation",
      interpolated = NA,
      schema = list(NULL)
    )


  # Modules table -----------------------------------------------------------
  
  modules <-
    scales_variables_modules$modules |>
    add_module(
      id = "natural_inf",
      theme = "Ecology",
      nav_title = "Natural infrastructure",
      title_text_title = "Natural infrastructure",
      title_text_main = paste0(
        "<p>Natural ecosystems contribute to well-being, quality of life and ",
        "public health in cities. This page quantifies the benefits provided ",
        "by urban trees and wooded areas to biodiversity ",
        "conservation, flood prevention, and heat-island reduction. "
      ),
      title_text_extra = paste0(
        "<p>The datasets visualized on this page come from Habitat. Note ",
        "that the natural infrastructure included in the study that generated t",
        "his data only covers approximately 25% of the Montreal region. For mor",
        "e information on the methods and data used for this page, visit the pu",
        "blication <a href = ‘https://fr.davidsuzuki.org/publication-scientifiq",
        "ue/le-role-des-infrastructures-naturelles-dans-la-prevention-des-inond",
        "ations-dans-la-communaute-metropolitaine-de-montreal/ ‘ target = ‘_bla",
        "nk’>“Le rôle des infrastructures naturelles dans la prévention des ino",
        "ndations dans la Communauté métropolitaine de Montréal”</a>."
      ),
      regions = NULL,
      metadata = TRUE,
      dataset_info = paste0(
        "<p>Data made available by the firm Habitat. For more information on th",
        "e methods and data used for this page, see <a href = 'https://fr.dav",
        "idsuzuki.org/publication-scientifique/le-role-des-infrastructures-natr",
        "elles-dans-la-prevention-des-inondations-dans-la-communaute-metropolit",
        "aine-de-montreal/'>Maure et al., 2018, Le rôle des infrastructures nat",
        "urelles dans la prévention des inondations dans la Communauté métropol",
        "itaine de Montréal, Fondation David Suzuki.</a></p>"
      )
    )
  
  
  # Save natural inf in its own sqlite db -----------------------------------

  # db_write_prod(natural_inf$original_priorities,
  #               table_name = "natural_inf_original_priorities",
  #               schema = "mtl", primary_key = "slider")
  # db_write_prod(natural_inf$custom_explore,
  #               table_name = "natural_inf_custom_explore",
  #               schema = "mtl", primary_key = NULL,
  #               index = c("slider", "biodiversity", "heat_island", "flood"))
  # db_write_prod(natural_inf$custom_explore,
  #               table_name = "natural_inf_custom_explore",
  #               schema = "mtl", primary_key = NULL,
  #               index = c("slider", "biodiversity", "heat_island", "flood"))
  # db_write_prod(natural_inf$explore,
  #               table_name = "natural_inf_explore",
  #               schema = "mtl", primary_key = NULL)
  # 
  # custom <- purrr::map_dfr(natural_inf$custom, \(x) {
  #   out <- dplyr::group_by(x, slider, biodiversity, heat_island, flood) |>
  #     dplyr::summarize(group_values = list({setNames(as.list(value), group)}),
  #                      .groups = 'drop')
  # 
  #   # Make it a JSON for the database
  #   out$group_values <- lapply(out$group_values, jsonlite::toJSON, auto_unbox = TRUE)
  #   out
  # })
  # db_write_prod(custom, table_name = "natural_inf_custom",
  #               schema = "mtl", primary_key = NULL)


  # Return ------------------------------------------------------------------

  return(list(
    scales = scales_variables_modules$scales,
    variables = variables,
    modules = modules
  ))

}

