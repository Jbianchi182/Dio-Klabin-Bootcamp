DROP DATABASE IF EXISTS oficina;
CREATE DATABASE IF NOT EXISTS oficina;
USE oficina;

-- CRIAÇÃO DAS TABELAS

-- Tabela Pessoas
CREATE TABLE Persons (
    idPerson INT AUTO_INCREMENT PRIMARY KEY,
    fullName VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    address VARCHAR(255),
    contactPhone VARCHAR(15)
);

-- Tabela Clientes
CREATE TABLE Clients (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    idPerson_fk INT NOT NULL UNIQUE,
    registrationDate DATE,
    CONSTRAINT fk_client_person FOREIGN KEY (idPerson_fk) REFERENCES Persons(idPerson)
);

-- Tabela Mecânicos
CREATE TABLE Mechanics (
    idMechanic INT AUTO_INCREMENT PRIMARY KEY,
    idPerson_fk INT NOT NULL UNIQUE,
    specialty VARCHAR(50) NOT NULL,
    CONSTRAINT fk_mechanic_person FOREIGN KEY (idPerson_fk) REFERENCES Persons(idPerson)
);

-- Tabela de Veículos
CREATE TABLE Vehicles (
    idVehicle INT AUTO_INCREMENT PRIMARY KEY,
    idClient_fk INT,
    model VARCHAR(50) NOT NULL,
    make VARCHAR(50) NOT NULL,
    vehicleYear INT,
    licensePlate CHAR(7) NOT NULL UNIQUE,
    CONSTRAINT fk_vehicle_client FOREIGN KEY (idClient_fk) REFERENCES Clients(idClient)
);

-- Tabela de Ordens de Serviço
CREATE TABLE ServiceOrders (
    idServiceOrder INT AUTO_INCREMENT PRIMARY KEY,
    idVehicle_fk INT,
    issueDate DATE NOT NULL,
    completionDate DATE,
    statusOS ENUM('Aguardando Aprovação', 'Em Andamento', 'Concluído', 'Cancelado') NOT NULL DEFAULT 'Aguardando Aprovação',
    authorizationStatus BOOL DEFAULT FALSE,
    CONSTRAINT fk_os_vehicle FOREIGN KEY (idVehicle_fk) REFERENCES Vehicles(idVehicle)
);

-- Tabela de Peças
CREATE TABLE Parts (
    idPart INT AUTO_INCREMENT PRIMARY KEY,
    partName VARCHAR(100) NOT NULL,
    stockQuantity INT DEFAULT 0,
    unitPrice DECIMAL(10, 2) NOT NULL
);

-- Tabela de Serviços (Mão de Obra)
CREATE TABLE Services (
    idService INT AUTO_INCREMENT PRIMARY KEY,
    serviceName VARCHAR(100) NOT NULL,
    laborCost DECIMAL(10, 2) NOT NULL
);

-- Tabela Associativa: Peças por OS
CREATE TABLE Order_Parts (
    idServiceOrder_fk INT,
    idPart_fk INT,
    quantityUsed INT NOT NULL,
    PRIMARY KEY (idServiceOrder_fk, idPart_fk),
    CONSTRAINT fk_op_order FOREIGN KEY (idServiceOrder_fk) REFERENCES ServiceOrders(idServiceOrder),
    CONSTRAINT fk_op_part FOREIGN KEY (idPart_fk) REFERENCES Parts(idPart)
);

-- Tabela Associativa: Serviços por OS
CREATE TABLE Order_Services (
    idServiceOrder_fk INT,
    idService_fk INT,
    PRIMARY KEY (idServiceOrder_fk, idService_fk),
    CONSTRAINT fk_oserv_order FOREIGN KEY (idServiceOrder_fk) REFERENCES ServiceOrders(idServiceOrder),
    CONSTRAINT fk_oserv_service FOREIGN KEY (idService_fk) REFERENCES Services(idService)
);

-- Tabela Associativa: Equipe de Mecânicos por OS
CREATE TABLE Mechanic_Team (
    idServiceOrder_fk INT,
    idMechanic_fk INT,
    PRIMARY KEY (idServiceOrder_fk, idMechanic_fk),
    CONSTRAINT fk_mt_order FOREIGN KEY (idServiceOrder_fk) REFERENCES ServiceOrders(idServiceOrder),
    CONSTRAINT fk_mt_mechanic FOREIGN KEY (idMechanic_fk) REFERENCES Mechanics(idMechanic)
);


