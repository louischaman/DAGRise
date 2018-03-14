library(readr)
library(fst)
library(data.table)
require(DAGRise)
code_file = "do_data_stuff.R"
raw_code = readLines(code_file)
raw_code

## example with pp
dest_file = "pp-2017.csv"

if(!file.exists(dest_file)){
      download.file("http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-2017.csv",destfile = dest_file)
}

dependencies = c(packrat:::fileDependencies(code_file))

processed_data_dir = paste0("processed_data")
scripts_dir = paste0(".scripts")

dir.create(processed_data_dir, showWarnings = F)
dir.create(scripts_dir, showWarnings = F)


saveRDS(dependencies, "processed_data/packages_used.rds")


break_lines = c(1,which(substr(raw_code,1,3) == "## "),length(raw_code))


broken_code = gsub("##", "breakfunction()##", raw_code, fixed = T)
write_lines(broken_code, ".tempfile")
sc = CodeDepends::readScript(".tempfile")

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
      else snippit_name = stringr::str_sub(raw_code[start_line],4,-1)

      script_name = paste0(".scripts/",i, "-", snippit_name, ".R")

      ins_outs = list()

      ins_outs = get_in_out_step(sc, i)

      # get the code snippit
      snippit = get_subcode(raw_code, start_line, end_line, inputs=ins_outs$input, outputs=ins_outs$output)

      # if it is an end node create a little complete file output
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


