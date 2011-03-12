Feature: Running
  As a crazy physicist
  In order to figure out the meaning of life
  I want to be able to run tasks on batches of input files from the command line

  Scenario: Finding out the version
    When I run "kepler --version"
    Then the output should contain "2.0.0"

  Scenario: Asking for help
    When I run "kepler --help"
    Then the output should contain "Usage: kepler"
