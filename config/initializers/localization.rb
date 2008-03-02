TzTime.zone = TZInfo::Timezone.new("America/Fortaleza")

class Time
  alias :strftime_nolocale :strftime
 
  def strftime(format)
    format = format.dup
    format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
    format.gsub!(/%A/, Date::DAYNAMES[self.wday])
    format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
    format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
    self.strftime_nolocale(format)
  end
end


ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
	:default => '%d/%m/%Y %H:%M',
	:date_time12  => "%d/%m/%Y %I:%M%p",
	:date_time24  => "%d/%m/%Y %H:%M"
)
