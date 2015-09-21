//
//  ViewController.swift
//  MeMeGenerator
//
//  Created by Janaki Burugula on Sep/16/2015.
//  Copyright (c) 2015 janaki. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,
UITextFieldDelegate{
    
    @IBOutlet weak var TopText: UITextField!
    @IBOutlet weak var BottomText: UITextField!
    
    @IBOutlet weak var TopToolbar: UIToolbar!
    
    @IBOutlet weak var BottomToolbar: UIToolbar!
    
    
    @IBOutlet weak var CameraBtn: UIBarButtonItem!
    
    @IBOutlet weak var AlbumBtn: UIBarButtonItem!
    
    @IBOutlet weak var ShareBtn: UIBarButtonItem!
    @IBOutlet weak var CancelBtn: UIBarButtonItem!
    
    @IBOutlet weak var showImage: UIImageView!
    
    var memedImage : UIImage?
    
  
    struct Meme {
        var TopText:String?
        var BottomText:String?
        var originalImage:UIImage?
        var memedImage:UIImage!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
       
        // Setup Top and Bottom text field properties
        
        setTextFieldAttributes()
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let  selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.showImage.image = selectedImage
            showImage.contentMode =
                UIViewContentMode.ScaleAspectFill
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func generateMemedImage() -> UIImage
    {
        self.TopToolbar.hidden = true
        self.BottomToolbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        
        memedImage  =
            UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        
        return memedImage!
    }
    
    @IBAction func TakePictureWithCamera(sender: AnyObject) {
      
        // Take picture with camera
        
        pickImageFromSource("Camera")
    }
    
    @IBAction func SelectImageFromAlbum(sender: AnyObject) {
        
       // Select image from camera roll
        
        pickImageFromSource("Album")
        
    }
    
    func save() {
        
        //Save the meme image
        var meme = Meme(TopText: TopText.text!, BottomText: BottomText.text!, originalImage: showImage.image!, memedImage: memedImage)
    }
    
    @IBAction func ShareBtnClicked(sender: AnyObject) {
        
        generateMemedImage()
        
        let shareMeme:UIImage = memedImage!
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [shareMeme], applicationActivities: nil)
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
            
            self.TopToolbar.hidden = false
            self.BottomToolbar.hidden = false
            
        }
        
    }
    
    @IBAction func CancelBtnClicked(sender: AnyObject) {
        
        self.showImage.image = nil
        setTextFieldAttributes()
        
    }
    
    
    //subscribe
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        
        CameraBtn.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
    }
    
    
    //Unsubscribe
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:" , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        if BottomText.isFirstResponder() {
            return keyboardSize.CGRectValue().height
        } else {
            
            return 0
        }
    }
    
    // Don't clear the text upon editing after the first time
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.clearsOnBeginEditing = false
    }
    
    
    // Dismisses the keyboard when you press return (the bottom right key)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // set the display propertis for TOP and BOTTOM text fields
    
    func setTextFieldAttributes(){
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName :UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName :-2.0
        ]
        
        TopText.text = "TOP"
        TopText.defaultTextAttributes = memeTextAttributes
        TopText.clearsOnBeginEditing = true
        TopText.delegate = self
        
        BottomText.text = "BOTTOM"
        BottomText.defaultTextAttributes = memeTextAttributes
        BottomText.clearsOnBeginEditing = true
        BottomText.delegate = self
        
        
    }
    
    
    // Pick Image from Source
    
    func pickImageFromSource(sourceType: String?){
    
    let pickImageController = UIImagePickerController()
    pickImageController.delegate = self
    if (sourceType == "Album"){
       pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    }
    else if (sourceType == "Camera"){
    pickImageController.sourceType = UIImagePickerControllerSourceType.Camera
    
    }
    pickImageController.allowsEditing = false
    self.presentViewController( pickImageController, animated: true, completion: nil)
    
    
    
    }
    
    
}

