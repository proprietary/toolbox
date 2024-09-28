INSTALL_PREFIX = ~/.local/bin

.PHONY = install
install:
	@mkdir -p $(INSTALL_PREFIX)
	@for f in bin/*; do \
	  echo "Installing $$f"; \
	  ln -s `realpath $$f` $(INSTALL_PREFIX); \
	done
