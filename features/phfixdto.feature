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
    Given a directory named "2settag1"
    And example file "features/media/renamed/20130103-103254_ANB DSC03313_notagset.JPG" copied to file "2settag1/DSC03313.JPG"

    When I cd to "2settag1"
    When I run the following commands:
    """bash
    phls | phfixdto
    """
    Then the exit status should be 0
    And the stderr should contain "ERROR: './DSC03313.JPG' - wrong date-time-in-the-name"

  #@announce
  Scenario: The command does not touch CreateDate if it was not set originally
    Given a directory named "2settag2"
    And example file "features/media/iphone/IMG_0887_no_cd.jpg" copied to file "2settag2/20140718-200000_ANB IMG_0887.JPG"

    When I cd to "2settag2"
    And I run the following commands:
    """bash
    exiftool -s -DateTimeOriginal -CreateDate '20140718-200000_ANB IMG_0887.JPG'
    """
    Then the output should match each of:
      |/^DateTimeOriginal( *):( *)2014:07:18 10:00:00/|
    And the stdout should not contain any of:
      |CreateDate|

    When I run the following commands:
    """bash
    phls | phfixdto
    """
    Then the exit status should be 0

    When I run the following commands:
    """bash
    exiftool -s -DateTimeOriginal -CreateDate '20140718-200000_ANB IMG_0887.JPG'
    """
    Then the output should match each of:
      |/^DateTimeOriginal( *):( *)2014:07:18 20:00:00/|
    And the stdout should not contain any of:
      |CreateDate|

  #@announce
  Scenario: The command does not update file in No-Run mode
    Given a directory named "2settag3"
    And example file "features/media/renamed/20130103-103254_ANB DSC03313_notagset.JPG" copied to file "2settag3/20160927-224500_ANB DSC03313.JPG"

    When I cd to "2settag3"

    When I run the following commands:
    """bash
    phls | phfixdto -N
    """
    Then the exit status should be 0
    And the file named "exif_tagger_dto.txt" should exist

    When I run the following commands:
    """bash
    exiftool -s -DateTimeOriginal -CreateDate '20160927-224500_ANB DSC03313.JPG'
    """
    Then the output should match each of:
      |/^DateTimeOriginal( *):( *)2013:01:03 10:32:54/|
      |/^CreateDate( *):( *)2013:01:03 10:32:54/|
