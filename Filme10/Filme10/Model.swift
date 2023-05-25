//
//  Model.swift  
//  Filme10
//
//  Created by Professor.
//  Copyright © 2021 Senai. All rights reserved.
//  

struct Filme {
    var idFilme: Int
    var titulo: String
    var diretor: String
    var genero: String
    var origem: String
    var duracao: Int
    var ano: Int
    var capa: String = ""
    var colunas: [Any] { [ idFilme, titulo, diretor, genero, origem, duracao, ano, capa ] }
}

struct Elenco {
    var idElenco: Int
    var ator: String
    var idade: Int
    var nacionalidade: String
    var filme: Filme
    var colunas: [Any] { [ idElenco, ator, idade, nacionalidade, filme.idFilme ] }
}
