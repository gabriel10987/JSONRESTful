//
//  EditProfileViewController.swift
//  JSONRESTful
//
//  Created by Gabriel Anderson Ccama Apaza on 7/11/24.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var lblUsuario: UILabel!
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtClave: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    var usuarioLogeado: Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let usuario = usuarioLogeado {
            lblUsuario.text = usuario.nombre
            txtNombre.text = usuario.nombre
            txtClave.text = usuario.clave
            txtEmail.text = usuario.email
        }
    }
    
    @IBAction func btnActualizarPerfil(_ sender: Any) {
        let nombre = txtNombre.text
        let clave = txtClave.text
        let email = txtEmail.text
        let datos = ["nombre": nombre, "clave": clave, "email": email] as [String : Any]
        let ruta = "http://localhost:3000/usuarios/\(usuarioLogeado!.id)"
        metodoPUT(ruta: ruta, datos: datos) { success in
            DispatchQueue.main.async {
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo actualizar el perfil", acciones: [UIAlertAction(title: "OK", style: .default)])
                }
            }
        }
    }

    func metodoPUT(ruta:String, datos:[String:Any], completion: @escaping (Bool) -> Void) {
        let url = URL(string: ruta)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: datos, options: .prettyPrinted)
        } catch {
            completion(false)
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, acciones: [UIAlertAction]) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        for accion in acciones {
            alerta.addAction(accion)
        }
        present(alerta, animated: true, completion: nil)
    }
}

