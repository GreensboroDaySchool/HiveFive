import Foundation

class Hive5Server {
    let transport: ServerTransport
    var delegate: ServerDelegate?
    
    var games = [Game]()
    var clients = [Client]()
    
    init(with transport: ServerTransport) {
        self.transport = transport
    }
    
    /**
     Create a new Game, and send didJoin message to the client
     
     - note: The Client.color property should be set before using this method
     
     - parameters:
        - host: The instance of Client that is creating the game
     */
    func createGame(host: Client) -> Game {
        //GameID should be 6 digits, filled with 0 if less than 100,000
        let gameId = Int(arc4random_uniform(999_999))
        let game = Game(host: host, id: gameId)
        clients.append(host)
        games.append(game)
        host.didJoin(game: game, as: host.color!)
        return game
    }
    
    /**
     Handles new clients
     Note: this is a pre-join checking method
     
     - returns:
     An instance of Game corresponding to the room number. nil if the game is not jointable
     */
    func on(newClient client: Client, in roomNumber: Int) -> Game? {
        //checks if there are any game with the same roomNumber
        if let existingRoom = games.reduce((Game?).none, { $1.id == roomNumber ? $1 : $0 }) {
            //Only able to join when the state is waiting
            if case .waiting = existingRoom.state {
                clients.append(client)
                existingRoom.guest = client
                //Tell the client that it did join the room with this color
                client.didJoin(game: existingRoom, as: existingRoom.host.color!.opposite)
                existingRoom.on(guestJoin: client)
                return existingRoom
            } else { client.kick(for: "Game is already on in this room") }
        } else { client.kick(for: "No room with number \(roomNumber) is found") }
        return nil
    }
    
    func on(clientLeave client: Client){
        guard let clientIndex = clients.index(where: { $0 == client }) else { return }
        //we have to clear people out when their opponent exit the game
        if let game = client.game {
            game.end(reason: "Opponent left the game")
            game.guest = nil
            games.remove(at: games.index{ $0 == game }!)
        }
        client.game = nil
        clients.remove(at: clientIndex)
    }
    
    func on(unclaimedMessage op: HFTransportModel, replay: (HFTransportModel) throws -> ()) rethrows {
        
    }
    
    func up(){
        delegate?.server(willStart: self)
        transport.onSetup(server: self)
        games = []
        delegate?.server(didStart: self)
    }
    
    func down(){
        delegate?.server(willStop: self)
        transport.onShutdown(server: self)
        games.forEach{ $0.end(reason: "Server closing") }
        delegate?.server(didStop: self)
    }
}

protocol ServerDelegate {
    func server(willStart server: Hive5Server)
    func server(didStart server: Hive5Server)
    func server(willStop server: Hive5Server)
    func server(didStop server: Hive5Server)
}
