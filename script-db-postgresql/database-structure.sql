/*Tabela:  pessoa*/
CREATE TABLE pessoa (
 idpessoa bigserial NOT NULL,
 flnatureza int2 NOT NULL,
 dsdocumento varchar(20) NOT NULL,
 nmprimeiro varchar(100) NOT NULL,
 nmsegundo varchar(100) NOT NULL,
 dtregistro date NULL,
 CONSTRAINT pessoa_pk PRIMARY KEY (idpessoa)
);

/*Tabela:  endereco*/
CREATE TABLE endereco (
 idendereco bigserial NOT NULL,
 idpessoa int8 not null,
 dscep varchar(15) NOT NULL,
 CONSTRAINT endereco_pk PRIMARY KEY (idendereco),
 CONSTRAINT endereco_fk_pessoa FOREIGN KEY (idpessoa) references pessoa(idpessoa) on delete cascade);

/*Indice: idpessoa na tabela de endereco*/
create index endereco_idpessoa on endereco (idpessoa);

/*Tabela:  endereco integracao*/
CREATE TABLE endereco_integracao (
 idendereco bigint NOT NULL,
 dsuf varchar(50) NULL,
 nmcidade varchar(100) NULL,
 nmbairro varchar(50) NULL,
 nmlogradouro varchar(100) NULL,
 dscomplemento varchar(100) NULL, 
 CONSTRAINT enderecointegracao_pk PRIMARY KEY (idendereco),
 CONSTRAINT enderecointegracao_fk_endereco FOREIGN KEY (idendereco) references endereco(idendereco) on delete cascade);
 
 /*Zerar autoincremento*/
ALTER SEQUENCE pessoa_idpessoa_seq RESTART
ALTER SEQUENCE endereco_idendereco_seq RESTART













