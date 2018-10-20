module DataFetchService
    include Selenium
    class DataFetchService
        # def initialize(period)
        #     @period = period
        # end

        def self.execute
            count = 0
            @period = (365*1.5).round
            options = Selenium::WebDriver::Chrome::Options.new
            options.add_argument('--headless')
            driver = Selenium::WebDriver.for :chrome, options: options
            
            # set window size using Dimension struct
            target_size = Selenium::WebDriver::Dimension.new(1024, 768)
            driver.manage.window.size = target_size
            
            while count < @period
                # if count % 20 == 1 && count > 1
                #     driver.close
                #     driver = Selenium::WebDriver.for :chrome
                # end
                date = Date.tomorrow + count
                url = "https://flights.wingontravel.com/tickets-oneway-tpe-tyo/?outbounddate=#{date.day}%2F#{date.month}%2F#{date.year}&adults=1&children=0&infants=0&direct=false&cabintype=Tourist&airlinecode=&dport=&aport=&searchbox=t&curr=TWD"
                driver.navigate.to url

                # pause for 20 seconds to avoid being detected as a robot
                # sleep(8)

                # set window size using Dimension struct
                target_size = Selenium::WebDriver::Dimension.new(1024, 768)
                driver.manage.window.size = target_size

                content = nil
                while content.blank?
                    serch_btn = driver.find_elements(:xpath, '//*[@id="app"]/div/div[1]/div[1]/header/div/div/div[2]/div[6]/button')[0]
                    puts serch_btn.text.encode('UTF-8')
                    serch_btn.click
                    sleep(2)
                    # press search button
                    content = driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[5]')[0]
                    puts content
                end

                # # close advertisement
                # if count == 0 # || (count % 20 == 1 && count > 1)
                #     driver.find_elements(:xpath, '//*[@id="wg-site-apppop"]/div/a')[0].click
                #     driver.find_elements(:xpath,'//*[@id="app"]/div/div[4]/div/a')[0].click
                # end

                # # pause for 8 seconds to avoid being detected as a robot
                # sleep(2)

                # # sorting data according price
                # (driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[4]/div[4]'))[0].click
                # # pause for 8 seconds to avoid being detected as a robot
                # sleep(1)

                # # screening for the flights without transfer
                # element = driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[1]/div/div[2]/div[2]/div/div[1]/div[1]/label/span[2]')[0]
                # if element.text == "直飛"
                #     element.click
                # end

                # sleep(2)


                # find the information of company
                flight_company = driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[3]/div[3]/div[1]/div/div[1]/span')[0].text.encode('UTF-8')
    
                # find flight information
                price = (driver.find_elements(:xpath, '//*[@id="app"]/div/div[3]/div/div[2]/div/div[3]/div[3]/div[1]/div/div[2]/span')[0].text)
                price = price.gsub('TWD', '') 
                price = price.gsub(',', '').to_i

                ticket = FlightTicket.find_by(flight_date: date)
                creatable = false
                if ticket.present?
                    if ticket.price > price
                        ticket.update_attributes(
                            flight_company: flight_company,
                            price: 3000
                        )
                    end
                else
                    creatable = true
                end

                if creatable
                    FlightTicket.create(
                        flight_company: flight_company,
                        price: price,
                        destination: "Tokyo",
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
    end
end