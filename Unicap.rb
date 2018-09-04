require 'net/http'
require 'json'
require 'pry'

class Unicap
    attr_accessor :url
    attr_reader :cookie
    def initialize(login,senha)
        if not defined?@url
            @url = "http://www.unicap.br/"
        end
        data = {"flag" => "index.php", "login" => login, "password" => senha, "button" => "Acessar"}
        response = request("#{@url}/pergamum3/Pergamum/biblioteca_s/php/login_usu.php",data,"post",nil)
        @cookie = response['set-cookie']
        location = response['location']

        header = {"Referer" => "http://www.unicap.br/pergamum3/Pergamum/biblioteca_s/php/login_usu.php?flag=index.php","Cookie" => @cookie}
        response = request("#{@url}/pergamum3/Pergamum/biblioteca_s/php/#{location}","","get",header)
        binding.pry
    end

    def request(uri, data,method,header)
        url = URI.parse(uri) 
        if uri.include?"https"
            begin
                if not defined?@http
                    @http = Net::HTTP.new( url.host, url.port)
                    @http.use_ssl = true
                    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                end
            rescue 
                puts "Erro ao criar conexão"
                exit
            end
        else
            begin
                if not defined?@http
                    @http = Net::HTTP.new( url.host, url.port, "localhost", 8080)
                end
            rescue 
                puts "Erro ao criar conexão"
                exit
            end
        end
    
        if method.upcase == "POST"
            request = Net::HTTP::Post.new( url.path , header)
            request.set_form_data(data)
            response = @http.request( request )
        elsif method.upcase == "GET"
            if data != ""
                url.query = URI.encode_www_form(data)
            end
            request = Net::HTTP::Get.new(url)
            header.each do |value|
                request[value[0]] = value[1]
            end
            response = Net::HTTP.start(url.hostname, url.port,"localhost",8080) {|http|
                http.request(request)
            }
        end
        return response
    end

    def get_livros()
        url = "#{@url}/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        header = {
            "Cookie" => @cookie, 
            "Referer" => "http://www.unicap.br/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php",
            "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language" => "pt-BR,pt;q=0.8,en-US;q=0.5,en;q=0.3",
            "Accept-Encoding" => "Accept-Encoding: gzip, deflate"

        }
        response = request(url,"","get",header)
        binding.pry
    end
end

session = Unicap.new("2015204740","196722")
# data = {"nomepessoa2" => "RAMON+RANIERI+ALVES+ALCANTARA", "codigointeiro2" => "2015204740", "codigoreduzido2" => "2015204740", "flag" => "index.php"}
# header = {
#     "Cookie" => session.cookie,
#     "Referer" => "http://www.unicap.br/pergamum3/Pergamum/biblioteca_s/php/login_usu.php?flag=index.php",
#     "Host" => "www.unicap.br",
#     "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0",
#     "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
#     "Accept-Language" => "pt-BR,pt;q=0.8,en-US;q=0.5,en;q=0.3",
#     "Accept-Encoding" => "gzip, deflate"
# }
# r = session.request("#{session.url}/pergamum3/Pergamum/biblioteca_s/php/sessao.php",data,"get",header)
binding.pry