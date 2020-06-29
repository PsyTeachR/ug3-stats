htarg := docs

.PHONY : book
book : clean 
	Rscript -e 'bookdown::render_book("index.Rmd", output_dir = "$(htarg)")'
	zip -r docs/offline-textbook.zip docs/

clean :
	Rscript -e 'bookdown::clean_book(TRUE)'
