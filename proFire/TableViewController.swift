import UIKit
import Firestore

class TableViewController: UITableViewController {

    var db:Firestore!
    var mensajesArray = [Mensajes]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        cargarDatos()
        obtenerActualizaciones()
    }
    
    func cargarDatos() {
        db.collection("mensajes").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.mensajesArray = querySnapshot!.documents.flatMap({Mensajes(dictionary: $0.data())})
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func obtenerActualizaciones() {
        db.collection("mensajes").whereField("timeStamp", isGreaterThan: Date())
            .addSnapshotListener {
                querySnapshot, error in
                guard let snapshot = querySnapshot else {return}
                snapshot.documentChanges.forEach {
                    diff in
                    if diff.type == .added {
                        self.mensajesArray.append(Mensajes(dictionary: diff.document.data())!)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
    }
    
    @IBAction func composeSweet(_ sender: Any) {
        let composeAlert = UIAlertController(title: "Nuevo mensaje", message: "Introduce tú nombre y tú mensaje", preferredStyle: .alert)
        composeAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "Tú nombre"
        }
        composeAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "Tú mensaje"
        }
        composeAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        composeAlert.addAction(UIAlertAction(title: "Enviar", style: .default, handler: { (action:UIAlertAction) in
            if let nombre = composeAlert.textFields?.first?.text, let contenido = composeAlert.textFields?.last?.text {
                let nuevoMensaje = Mensajes(nombre: nombre, contenido: contenido, timeStamp: Date())
                var ref:DocumentReference? = nil
                ref = self.db.collection("mensajes").addDocument(data: nuevoMensaje.dictionary) {
                    error in
                    if let error = error {
                        print("Error añadiendo el documento: \(error.localizedDescription)")
                    }else{
                        print("Documento añadido con ID: \(ref!.documentID)")
                    }
                }
            }
        }))
        self.present(composeAlert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mensajesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let mensaje = mensajesArray[indexPath.row]
        cell.textLabel?.text = "\(mensaje.nombre): \(mensaje.contenido)"
        cell.detailTextLabel?.text = "\(mensaje.timeStamp)"
        return cell
    }
}
