# language: en
Feature: Fix File Modify Date
  In order to get well sorted files for the systems which use
  File Modify Date property to sort files (like Wii, Picasa etc)
  As a photographer
  I want to get the given files to be set FileModifyDate equal to date-time-in-the-name

  #@announce
  Scenario: phtools knows about this tool
    When I successfully run `phtools`
    Then the stdout should contain "phfixfmd\t(fixes FileModifyDate to be equal to date-time-in-the-name)"
    And the stdout should not contain "phfixfmd\t(!UNDER CONSTRUCTION!)"

  #@announce
  Scenario: Output with -h produces usage information
    When I run `phfixfmd -h`
    Then the stderr should contain each of:
    | phtools - *Keep Your Photos In Order*|
    | (c) ANB                   |
    | Example:                  |
    | Usage:                    |
    | Options:                  |
    | -D --debug                |
    | -h --help                 |
    | --version                 |
    | -v                        |

  #@announce
  Scenario: Output with -v produces version information
    When I run `phfixfmd -v`
    Then the output should match /v[0-9]+\.[0-9]+\.[0-9]+(-[a-z,0-9]+)?/
