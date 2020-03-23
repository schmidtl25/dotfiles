PREFIX=$(HOME)

# Get all files from this repo
ALL_FILES = $(wildcard *)
# Files to exclude
EXCLUDED_FILES = Makefile README.md $(wildcard \#)

FILTERED_FILES = $(filter-out $(EXCLUDED_FILES),$(ALL_FILES))
DOT_FILES = $(addprefix $(PREFIX)/.,$(FILTERED_FILES))

DIRS = $(PREFIX)

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
install : $(DOT_FILES)
$(PREFIX)/.% : $(PWD)/% | $(PREFIX)
	@echo "  slink '$<' -> '$@'"
	@if [[ -L $@ ]]; then \
		rm $@; \
	fi; \
	ln -s $< $@;

endif

.PHONY : clean
clean:
	rm -rf $(DOT_FILES)

$(DIRS) :
	mkdir $@
