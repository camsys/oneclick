require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  # Coveralls::SimpleCov::Formatter
]
SimpleCov.maximum_coverage_drop 1
SimpleCov.start 'rails'
# Coveralls.wear_merged!('rails')

# require 'simplecov'
# SimpleCov.start 'rails'

# require 'coveralls'
# # See https://github.com/lemurheavy/coveralls-ruby/issues/22
# SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
#   SimpleCov::Formatter::HTMLFormatter
# ]
# Coveralls.wear_merged!('rails')
