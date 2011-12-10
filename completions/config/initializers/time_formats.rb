ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :default => "%m/%d/%Y",
  :mmddyy => "%m/%d/%y",
  :short => "%m/%d",
  :date_time12 => "%m/%d/%Y %I:%M%p",
  :date_time24 => "%m/%d/%Y %H:%M"
)

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :time => '%l:%M %p',
  :us => '%m/%d/%y',
  :us_with_time => '%m/%d/%y, %l:%M %p',
  :short_day => '%e %B %Y',
  :long_day => '%A, %e %B %Y',
  :day_of_week => '%w'
)