library(readr)
library(fst)
library(data.table)
code_file = "do_data_stuff.R"
raw_code = readLines(code_file)
raw_code

dependencies = c(packrat:::fileDependencies(code_file))

saveRDS(dependencies, "processed_data/packages_used.rds")

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



break_lines = c(1,which(substr(raw_code,1,3) == "## "),length(raw_code))


broken_code = gsub("##", "breakfunction()##", raw_code, fixed = T)
write_lines(broken_code, ".tempfile")
sc = readScript(".tempfile")

snake_list = list()
write_if_diff = function(lines, filename){
      if(!file.exists(filename)){
            write_lines(lines,filename)
            return()
      }
      old_lines = read_lines(filename)
      if(!identical(old_lines, lines)){
            write_lines(lines,filename)
      }
}

for(i in 1:(length(break_lines)-1) ){
      start_line = break_lines[i]
      end_line = break_lines[i+1]
      if(i == 1) snippit_name = "init.R"
      else snippit_name = str_sub(raw_code[start_line],4,-1)
      
      script_name = paste0(".scripts/",i, "-", snippit_name, ".R")
      
      ins_outs = list()
      
      ins_outs = get_in_out_step(sc, i)
      
            
      snippit = get_subcode(raw_code, start_line, end_line, inputs=ins_outs$input, outputs=ins_outs$output)
      if( length(ins_outs$output) == 0){
            snippit = c(snippit, paste0("write.csv('complete','processed_data/output",i,".rds')") )
            ins_outs$output = paste0("output",i)
      }
      
      
      rule = ins_outs
      rule[["script"]] =  script_name
      snake_list[[paste0("rule rule",i)]] = rule
      write_if_diff(snippit, script_name)
}


snake_list[['rule final_rule']] = list(input = unique(unlist(lapply(snake_list, function(x)x$output))))
snakefile =rev(snake_list)


lines = character()

for(i in 1:length(snakefile)){
      line = paste0(names(snakefile)[i],":")
      lines = c(lines, line)
      for(j in 1:length(snakefile[[i]])){
            val = snakefile[[i]][[j]]
            key = names(snakefile[[i]])[j]
            if(length(val)==0) next
            if(key != "script")
                  val = paste0( "'processed_data/", val,".rds'")
            else
                  val = paste0( "'", val,"'")
            if(length(val)>1){
                  val = paste(val, collapse = ", ")
            }
            line = paste0("    ",key ,": ", val)
           
            lines = c(lines, line)
      }
}
write_lines(lines,"Snakefile")


