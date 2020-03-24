PREFIX=$(HOME)

# Get all files from this repo
ALL_FILES = $(wildcard *)
BASHRC_FILES = $(wildcard bashrc.d/*.bashrc)
# Files to exclude
EXCLUDED_FILES = Makefile README.md $(BASHRC_FILES) $(wildcard \#)

FILTERED_FILES = $(filter-out $(EXCLUDED_FILES),$(ALL_FILES))
DOT_FILES = $(addprefix $(PREFIX)/.,$(FILTERED_FILES))

DIRS = $(PREFIX)

ifneq ($(BASHRC_FILES),)
BASHRC_D_FILES =$(addprefix $(PREFIX)/.,$(BASHRC_FILES))
DIRS += $(HOME)/.bashrc.d
endif

ifneq ($(filter backup,$(MAKECMDGOALS)),)
BACKUP_DIR=$(HOME)/backup
INSTALLED_FILES=$(wildcard $(PREFIX)/.*)
FILES_TO_BACKUP=$(filter $(DOT_FILES),$(addprefix $(PREFIX)/,$(notdir $(INSTALLED_FILES))))
BACKUP_FILES=$(addprefix $(BACKUP_DIR)/,$(notdir $(FILES_TO_BACKUP)))
DIRS += $(BACKUP_DIR)

.PHONY : backup
backup : $(BACKUP_FILES)
$(BACKUP_DIR)/.% : $(PREFIX)/.% | $(BACKUP_DIR)
	@if [[ -L $< ]]; \
	then \
	  echo "Skipping slink '$< -> `readlink $<`'"; \
	else \
	  echo "Copying $< to $@"; \
	  cp -r $< $@; \
	fi
else
.PHONY : install
install : $(DOT_FILES) $(BASHRC_D_FILES)

$(PREFIX)/.% : $(PWD)/% | $(PREFIX)
	@echo "  slink '$<' -> '$@'"
	@if [[ -L $@ ]]; then \
		rm $@; \
	fi; \
	ln -s $< $@;

$(PREFIX)/.bashrc.d/% : $(PWD)/% | $(DIRS)
	@echo "  slink '$<' -> '$@'"
	@if [[ -L $@ ]]; then \
		rm $@; \
	fi; \
	ln -sT $< $@
endif

.PHONY : clean
clean:
	rm -rf $(DOT_FILES)

$(DIRS) :
	mkdir $@
