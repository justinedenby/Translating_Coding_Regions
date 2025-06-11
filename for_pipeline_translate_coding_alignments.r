library(rphast)

#write working directory -- this is where your translated alignments will be created
setwd("/path/to/create/translated/alignments/")

#this is a directory/folder that has all of the gene files with each MSA within
genes <- list.files("/full/path/to/alignments/")

#holds the skipped files due to alignments not being % 3
skipped_files <- character()

print(Sys.time())

#create two directories for the rphast pipeline -- one to hold all gene files before and after translation
dir.create("CODON", showWarnings = FALSE)
dir.create("AA", showWarnings = FALSE)


for (gene in genes) {
  print(paste0("gene currently running: ", gene))
  
  tryCatch({
#this try-catch checks the length of each alignment to ensure that they are a length of % 3 -- rphast throws an error if not
    msa <- read.msa(paste("/full/path/to/alignments/", gene, sep=''), format="FASTA")
    msa_cleaned <- codon.clean.msa(msa, refseq = "Homo_sapiens")
    
    msa_aa <- msa_cleaned
    seqs_aa <- translate.msa(msa_cleaned)
    seqs_aa <- gsub("\\*", "-", seqs_aa)
    seqs_aa <- gsub("\\$", "*", seqs_aa)
    msa_aa$seqs <- seqs_aa
    
    write.msa(msa_aa, paste0("AA/", gene))
    write.msa(msa_cleaned, paste0("CODON/", gene))
    print("gene finished")
  }, error = function(e) {
    if (grepl("msa length \\(\\d+\\) not multiple of three after gap removal", e$message)) {
      warning(paste("Skipping file", gene, "due to length not being multiple of three after gap removal"))
      skipped_files <<- c(skipped_files, gene)
    } else {
      stop(e)
    }
  })
}

#prints out if any of the files were skipped and which ones were
if (length(skipped_files) > 0) {
  cat("\nThe following files were skipped due to length not being multiple of three:\n")
  print(skipped_files)
} else {
  cat("\nAll files processed successfully.\n")
}

print(Sys.time())
