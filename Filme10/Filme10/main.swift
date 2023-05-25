//
//  main.swift  
//  Filme10
//
//  Created by Professor.
//  Copyright © 2021 Senai. All rights reserved.
//  

import SwiftKuery

let utils = CommonUtils.sharedInstance



let filmes = Filmes()
utils.criaTabela(filmes)
print("Tabela Filme Criada")

let elencos = Elencos()
_ = elencos.foreignKey(elencos.idFilme, references: filmes.idFilme)
utils.criaTabela(elencos)
print("Tabela Elenco Criada")

let listaFilmes = [
    Filme(idFilme: 1, titulo: "Batman", diretor: "Matt Reeves", genero: "Ação", origem: "EUA", duracao: 159, ano: 2022),
    //https://www.youtube.com/watch?v=rsQEor4y2hg
    Filme(idFilme: 2, titulo: "Doutor Estranho no Multiverso da Loucura", diretor: "Sam Raimi", genero: "Ficção", origem: "EUA", duracao: 132, ano: 2022),
    //https://www.youtube.com/watch?v=X23XCFgdh2M
    Filme(idFilme: 3, titulo: "Emboscada", diretor: "Edward Drake", genero: "Ação", origem: "EUA", duracao: 90, ano: 2022)
    //https://www.youtube.com/watch?v=xRClgeVAzQI
]
utils.executaQuery(Insert(into: Filmes(), rows: listaFilmes.map{ $0.colunas }))
print("Os Registros dos Filmes foram inseridos")

let listaElenco = [
    Elenco(idElenco: 1,  ator: "Robert Pattison",      idade: 35, nacionalidade: "Reino Unido", filme: listaFilmes[0]),
    Elenco(idElenco: 2,  ator: "Zoë Kravitz",          idade: 33, nacionalidade: "EUA",         filme: listaFilmes[0]),
    Elenco(idElenco: 3,  ator: "Paul Dano",            idade: 37, nacionalidade: "EUA",         filme: listaFilmes[0]),
    Elenco(idElenco: 4,  ator: "Colin Farrell",        idade: 45, nacionalidade: "Irlanda",     filme: listaFilmes[0]),
    Elenco(idElenco: 5,  ator: "Jeffrey Wright",       idade: 56, nacionalidade: "EUA",         filme: listaFilmes[0]),
    Elenco(idElenco: 6,  ator: "Andy Serkis",          idade: 57, nacionalidade: "Reino Unido", filme: listaFilmes[0]),
    Elenco(idElenco: 7,  ator: "Xochitl Gomez",        idade: 16, nacionalidade: "Canada",      filme: listaFilmes[1]),
    Elenco(idElenco: 8,  ator: "Benedict Cumbertatch", idade: 45, nacionalidade: "Reino Unido", filme: listaFilmes[1]),
    Elenco(idElenco: 9,  ator: "Elizabeth Olsen",      idade: 33, nacionalidade: "EUA",         filme: listaFilmes[1]),
    Elenco(idElenco: 10, ator: "Bruce Campbell" ,      idade: 63, nacionalidade: "EUA",         filme: listaFilmes[1]),
    Elenco(idElenco: 11, ator: "Rachel MacAdams",      idade: 43, nacionalidade: "Canada",      filme: listaFilmes[1]),
    Elenco(idElenco: 12, ator: "Benedict Wong",        idade: 50, nacionalidade: "Reino Unido", filme: listaFilmes[1]),
    Elenco(idElenco: 13, ator: "Bruce Willis",         idade: 67, nacionalidade: "Alemanha",    filme: listaFilmes[2]),
    Elenco(idElenco: 14, ator: "Janet Jones",          idade: 61, nacionalidade: "EUA",         filme: listaFilmes[2]),
    Elenco(idElenco: 15, ator: "Anna Hindman",         idade: 29, nacionalidade: "EUA",         filme: listaFilmes[2]),
    Elenco(idElenco: 16, ator: "Timothy V, Murphy",    idade: 61, nacionalidade: "Irlanda",     filme: listaFilmes[2]),
    Elenco(idElenco: 17, ator: "Trevor Gretzky",       idade: 29, nacionalidade: "EUA",         filme: listaFilmes[2]),
    Elenco(idElenco: 18, ator: "Johnny Messner",       idade: 51, nacionalidade: "EUA",         filme: listaFilmes[2])
]
utils.executaQuery(Insert(into: Elencos(), rows: listaElenco.map{ $0.colunas }))
print("Os Registros do Eleco dos Filmes foram inseridos")

utils.executaQuery(Update(elencos, set: [(elencos.ator, "Patrick Stewart"),(elencos.idade, 81)], where: elencos.idElenco == 12))
print("Foi substituido o ator Benedict Wong por Patrick Stewart")

consulta(Select(elencos.ator, filmes.titulo, filmes.diretor, filmes.ano, from: elencos)
    .join(filmes).on(elencos.idFilme == filmes.idFilme)
    .order(by: [.ASC(filmes.titulo), .ASC(elencos.ator)]))

utils.executaQuery(Delete(from: elencos).where(elencos.ator == "Zoë Kravitz"))
print("A atriz Zoë Kravitz foi removida do elenco do filme Batman")

utils.removeTabela(elencos)
utils.removeTabela(filmes)

func consulta(_ select: Select) {
    let utils = CommonUtils.sharedInstance
    utils.executaConsulta(select) { registros in
        guard let registros = registros else {
            return print("Sem registros")
        }
        registros.forEach { linha in
            linha.forEach { item in
                print("\(item ?? "")".fill(), terminator: " ")
            }
            print()
        }
    }
}

public extension String {
    func fill(to: Int = 20) -> String {
        var saida = self
        if self.count < to {
            for _ in 0..<(to - self.count) {
                saida += " "
            }
        }
        return saida
    }
}
