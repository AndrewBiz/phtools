# language: en
Feature: Set (update) EXIF DateTimeOriginal in media files
  In order to get all my photo files with the correct creation Date-Time
  As a photographer
  I want to get the given files to be saved with updated DateTimeOriginal tag

  #@announce
  Scenario: phtools knows about this tool
    When I successfully run `phtools`
    Then the stdout should contain "phfixdto\t(fixes DateTimeOriginal tag to be equal to date-time-in-the-name)"
    And the stdout should not contain "phfixdto\t(!UNDER CONSTRUCTION!)"

  #@announce
  Scenario: Output with -h produces usage information
    When I run `phfixdto -h`
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
    When I run `phfixdto -v`
    Then the output should match /v[0-9]+\.[0-9]+\.[0-9]+(-[a-z,0-9]+)?/

  # #@announce
  Scenario: Runing phfixdto on the file previously renamed to Standard phtools Name will change DateTimeOriginal and CreateDate tags to date-time-in-the-name

    Given a directory named "2settag"
    And example file "features/media/renamed/20130103-103254_ANB DSC03313_notagset.JPG" copied to file "2settag/20160927-224500_ANB DSC03313.JPG"

    When I cd to "2settag"
    And I run the following commands:
    """bash
    exiftool -s -DateTimeOriginal -CreateDate '20160927-224500_ANB DSC03313.JPG'
    """
    Then the output should match each of:
      |/^DateTimeOriginal( *):( *)2013:01:03 10:32:54/|
      |/^CreateDate( *):( *)2013:01:03 10:32:54/|

    When I run the following commands:
    """bash
    phls | phfixdto
    """
    Then the exit status should be 0

    When I run the following commands:
    """bash
    exiftool -s -DateTimeOriginal -CreateDate '20160927-224500_ANB DSC03313.JPG'
    """
    Then the output should match each of:
      |/^DateTimeOriginal( *):( *)2016:09:27 22:45:00/|
      |/^CreateDate( *):( *)2016:09:27 22:45:00/|

  #@announce
  Scenario: jpg file produces error if the name is not standard
    Given I still work on this feature
    # Given a directory named "2settag1"
    # And example file "features/media/renamed/20130103-103254_ANB DSC03313_notagset.JPG" copied to file "2settag1/DSC03313.JPG"
    #
  #   When I cd to "changetime"
  #   When I run the following commands:
  #   """bash
  #   phls | phrename --shift_time 100
  #   """
  #   Then the exit status should be 0
  #   And the stderr should contain "ERROR: './DSC03313.JPG' - file renaming - non-standard file name"

  # #@announce
  # Scenario: The jpg file produces ERROR if the name is not Standard
  #   Given a directory named "2settag"
  #   And example file "features/media/iphone/IMG_0887_no_dto_cd.jpg" copied to file "2settag/IMG_0887.JPG"
  #
  #   When I cd to "2settag"
  #   And I successfully run `fttags 'IMG_0887.JPG'`
  #
  #   Then the stdout from "fttags 'IMG_0887.JPG'" should not contain any of:
  #     |DateTimeOriginal|
  #     |CreateDate|
  #
  #   When I successfully run `ftls_ftfixdate -s -10`
  #
  #   Then the stderr from "ftls_ftfixdate -s -10" should contain "IMG_0887.JPG"
  #   And the stderr from "ftls_ftfixdate -s -10" should contain "ERROR: './IMG_0887.JPG' - DateTimeOriginal is not set"
  #
  #   When I successfully run `fttags 'IMG_0887.JPG'`
  #   Then the stdout from "fttags 'IMG_0887.JPG'" should not contain any of:
  #     |DateTimeOriginal|
  #     |CreateDate|

  #@announce
  Scenario: The command does not touch CreateDate if it was not set originally
    Given I still work on this feature
  #   Given a directory named "2settag"
  #   And example file "features/media/iphone/IMG_0887_no_cd.jpg" copied to file "2settag/IMG_0887.JPG"
  #
  #   When I cd to "2settag"
  #   And I successfully run `fttags 'IMG_0887.JPG'`
  #
  #   Then the stdout from "fttags 'IMG_0887.JPG'" should match each of:
  #     |/^DateTimeOriginal( *):( *)2014-07-18 10:00:00/|
  #   And the stdout from "fttags 'IMG_0887.JPG'" should not contain any of:
  #     |CreateDate|
  #
  #   When I successfully run `ftls_ftfixdate -s 10`
  #
  #   Then the stderr from "ftls_ftfixdate -s 10" should contain "IMG_0887.JPG"
  #   And the stderr from "ftls_ftfixdate -s 10" should not contain "ERROR"
  #
  #   When I successfully run `fttags 'IMG_0887.JPG'`
  #   Then the stdout from "fttags 'IMG_0887.JPG'" should not contain any of:
  #     |CreateDate|
  #   Then the stdout from "fttags 'IMG_0887.JPG'" should match each of:
  #     |/^DateTimeOriginal( *):( *)2014-07-18 10:00:10/|

  #@announce
  Scenario: The command does not update file in No-Run mode
    Given I still work on this feature
