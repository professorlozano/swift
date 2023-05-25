//
//  Utils.swift  
//  Filme10
//
//  Created by Professor.
//  Copyright © 2021 Senai. All rights reserved.
//  

import Foundation
import SwiftKuery
import SwiftKueryMySQL

/// Esta classe tem as implementações para o acesso ao Banco de Dados
class CommonUtils {
    private var pool: ConnectionPool?
    private var connection: Connection?
    static let sharedInstance = CommonUtils()
    private init() {}
    
    /// Este método é de uso interno para a criação do pool de conexões ao bando de dados
    private func getConnectionPool(characterSet: String? = nil) -> ConnectionPool {
        if let pool = pool {
            return pool
        }
        do {
            let connectionFile = #file.replacingOccurrences(
                    of: "Utils.swift", with: "connection.json")
            let data = Data(referencing: try NSData(
                    contentsOfFile: connectionFile))
            let json = try JSONSerialization.jsonObject(with: data)
            
            if let dictionary = json as? [String: String] {
                let host = dictionary["host"]
                let username = dictionary["username"]
                let password = dictionary["password"]
                let database = dictionary["database"]
                var port: Int? = nil
                if let portString = dictionary["port"] {
                    port = Int(portString)
                }

                let randomBinary = arc4random_uniform(2)
                
                let poolOptions = ConnectionPoolOptions(
                        initialCapacity: 1, maxCapacity: 1)
                
                if characterSet != nil || randomBinary == 0 {
                    pool = MySQLConnection.createPool(host: host, user: username,
                            password: password, database: database, port: port,
                            characterSet: characterSet, connectionTimeout: 10000,
                            poolOptions: poolOptions)
                } else {
                    var urlString = "mysql://"
                    if let username = username, let password = password {
                        urlString += "\(username):\(password)@"
                    }
                    urlString += host ?? "localhost"
                    if let port = port {
                        urlString += ":\(port)"
                    }
                    if let database = database {
                        urlString += "/\(database)"
                    }

                    if let url = URL(string: urlString) {
                        pool = MySQLConnection.createPool(url: url, poolOptions: poolOptions)
                    } else {
                        pool = nil
                        print("URL com formato inválido: \(urlString)")
                    }
                }
            } else {
                pool = nil
                print("""
                      Formato invalido no
                      conteúdo do arquivo connection.json: \(json)
                      """)
            }
        } catch {
            print("Erro lançado")
            pool = nil
            print(error.localizedDescription)
        }
        return pool!
    }

    /// Este método obtém a conexão ao banco de dados do pool de conexões
    func getConnection() -> Connection? {
        if let connection = connection {
            return connection
        }
        
        self.connection = nil
        getConnectionPool().getConnection { connection, error in
            guard let connection = connection else {
                guard let error = error else {
                    return print("Falha ao conectar no Banco de Dados: \(error?.localizedDescription ?? "Erro desconhecido")")
                }
                return print("Falha ao conectar no Banco de Dados: \(error.localizedDescription)")
            }
            self.connection = connection
            return
        }
        return connection
    }

    /// Este método executa uma consulta SQL (SELECT)
    /// - Parameter query: Uma instância de Select
    /// - Parameter aoFinal: O Bloco de instruções que receberá o retorno do Select
    func criaTabela(_ tabela: Table) {
        let thread = DispatchGroup()
        thread.enter()
        guard let con = getConnection() else {
            return print("Sem Conexão")
        }
        tabela.create(connection: con) { result in
            if !result.success {
                print("Falha ao criar a tabela \(tabela.nameInQuery)")
            }
            thread.leave()
        }
        thread.wait()
    }
    
    /// Este método executa instruções SQL (INSERT, UPDATE, DELETE)
    /// - Parameter query: Uma instância de Query (Insert, Update ou Delete)
    func executaQuery(_ query: Query) {
        let thread = DispatchGroup()
        thread.enter()
        if let connection = getConnection() {
            connection.execute(query: query) { result in
                var nomeQuery = String(describing: type(of:query))
                if nomeQuery == "Raw" {
                    nomeQuery =  String(describing: query.self).split(separator: "\"")[1].split(separator: " ")[0].capitalized
                }
                
                if let erro = result.asError {
                    print("\(nomeQuery), Falha na execução: \(erro)")
                }
                thread.leave()
            }
        } else {
            print("Sem Conexão")
            thread.leave()
        }
        thread.wait()
    }

    /// Este método executa a instrução de criação de tabelas (CREATE TABLE)
    /// - Parameter tabela: Uma instância de Table
    func executaConsulta(_ query: Select, _ aoFinal: @escaping ([[Any?]]?)->()) {
        let thread = DispatchGroup()
        thread.enter()
        var registros = [[Any?]]()
        if let connection = getConnection() {
            connection.execute(query: query) { result in
                guard let dados = result.asResultSet else {
                    print("Não houve resultado para esta consulta")
                    return thread.leave()
                }
                
                dados.forEach { linha, error in
                    if let _linha = linha {
                        var colunas: [Any?] = [Any?]()
                        _linha.forEach({ atributo in
                            colunas.append(atributo)
                        })
                        registros.append(colunas)
                    } else {
                        thread.leave()
                    }
                }
            }
        } else {
            print("Sem conexão")
            thread.leave()
        }
        thread.wait()
        aoFinal(registros)
    }

    /// Este método é utilizado para a exclusão de tabelas (DROP TABLE)
    /// - Parameter tabela: Uma instância de Table
    func removeTabela(_ tabela: Table) {
        executaQuery(tabela.drop())
    }
}
