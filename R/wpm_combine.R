#' Combine all Partner Weekly Data into one tidy dataset
#'
#' @param folderpath_reports what folder are all the partner reports stored in?
#' @param folderpath_sitecoords what folder is the site coordinates files stored in? If no folder is noted, no coordinates will be merged on
#' @param folderpath_targets what folder is the targets file stored in?
#' @param folderpath_output what folder would you like to save the combines output dataset in? If no folder is noted, no file will be saved
#'
#' @export
#' @importFrom dplyr %>%
#'
#' @examples
#'  \dontrun{
#'  df_weekly <- wpm_combine("~/Week_23")}

wpm_combine <- function(folderpath_reports, folderpath_sitecoords = NULL, folderpath_targets = NULL, folderpath_output = NULL){ 

  #genreate full list of sheets within each file
    df_full_list <- wpm_identify(folderpath_reports)
  
  #combine all data into one df
    df_full_weekly <- purrr::map2_dfr(df_full_list$path, df_full_list$sheet_name,
                                   ~ wpm_import(.x, .y))
  #create week
    df_full_weekly <- wpm_addweek(df_full_weekly, date)
    
  #add mechanism id
    df_full_weekly <- wpm_addmechid(df_full_weekly)
      
  #add coordinates
    df_full_weekly <- wpm_map(df_full_weekly, folderpath_sitecoords)
    
  #add weekly targets
    df_full_weekly <- wpm_addtargets(df_full_weekly, folderpath_targets)
  
  #add extra dates
    df_full_weekly <- wpm_addpds(df_full_weekly, date)
    
  #arrange
    df_full_weekly <- df_full_weekly %>% 
      dplyr::select(fundingagency, mechanismid, partner, snu1, snu1uid, psnu, psnuuid, community, facility, 
                    facilityuid, latitude, longitude, tenxten_facility, reporting_freq, 
                    provincial_lead, site_lead,indicator, date, month, fy_week, quarter, value, target_wkly)
    
  #export
    if(!is.null(folderpath_output)){
    readr::write_csv(df_full_weekly, 
                     file.path(folderpath_output, 
                               "ZAF-Weekly-Programmme-Monitoring.csv"), 
                     na = "")
    } else {
      return(df_full_weekly)
    }
}