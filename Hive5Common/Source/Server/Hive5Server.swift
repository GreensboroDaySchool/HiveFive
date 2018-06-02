import Foundation

/**
 The wrapper class of Hive5 Server.
 
 This class handles and manages clients, games, as well as overall states of the server.
 Normally there will only be one server instance, but this class is also designed to
 operate in multi-instance enviorments.
 
 - important:
 It is the `ServerTransport`'s responsibility to manage and recover communications.
 This module provides a set of APIs to help transports abstract and serialize data.
 This class is not responsible for the coding of messages and recovery of connections.
 */
public class Hive5Server {
    let transport: ServerTransport
    public var delegate: ServerDelegate?
    
    public var games = [Game]()
    public var clients = [Client]()
    
    public init(with transport: ServerTransport) {
        self.transport = transport
    }
    
    /**
     Get the instance of the client with the token
     */
    public func client(withToken token: Int) -> Client? {
        return clients.reduce(nil){
            return $1.token == token ? $1 : $0
        }
    }
    
    /**
     Create a new Game, and send didJoin message to the client
     
     - note: The Client.color property should be set before using this method
     
     - parameters:
        - host: The instance of Client that is creating the game
     */
    public func createGame(host: Client) -> Game {
        //GameID should be 6 digits, filled with 0 if less than 100,000
        let gameId = Int(arc4random_uniform(999_999))
        let game = Game(host: host, id: gameId)
        clients.append(host)
        games.append(game)
        
        HFLog.info("Client \(host) created a new game \(gameId)")
        
        host.didJoin(game: game, as: host.color!)
        return game
    }
    
    /**
     Handles new clients
     Note: this is a pre-join checking method
     
     - returns:
     An instance of Game corresponding to the room number. nil if the game is not jointable
     */
    public func on(newClient client: Client, in roomNumber: Int) -> Game? {
        //checks if there are any game with the same roomNumber
        if let existingRoom = games.reduce((Game?).none, { $1.id == roomNumber ? $1 : $0 }) {
            //Only able to join when the state is waiting
            if case .waiting = existingRoom.state {
                clients.append(client)
                existingRoom.guest = client
                //Tell the client that it did join the room with this color
                client.didJoin(game: existingRoom, as: existingRoom.host.color!.opposite)
                existingRoom.on(guestJoin: client)
                
                HFLog.info("Client '\(client)' joined the server.")
                
                return existingRoom
            } else { client.kick(for: "Game is already on in this room") }
        } else { client.kick(for: "No room with number \(roomNumber) is found") }
        return nil
    }
    
    public func on(clientLeave client: Client){
        guard let clientIndex = clients.index(where: { $0 == client }) else { return }
        //we have to clear people out when their opponent exit the game
        if let game = client.game {
            game.end(reason: "Opponent left the game")
            game.guest = nil
            games.remove(at: games.index{ $0 == game }!)
        }
        client.game = nil
        clients.remove(at: clientIndex)
        HFLog.info("Client \(client) left the server.")
    }
    
    public func on(unclaimedMessage op: HFTransportModel, replay: (HFTransportModel) throws -> ()) rethrows {
        
    }
    
    public func up(){
        delegate?.server(willStart: self)
        transport.onSetup(server: self)
        games = []
        delegate?.server(didStart: self)
    }
    
    public func down(){
        delegate?.server(willStop: self)
        transport.onShutdown(server: self)
        games.forEach{ $0.end(reason: "Server closing") }
        delegate?.server(didStop: self)
    }
}

public protocol ServerDelegate {
    func server(willStart server: Hive5Server)
    func server(didStart server: Hive5Server)
    func server(willStop server: Hive5Server)
    func server(didStop server: Hive5Server)
}
