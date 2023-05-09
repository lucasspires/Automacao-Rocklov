describe "POST /signup" do
  context "novo usuario" do
    before(:all) do
      payload = { name: "Pitty", email: "pitty@bol.com.br", password: "pwd123" }
      MongoDB.new.remove_user(payload[:email])

      @result = Signup.new.create(payload)
    end

    it "valida status code" do
      expect(@result.code).to eql 200
    end

    it "valida id do usuário" do
      expect(@result.parsed_response["_id"].length).to eql 24
    end
  end

  context "usuario ja existe" do
    before(:all) do
      #Dado que eu tenho um novo usuário
      payload = { name: "João da Silva", email: "joao@ig.com.br", password: "pwd123" }
      MongoDB.new.remove_user(payload[:email])

      #E o email desse usuário já foi cadastrado no sistema
      Signup.new.create(payload)

      # Quando faço uma nova requisição para a rota /signup
      @result = Signup.new.create(payload)
    end

    it "deve retornar 409" do
      #Então deve retornar o status code 409
      expect(@result.code).to eql 409
    end

    it "deve retornar mensagem" do
      expect(@result.parsed_response["error"]).to eql "Email already exists :("
    end
  end

  examples = [
    {
      title: "Nome em Branco",
      payload: { name: "", email: "joao@ig.com.br", password: "pwd123" },
      code: 412,
      error: "required name",
    },
    {
      title: "Sem o campo nome",
      payload: { email: "joao@ig.com.br", password: "pwd123" },
      code: 412,
      error: "required name",
    },
    {
      title: "email em branco",
      payload: { name: "João da Silva", email: "", password: "pwd123" },
      code: 412,
      error: "required email",
    },
    {
      title: "sem o campo email",
      payload: { name: "João da Silva", password: "pwd123" },
      code: 412,
      error: "required email",
    },
    {
      title: "senha em branco",
      payload: { name: "João da Silva", email: "joao@ig.com.br", password: "" },
      code: 412,
      error: "required password",
    },
    {
      title: "sem o campo senha",
      payload: { name: "João da Silva", email: "joao@ig.com.br" },
      code: 412,
      error: "required password",
    },
  ]

  examples.each do |e|
    context "#{e[:title]}" do
      before(:all) do
        @result = Signup.new.create(e[:payload])
      end

      it "valida status code #{e[:code]}" do
        expect(@result.code).to eql e[:code]
      end

      it "valida menasgem #{e[:error]}" do
        expect(@result.parsed_response["error"]).to eql e[:error]
      end
      # nome é obrigatório
      # email é obrigatório
      # password é obrigatório

    end
  end
end
