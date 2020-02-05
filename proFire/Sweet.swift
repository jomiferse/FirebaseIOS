import Foundation
import Firestore

protocol DocumentSerializable  {
    init?(dictionary:[String:Any])
}


struct Sweet {
    var nombre:String
    var contenido:String
    var timeStamp:Date
    
    var dictionary:[String:Any] {
        return [
            "nombre":nombre,
            "contenido" : contenido,
            "timeStamp" : timeStamp
        ]
    }
    
}

extension Sweet : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let nombre = dictionary["nombre"] as? String,
            let contenido = dictionary["contenido"] as? String,
            let timeStamp = dictionary ["timeStamp"] as? Date else {return nil}
        
        self.init(nombre: nombre, contenido: contenido, timeStamp: timeStamp)
    }
}
