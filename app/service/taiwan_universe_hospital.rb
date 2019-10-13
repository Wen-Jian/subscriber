module TaiwanUniverseHospital
    class TaiwanUniverseHospital
        include Selenium
        include MiniMagick

        def self.sync_execute
            drivers = []
            options = Selenium::WebDriver::Chrome::Options.new
            5.times { drivers << (Selenium::WebDriver.for :chrome, options: options)}
            threads = []
            drivers.each { |driver|
              threads << Thread.new { self.execute(driver)}
              sleep(0.1) 
            }
            threads.each(&:join)
        end
        
        def self.execute(driver)
            timestamp = DateTime.now.strftime('%Y%M%d%H%M%S%3N')
            image_path = "/Users/wen/Desktop/programing/subscriber/ruby/subscriber/screenshot/#{timestamp}.png"
            output_path = "/Users/wen/Desktop/programing/subscriber/ruby/subscriber/screenshot/sample#{timestamp}.png"
            options = Selenium::WebDriver::Chrome::Options.new
            # options.add_argument('--headless')
            # @driver = Selenium::WebDriver.for :chrome, options: options
            url = "https://reg.ntuh.gov.tw/webadministration/DoctorServiceQueryByDrName.aspx?HospCode=T0"
            driver.navigate.to url
            element = driver.find_elements(:id, "DoctorNameInputTextBox")[0]
        
            element.send_keys("李克仁")
            # element.send_keys("李")

            element = driver.find_elements(:id, "SubmitQueryButton")[0]
            element.click
            element =  driver.find_elements(:xpath, '//*[@id="DoctorServiceListInSeveralDaysInput_GridViewDoctorServiceList__ctl4_AdminTextShow"]')[0]
            # element =  driver.find_elements(:id, 'DoctorServiceListInSeveralDaysInput_GridViewDoctorServiceList__ctl8_AdminTextShow')[0]
    
            # driver.execute_script("window.scrollTo(0, #{element.location.y});")
            puts element.text
            if element.text == '掛號'
                element.click
            end
            driver.save_screenshot(image_path)
            
            image = MiniMagick::Image.open(image_path)
            cropped_img = image.crop('356x109+395+715').contrast().colorspace("Gray").write(output_path)

            image = RTesseract.new(output_path , options: :digits)
            str = image.to_s.split().pop
            puts str
            driver.find_elements(:xpath, '//*[@id="radInputNum"]/tbody/tr[2]/td/label')[0].click
            driver.find_elements(:xpath, '//*[@id="txtIdno"]')[0].send_keys('q221238608')
            driver.find_elements(:xpath, '//*[@id="txtVerifyCode"]')[0].send_keys(str)

            driver.find_elements(:xpath, '//*[@id="ddlBirthYear"]')[0].send_keys('55')
            driver.find_elements(:xpath, '//*[@id="ddlBirthMonth"]')[0].send_keys('12')
            driver.find_elements(:xpath, '//*[@id="ddlBirthDay"]')[0].send_keys('04')

            driver.find_elements(:xpath, '//*[@id="btnOK"]')[0].click()
            driver.save_screenshot(image_path)

        end
    end
end