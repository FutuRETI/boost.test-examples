TARGETS=main hello suites fixtures assertions

all: $(TARGETS)

test: $(TARGETS) $(addprefix run-,$(TARGETS))

coverage: test $(addprefix cov-,$(TARGETS))
	lcov --capture --directory . --output-file test-coverage.info
	gcovr -x -r . > test-coverage.xml

coverage-web: coverage

style:
	vera++ -c code-style.xml src/*.cpp

%: src/add.cpp src/test-examples.h test/%.cpp
	$(CXX) -I./src -o $@ src/test-examples.h src/add.cpp test/$@.cpp -lboost_unit_test_framework -fprofile-arcs -ftest-coverage --coverage

run-%: %
	-./$^ --log_format=XML --log_sink=$(^)-report.xml --log_level=test_suite --report_level=no

cov-%: %
	gcov -r $(^).cpp

clean:
	rm -f $(TARGETS) *-report.xml *-report.xml.after_xslt *.gcov *.gcno *.gcda test-coverage.* *-style.xml

sonar: coverage style
	sonar-runner
