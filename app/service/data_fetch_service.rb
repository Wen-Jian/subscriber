module DataFetchService
    class DataFetchService
        include Selenium
        include ConstantDefinition
        # def initialize(period)
        #     @period = period
        # end

        def self.execute
            settings = FetchSetting.where(revoke: false)
            destination = ""
            settings.each do |s|
                if destination != s.destination
                    if s.ticket_type == ROUND_TRIP_TICKET
                        fetch(s, s.depart, s.destination)
                        fetch(s, s.destination, s.depart)
                    else
                        fetch(s, s.depart, s.destination)
                    end
                end
                destination = s.destination
            end
            
            @period = (365 * 1.5).round
        end

        def self.fetch(setting, depart, destination)
            count = 0
            options = Selenium::WebDriver::Chrome::Options.new
            # options.add_argument('--headless')
            @driver = Selenium::WebDriver.for :chrome, options: options
            # set window size using Dimension struct
            @driver.manage.window.resize_to(1200, 768)
            date = setting.start_date > Date.today ? setting.start_date : Date.today + 1.day
            while date < setting.end_date
                date += count
                url = "https://flights.wingontravel.com/tickets-oneway-#{depart}-#{destination}/?outbounddate=#{date.day}%2F#{format('%02d', date.month)}%2F#{date.year}&adults=1&children=0&direct=false&cabintype=tourist&dport=&aport=&airline=&searchbox=t&curr=TWD"
                    # "https://flights.wingontravel.com/tickets-oneway-tpe-lon/?outbounddate=09%2F06%2F2019&adults=1&children=0&direct=false&cabintype=Tourist&dport=&aport=&airline=&searchbox=t"
                    # "https://flights.wingontravel.com/tickets-oneway-tpe-lon/?outbounddate=10%2F6%2F2019&adults=1&children=0&direct=false&cabintype=tourist&dport=&aport=&airline=&searchbox=t&curr=TWD"
                @driver.navigate.to url
                flight_type = TRANSFER_FLIGHT

                # set window size using Dimension struct
                @driver.manage.window.resize_to(1200, 768)

                content_type_1 = nil
                content_type_2 = nil
                while content_type_1.blank? && content_type_2.blank?
                    serch_btn = @driver.find_elements(:xpath, '//*[@id="app"]/div/div[1]/div[1]/header/div/div/div[2]/div[6]/button')[0]
                    puts serch_btn.text.encode('UTF-8')
                    serch_btn.click
                    sleep(2)
                    # press search button
                    content_type_1 = @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[4]/div')[0]
                    puts(content_type_1.try(:text))
                    content_type_2 = @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[5]/div[1]')[0]
                    puts(content_type_2.try(:text))
                end

                # close advertisement
                if count == 0 # || (count % 20 == 1 && count > 1)
                    @driver.find_elements(:xpath, '//*[@id="wg-site-apppop"]/div/a')[0].click
                    @driver.find_elements(:xpath,'//*[@id="app"]/div/div[4]/div/a')[0].click
                end

                # pause to avoid being detected as a robot
                sleep(2)

                # sorting data according price
                (@driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[3]/div[4]'))[0].click
                # pause for 8 seconds to avoid being detected as a robot
                sleep(1)


                if content_type_1.present? && content_type_1.text != '出發時間'
                    # screening for the flights without transfer
                    element = @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[1]/div/div[2]/div[2]/div/div[1]/div[1]/label/span[2]')[0]
                    if element.present? && element.try(:text) == "直飛"
                        element.click
                        flight_type = DIRECT_FLIGT
                        sleep(2)
                    end
                    # find the information of company
                    
                    flight_company = @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[4]/div[1]/div[1]/div[1]/div[2]/div[1]/span/span')[0].present? ? 
                        @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[4]/div[1]/div[1]/div[1]/div[2]/div[1]/span/span')[0].text.encode('UTF-8') : 
                        @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[5]/div[1]/div[1]/div[1]/div[2]/div[1]/span/span')[0].text.encode('UTF-8')
                                                                    
                    # find flight information
                    price_context = (@driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[4]/div[1]')[0].text)
                    prices = price_context.scan(/TWD(\d*,\d*)/)
                    unless prices.present?
                        price_context = (@driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[5]/div[1]/div[2]/div')[0].text)
                                                                        
                        prices = price_context.scan(/TWD(\d*,\d*)/)
                    end
                    unless prices.present?
                        price_context = (@driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div[1]/div[5]/div[1]/div[2]/div')[0].text)
                        prices = price_context.scan(/TWD(\d*,\d*)/)
                    end
                    
                elsif content_type_2.present?
                    # screening for the flights without transfer
                    element = @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[1]/div/div[2]/div[2]/div/div[1]/div[1]/label/span[2]')[0]
                    if element.present? && element.try(:text) == "直飛"
                        element.click
                        sleep(2)
                    end
                    # find the information of company
                    flight_company = @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[5]/div[1]/div[1]/div[1]/div[2]/div[1]/span/span')[0].text.encode('UTF-8')
    
                    # find flight information
                    price_context = (@driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[5]/div[1]')[0].text)
                    prices = price_context.scan(/TWD(\d*,\d*)/)
                end

                lowest_price = 99999999
                price = 0
                if prices.present?
                    prices = prices.flatten
                    prices.each do |p|
                        price = p.gsub(',', '').to_i
                        lowest_price = price if price < lowest_price
                    end
                end

                ticket = FlightTicket.find_by(flight_date: date, destination: destination, depart: depart)
                creatable = true
                if ticket.present?
                    ticket.update_attributes(
                        flight_company: flight_company,
                        price: lowest_price,
                        flight_type: flight_type,
                        updated_at: DateTime.now
                    )
                    creatable = false
                elsif prices.nil?
                    creatable = false
                end

                if creatable
                    FlightTicket.create(
                        flight_company: flight_company,
                        price: lowest_price,
                        destination: destination,
                        depart: depart,
                        flight_type: flight_type,
                        flight_date: date      
                    )
                end
                puts count
                count += 1
                # pause for 5 seconds to avoid being detected as a robot
                # sleep(5)
            end
        end
        def chinese_month_to_integer(chinese_month)
            case chinese_month
            when "一月"
                return 1
            when "二月"
                return 2
            when "三月"
                return 3
            when "四月"
                return 4
            when "五月"
                return 5
            when "六月" 
                return 6
            when "七月" 
                return 7
            when "八月" 
                return 8
            when "九月" 
                return 9
            when "十月" 
                return 10
            when "十一月" 
                return 11
            when "十二月" 
                return 12
            end
        end

        def dump_from_heroku
            `heroku pg:backups:capture`
            `heroku pg:backups:download`
            `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U wen -d crawler_develop latest.dump`
        end
    end
end
