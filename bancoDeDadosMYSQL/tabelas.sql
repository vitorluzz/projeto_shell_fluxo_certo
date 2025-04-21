CREATE DATABASE IF NOT EXISTS fluxocerto;
USE fluxocerto;

create table if not exists empresa ( 
	id int primary key auto_increment,
	nomeEmpresa varchar (45),
	cnpjEmpresa char(14),
	Responsavel varchar (45),
	nomeFantasia varchar(45),
	razaoSocial varchar(45),
	email varchar(45)
);

insert into empresa VALUES(NULL, "nome", "000.000.000-00", "eu", "nome", "nome", "nome@gmail.com");

CREATE TABLE if not exists users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  cargo varchar(9),
  cpf char(13),
  linha varchar (10),
  dataNasc date,
  dataEntrada datetime default current_timestamp,
  senha varchar(100) NOT NULL,
  fk_responsavel int,
  fk_empresa int,
  constraint ct_responsavel foreign key (fk_responsavel) references users(id),
  constraint ct_empresa foreign key (fk_empresa) references empresa(id),
  constraint chkCargo Check (cargo in ("analista","gestor")),
  constraint chkLinha check (linha in ("azul", "verde","vermelha"))
);

CREATE TABLE IF NOT EXISTS demandaPorEstacao(
	id INT PRIMARY KEY auto_increment,
    fk_empresa INT,
    ano VARCHAR(10),
    mes VARCHAR(30),
    linha VARCHAR(20),
    fluxo INT,
    estacao VARCHAR(40),
    constraint fk_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa(id),
    constraint check (linha in ("azul", "verde","vermelha"))
);

CREATE TABLE IF NOT EXISTS entradaPorLinha(
	id INT PRIMARY KEY auto_increment,
    fk_empresa INT,
    dataColeta DATE,
    linha VARCHAR(20),
    fluxoTotal INT,
    mediaDia INT,
    maiorMaximaDiaria INT,
    constraint fk_linhaEmpresa FOREIGN KEY (fk_empresa) REFERENCES empresa(id),
    constraint check (linha in ("azul", "verde","vermelha"))
);

create table if not exists log (
	id int primary key auto_increment,
    fk_empresa INT,
    statusResposta VARCHAR(5),
	dataColeta datetime,
	descricao varchar(400),
    origem varchar(50),
    constraint fk_logEmpresa FOREIGN KEY (fk_empresa) REFERENCES empresa(id)
);


CREATE USER 'admin'@'%' IDENTIFIED BY 'urubu100';

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'urubu100';

GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;