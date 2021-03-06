module Mail
  # A delivery method implementation which sends via sendmail.
  # 
  # To use this, first find out where the sendmail binary is on your computer,
  # if you are on a mac or unix box, it is usually in /usr/sbin/sendmail, this will
  # be your sendmail location.
  # 
  #   Mail.defaults do
  #     delivery_method :sendmail
  #   end
  # 
  # Or if your sendmail binary is not at '/usr/sbin/sendmail'
  # 
  #   Mail.defaults do
  #     delivery_method :sendmail, :location => '/absolute/path/to/your/sendmail'
  #   end
  # 
  # Then just deliver the email as normal:
  # 
  #   Mail.deliver do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing sendmail'
  #     body 'testing sendmail'
  #   end
  # 
  # Or by calling deliver on a Mail message
  # 
  #   mail = Mail.new do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing sendmail'
  #     body 'testing sendmail'
  #   end
  # 
  #   mail.deliver!
  class Sendmail
    
    def initialize(values)
      self.settings = { :location       => '/usr/sbin/sendmail',
                        :arguments      => '-i -t' }.merge(values)
    end
    
    attr_accessor :settings

    def deliver!(mail)
      mail.return_path ? return_path = "-f \"#{mail.return_path}\"" : return_path = nil
      arguments = [settings[:arguments], return_path].compact.join(" ")
      
      Sendmail.call(settings[:location], arguments, mail.destinations.join(" "), mail)
    end
    
    def Sendmail.call(path, arguments, destinations, mail)
      IO.popen("#{path} #{arguments} #{destinations}", "w+") do |io|
        io.puts mail.encoded.to_lf
        io.flush
      end
    end
  end
end
