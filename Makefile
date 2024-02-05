# Makefile to create a symlink in the user's home directory

# Variables
SOURCE_FILE := $(CURDIR)/config/nvim
TARGET_LINK := $(HOME)/.config/nvim

# Default target
all: create_symlink

# Target to create a symbolic link
create_symlink:
	@if [ -d $(TARGET_LINK) ]; then \
		echo "'$(TARGET_LINK)' already exists. Not modifying anything..."; \
	else \
		mkdir -p $(dir $(patsubst %/,%,$(TARGET_LINK))); \
		ln -sn $(SOURCE_FILE) $(TARGET_LINK); \
		echo "Symbolic link successfully created: $(TARGET_LINK)"; \
	fi

# Clean target to remove the symbolic link
clean:
	@rm -f $(TARGET_LINK)
	@echo "Symbolic link removed: $(TARGET_LINK)"

