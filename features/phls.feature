# language: en
Feature: Generate a list of phtools-friendly-files
  In order to simplify chosing the foto\video files for further process
  As a photographer
  I want to get the list of foto\video files in a form of a plain text
  (one filename by line)

  #@announce
  Scenario: 00 Default output with -h produces usage information
    When I successfully run `phls -h`
    Then the stderr should contain each of:
    | Keep Your Photos In Order |
    | ANB                       |
    | Example:                  |
    | Usage:                    |
    | Options:                  |
    | -D --debug                |
    | -h --help                 |
    | --version                 |
    | -v                        |

  #@announce
  Scenario: 01 Output with -v produces version information
    When I successfully run `phls -v`
    Then the output should match /[0-9]+\.[0-9]+\.[0-9]+ \(core [0-9]+\.[0-9]+\.[0-9]+\)/

  #@announce
  Scenario: 1 Default output produces supported-by-phtools file list
    Given empty files named:
    | foto.jpeg       |
    | foto.jpg        |
    | foto.tif        |
    | foto.tiff       |
    | foto.orf        |
    | foto.arw        |
    | foto.png        |
    | foto.dng        |
    | foto_wrong.psd  |
    | video.avi       |
    | video.mp4       |
    | video.mpg       |
    | video.mts       |
    | video.dv        |
    | video.mov       |
    | video_wrong.3gp |
    | video.mkv       |
    | video.m2t       |
    | video.m2ts      |
    When I successfully run `phls`
    Then the stdout should contain each of:
    | foto.jpeg |
    | foto.jpg  |
    | foto.tif  |
    | foto.tiff |
    | foto.orf  |
    | foto.arw  |
    | foto.png  |
    | foto.dng  |
    | video.avi |
    | video.mp4 |
    | video.mpg |
    | video.dv  |
    | video.mts |
    | video.mov |
    | video.mkv |
    | video.m2t |
    | video.m2ts|
    And the stdout should not contain "foto_wrong.psd"
    And the stdout should not contain "video_wrong.3gp"

  #@announce
  Scenario: 2 The output DOES NOT show unsupported files EVEN if I intentionally enter it as a parameter
    Given empty files named:
    | foto_wrong.psd  |
    | video_wrong.3gp |
    When I successfully run `phls foto_wrong.psd video_wrong.3gp`
    Then the stdout should not contain "foto_wrong.psd"
    And  the stdout should not contain "video_wrong.3gp"

  #@announce
  Scenario: 3 The output shows files inside directories entered as paramenets
    Given a directory named "fotos"
    And empty files named:
    | ./fotos/f4.jpg       |
    | ./fotos/f4.tiff      |
    | ./fotos/f4.orf       |
    | ./fotos/f4.arw       |
    And a directory named "videos"
    And empty files named:
    | ./videos/v4.avi       |
    | ./videos/v4.mp4       |
    | ./videos/v4.mpg       |
    | ./videos/v4.dv        |
    When I successfully run `phls fotos videos`
    Then the stdout should contain each of:
    | fotos/f4.jpg  |
    | fotos/f4.tiff |
    | fotos/f4.orf  |
    | fotos/f4.arw  |
    | videos/v4.avi |
    | videos/v4.mp4 |
    | videos/v4.mpg |
    | videos/v4.dv  |

  #@announce
  Scenario: 4 The output DOES NOT show usopported files inside directories entered as paramenets
    Given a directory named "fotos"
    And empty files named:
    | ./fotos/f5_wrong.ppp  |
    And a directory named "videos"
    And empty files named:
    | ./videos/v5_wrong.vvv  |
    When I successfully run `phls fotos videos`
    Then the stdout should not contain "fotos/f5_wrong.ppp"
    And  the stdout should not contain "videos/v5_wrong.vvv"

  #@announce
  Scenario: 5 The output shows files inside directories and subdirectories
    Given a directory named "fotos"
    And empty files named:
    | ./fotos/f6.jpg         |
    And a directory named "fotos/fotos2"
    And empty files named:
    | ./fotos/fotos2/f6.tif  |
    And a directory named "fotos/fotos2/fotos3"
    And empty files named:
    | ./fotos/fotos2/fotos3/f6.png |
    When I successfully run `phls --recursive fotos`
    Then the stdout should contain each of:
    | fotos/f6.jpg                 |
    | fotos/fotos2/f6.tif          |
    | fotos/fotos2/fotos3/f6.png   |

  #@announce
  Scenario: 6 Default output produces supported-by-phtools file list with CAPITALIZED extentions
    Given a directory named "capitalized"
    Given empty files named:
    | foto_cap.JPG           |
    | ./capitalized/foto.TIF  |
    | ./capitalized/video.DV  |
    | ./capitalized/video.MOV |
    When I successfully run `phls foto_cap.JPG capitalized`
    Then the stdout should contain each of:
    | foto_cap. |
    | foto.TIF  |
    | video.DV  |
    | video.MOV |
