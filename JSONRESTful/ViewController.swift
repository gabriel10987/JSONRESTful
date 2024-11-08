//
//  ViewController.swift
//  JSONRESTful
//
//  Created by Gabriel Anderson Ccama Apaza on 6/11/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    var users = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func logear(_ sender: Any) {
        let ruta = "http://localhost:3000/usuarios?"
        let usuario = txtUsuario.text!
        let contrasena = txtContrasena.text!
        let url = ruta + "nombre=\(usuario)&clave=\(contrasena)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")
        validarUsuario(ruta: crearURL) {
            if self.users.count <= 0 {
                print("Nombre de usuario y/o contraseña es incorrecto")
            } else {
                print("Logeo Exitoso")
                self.performSegue(withIdentifier: "segueLogeo", sender: nil)
                
                for data in self.users {
                    print("id:\(data.id), nombre:\(data.nombre), email:\(data.email)")
                }
            }
        }
    }
    
    func validarUsuario(ruta:String, completed: @escaping () -> ()) {
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    self.users = try JSONDecoder().decode([Users].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("Error em JSON")
                }
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLogeo" {
            if let navigationController = segue.destination as? UINavigationController {
                if let searchVC = navigationController.viewControllers.first as? SearchViewController {
                    searchVC.usuarioLogeado = users.first
                }
            }
        }
    }

}

