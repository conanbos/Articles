LATEXFLAGS?=-interaction=nonstopmode -file-line-error
PDFLATEX=xelatex $(LATEXFLAGS)
BIBTEX=bibtex

ifdef JOB
else
JOB=main
endif

TEXS=$(wildcard *.tex) $(wildcard *.sty) $(wildcard *.cls)
PICS=$(wildcard *.png) $(filter-out $(JOB).pdf,$(wildcard *.pdf))
BIBS=$(wildcard *.bib) $(wildcard *.bst)

.DEFAULT: all
.PHONY: all clean pure auto

all: $(JOB).pdf

# Bootstrap aux file, then keep running pdflatex until it reaches a fixpoint

$(JOB).aux: | $(TEXS) $(PICS)
	$(PDFLATEX) $(JOB)

$(JOB).bbl: $(JOB).aux $(BIBS)
	$(BIBTEX) $(JOB)


$(JOB).pdf: $(TEXS) $(PICS) $(JOB).aux $(JOB).bbl
	@cp -p $(JOB).aux $(JOB).aux.bak
	$(PDFLATEX) $(JOB)
	@if cmp -s $(JOB).aux $(JOB).aux.bak; \
	then touch -r $(JOB).aux.bak $(JOB).aux; \
	else NEWS="$$NEWS -W $(JOB).aux"; fi; rm $(JOB).aux.bak; \
	if [ -n "$$NEWS" ]; then $(MAKE) $$NEWS $@; fi

clean:
	@rm -f $(JOB).aux $(JOB).log $(JOB).blg $(JOB).bbl $(JOB).out $(JOB).nav $(JOB).snm $(JOB).toc $(JOB)*.bak $(JOB).ist $(JOB).lof $(JOB).lot $(JOB).bcf $(JOB).glo *.log $(JOB)*.xml content/*.aux $(JOB).m* $(JOB).g* $(JOB).i* $(JOB).a*

pure:clean
	@rm  -f $(JOB).pdf
	@echo "$(JOB).pdf has been deleted"
	@echo "All temporary files are deleted"

auto:all clean
