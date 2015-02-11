TARGETS=main hello suites fixtures assertions

CXX=g++
CPPFLAGS=-Wall
SRCDIR=src
TESTDIR=test
BINDIR=bin
REPORTDIR=reports

WEBDIR=/var/www/html/coverage

all: $(addprefix $(BINDIR)/,$(TARGETS))

$(BINDIR)/%: $(SRCDIR)/add.cpp $(SRCDIR)/add.h $(TESTDIR)/%.cpp
	$(CXX) -I$(SRCDIR) -o $(notdir $@) $(SRCDIR)/add.h $(SRCDIR)/add.cpp $(TESTDIR)/$(notdir $@).cpp -lboost_unit_test_framework -fprofile-arcs -ftest-coverage --coverage --debug
	-mv $(notdir $@) $(BINDIR)/
	-mv *.gcno $(REPORTDIR)/

test: $(addprefix $(BINDIR)/,$(TARGETS)) $(addprefix run-,$(TARGETS)) $(addprefix val-,$(TARGETS))

run-%: $(addprefix $(BINDIR)/,%)
	-$^ --log_format=XML --log_sink=$(REPORTDIR)/$(notdir $^)report.xml --log_level=test_suite -report_level=no
	-mv *.gcda $(REPORTDIR) 2>/dev/null

val-%: $(addprefix $(BINDIR)/,%)
	-valgrind --xml=yes --xml-file=$(REPORTDIR)/$(notdir $^)-valgrind-report.xml $(BINDIR)/$(notdir $^)
	-mv *.gcda $(REPORTDIR) 2>/dev/null

coverage: test $(addprefix cov-,$(TARGETS))
	lcov --capture --directory . --output-file $(REPORTDIR)/test-coverage.info --rc lcov_branch_coverage=1 --no-external
	gcovr -x -r $(REPORTDIR) > $(REPORTDIR)/test-coverage.xml

cov-%: $(addprefix $(BINDIR)/,%)
	gcov --object-directory $(REPORTDIR) -r $(TESTDIR)/$(notdir $^).cpp
	-mv *.gcov $(REPORTDIR) 2>/dev/null

coverage-web: coverage
	genhtml $(REPORTDIR)/test-coverage.info --rc lcov_branch_coverage=1 --output-directory $(WEBDIR)

style:
	vera++ -c $(REPORTDIR)/code-style.xml src/*.cpp

quality: coverage style

sonar: quality
	sonar-runner

clean:
	rm -f $(addprefix $(BINDIR)/,$(TARGETS)) $(REPORTDIR)/*
