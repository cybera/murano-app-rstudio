all: zip upload

zip:
	rm ca.cybera.RStudio.zip || true
	zip -r ca.cybera.RStudio.zip *

upload:
	murano package-import --is-public --exists-action u ca.cybera.RStudio.zip
