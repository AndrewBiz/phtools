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
    When I run `phrename -h`
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
    When I run `phrename -v`
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

  #@announce
  Scenario: Standard named files can be renamed back to original names
    Given empty files named:
    | 20130101-005311_ANB DSC00001.JPG    |
    | 20130102-005311_ANBA DSC00002.JPG   |
    | 20130103-005311_ANBAN DSC00003.JPG  |
    | 20130104-005311_ANBANB DSC00004.JPG |
    When I run the following commands:
    """bash
    phls | phrename --clean
    """
    Then the exit status should be 0
    And the stdout should contain each of:
    | DSC00001.JPG |
    | DSC00002.JPG |
    | DSC00003.JPG |
    | DSC00004.JPG |
    And the stdout should not contain any of:
    | 20130101-005311 |
    | ANB             |
    | ANBA            |
    | ANBAN           |
    | ANBANB          |
    And the following files should exist:
    | DSC00001.JPG |
    | DSC00002.JPG |
    | DSC00003.JPG |
    | DSC00004.JPG |

  #@announce
  Scenario: Non-Standard named files are renamed back to origin as well
    Given empty files named:
    | 20130101-105311_ANB[12345678-dfdfdfdf]{flags}DSC10001.JPG |
    | 20130102-105311_ANB[12345678-erererer]DSC10002.JPG        |
    | 20130103-105311_ANB_DSC10003.JPG                          |
    | 20130104-105311_ANB-DSC10004.JPG                          |
    | 20130105-1053_ANB_DSC10005.JPG                            |
    | 20130106-1053-ANB_DSC10006.JPG                            |
    | 20130107-1053_ANB DSC10007.JPG                            |
    | 20130108-1053_DSC10008.JPG                                |
    | 20130109-1053 DSC10009.JPG                                |
    | 20130110_DSC10010.JPG                                     |
    | 20130111 DSC10011.JPG                                     |
    | 2013_DSC10012.JPG                                         |
    | 2013-DSC10013.JPG                                         |
    | 2013 DSC10014.JPG                                         |
    | CLEAN NAME.JPG                                            |
    | CLEAN_NAME.JPG                                            |
    | CLEAN-NAME.JPG                                            |
    | CLEANNAME.JPG                                             |
    When I run the following commands:
    """bash
    phls | phrename --clean
    """
    Then the exit status should be 0
    And the stdout should contain each of:
    | DSC10001.JPG   |
    | DSC10002.JPG   |
    | DSC10003.JPG   |
    | DSC10004.JPG   |
    | DSC10005.JPG   |
    | DSC10006.JPG   |
    | DSC10007.JPG   |
    | DSC10008.JPG   |
    | DSC10009.JPG   |
    | DSC10010.JPG   |
    | DSC10011.JPG   |
    | DSC10012.JPG   |
    | DSC10013.JPG   |
    | DSC10014.JPG   |
    | CLEAN NAME.JPG |
    | CLEAN_NAME.JPG |
    | CLEAN-NAME.JPG |
    | CLEANNAME.JPG  |
    And the stdout should not contain any of:
    | 20130101-105311_ANB[12345678-dfdfdfdf]{flags} |
    | 20130102-105311_ANB[12345678-erererer]        |
    | 20130103-105311_ANB_                          |
    | 20130104-105311_ANB-                          |
    | 20130105-1053_ANB_                            |
    | 20130106-1053-ANB_                            |
    | 20130107-1053_ANB                             |
    | 20130108-1053_                                |
    | 20130109-1053                                 |
    | 20130110_                                     |
    | 20130111                                      |
    | 2013_                                         |
    | 2013-                                         |
    | 2013                                          |
    And the following files should exist:
    | DSC10001.JPG   |
    | DSC10002.JPG   |
    | DSC10003.JPG   |
    | DSC10004.JPG   |
    | DSC10005.JPG   |
    | DSC10006.JPG   |
    | DSC10007.JPG   |
    | DSC10008.JPG   |
    | DSC10009.JPG   |
    | DSC10010.JPG   |
    | DSC10011.JPG   |
    | DSC10012.JPG   |
    | DSC10013.JPG   |
    | DSC10014.JPG   |
    | CLEAN NAME.JPG |
    | CLEAN_NAME.JPG |
    | CLEAN-NAME.JPG |
    | CLEANNAME.JPG  |

  #@announce
  Scenario: In SHIFT-TIME mode the jpg file is renamed with new date-time
    Given a directory named "changetime"
    And example file "features/media/renamed/20130103-103254_ANB DSC03313_notagset.JPG" copied to file "changetime/20130103-103254_ANB DSC03313.JPG"

    When I cd to "changetime"
    When I run the following commands:
    """bash
    phls | phrename --shift_time 100
    """
    Then the exit status should be 0
    And the stdout should contain each of:
      | 20130103-103434_ANB DSC03313.JPG |
    And the following files should exist:
      | 20130103-103434_ANB DSC03313.JPG |

  #@announce
  Scenario: In SHIFT-TIME mode the jpg file produces error if the name is not standard
    Given a directory named "changetime"
    And example file "features/media/renamed/20130103-103254_ANB DSC03313_notagset.JPG" copied to file "changetime/DSC03313.JPG"

    When I cd to "changetime"
    When I run the following commands:
    """bash
    phls | phrename --shift_time 100
    """
    Then the exit status should be 0
    And the stderr should contain "ERROR: './DSC03313.JPG' - file renaming - incorrect file name"
