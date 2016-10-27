//
//  BuscarVC.swift
//  TareaNube3
//
//  Created by Oscar Zarco on 23/09/16.
//  Copyright © 2016 oscarzarco. All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration

class BuscarVC: UIViewController, UITextFieldDelegate {
    @IBOutlet var portada: UIImageView!
    @IBOutlet var buscar: UITextField!
    @IBOutlet var titulo: UITextView!
    @IBOutlet var autores: UITextView!
    
    var managedObjectContext : NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buscar.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        buscarLibro()
        textField.resignFirstResponder()
        return true
    }
    

    
    func buscarLibro() {
        print("Inicio busqueda")
        //primero valido si hay conexion a INternet
        if hayInternet() {
        
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + buscar.text! //978-84-376-0494-7"
        let url = URL(string: urls)
        var datos : Data? = nil
        
        do {
            datos = try Data(contentsOf: url!,options: [])
            do {
                let json = try JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableLeaves)
                let dico1 = json  as! NSDictionary
                if dico1.count > 0 {
                    let dico2 = dico1["ISBN:"+buscar.text!] as! NSDictionary
                    if (dico2.value(forKey: "title") != nil){
                    
                        let titulo = dico2["title"] as! NSString as String
                        print(titulo)
                        self.titulo.text = titulo
                    }
                    if (dico2.value(forKey: "authors") != nil) {
                        
                        let dico3 = dico2["authors"] as! [[String : String]]
                        print(dico3)
                        var autores : String = ""
                        for i in 1...dico3.count {
                            autores = autores + " " + (dico3[i-1]["name"] as Optional)! as String
                        }
                        self.autores.text = autores
                    }
                    
                    
                    
                    
                    if (dico2.value(forKey: "cover") != nil) {
                        let dico4 = dico2["cover"] as! NSDictionary
                        let urlsPortada = dico4["small"] as! NSString as String
                        let urlPortada = URL(string: urlsPortada)
                        do {
                            let DatoPortada = try Data(contentsOf: urlPortada!, options: [])
                            self.portada.image = UIImage(data: DatoPortada)
                        } catch _{
                            self.portada.image = nil
                        }
                    }else{
                        let urlsPortada = "http://covers.openlibrary.org/b/isbn/" + buscar.text! + "-M.jpg"
                        let urlPortada = NSURL(string: urlsPortada)
                        do {
                            let DatoPortada = try NSData(contentsOf: urlPortada! as URL, options: [])
                            self.portada.image = UIImage(data: DatoPortada as Data)
                        } catch _{
                            
                        }

                    }
                    
                    grabar()
                }
                else{
                    self.titulo.text = "No encontrado"
                    self.autores.text = "No encontrado"
                    self.portada.image = nil

                    
                }
            }
            catch _ {
                print("Error 2")
            }
            
            
            
            
            
        } catch {
            print("Error 1")
        }
            
        }
        else{
            print("Error de Internet")
            let mensaje = UIAlertController.init(title:"Error de Internet", message: "Hay un error de conexion a Internet", preferredStyle: UIAlertControllerStyle.alert )
            let accionOK = UIAlertAction(title: "OK",style: .default){ accion in
                print("OK")
            }
            
            mensaje.addAction(accionOK)
            self.present(mensaje, animated: true, completion: nil)
        }
    
            
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func grabar() {
        if self.titulo.text == "No encontrado" {
            print("no grabo")
            let mensaje = UIAlertController.init(title:"Error", message: "No hay resultado para guardar", preferredStyle: UIAlertControllerStyle.alert )
            let accionOK = UIAlertAction(title: "OK",style: .default){ accion in
                print("OK")
            }
            
            mensaje.addAction(accionOK)
            self.present(mensaje, animated: true, completion: nil)
        }
        else {
        let context = self.managedObjectContext
        let newEvent = Event(context: context!)
        
        // If appropriate, configure the new managed object.
        newEvent.timestamp = NSDate()
        newEvent.isbn = buscar.text
        newEvent.titulo = titulo.text
        newEvent.autores = autores.text
        newEvent.portada = portada.image
        
        // Save the context.
        do {
            try context?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        }
    }
    
    func hayInternet() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}
