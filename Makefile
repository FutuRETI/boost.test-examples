TARGETS=main hello suites fixtures assertions

all: $(TARGETS)

test: $(TARGETS) $(addprefix run-,$(TARGETS))

coverage: $(TARGETS) test $(addprefix cov-,$(TARGETS))
	lcov --capture --directory . --output-file coverage.info
	genhtml coverage.info --output-directory /var/www/coverage

%: %.cpp
	$(CXX) -o$@ $^ -lboost_unit_test_framework -fprofile-arcs -ftest-coverage --coverage

run-%: %
	-./$^ --output_format=XML --log_level=test_suite > $(^)-report.xml

cov-%: %
	gcov -r $(^).cpp

clean:
	rm -f $(TARGETS) *-report.xml *.gcov *.gcno *.gcda coverage.info
