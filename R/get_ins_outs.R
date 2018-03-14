#' gets inputs and outputs of code
#'
#' @param sc source code
#' @param step which step to get from
get_in_out_step = function(sc, step){
      i = step
      starts = c(1, which(sc == "breakfunction()")+1)
      ends = c(which(sc == "breakfunction()")-1,length(sc))
      
      
      dtm = CodeDepends::getDetailedTimelines(sc, getInputs(sc))
      
      
      dtm_steps = dtm$step %in% starts[i]:ends[i]
      if(i == length(starts)){
            dtm_steps_after = NULL
      }else
            dtm_steps_after = dtm$step %in% starts[i+1]:length(sc)
      
      vars = as.character(unique(dtm$var))
      
      vars_used_step = dtm[dtm_steps & dtm$used,]
      vars_defined_step = dtm[dtm_steps & dtm$defined,]
      
      inputs = NULL
      outputs = NULL
      
      for(j in 1:length(vars)){
            var = vars[j]
            var_defined = which(dtm[dtm$var == var & dtm_steps,]$defined)
            var_used = which(dtm[dtm$var == var & dtm_steps,]$used)
            var_used_after = which(dtm[dtm$var == var & dtm_steps_after,]$used)
            
            if(length(var_used)>0){
                  if(length(var_defined)>0){
                        if(var_used[1]<=var_defined[1]){
                              inputs = c(inputs, var)
                        }
                  }else{
                        inputs = c(inputs, var)
                  }
            }
            
            if(length(var_defined)>0){
                  if(length(var_used_after)>0){
                        outputs = c(outputs, var)
                  }
            }
      }
      return( list(input = inputs, output = outputs) )
}
