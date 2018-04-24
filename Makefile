#Author: Polonio Davide <poloniodavide@gmail.com>
#License: GPLv3

OUTPUT_NAME= GestioneDiImpreseInformatiche
LIST_NAME= listOfSections.tex
PATH_OF_CONTENTS= res/sections
AUTOGEN_CONFIG_FILE= config/metadata.autogen.tex
MAIN_FILE= main
CC= latexmk
JOB_NAME=-jobname='$(OUTPUT_NAME)'
CCFLAGS= -pdflatex='pdflatex -interaction=nonstopmode' -pdf
LANG= it
SHELL := /bin/bash #Need bash not shell

export EXTRA_CCFLAGS;

all: compile

compile:
	if [[ -a "res/$(LIST_NAME)" ]]; then echo "Removing res/$(LIST_NAME)"; \
		rm res/$(LIST_NAME); fi; \
	for i in $(sort $(wildcard $(PATH_OF_CONTENTS)/*.tex)); do \
		echo "Adding $$i into $(LIST_NAME)"; \
		echo "\input{$$i}" >> res/$(LIST_NAME); \
	done; \
	sed -i "s/.*myVersion.*/\\newcommand{\\myVersion}{$(shell git describe)}" $(AUTOGEN_CONFIG_FILE); 2&>/dev/null || \
	echo "\newcommand{\myVersion}{$(shell git describe)}" > $(AUTOGEN_CONFIG_FILE); \
	$(CC) -C $(JOB_NAME); \
	$(CC) $(CCFLAGS) $(EXTRA_CCFLAGS) $(JOB_NAME); \

clean:
	git clean -Xfd
	$(CC) -C $(JOB_NAME)
	if [[ -a "$(OUTPUT_NAME)" ]]; then rm -rv $(OUTPUT_NAME)/; fi;

spellcheck:
	./tools/spellchecker/spellcheck.sh $(LANG)

ci: spellcheck compile

watch:
	@while true; do \
		make --silent; \
		inotifywait -qre close_write res/sections; \
	done


clean:
	git clean -Xfd
	$(CC) -C $(JOB_NAME)
	if [[ -a "$(OUTPUT_NAME)" ]]; then rm -rv $(OUTPUT_NAME)/; fi;

.PHONY: compile
