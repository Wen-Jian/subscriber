require "open-uri"

module ImageDownloader
    
    class ImageDownloader
        include Selenium
        include ConstantDefinition

        def self.fetch()
            count = 7576
            options = Selenium::WebDriver::Chrome::Options.new
            # options.add_argument('--headless')
            @driver = Selenium::WebDriver.for :chrome, options: options
            # set window size using Dimension struct
            @driver.manage.window.resize_to(1200, 768)

            url = "https://wall.alphacoders.com/big.php?i=602491&lang=Chinese"
            @driver.navigate.to url

            while count < 10000
                sleep(3.seconds)
                puts count
                url = @driver.current_url
                begin
                    element = @driver.find_element(:xpath, '//*[@id="page_container"]/div[7]/div[1]/span')
                    if element.text == '下载原图 1920x1080'
                        @driver.execute_script("window.scrollTo(0, #{element.location.y});")
                        element.click()
                        count += 1
                        sleep(1.seconds)
                    else
                        more_resol_btn = @driver.find_element(:xpath, '//*[@id="page_container"]/div[7]/div[1]/a[3]')
                        @driver.execute_script("window.scrollTo(0, #{more_resol_btn.location.y});")
                        more_resol_btn.click()
                        sleep(1.seconds)
                        element = @driver.find_element(:xpath, '//*[@id="resolution_container"]/div[1]/a[4]')
                        @driver.execute_script("window.scrollTo(0, #{element.location.y});")
                        element.click()
                        element = @driver.find_element(:xpath, '//*[@id="button_container"]/button[1]')
                        @driver.execute_script("window.scrollTo(0, #{element.location.y});")
                        element.click()
                        element = @driver.find_element(:xpath, '//*[@id="page_container"]/div[4]/span')
                        @driver.execute_script("window.scrollTo(0, #{element.location.y});")
                        element.click()
                        sleep(2.seconds)
                        count += 1
                        @driver.navigate.to url
                    end
                rescue
                    puts @driver.current_url
                    while @driver.current_url != url
                        @driver.navigate.to url
                    end
                    element = @driver.find_element(:xpath, '//*[@id="next_page"]')
                    @driver.execute_script("window.scrollTo(0, #{element.location.y});")
                    element.click()
                    next
                end
                puts @driver.current_url
                while @driver.current_url != url
                    @driver.navigate.to url
                end
                element = @driver.find_element(:xpath, '//*[@id="next_page"]')
                @driver.execute_script("window.scrollTo(0, #{element.location.y});")
                element.click()
            end
        end

        def self.other_fetch()
            count = 0
            options = Selenium::WebDriver::Chrome::Options.new
            # options.add_argument('--headless')
            @driver = Selenium::WebDriver.for :chrome, options: options
            # set window size using Dimension struct
            @driver.manage.window.resize_to(1200, 768)

            url = "http://www.8825.com/bizhi/342483.htm#1920x1080"
            @driver.navigate.to url

            while count <= 10000
                @driver.find_element(:xpath, '//*[@id="sizebtn"]').click()
                sleep(2.seconds)
                @driver.find_element(:xpath, '//*[@id="bignext"]/img').click()
                sleep(1.seconds)
            end
        end
    end

end