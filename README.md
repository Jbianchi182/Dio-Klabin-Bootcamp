Projetos de Modelagem de Banco de Dados

Este repositório contém as soluções completas para desafios de projeto focados em modelagem de bancos de dados relacionais. Cada projeto abrange o ciclo completo: desde a concepção do esquema lógico e sua implementação em SQL, até a inserção de dados de exemplo e a criação de consultas complexas para responder a perguntas de negócio.

Projeto 1: Plataforma de E-commerce

Descrição do Projeto

O primeiro desafio consistiu em modelar e implementar um banco de dados robusto para uma plataforma de e-commerce. A estrutura de dados foi projetada para gerenciar todo o fluxo de uma venda online, incluindo o cadastro de clientes e produtos, o processamento de pedidos, as múltiplas formas de pagamento e a logística de entrega com rastreamento. O modelo foi criado considerando o criado em aula online e alterações que julguei necessárias, acredito que vi isso sendo incentivado em materiais do bootcamp. 

Esquema Lógico (Modelo Relacional)

O banco de dados foi estruturado com as seguintes entidades principais:

    Client: Armazena dados de clientes, com suporte para PF e PJ.

    Product: O catálogo de produtos da loja.

    Orders: A entidade central que representa uma compra feita por um cliente.

    Payments: Controla as transações financeiras, ligadas a um pedido.

    Client_Payment_Methods: Permite que clientes salvem seus métodos de pagamento.

    Shipping: Gerencia a entrega de cada pedido, com status e código de rastreio.

    Seller e Supplier: Distinção entre quem vende e quem fornece os produtos.

    Tabelas de Localização (Address, City, State, etc.).

    Tabelas Associativas para relacionamentos N-N (ProductOrder, ProductSeller).

Destaques do Modelo

O design foi refinado para suportar regras de negócio específicas e essenciais para um e-commerce moderno:

    Cliente PF e PJ: A tabela Client possui uma restrição (CHECK) que garante que um cliente seja cadastrado com CPF ou CNPJ, mas nunca ambos.

    Múltiplos Métodos de Pagamento: O modelo permite que um cliente salve várias formas de pagamento para uso futuro, agilizando o processo de checkout.

    Rastreamento de Entregas: Cada pedido pode ser associado a uma entrega com status (Em trânsito, Entregue, etc.) e um código de rastreio, oferecendo transparência total ao consumidor.

Projeto 2: Sistema de Gerenciamento de Oficina Mecânica

Descrição do Projeto

O segundo desafio foi criar um banco de dados para gerenciar as operações de uma oficina mecânica. O sistema organiza o fluxo de trabalho completo: desde a recepção de um cliente e seu veículo, passando pela criação de uma Ordem de Serviço (OS), até a alocação de mecânicos, o uso de peças e a finalização do serviço.

Esquema Lógico (Modelo Relacional)

As principais tabelas do modelo da oficina são:

    Persons: Tabela "pai" que armazena dados comuns a todas as pessoas (clientes e mecânicos).

    Clients: Tabela "filha" que especializa uma pessoa como cliente.

    Mechanics: Tabela "filha" que especializa uma pessoa como mecânico, com sua especialidade.

    Vehicles: Armazena os veículos de cada cliente.

    ServiceOrders: A entidade central que representa uma Ordem de Serviço, conectando veículo, serviços, peças e a equipe de mecânicos.

    Parts e Services: Catálogos de peças em estoque e tipos de mão de obra oferecidos.

    Tabelas Associativas (Order_Parts, Order_Services, Mechanic_Team) para gerenciar os relacionamentos N-N da Ordem de Serviço.

Destaques do Modelo

Este projeto explora um padrão de design mais avançado para otimizar a estrutura de dados:

    Padrão de Generalização/Especialização (Herança): A principal característica do modelo é o uso de uma tabela genérica Persons como supertipo (ou classe pai). As tabelas Clients e Mechanics herdam os atributos comuns de Persons, eliminando a redundância de dados e criando um modelo mais coeso e extensível.

    Ordem de Serviço como Hub Central: A tabela ServiceOrders funciona como o coração do sistema, ligando todas as outras entidades para formar um registro completo de cada trabalho realizado, o que facilita a criação de relatórios e análises de faturamento.

🛠️ Tecnologias Utilizadas

    SQL (Sintaxe compatível com MySQL)

👨‍💻 Autor

João Bianchi
