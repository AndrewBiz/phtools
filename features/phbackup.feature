# language: en
Feature: Backup files
  In order to be at the safe side
  As a photographer
  I want to get the given files to be backed up

  #@announce
  Scenario: phtools knows about this tool
    When I successfully run `phtools`
    Then the stdout should contain "phbackup\t(copies input files to backup folder)"
    And the stdout should not contain "phbackup\t(!UNDER CONSTRUCTION!)"

  #@announce
  Scenario: Output with -h produces usage information
    When I run `phbackup -h`
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
    When I run `phbackup -v`
    Then the output should match /v[0-9]+\.[0-9]+\.[0-9]+(-[a-z,0-9]+)?/

  #@announce
  Scenario: Default backup is made into ./backup dir
    Given empty files named:
    | foto2backup.jpg |
    | foto2backup.wav |
    When I run the following commands:
    """bash
    phls | phbackup
    """
    Then the exit status should be 0
    And the stdout should contain each of:
    | foto2backup.jpg |
    | foto2backup.wav |
    And a directory named "backup" should exist
    And the following files should exist:
    | backup/foto2backup.jpg |
    | backup/foto2backup.wav |

  #@announce
  Scenario: backup is made into given dir
    Given empty files named:
    | foto2newbackup.jpg |
    | foto2newbackup.wav |
    When I run the following commands:
    """bash
    phls | phbackup -b newbackup
    """
    Then the exit status should be 0
    Then the stdout should contain each of:
    | foto2newbackup.jpg |
    | foto2newbackup.wav |
    And a directory named "newbackup" should exist
    And the following files should exist:
    | newbackup/foto2newbackup.jpg |
    | newbackup/foto2newbackup.wav |
