import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    enum CameraDevice :Int{
        case rear
        case front
    }
    
    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Setup Session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        //Select Input Device
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)

            //Step 9
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                self.setupLivePreview()
                DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                    self.captureSession.startRunning()
                    //Step 13
                    DispatchQueue.main.async {
                        self.videoPreviewLayer.frame = self.previewView.bounds
                    }
                }
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    //MARK: func - setupLivePreview
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
    }
    //MARK: func - didTakePhoto
    @IBAction func didTakePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    //get photoLibrary.
    @IBAction func photoLibrary(_ sender: Any) {
    }
    //change Camera Device
    @IBAction func changeCameraDevice(_ sender: Any) {
        
    }
    
}

extension CameraViewController :AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        //let image = UIImage(data: imageData)
    }
}
