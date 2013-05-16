DOC_DIR = doc

all: docs analysis

docs:
	$(MAKE) -C $(DOC_DIR) all

analysis:

clean:
	$(MAKE) -C $(DOC_DIR) clean
