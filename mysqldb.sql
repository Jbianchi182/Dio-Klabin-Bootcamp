DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE country (
    idcountry INT AUTO_INCREMENT PRIMARY KEY,
    countryname VARCHAR(50) NOT NULL
);

CREATE TABLE state (
    idstate INT AUTO_INCREMENT PRIMARY KEY,
    statename VARCHAR(50) NOT NULL,
    idcountry INT,
    CONSTRAINT fk_country_state FOREIGN KEY (idcountry) REFERENCES country(idcountry)
);

CREATE TABLE city (
    idcity INT AUTO_INCREMENT PRIMARY KEY,
    cityname VARCHAR(50) NOT NULL,
    idstate INT,
    CONSTRAINT fk_state_city FOREIGN KEY (idstate) REFERENCES state(idstate)
);

CREATE TABLE postcode (
    idpostcode INT AUTO_INCREMENT PRIMARY KEY,
    postcodenumber VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE address (
    idaddress INT AUTO_INCREMENT PRIMARY KEY,
    addresstype ENUM('Residencial', 'Comercial', 'Entrega', 'Cobrança'),
    addressname VARCHAR(50), -- Ex: "Casa", "Trabalho"
    streetname VARCHAR(100) NOT NULL,
    addressnumber VARCHAR(10),
    complement VARCHAR(50),
    idcity INT,
    idpostcode INT,
    CONSTRAINT fk_address_postcode FOREIGN KEY (idpostcode) REFERENCES postcode(idpostcode),
    CONSTRAINT fk_address_city FOREIGN KEY (idcity) REFERENCES city(idcity)
);

CREATE TABLE client (
    idclient INT AUTO_INCREMENT PRIMARY KEY,
    fnameclient VARCHAR(20) NOT NULL,
    mnameclient VARCHAR(20),
    lnameclient VARCHAR(20) NOT NULL,
    cpf CHAR(11),
    cnpj CHAR(14),
    birthdate DATE,
    CONSTRAINT unique_cpf_client UNIQUE (cpf),
    CONSTRAINT unique_cnpj_client UNIQUE (cnpj),
    CONSTRAINT chk_client_pf_or_pj CHECK ((cpf IS NOT NULL AND cnpj IS NULL) OR (cpf IS NULL AND cnpj IS NOT NULL))
);

CREATE TABLE product (
    idproduct INT AUTO_INCREMENT PRIMARY KEY,
    pname VARCHAR(50) NOT NULL,
    is_kid_product BOOL DEFAULT FALSE,
    category ENUM('Eletrônicos', 'Brinquedos', 'Decoração', 'Móveis', 'Vestuário') NOT NULL,
    rating FLOAT DEFAULT 0,
    dimensions VARCHAR(25)
);

CREATE TABLE supplier (
    idsupplier INT AUTO_INCREMENT PRIMARY KEY,
    socialname VARCHAR(100) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    email VARCHAR(50),
    phone CHAR(11),
    CONSTRAINT unique_supplier_cnpj UNIQUE (cnpj)
);

CREATE TABLE seller (
    idseller INT AUTO_INCREMENT PRIMARY KEY,
    socialname VARCHAR(100) NOT NULL,
    cnpj CHAR(14),
    cpf CHAR(11),
    email VARCHAR(50),
    phone CHAR(11),
    CONSTRAINT unique_seller_cnpj UNIQUE (cnpj),
    CONSTRAINT unique_seller_cpf UNIQUE (cpf),
    CONSTRAINT chk_seller_type CHECK ((cpf IS NOT NULL AND cnpj IS NULL) OR (cpf IS NULL AND cnpj IS NOT NULL))
);

CREATE TABLE productstorage (
    idprodstorage INT AUTO_INCREMENT PRIMARY KEY,
    idaddress INT,
    quantity INT DEFAULT 0,
    CONSTRAINT fk_storage_address FOREIGN KEY (idaddress) REFERENCES address(idaddress)
);

CREATE TABLE orders (
    idorder INT AUTO_INCREMENT PRIMARY KEY,
    idorderclient INT,
    orderstatus ENUM('Cancelado', 'Confirmado', 'Processando', 'Enviado', 'Entregue') DEFAULT 'Processando' NOT NULL,
    orderdescription VARCHAR(255),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_client FOREIGN KEY (idorderclient) REFERENCES client(idclient)
);

CREATE TABLE shipping (
    idshipping INT AUTO_INCREMENT PRIMARY KEY,
    idorder INT, 
    tracking_code VARCHAR(50),
    shipping_fee FLOAT DEFAULT 0,
    shipping_status ENUM('Preparando o pedido', 'Coletado', 'Em trânsito', 'Saiu para entrega', 'Entregue'),
    CONSTRAINT fk_shipping_order FOREIGN KEY (idorder) REFERENCES orders(idorder)
);

CREATE TABLE client_payment_methods (
    idmethod INT AUTO_INCREMENT PRIMARY KEY,
    idclient INT,
    method_type ENUM('Cartão de Crédito', 'PIX', 'Boleto'),
    provider VARCHAR(50),
    card_number_final CHAR(4),
    details VARCHAR(255),
    is_default BOOL DEFAULT FALSE,
    CONSTRAINT fk_cpm_client FOREIGN KEY (idclient) REFERENCES client(idclient)
);

CREATE TABLE payments (
    idpayment INT AUTO_INCREMENT PRIMARY KEY,
    idorder INT,
    id_client_method INT,
    paymenttype ENUM('Boleto', 'Cartão de Crédito', 'Cartão de Débito', 'PIX') NOT NULL,
    payment_status ENUM('Pendente', 'Aprovado', 'Recusado') DEFAULT 'Pendente',
    CONSTRAINT fk_payment_order FOREIGN KEY (idorder) REFERENCES orders(idorder),
    CONSTRAINT fk_payment_method FOREIGN KEY (id_client_method) REFERENCES client_payment_methods(idmethod)
);

CREATE TABLE productseller (
    idseller INT,
    idproduct INT,
    prodquantity INT DEFAULT 1,
    PRIMARY KEY (idseller, idproduct),
    CONSTRAINT fk_prod_seller FOREIGN KEY (idseller) REFERENCES seller(idseller),
    CONSTRAINT fk_prod_prod FOREIGN KEY (idproduct) REFERENCES product(idproduct)
);

CREATE TABLE productorder (
    idPOproduct INT,
    idPOorder INT,
    poquantity INT DEFAULT 1,
    postatus ENUM('Disponível', 'Fora de estoque') DEFAULT 'Disponível',
    PRIMARY KEY (idPOproduct, idPOorder),
    CONSTRAINT fk_productorder_product FOREIGN KEY (idPOproduct) REFERENCES product(idproduct),
    CONSTRAINT fk_productorder_order FOREIGN KEY (idPOorder) REFERENCES orders(idorder)
);

CREATE TABLE addressclient (
    idclient_fk INT,
    idaddress_fk INT,
    PRIMARY KEY (idclient_fk, idaddress_fk),
    CONSTRAINT fk_addressclient_client FOREIGN KEY (idclient_fk) REFERENCES client(idclient),
    CONSTRAINT fk_addressclient_address FOREIGN KEY (idaddress_fk) REFERENCES address(idaddress)
);


-- Queries:
SHOW TABLES;

-- Quantos pedidos foram feitos por cada cliente?
SELECT
    c.idclient,
    CONCAT(c.fnameclient, ' ', c.lnameclient) AS client_fullname,
    COUNT(o.idorder) AS total_orders
FROM
    client c
INNER JOIN
    orders o ON c.idclient = o.idorderclient
GROUP BY
    c.idclient, client_fullname
HAVING
    total_orders > 1
ORDER BY
    total_orders DESC; 
    
-- Relação de produtos fornecedores e estoques  
SELECT
    p.pname AS product_name,
    p.category,
    s.socialname AS seller_name,
    ps.quantity AS stock_quantity,
    a.addressname AS storage_location
FROM
    product p
LEFT JOIN
    productseller psel ON p.idproduct = psel.idproduct
LEFT JOIN
    seller s ON psel.idseller = s.idseller
LEFT JOIN
    productstorage ps ON p.idproduct = ps.idprodstorage
LEFT JOIN
    address a ON ps.idaddress = a.idaddress
ORDER BY
    p.pname;

-- Algum vendedor também é fornecedor?
SELECT
    s.socialname AS seller_social_name,
    s.email AS seller_email,
    s.phone AS seller_phone,
    sup.socialname AS supplier_social_name,
    s.cnpj
FROM
    seller s
INNER JOIN
    supplier sup ON s.cnpj = sup.cnpj
WHERE
    s.cnpj IS NOT NULL;
    
-- Quais pedidos com status "Entregue" foram pagos com 'PIX' e tiveram um frete superior a R$ 25,00?
SELECT
    o.idorder,
    o.order_date,
    c.fnameclient AS client_name,
    p.paymenttype,
    s.shipping_fee
FROM
    orders o
INNER JOIN
    payments p ON o.idorder = p.idorder
INNER JOIN
    shipping s ON o.idorder = s.idorder
INNER JOIN
    client c ON o.idorderclient = c.idclient
WHERE
    o.orderstatus = 'Entregue'
    AND p.paymenttype = 'PIX'
    AND s.shipping_fee > 25.00;