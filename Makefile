.PHONY: check build test demo web verify clean

check:
	moon check

build:
	moon build --target native

test:
	moon test

demo:
	moon run cmd/main svg > examples/water.svg
	moon run cmd/main ppm > examples/water.ppm
	moon run cmd/main csv > examples/water.csv

web:
	python3 -m http.server 8080

verify: check build test
	moon run cmd/main summary

clean:
	rm -rf target examples/water.svg examples/water.ppm examples/water.csv
