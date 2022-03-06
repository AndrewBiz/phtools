# How to release a new gem version
1. Develop and test the feature in a separate branch
2. Merge branch in to master
3. Bump a version (version.rb)
4. Update TODO.md
5. Update History.md
6. Update README.md
7. `rake release`


# Manual gem release
1. Develop, test, document
2. gem build phtools.gemspec
3. install locally (if needed): gem install phtools
4. publish to rubygems.org: gem push phtools-x.xx.x.gem
5. don't forget to remove local phtools-x.xx.x.gem file
