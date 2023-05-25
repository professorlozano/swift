create database filmes10;

use filmes10;

CREATE TABLE IF NOT EXISTS filme 
(idfilme INT NOT NULL AUTO_INCREMENT,
titulo VARCHAR(100) NOT NULL,
diretor VARCHAR(100) NOT NULL,
genero VARCHAR(45) NOT NULL,
origem VARCHAR(100) NOT NULL,
duracao INT NOT NULL,
ano INT NOT NULL,
capa LONGTEXT NULL,
PRIMARY KEY (idfilme));

CREATE TABLE IF NOT EXISTS elenco 
(idelenco INT NOT NULL AUTO_INCREMENT,
ator VARCHAR(100) NOT NULL,
idade INT NOT NULL,
nacionalidade VARCHAR(45) NOT NULL,
filme_idfilme INT NOT NULL,
PRIMARY KEY (idelenco),
CONSTRAINT fk_elenco_filme FOREIGN KEY (filme_idfilme) REFERENCES filme (idfilme)ON DELETE NO ACTION ON UPDATE NO ACTION);