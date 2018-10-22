module DataFetchService
    include Selenium
    class DataFetchService
        # def initialize(period)
        #     @period = period
        # end

        def self.execute
            count = 0
            @period = (365 * 1.5).round
            options = Selenium::WebDriver::Chrome::Options.new
            options.add_argument('--headless')
            @driver = Selenium::WebDriver.for :chrome, options: options
            
            # set window size using Dimension struct
            @driver.manage.window.resize_to(1200, 768)
            
            while count < @period
                # if count % 20 == 1 && count > 1
                #     driver.close
                #     driver = Selenium::WebDriver.for :chrome
                # end
                date = Date.tomorrow + count
                url = "https://flights.wingontravel.com/tickets-oneway-tpe-lon/?outbounddate=#{date.day}%2F#{date.month}%2F#{date.year}&adults=1&children=0&direct=false&cabintype=tourist&dport=&aport=&airline=&searchbox=t&curr=TWD"
                @driver.navigate.to url

                # pause for 20 seconds to avoid being detected as a robot
                # sleep(3)

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
                        sleep(2)
                    end
                    # find the information of company
                    
                    flight_company = @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[4]/div[1]/div[1]/div[1]/div[2]/div[1]/span/span')[0].present? ? 
                        @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[4]/div[1]/div[1]/div[1]/div[2]/div[1]/span/span')[0].text.encode('UTF-8') : 
                        @driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[5]/div[1]/div[1]/div[1]/div[2]/div[1]/span/span')[0].text.encode('UTF-8')
                                                                    
                    # find flight information
                    price_context = (@driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[4]/div[1]')[0].text)
                    prices = price_context.scan(/TWD(\d*,\d*)/)
                    
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

                ticket = FlightTicket.find_by(flight_date: date, destination: 'LON')
                creatable = true
                if ticket.present?
                    if ticket.price > lowest_price
                        ticket.update_attributes(
                            flight_company: flight_company,
                            price: lowest_price
                        )
                        creatable = false
                    end
                elsif prices.nil?
                    creatable = false
                end

                if creatable
                    FlightTicket.create(
                        flight_company: flight_company,
                        price: lowest_price,
                        destination: "London",
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

        def get_flight_information(content)
            
        end

    end
end