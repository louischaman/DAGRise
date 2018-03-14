#' get a sub-section of the code
#'
#' @param raw_code lines of code 
get_subcode = function(raw_code, start_line, end_line, inputs, outputs){
      
      code_snippit = raw_code[start_line:end_line]
      
      load_packages_line = c(
            'packages_used = readRDS("processed_data/packages_used.rds")',
            'lapply(packages_used, require, character.only=TRUE)')
      
      input_lines = NULL
      for(input in inputs){
            input_line = paste0(input, ' = readRDS("processed_data/', input,'.rds")' )
            input_lines = c(input_lines, input_line)
      }
      
      output_lines = NULL
      for(output in outputs){
            output_line = paste0('saveRDS( ',output,', "processed_data/', output,'.rds")' )
            output_lines = c(output_lines, output_line)
      }
      
      snippet = c(load_packages_line, 
                  input_lines, 
                  code_snippit, 
                  output_lines)
      
      return( snippet)
      
}