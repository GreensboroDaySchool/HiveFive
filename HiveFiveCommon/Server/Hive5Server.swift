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
                existingRoom.guest = client
                existingRoom.on(guestJoin: client)
                //Tell the client that it did join the room with this color
                client.didJoin(game: existingRoom, as: existingRoom.host.color!.opposite)
                return existingRoom
            } else { client.kick(for: "Game is already on in this room") }
        } else { client.kick(for: "No room with number \(roomNumber) is found") }
        return nil
    }
    
    func on(clientLeave client: Client){
        //we have to clear people out when their opponent exit the game
        if let game = client.game {
            client.game = nil
            game.end(for: "Opponent left the game")
        }
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
        games.forEach{ $0.end(for: "Server closing") }
        delegate?.server(didStop: self)
    }
}

protocol ServerDelegate {
    func server(willStart server: Hive5Server)
    func server(didStart server: Hive5Server)
    func server(willStop server: Hive5Server)
    func server(didStop server: Hive5Server)
}
