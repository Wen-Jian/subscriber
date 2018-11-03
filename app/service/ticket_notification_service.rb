module TicketNotificationService
    class TicketNotificationService
        def self.price_check
            settings = FetchSetting.where(revoke: false)
            settings.each do |s|
                @tickets = FlightTicket.where("price < ?", s.notify_price).where(destination: s.destination).order(flight_date: :asc)
                if @tickets.present?
                    date_from = @tickets.first.flight_date
                    date_end = @tickets.first.flight_date
                    @tickets.each do |t|
                        if t.flight_date < date_from
                            date_from = t.flight_date
                        end
                        if t.flight_date > date_end
                            date_end = t.flight_date
                        end
                    end
                end
                sender = "afteepublic01@gmail.com"
                recipient = "genning7@gmail.com"
                awsregion = "us-west-2"
                subject = "TPE-> #{s.destination}便宜機票"
                table_content = create_table_content
                htmlbody =
                    '<h1>TPE->' + s.destination + '便宜機票</h1>'\
                    '<h3>機票時間區間</h3>'\
                    '<h3>起</h3>'\
                    "<h3>#{@date_from}</h3>"\
                    '<h3>迄</h3>'\
                    "<h3>#{@date_end}</h3>"\
                    '<h4>航班資訊</h4>'\
                    '<table>'\
                    '<tr>'\
                        '<th>價格</th>'\
                        '<th>航班時間</th>'\
                    '</tr>'\
                    "#{table_content}"\
                    '</table>'
    
                
                encoding = "UTF-8"
                ses = Aws::SES::Client.new(region: awsregion)
    
                # Try to send the email.
                begin
                    # Provide the contents of the email.
                    resp = ses.send_email({
                                            destination: {
                                            to_addresses: [
                                                            recipient,
                                                            ],
                                            },
                                            message: {
                                            body: {
                                                html: {
                                                charset: encoding,
                                                data: htmlbody,
                                                }
                                            },
                                            subject: {
                                                charset: encoding,
                                                data: subject,
                                            },
                                            },
                                            source: sender
                                            # Comment or remove the following line if you are not using
                                            # a configuration set
                                            # configuration_set_name: configsetname,
                                        })
                    puts "Email sent!"
                
                # If something goes wrong, display an error message.
                rescue Aws::SES::Errors::ServiceError => error
                    puts "Email not sent. Error message: #{error}"
                
                end
            end
        end
        
        def self.create_table_content
            str = ""
            @tickets.each do |t|
                str << '<tr>'\
                 "<th> #{t.price} </th>"\
                 "<th> #{t.flight_date} </th>"\
                 '</tr>'\
            end
            return str
        end
    end
end