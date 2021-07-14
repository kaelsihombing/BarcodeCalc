//
//  ViewController.swift
//  BarcodeCalc
//
//  Created by Santo Michael Sihombing on 11/04/21.
//

import UIKit
import AVFoundation
import CoreData


extension ViewController: AVCaptureMetadataOutputObjectsDelegate{
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var products = [ProductItems]()
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var bucketTableView: UITableView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private var buckets: [Bucket] = []
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalRp: UILabel!
    var totalPrice: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bucketTableView.separatorColor = UIColor(white: 1, alpha: 0.0)
        self.bucketTableView.tableFooterView = UIView()
        self.bucketTableView.estimatedRowHeight = 220 //Your estimated height
        self.bucketTableView.rowHeight = UITableView.automaticDimension
        bucketTableView.dataSource = self
        bucketTableView.delegate = self
        
        cameraView.layer.cornerRadius = 50
//        cameraView.layer.masksToBounds = true
        cameraView.layer.borderWidth = 5
        cameraView.layer.borderColor = #colorLiteral(red: 1, green: 0.8274509804, blue: 0.9098039216, alpha: 1)
        
        cameraView.clipsToBounds = true

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("====================================",buckets.count)
        return buckets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "bucketCell", for: indexPath) as! BucketTableViewCell
        
        let bucket = buckets[indexPath.row]

        cell.product = bucket
     
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.contentView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.8431372549, blue: 1, alpha: 1)
        
        return cell

    }
    
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nill and it contains at least one object
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            numberLabel.text = ""
            return
        }
        
        // get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == .qr || metadataObj.type == .ean13 || metadataObj.type == .code128     {
            // if the dound metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer? .transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                
                numberLabel.text = metadataObj.stringValue
//                captureSession.stopRunning()
                isExist(id: metadataObj.stringValue!)
            }
        }
    }
    
//    func getItem() {
//        do{
//            let request = ProductItems.fetchRequest() as NSFetchRequest
//
//            // set the filtering and sorting on the request
//
//            let pred = NSPredicate(format: "id CONTAINS '1'")
//            request.predicate = pred
//
//            products = try context.fetch(request)
//
//            DispatchQueue.main.async {
//                self.productTable.reloadData()
//            }
//        } catch {
//            return
//        }
//    }
    
    func isExist(id: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductItems")
        request.predicate = NSPredicate(format: "id == %@", id)
       
        do {
            let result = try context.fetch(request)
            
            if result.count != 0 {
                for product in result {
                    let aProduct = product as! ProductItems
                    print("A PRODUCT: ",aProduct)
                    addItem(product: aProduct)
                }
//                print("BUCKET: ",bucket)
            } else {
                numberLabel.text = "No such product in database"
//                print("BUCKET: ",bucket)
            }
        }catch {
            return
        }
    }

    private func addItem(product: ProductItems) {
//        print("ID: ",id)
        let alert = UIAlertController(title: product.title, message: "Rp \(product.price)", preferredStyle: .alert)
        
    
        alert.addTextField{ (amount) in
            amount.text = ""
            amount.placeholder = "Amount: "
            amount.keyboardType = .numberPad
        }
         
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in

            guard let amountField = alert.textFields?[0], let amount = amountField.text, !amount.isEmpty else {
                return
            }

            let total = self?.calculateTotal(price: product.price, amount: Int64(amount)!)
            self?.buckets.append(Bucket(title: product.title!, price: Int64(Int32(product.price)), amount: Int(amount)!, total: total!))
            self?.updateTableview()
            self?.totalPrice += total!
            self?.totalLabel.text = String((self?.totalPrice)!)
            print("BUCKET: ", self?.buckets as Any)
        }))
        
        present(alert, animated: true)

    }
    
    func calculateTotal(price: Int64, amount: Int64)-> Int64 {
        return price * amount
    }
    
    func updateTableview() {
        bucketTableView.beginUpdates()
        bucketTableView.insertRows(at: [IndexPath(row: buckets.count-1, section: 0)], with: .automatic)
        bucketTableView.endUpdates()
    }
    
//    func delete(index: IndexPath) {
//        buckets[index]
//    }
    

}

