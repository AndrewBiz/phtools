# language: en
Feature: Rename photo and video files
  In order to have all my photo and video files (taken with my digital camera)
  get well readable and informative filenames
  As a photographer
  I want to get the given files to be renamed to the standard phtools name template

  #@announce
  Scenario: phtools knows about this tool
    When I successfully run `phtools`
    Then the stdout should contain "phrename\t(renames input files to phtools standard)"
    And the stdout should not contain "phrename\t(!UNDER CONSTRUCTION!)"

  #@announce
  Scenario: Output with -h produces usage information
    When I successfully run `phrename -h`
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
    When I successfully run `phrename -v`
    Then the output should match /v[0-9]+\.[0-9]+\.[0-9]+(-[a-z,0-9]+)?/

  #@announce
  Scenario: Originally named files are renamed to phtools standard
    Given a directory named "rename1"
    And example files from "features/media/sony_jpg" copied to "rename1" named:
   | DSC03403.JPG |
   | DSC03313.JPG |
   | DSC03499.JPG |
   | DSC03802.JPG |
   | DSC04032.JPG |

    When I cd to "rename1"
    When I run the following commands:
    """bash
    phls | phrename -a anb
    """
    Then the exit status should be 0

    Then the stdout should contain each of:
    | 20130103-103254_ANB DSC03313.JPG |
    | 20130103-153908_ANB DSC03403.JPG |
    | 20130104-120745_ANB DSC03499.JPG |
    | 20130105-150446_ANB DSC03802.JPG |
    | 20130107-115201_ANB DSC04032.JPG |
    And the following files should exist:
    | ./20130103-103254_ANB DSC03313.JPG |
    | ./20130103-153908_ANB DSC03403.JPG |
    | ./20130104-120745_ANB DSC03499.JPG |
    | ./20130105-150446_ANB DSC03802.JPG |
    | ./20130107-115201_ANB DSC04032.JPG |
    And the following files should not exist:
    | ./DSC03313.JPG |
    | ./DSC03403.JPG |
    | ./DSC03499.JPG |
    | ./DSC03802.JPG |
    | ./DSC04032.JPG |

  #@announce
  Scenario: File is renamed using ModifyDate tag
    Given a directory named "rename2"
    And example files from "features/media/sony_jpg" copied to "rename2" named:
   | DSC03313.JPG |

    When I cd to "rename2"
    When I run the following commands:
    """bash
    phls | phrename -a anb -t ModifyDate
    """
    Then the exit status should be 0

    Then the stdout should contain each of:
    | 20131114-225114_ANB DSC03313.JPG |
    And the following files should exist:
    | ./20131114-225114_ANB DSC03313.JPG |
    And the following files should not exist:
    | ./DSC03313.JPG |
    And the following files should not exist:
    | ./20130103-103254_ANB DSC03313.JPG |

  #@announce
  Scenario: cmd reports error if tag does not exist
    Given a directory named "rename2"
    And example files from "features/media/sony_jpg" copied to "rename2" named:
   | DSC03313.JPG |

    When I cd to "rename2"
    When I run the following commands:
    """bash
    phls | phrename -a anb -t XXXDateTime
    """
    Then the exit status should be 0

    And the stderr should contain "tag XXXDateTime is not found"
    And the following files should exist:
    | ./DSC03313.JPG |
    And the following files should not exist:
    | ./20131114-225114_ANB DSC03313.JPG |
    And the following files should not exist:
    | ./20130103-103254_ANB DSC03313.JPG |

  #@announce
  Scenario: cmd reports error if tag is not DateTime type
    Given a directory named "rename2"
    And example files from "features/media/sony_jpg" copied to "rename2" named:
   | DSC03313.JPG |

    When I cd to "rename2"
    When I run the following commands:
    """bash
    phls | phrename -a anb -t Make
    """
    Then the exit status should be 0

    And the stderr should contain "tag Make is not a DateTime type"
    And the following files should exist:
    | ./DSC03313.JPG |
    And the following files should not exist:
    | ./20131114-225114_ANB DSC03313.JPG |
    And the following files should not exist:
    | ./20130103-103254_ANB DSC03313.JPG |
