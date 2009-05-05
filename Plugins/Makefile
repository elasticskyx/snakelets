
all:
	@echo "This makefile is only for cleaning stuff up. ('make clean')"
	@echo "You can also build the tarball dist with it ('make sdist')"

sdist: clean
	python setup.py sdist
	@echo "Look in the dist/ directory"

clean:
	@echo "Removing stray logfiles, .pyo/.pyc files..."
	find . -name \*~ -exec rm -v {} \;
	find . -name \*_log -exec rm -v {} \;
	find . -name \*.log -exec rm -v {} \;
	find . -name \*.pyo -exec rm -v {} \;
	find . -name \*.pyc -exec rm -v {} \;
	@echo "Removing non-CVS files..."
	rm -fv MANIFEST 
	rm -rf build
	find . -name  .#\* -exec rm -v {} \;
	@echo "clean!"


