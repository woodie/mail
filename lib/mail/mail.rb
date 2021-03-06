# encoding: utf-8
module Mail
  
  # Allows you to create a new Mail::Message object.
  # 
  # You can make an email via passing a string or passing a block.
  # 
  # For example, the following two examples will create the same email
  # message:
  # 
  # Creating via a string:
  # 
  #  string = 'To: mikel@test.lindsaar.net\r\n'
  #  string << 'From: bob@test.lindsaar.net\r\n\r\n'
  #  string << 'Subject: This is an email\r\n'
  #  string << '\r\n'
  #  string << 'This is the body'
  #  Mail.new(string)
  # 
  # Or creating via a block:
  # 
  #  message = Mail.new do
  #    to 'mikel@test.lindsaar.net'
  #    from 'bob@test.lindsaar.net'
  #    subject 'This is an email'
  #    body 'This is the body'
  #  end
  # 
  # Or creating via a hash (or hash like object):
  # 
  #  message = Mail.new({:to => 'mikel@test.lindsaar.net',
  #                      'from' => 'bob@test.lindsaar.net',
  #                       :subject 'This is an email',
  #                       :body 'This is the body' })
  # 
  # Note, the hash keys can be strings or symbols, the passed in object
  # does not need to be a hash, it just needs to respond to :each_pair
  # and yield each key value pair.
  # 
  # As a side note, you can also create a new email through creating
  # a Mail::Message object directly and then passing in values via string,
  # symbol or direct method calls.  See Mail::Message for more information.
  # 
  #  mail = Mail.new
  #  mail.to = 'mikel@test.lindsaar.net'
  #  mail[:from] = 'bob@test.lindsaar.net'
  #  mail['subject'] = 'This is an email'
  #  mail.body = 'This is the body'
  def Mail.new(*args, &block)
    Mail::Message.new(args, &block)
  end

  # Sets the default delivery method and retriever method for all new Mail objects.
  # The delivery_method and retriever_method default to :smtp and :pop3, with defaults
  # set.
  # 
  # So sending a new email, if you have an SMTP server running on localhost is
  # as easy as:
  # 
  #   Mail.deliver do
  #     to      'mikel@test.lindsaar.net'
  #     from    'bob@test.lindsaar.net'
  #     subject 'hi there!'
  #     body    'this is a body'
  #   end
  # 
  # If you do not specify anything, you will get the following equivalent code set in
  # every new mail object:
  # 
  #   Mail.defaults do
  #     delivery_method :smtp, { :address              => "localhost",
  #                              :port                 => 25,
  #                              :domain               => 'localhost.localdomain',
  #                              :user_name            => nil,
  #                              :password             => nil,
  #                              :authentication       => nil,
  #                              :enable_starttls_auto => true  }
  # 
  #     retriever_method :pop3, { :address             => "localhost",
  #                               :port                => 995,
  #                               :user_name           => nil,
  #                               :password            => nil,
  #                               :enable_ssl          => true }
  #   end
  # 
  #   Mail.delivery_method.new  #=> Mail::SMTP instance
  #   Mail.retriever_method.new #=> Mail::POP3 instance
  #
  # Each mail object inherits the default set in Mail.delivery_method, however, on
  # a per email basis, you can override the method:
  #
  #   mail.delivery_method :sendmail
  # 
  # Or you can override the method and pass in settings:
  # 
  #   mail.delivery_method :sendmail, { :address => 'some.host' }
  # 
  # You can also just modify the settings:
  # 
  #   mail.delivery_settings = { :address => 'some.host' }
  # 
  # The passed in hash is just merged against the defaults with +merge!+ and the result
  # assigned the mail object.  So the above example will change only the :address value
  # of the global smtp_settings to be 'some.host', keeping all other values
  def Mail.defaults(&block)
    Mail::Configuration.instance.instance_eval(&block)
  end
  
  # Returns the delivery method selected, defaults to an instance of Mail::SMTP
  def Mail.delivery_method
    Mail::Configuration.instance.delivery_method
  end

  # Returns the retriever method selected, defaults to an instance of Mail::POP3
  def Mail.retriever_method
    Mail::Configuration.instance.retriever_method
  end

  # Send an email using the default configuration.  You do need to set a default
  # configuration first before you use Mail.deliver, if you don't, an appropriate
  # error will be raised telling you to.
  # 
  # If you do not specify a delivery type, SMTP will be used.
  # 
  #  Mail.deliver do
  #   to 'mikel@test.lindsaar.net'
  #   from 'ada@test.lindsaar.net'
  #   subject 'This is a test email'
  #   body 'Not much to say here'
  #  end
  # 
  # You can also do:
  # 
  #  mail = Mail.read('email.eml')
  #  mail.deliver!
  # 
  # And your email object will be created and sent.
  def Mail.deliver(*args, &block)
    mail = Mail.new(args, &block)
    delivery_method.deliver!(mail)
    mail
  end

  # Find emails in a POP3 server.
  # See Mail::POP3 for a complete documentation.
  def Mail.find(*args, &block)
    retriever_method.find(*args, &block)
  end

  # Receive the first email(s) from a Pop3 server.
  # See Mail::POP3 for a complete documentation.
  def Mail.first(*args, &block)
    retriever_method.first(*args, &block)
  end

  # Receive the first email(s) from a Pop3 server.
  # See Mail::POP3 for a complete documentation.
  def Mail.last(*args, &block)
    retriever_method.last(*args, &block)
  end

  # Receive all emails from a POP3 server.
  # See Mail::POP3 for a complete documentation.
  def Mail.all(*args, &block)
    retriever_method.all(*args, &block)
  end

  # Reads in an email message from a path and instantiates it as a new Mail::Message
  def Mail.read(filename)
    Mail.new(File.read(filename))
  end

  # Provides a store of all the emails sent
  def Mail.deliveries
    @@deliveries ||= []
  end
  
  protected
  
  def Mail.random_tag
    t = Time.now
    sprintf('%x%x_%x%x%d%x',
            t.to_i, t.tv_usec,
            $$, Thread.current.object_id.abs, Mail.uniq, rand(255))
  end
  
  private

  def Mail.something_random
    (Thread.current.object_id * rand(255) / Time.now.to_f).to_s.slice(-3..-1).to_i
  end
  
  def Mail.uniq
    @@uniq += 1
  end
  
  @@uniq = Mail.something_random
  
end