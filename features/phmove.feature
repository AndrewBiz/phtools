# language: en
Feature: Arrange files into the given folder
  In order to simplify the further processing of the media files coming
  from different sources (flash cards, smartphones etc.)
  As a photographer
  I want to get all the given files to be moved in scecified target folder

  #@announce
  Scenario: phtools knows about this tool
    When I successfully run `phtools`
    Then the stdout should contain "phmove\t(moves input files to target folder)"
    And the stdout should not contain "phmove\t(!UNDER CONSTRUCTION!)"

  #@announce
  Scenario: Output with -h produces usage information
    When I run `phmove -h`
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
    When I run `phmove -v`
    Then the output should match /v[0-9]+\.[0-9]+\.[0-9]+(-[a-z,0-9]+)?/

  #@announce
  Scenario: Fails if TARGET_FOLDER does not exist
    Given empty files named:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    When I run the following commands:
    """bash
    phls | phmove FOLDER
    """
    Then the exit status should not be 0
    And the stderr should contain "FOLDER does not exist"
    And the stdout should not contain any of:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    And a directory named "FOLDER" should not exist
    And a directory named "FOLDER/RAW" should not exist
    And a directory named "FOLDER/VIDEO" should not exist
    And the following files should not exist:
    | FOLDER/foto1.jpg |
    | FOLDER/RAW/foto2.arw |
    | FOLDER/VIDEO/video.mts |

  #@announce
  Scenario: Fails if TARGET_FOLDER is not a folder
    Given empty files named:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    | FOLDER |
    When I run the following commands:
    """bash
    phls | phmove FOLDER
    """
    Then the exit status should not be 0
    And the stderr should contain "FOLDER is not a directory"
    And the stdout should not contain any of:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    And a directory named "FOLDER" should not exist
    And a directory named "FOLDER/RAW" should not exist
    And a directory named "FOLDER/VIDEO" should not exist
    And the following files should not exist:
    | FOLDER/foto1.jpg |
    | FOLDER/RAW/foto2.arw |
    | FOLDER/VIDEO/video.mts |

  #@announce:
  Scenario: Moves files to TARGET_FOLDER
    Given a directory named "FOLDER"
    And empty files named:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    When I run the following commands:
    """bash
    phls | phmove FOLDER
    """
    Then the exit status should be 0
    And the stdout should contain each of:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    And a directory named "FOLDER/RAW" should not exist
    And a directory named "FOLDER/VIDEO" should not exist
    And the following files should exist:
    | FOLDER/foto1.jpg |
    | FOLDER/foto2.arw |
    | FOLDER/video.mts |

  #@announce:
  Scenario: Moves files to current folder if TARGET_FOLDER is not set
    Given a directory named "FOLDER"
    And empty files named:
    | FOLDER/foto1.jpg |
    | FOLDER/foto2.arw |
    | FOLDER/video.mts |
    When I run the following commands:
    """bash
    phls FOLDER | phmove
    """
    Then the exit status should be 0
    And the stdout should contain each of:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    And the following files should exist:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    And the following files should not exist:
    | FOLDER/foto1.jpg |
    | FOLDER/foto2.arw |
    | FOLDER/video.mts |

  #@announce:
  Scenario: Moves and arranges files in TARGET_FOLDER
    Given a directory named "FOLDER"
    And empty files named:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    When I run the following commands:
    """bash
    phls | phmove -a FOLDER
    """
    Then the exit status should be 0
    And the stdout should contain each of:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    And a directory named "FOLDER" should exist
    And a directory named "FOLDER/RAW" should exist
    And a directory named "FOLDER/VIDEO" should exist
    And the following files should exist:
    | FOLDER/foto1.jpg |
    | FOLDER/RAW/foto2.arw |
    | FOLDER/VIDEO/video.mts |

    #@announce:
  Scenario: Keeps the RAW and VIDEO subfolders if they already exist
    Given a directory named "FOLDER"
    And a directory named "FOLDER/RAW"
    And a directory named "FOLDER/VIDEO"
    And empty files named:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    | FOLDER/RAW/foto2keep.arw |
    | FOLDER/VIDEO/video2keep.mts |
    When I run the following commands:
    """bash
    phls | phmove -a FOLDER
    """
    Then the exit status should be 0
    And the stdout should contain each of:
    | foto1.jpg |
    | foto2.arw |
    | video.mts |
    And a directory named "FOLDER" should exist
    And a directory named "FOLDER/RAW" should exist
    And a directory named "FOLDER/VIDEO" should exist
    And the following files should exist:
    | FOLDER/foto1.jpg |
    | FOLDER/RAW/foto2.arw |
    | FOLDER/VIDEO/video.mts |
    | FOLDER/RAW/foto2keep.arw |
    | FOLDER/VIDEO/video2keep.mts |

  #@announce:
  Scenario: Deletes unused RAW and VIDEO folders
    Given a directory named "FOLDER"
    And empty files named:
    | foto1.jpg |
    | foto2.tiff |
    When I run the following commands:
    """bash
    phls | phmove -a FOLDER
    """
    Then the exit status should be 0
    And the stdout should contain each of:
    | foto1.jpg |
    | foto2.tiff |
    And a directory named "FOLDER/RAW" should not exist
    And a directory named "FOLDER/VIDEO" should not exist
    And the following files should exist:
    | FOLDER/foto1.jpg |
    | FOLDER/foto2.tiff |
