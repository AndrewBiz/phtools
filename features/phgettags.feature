# language: en
Feature: Get EXIF/IPC/whatever tags of the media file
  In order to examine the values and the list of tags stored inside the file
  As a photographer I want to get the output with the tags

  #@announce
  Scenario: phtools knows about this tool
    When I successfully run `phtools`
    Then the stdout should contain "phgettags\t(extracts the tags stored inside the file)"
    And the stdout should not contain "phgettags\t(!UNDER CONSTRUCTION!)"

  #@announce
  Scenario: Output with -h produces usage information
    When I run `phgettags -h`
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
    When I run `phgettags -v`
    Then the output should match /v[0-9]+\.[0-9]+\.[0-9]+(-[a-z,0-9]+)?/

  #@announce
  Scenario: For photo file is shows phtools related tags
    Given a directory named "tags1"
    And example files from "features/media/sony_jpg" copied to "tags1" named:
    | DSC03403.JPG |

    When I cd to "tags1"
    When I run the following commands:
    """bash
    phls | phgettags
    """
    Then the exit status should be 0

    Then the stdout should contain each of:
    | FileModifyDate |
    | City |
    | LocationShownCity |
    | CodedCharacterSet |
    | CollectionName |
    | CollectionURI |
    | Copyright |
    | CopyrightNotice |
    | Rights |
    | Country-PrimaryLocationName |
    | Country |
    | LocationShownCountryName |
    | LocationShownCountryCode |
    | CreateDate |
    | SubSecTimeDigitized |
    | DigitalCreationDate |
    | DigitalCreationTime |
    | Artist |
    | By-line |
    | Creator |
    | DateTimeOriginal |
    | SubSecTimeOriginal |
    | DateCreated |
    | TimeCreated |
    | GPSPosition |
    | GPSLatitude |
    | GPSLatitudeRef |
    | GPSLongitude |
    | GPSLongitudeRef |
    | GPSAltitude |
    | GPSAltitudeRef |
    | ImageUniqueID |
    | Keywords |
    | Subject |
    | Sub-location |
    | Location |
    | LocationShownSublocation |
    | ModifyDate |
    | Province-State |
    | State |
    | LocationShownProvinceState |
    | LocationShownWorldRegion |

  #@announce
  Scenario: In full_dump mode it shows all existing tags
    Given a directory named "tags2"
    And example files from "features/media/sony_jpg" copied to "tags2" named:
    | DSC03403.JPG |

    When I cd to "tags2"
    When I run the following commands:
    """bash
    phls | phgettags --full_dump
    """
    Then the exit status should be 0

    Then the stdout should contain each of:
    | ExifToolVersion          |
    | FileSize                 |
    | FileModifyDate           |
    | FileAccessDate           |
    | FileInodeChangeDate      |
    | FilePermissions          |
    | FileType                 |
    | FileTypeExtension        |
    | MIMEType                 |
    | JFIFVersion              |
    | ExifByteOrder            |
    | ImageDescription         |
    | Make                     |
    | Model                    |
    | XResolution              |
    | YResolution              |
    | ResolutionUnit           |
    | Software                 |
    | ModifyDate               |
    | Artist                   |
    | YCbCrPositioning         |
    | ExposureTime             |
    | FNumber                  |
    | ExposureProgram          |
    | ISO                      |
    | SensitivityType          |
    | RecommendedExposureIndex |
    | ExifVersion              |
    | DateTimeOriginal         |
    | CreateDate               |
