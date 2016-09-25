# language: en
Feature: Fix File Modify Date
  In order to get well sorted files for the systems which use
  File Modify Date property to sort files (like Wii, Picasa etc)
  As a photographer I want to get the given files to be set FileModifyDate equal to date-time-in-the-name

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

  #@announce
  Scenario: Runing phfixfmd on the files previously renamed to Standard phtools Name will change FileModifyDate equal to date-time-in-the-name

    Given a directory named "rename1"
    And example files from "features/media/dates_renamed" copied to "rename1" named:
    | 20010101-010101_XXX file1.JPG |
    And example file "rename1/20010101-010101_XXX file1.JPG" with file-modify-date set to "2016-09-25 22:03:24"

    When I cd to "rename1"
    When I run the following commands:
    """bash
    phls | phfixfmd
    """
    Then the exit status should be 0

    Then the stdout should contain each of:
    | 20010101-010101_XXX file1.JPG |

    And the following files should exist:
    | 20010101-010101_XXX file1.JPG |

    When I run the following commands:
    """bash
    exiftool -s -FileModifyDate '20010101-010101_XXX file1.JPG'
    """
    Then the output should match each of:
      |/^FileModifyDate( *):( *)2001:01:01 01:01:01/|
