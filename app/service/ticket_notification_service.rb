module TicketNotificationService
    class TicketNotificationService
        include ConstantDefinition
        def self.price_check
            settings = FetchSetting.where(revoke: false)
            htmlbody = ""
            settings.each do |setting|
                htmlbody << (setting.ticket_type == ONE_WAY_TICKET ? one_way_ticket(setting) : round_trip_tickets(setting))
            end
            if htmlbody.present?
                sender = "yichi0707@gmail.com"
                recipient = "genning7@gmail.com"
                awsregion = "us-west-2"
                subject = "便宜機票"
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
                                        })
                    puts "Email sent!"
                
                # If something goes wrong, display an error message.
                rescue Aws::SES::Errors::ServiceError => error
                    puts "Email not sent. Error message: #{error}"
                end
            end
        end
        
        def self.create_table_content(tickets_hash)
            str = "#{@flight_type} \n"
            str << '<tr>'\
                 "<th> #{tickets_hash[:ticket_price]} </th>"\
                 "<th> #{tickets_hash[:depart_date]} </th>"\
                 "<th>#{tickets_hash[:return_date]}</th>"
                 '</tr>'
            return str
        end

        def self.one_way_ticket(setting)
            htmlbody = ""
            table_content = ""
            @tickets = FlightTicket.where("price < ?", setting.notify_price).where(destination: setting.destination, flight_type: setting.flight_type).order(flight_date: :asc).where("flight_date > ?", Date.today)
           if @tickets.present?
               if setting.flight_type == DIRECT_FLIGT
                   @flight_type = '直飛'
               else
                   @flight_type = '轉機'
               end
               @date_from = @tickets.first.flight_date
               @date_end = @tickets.first.flight_date
               @tickets.each do |t|
                   if t.flight_date < @date_from
                       @date_from = t.flight_date
                   end
                   if t.flight_date > @date_end
                       @date_end = t.flight_date
                   end
                   tickets_hash = {depart_date: t.flight_date, ticket_price: t.price}
                   table_content << create_table_content(tickets_hash)
               end
           
               htmlbody <<
               '<h1>TPE->' + setting.destination + '便宜機票</h1>'\
               '<h2>One way tickets</h2>'\
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
           end
           return htmlbody
                

        end

        def self.round_trip_tickets(setting)
            htmlbody = ""
            table_content = ""
            return_tickets = []
            @tickets = FlightTicket.where(
                destination: setting.destination,
                flight_type: setting.flight_type 
                 ).order(flight_date: :asc).where("flight_date > ?", Date.today)
            if @tickets.present?
                if setting.flight_type == DIRECT_FLIGT
                    @flight_type = '直飛'
                else
                    @flight_type = '轉機'
                end

                @date_from = @tickets.first.flight_date
                @date_end = @tickets.first.flight_date
                @tickets.each do |t|
                    if t.flight_date < @date_from
                        @date_from = t.flight_date
                    end
                    if t.flight_date > @date_end
                        @date_end = t.flight_date
                    end
                    for i in 5..7 do
                        desired_price = setting.notify_price - t.price
                        FlightTicket.where("price < ?", desired_price).where(
                            depart: setting.destination, 
                            destination: t.depart.present? ? t.depart : 'tpe',
                            flight_type: setting.flight_type,
                            flight_date: t.flight_date + i
                            ).order(flight_date: :asc).each do |t|
                                return_tickets << t
                            end
                    end
                    ticket_prices = []
                    if return_tickets.present?
                        return_tickets.each do |r|
                            tickets_hash = {depart_date: t, ticket_price: t.price + r.price, return_date: r.flight_date }
                            table_content << create_table_content(tickets_hash)
                        end
                    end
                end
                if table_content.present?
                    htmlbody <<
                    '<h1>TPE->' + setting.destination + '便宜機票</h1>'\
                    '<h2>One way tickets</h2>'\
                    '<h3>機票時間區間</h3>'\
                    '<h3>起</h3>'\
                    "<h3>#{@date_from}</h3>"\
                    '<h3>迄</h3>'\
                    "<h3>#{@date_end}</h3>"\
                    '<h4>航班資訊</h4>'\
                    '<table>'\
                    '<tr>'\
                        '<th>總價格</th>'\
                        '<th>台北出發日期</th>'\
                        '<th>回程時間</th>'
                    '</tr>'\
                    "#{table_content}"\
                    '</table>\n\n'
                end
            end
            return htmlbody
        end
    end
end