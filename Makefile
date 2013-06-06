DOC_DIR = doc

all: docs analysis

docs:
	$(MAKE) -C $(DOC_DIR) all

thesis:
	$(MAKE) -C $(DOC_DIR) thesis

analysis:

clean:
	$(MAKE) -C $(DOC_DIR) clean
