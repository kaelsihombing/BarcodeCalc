//
//  TableViewDataControllerViewController.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 11/04/21.
//

import UIKit
import AVFoundation

extension TableViewDataControllerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
}

class TableViewDataControllerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    @IBOutlet weak var productTable: UITableView!
    
    private var products = [ProductItems]()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var id: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product List"
        productTable.delegate = self
        productTable.dataSource = self
        getAllItems()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session
            captureSession.addInput(input)
            
            // initialize AVCaptureMetadataOutput object and set it as the output device to the capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.qr, .ean13, .code128]
        
            // initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            videoPreviewLayer?.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
            videoPreviewLayer?.bounds = cameraView.frame
            
            
            cameraView.layer.addSublayer(videoPreviewLayer!)
            captureSession.startRunning()
            
            // initialize QR Code frame to higlight the QR Code
            qrCodeFrameView = UIView()
            
            if let qrcodeFrameView = qrCodeFrameView {
                qrcodeFrameView.layer.borderColor = UIColor.yellow.cgColor
                qrcodeFrameView.layer.borderWidth = 2
                cameraView.addSubview(qrcodeFrameView)
                cameraView.bringSubviewToFront(qrcodeFrameView)
            }
        } catch {
//            print(error)
        }
    }
    
    @objc private func didTapAdd(idNumber: Int64) {
//        print("ID: ",id)
        let alert = UIAlertController(title: "New Product", message: "Enter new product", preferredStyle: .alert)
        
        alert.addTextField{ (id) in
           id.text = "\(idNumber)"
           id.placeholder = "ID: "
        }
        
        alert.addTextField{ (name) in
           name.text = ""
           name.placeholder = "Name: "
        }
        
        alert.addTextField{ (price) in
           price.text = ""
           price.placeholder = "Price: "
            price.keyboardType = .numberPad
        }
         
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            
            guard let idField = alert.textFields?[0], let id = idField.text, !id.isEmpty else {
                return
            }
            guard let titleField = alert.textFields?[1], let title = titleField.text, !title.isEmpty else {
                return
            }
            
            guard let priceField = alert.textFields?[2], let price = priceField.text, !price.isEmpty else {
                return
            }
        
            self?.createItem(id: Int64(id)!, title: title, price: Int64(price)!)
        }))
        
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell
        
        let product = products[indexPath.row]

        cell.product = product
//        cell.textLabel?.text = product.title
        return cell
        
        //        cell.textLabel?.text = String(model.id)
        //        cell.column1?.text = String(model.id) // fill in your value for column 1 (e.g. from an array)
        //        cell.column2?.text = model.name // fill in your value for column 2
        //        cell.column3?.text = String(model.price)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = products[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: {_ in
            let alert = UIAlertController(title: "Edit Product", message: "Edit the product", preferredStyle: .alert)
            
            alert.addTextField{ (name) in
                
            }
            
            alert.addTextField{ (price) in
                price.text = ""
                price.keyboardType = .numberPad
            }
            
            alert.textFields?.first?.text = product.title
            alert.textFields?[1].text = String(product.price)
            
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let titleField = alert.textFields?.first, let newName = titleField.text, !newName.isEmpty else {
                    return
                }
                
                guard let priceField = alert.textFields?[1], let newPrice = priceField.text, !newPrice.isEmpty else {
                    return
                }
                
                self?.updateItem(product: product, newName: newName, newPrice: Int64(newPrice)!)
            }))
            
            self.present(alert, animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(product: product)
        }))
        
        present(sheet, animated: true)
    }

    
    func createItem(id: Int64, title: String, price: Int64 ) {
        let newProduct = ProductItems(context: context)
        newProduct.id = id
        newProduct.title = title
        newProduct.price = price
        
        do {
            try context.save()
            getAllItems()
        } catch {
        }
    }
    
    func getAllItems() {
        do{
            products = try context.fetch(ProductItems.fetchRequest())
            
            DispatchQueue.main.async {
                self.productTable.reloadData()
            }
        } catch {
        }
    }
    
    func deleteItem(product: ProductItems) {
        context.delete(product)
        
        do {
            try context.save()
            getAllItems()
        } catch {
        }
    }
    
    func updateItem(product: ProductItems, newName: String, newPrice: Int64) {
        product.title = newName
        product.price = newPrice
        
        do {
            try context.save()
            getAllItems()
        } catch {
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nill and it contains at least one object
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            numberLabel.text = "No QR code is detected"
            return
        }
        
        // get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == .qr || metadataObj.type == .ean13 || metadataObj.type == .code128     {
            // if the dound metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer? .transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                print(type(of: metadataObj.stringValue))
                numberLabel.text = metadataObj.stringValue
                didTapAdd(idNumber: Int64(metadataObj.stringValue!)!)
//                id = Int32(metadataObj.stringValue)
            }
        }
    }

    
    
}
