fs <- list.files("R", full.names=TRUE)
ok <- TRUE
for(f in fs){
  tryCatch(parse(file=f), error=function(e){
    cat("PARSE FAIL:", f, "->", e$message, "\n")
    ok <<- FALSE
  })
}
if(ok) cat("All R files parse OK\n") else quit(status=1)