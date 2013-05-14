DOC_DIR = doc

docs:
	$(MAKE) -C $(DOC_DIR) all

clean:
	$(MAKE) -C $(DOC_DIR) clean
