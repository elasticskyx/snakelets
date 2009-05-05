
all:
	@echo "This makefile is only for cleaning stuff up. ('make clean')"
	@echo "You can also build the tarball dists with it ('make tarballs')"

tarballs: clean
	@python maketarball.py frog
	@python maketarball.py filemgr

clean:
	@echo "Removing stray logfiles, .pyo/.pyc files..."
	find . -name \*~ | xargs  rm
	find . -name \*_log | xargs  rm
	find . -name \*.log | xargs  rm
	find . -name \*.pyo | xargs  rm
	find . -name \*.pyc | xargs  rm

	@echo "Removing non-CVS files..."
	rm -fv MANIFEST 
	rm -rf build
	find . -name  .#\* | xargs  rm
	@echo "clean!"


