DOC_DIR = doc
EXPLORE_DIR = explore

all: docs analysis

docs:
	$(MAKE) -C $(DOC_DIR) all

thesis:
	$(MAKE) -C $(DOC_DIR) thesis

analysis:

explore:
	$(MAKE) -C $(EXPLORE_DIR) html

clean:
	$(MAKE) -C $(DOC_DIR) clean
