

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
                    @http = Net::HTTP.new( url.host, url.port)
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
            response = Net::HTTP.start(url.hostname, url.port) {|http|
                http.request(request)
            }
        end
        return response
    end

    def get_all_cod_livros()
        url = "#{@url}/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        header = {
            "Cookie" => @cookie, 
            "Referer" => "http://www.unicap.br/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        }
        response = request(url,"","get",header)
        codigos_livros_aux = response.body.scan(/class="box_write_left">[0-9]{8}/)
        codigos_livros_aux.select {|value| value.gsub!("class=\"box_write_left\">","") }
        return codigos_livros_aux
    end

    def renova_livro_by_cod(cod_livro,matricula)
        url = "#{@url}/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        header = {
            "Cookie" => @cookie, 
            "Referer" => "http://www.unicap.br/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        }
        data = ""
        selecs = ""
        cod_livro.each do |value|
            selecs+="#{value}@#1@#1;"
            data = {
                "renova" => "renovar",
                "Selecs" => selecs,
                "acao"   => "clicou",
                "codigoreduzido_anterior" => matricula,
                "todos"  => "on"
            }
        end
        data = data.uniq
        response = request(url,data,"post",header)
    end
end

matricula = "2015204740"
senha = "196722"
session = Unicap.new(matricula,senha)
livros = session.get_all_cod_livros
binding.pry
session.renova_livro_by_cod(livros,matricula)