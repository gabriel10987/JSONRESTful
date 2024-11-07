//
//  SearchViewController.swift
//  JSONRESTful
//
//  Created by Gabriel Anderson Ccama Apaza on 6/11/24.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var txtBuscar: UITextField!
    @IBOutlet weak var tablaPeliculas: UITableView!
    
    var peliculas = [Peliculas]()
    var usuarioLogeado: Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaPeliculas.delegate = self
        tablaPeliculas.dataSource = self
        
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta) {
            self.tablaPeliculas.reloadData()
        }
    }
    
    @IBAction func btnBuscar(_ sender: Any) {
        let ruta = "http://localhost:3000/peliculas?"
        let nombre = txtBuscar.text!
        let url = ruta + "nombre_like=\(nombre)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")
        
        if nombre.isEmpty{
            let ruta = "http://localhost:3000/peliculas/"
            self.cargarPeliculas(ruta: ruta) {
                self.tablaPeliculas.reloadData()
            }
        } else {
            cargarPeliculas(ruta: crearURL) {
                if self.peliculas.count <= 0 {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se encontraron coincidencias para: \(nombre)", acciones: [UIAlertAction(title: "cancel", style: .default)])
                } else {
                    self.tablaPeliculas.reloadData()
                }
            }
        }
    }
    
    @IBAction func btnSalir(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peliculas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(peliculas[indexPath.row].nombre)"
        cell.detailTextLabel?.text = "Genero:\(peliculas[indexPath.row].genero) Duración:\(peliculas[indexPath.row].duracion)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pelicula = peliculas[indexPath.row]
        performSegue(withIdentifier: "segueEditar", sender: pelicula)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditar" {
            let siguienteVC = segue.destination as! AddViewController
            siguienteVC.pelicula = sender as? Peliculas
        } else if segue.identifier == "segueEditarPerfil" {
            let editProfileVC = segue.destination as! EditProfileViewController
            editProfileVC.usuarioLogeado = usuarioLogeado
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta) {
            self.tablaPeliculas.reloadData()
        }
    }

    func cargarPeliculas(ruta:String, completed: @escaping () -> ()) {
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do{
                    self.peliculas = try JSONDecoder().decode([Peliculas].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch{
                    print("Error en JSON")
                }
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pelicula = peliculas[indexPath.row]
            
            let accionSi = UIAlertAction(title: "Sí", style: .destructive) { _ in
                self.metodoDELETE(ruta: "http://localhost:3000/peliculas/\(pelicula.id)") { success in
                    DispatchQueue.main.async {
                        if success {
                            self.peliculas.remove(at: indexPath.row)
                            self.tablaPeliculas.deleteRows(at: [indexPath], with: .automatic)
                        } else {
                            self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo eliminar la película", acciones: [UIAlertAction(title: "OK", style: .default)])
                        }
                    }
                }
            }
            
            let accionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            mostrarAlerta(titulo: "Eliminar Película", mensaje: "¿Está seguro que desea eliminar la película \(pelicula.nombre)?", acciones: [accionSi, accionNo])
        }
    }
    
    func metodoDELETE(ruta: String, completion: @escaping (Bool) -> Void) {
        let url : URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "DELETE"

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error al eliminar la película: \(error)")
                completion(false)
                return
            }
            completion(true)
        })
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