-- INSERÇÃO DE DADOS 

-- Inserção na tabela Pessoas
INSERT INTO Persons (fullName, cpf, address, contactPhone) VALUES
('João Silva', '12345678901', 'Rua A, 123', '11987654321'),
('Maria Oliveira', '23456789012', 'Avenida B, 456', '11987654322'),
('Carlos Pereira', '34567890123', 'Praça C, 789', '11987654323'),
('Roberto Souza', '45678901234', 'Rua D, 101', '11987654324'),
('Fernanda Costa', '56789012345', 'Avenida E, 202', '11987654325'),
('Lucas Martins', '67890123456', 'Rua F, 303', '11987654326');

-- Especialização em Clientes
INSERT INTO Clients (idPerson_fk, registrationDate) VALUES
(1, NOW()),
(2, NOW()),
(3, NOW()),
(4, NOW());

-- Especialização em Mecânicos
INSERT INTO Mechanics (idPerson_fk, specialty) VALUES
(4, 'Motor'),
(5, 'Eletricista'),
(6, 'Suspensão e Freios');

-- Inserção de Veículos
INSERT INTO Vehicles (idClient_fk, model, make, vehicleYear, licensePlate) VALUES
(1, 'Gol', 'Volkswagen', 2020, 'ABC1D23'),
(1, 'Onix', 'Chevrolet', 2021, 'EFG4H56'),
(2, 'Mobi', 'Fiat', 2019, 'IJK7L89'),
(3, 'HB20', 'Hyundai', 2022, 'MNO1P23');

-- Inserção de Peças
INSERT INTO Parts (partName, stockQuantity, unitPrice) VALUES
('Filtro de Óleo', 50, 45.50), ('Pastilha de Freio', 30, 120.00),
('Vela de Ignição', 100, 25.00), ('Bateria 60Ah', 15, 350.00);

-- Inserção de Serviços
INSERT INTO Services (serviceName, laborCost) VALUES
('Troca de Óleo e Filtro', 100.00), ('Revisão do Sistema de Freios', 150.00),
('Diagnóstico Elétrico', 120.00), ('Alinhamento e Balanceamento', 90.00);

-- Inserção de Ordens de Serviço
INSERT INTO ServiceOrders (idVehicle_fk, issueDate, completionDate, statusOS, authorizationStatus) VALUES
(1, '2025-10-15', '2025-10-16', 'Concluído', TRUE),
(3, '2025-10-18', NULL, 'Em Andamento', TRUE),
(4, '2025-10-20', NULL, 'Aguardando Aprovação', FALSE),
(2, '2025-10-21', '2025-10-21', 'Concluído', TRUE);

-- Detalhes das Ordens de Serviço
INSERT INTO Order_Services (idServiceOrder_fk, idService_fk) VALUES (1, 1), (2, 2), (2, 4), (4, 3);
INSERT INTO Order_Parts (idServiceOrder_fk, idPart_fk, quantityUsed) VALUES (1, 1, 1), (2, 2, 4), (4, 4, 1);
INSERT INTO Mechanic_Team (idServiceOrder_fk, idMechanic_fk) VALUES (1, 1), (2, 3), (4, 2), (4, 1);

-- CONSULTAS 

-- Query 1: Relatório de uma Ordem de Serviço específica.
SELECT
    os.idServiceOrder,
    p.fullName AS clientName,
    v.model AS vehicleModel,
    v.licensePlate,
    os.statusOS
FROM
    ServiceOrders os
JOIN Vehicles v ON os.idVehicle_fk = v.idVehicle
JOIN Clients c ON v.idClient_fk = c.idClient
JOIN Persons p ON c.idPerson_fk = p.idPerson
WHERE
    os.idServiceOrder = 1;

-- Query 2: Mecânicos mais ativos e a quantidade de ordens concluídas.
SELECT
    p.fullName AS mechanicName,
    m.specialty,
    COUNT(DISTINCT mt.idServiceOrder_fk) AS completed_orders_count
FROM
    Mechanics m
JOIN Persons p ON m.idPerson_fk = p.idPerson
JOIN Mechanic_Team mt ON m.idMechanic = mt.idMechanic_fk
JOIN ServiceOrders os ON mt.idServiceOrder_fk = os.idServiceOrder
WHERE
    os.statusOS = 'Concluído'
GROUP BY
    m.idMechanic, p.fullName, m.specialty
HAVING
    completed_orders_count >= 1
ORDER BY
    completed_orders_count DESC;