# frozen_string_literal: true

PACKAGES_DIR = 'app/data/packages'
PACKAGES_FIELDS = %i[package version md5sum].freeze
REQUIRED_FIELDS = %i[package version date/publication title author license maintainer].freeze
TRANSFORM_OUTPUT = {
  "package": 'Package Name',
  "version": 'Versions',
  "R Version needed": 'R Version needed',
  "Dependencies": 'Dependencies',
  "date/publication": 'Date/Publication',
  "title": 'Title',
  "author": 'Authors',
  "license": 'License',
  "maintainer": 'Maintainers'
}.freeze
