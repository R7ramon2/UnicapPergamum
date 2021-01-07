require 'net/http'
require 'net/https'
require 'json'
require 'pry'
require 'socket'


class Unicap
    attr_accessor :url
    attr_reader :cookie
    def initialize(login,senha)
        if not defined?@url
            @url = "https://www1.unicap.br/"
        end
        data = {"flag" => "index.php", "login" => login, "password" => senha, "button" => "Access"}
        response = request("#{@url}/pergamum3/Pergamum/biblioteca_s/php/login_usu.php",data,"post",nil)
        @cookie = response['set-cookie']
        location = response['location']

        header = {"Referer" => "https://www1.unicap.br/pergamum3/Pergamum/biblioteca_s/php/login_usu.php?flag=index.php","Cookie" => @cookie}
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
            request = Net::HTTP::Get.new( url )
            request['Cookie'] = @cookie
            request['User-Agent'] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:69.0) Gecko/20100101 Firefox/69.0"
            request['Accept'] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
            request['Referer'] = header['Referer']
            response = @http.request(request)
        end
        return response
    end

    def get_all_cod_livros()
        url = "#{@url}/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        header = {
            "Cookie" => @cookie, 
            "Referer" => "https://www1.unicap.br/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        }
        response = request(url,"","get",header)
        codigos_livros_aux = response.body.scan(/class="box_write_left">[0-9]{8}/)
        codigos_livros_aux.select {|value| value.gsub!("class=\"box_write_left\">","") }
        return codigos_livros_aux
    end

    def get_all_cod_name_livros()
        url = "#{@url}/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        header = {
            "Cookie" => @cookie, 
            "Referer" => "https://www1.unicap.br/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        }
        response = request(url,"","get",header)
        cod_livros = get_all_cod_livros
        livros = response.body.scan(/class="box_azul_left">.*/)
        livros.select {|value| 
            value.gsub!("class=\"box_azul_left\">","").gsub!(/ - <i>.*/,"")
            value.force_encoding('iso-8859-1').encode!('utf-8')
        }
        livros.delete_at(0)
        cod_and_livros = Hash.new
        livros.each_with_index do |value, index|
            cod_and_livros[cod_livros[index]] = value
        end
        return cod_and_livros
    end

    def renova_livro_by_cod(cod_livro,matricula)
        url = "#{@url}/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
        header = {
            "Cookie" => @cookie, 
            "Referer" => "https://www1.unicap.br/pergamum3/Pergamum/biblioteca_s/meu_pergamum/emp_renovacao.php"
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


matricula = ""
senha = ""
session = Unicap.new(matricula,senha)
cod_livros = session.get_all_cod_name_livros
binding.pry
