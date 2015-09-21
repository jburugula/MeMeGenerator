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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        
        // Setup Top and Bottom text field properties
        
        setTextFieldAttributes(TopText)
        setTextFieldAttributes(BottomText)
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let  selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            showImage.image = selectedImage
            showImage.contentMode =
                UIViewContentMode.ScaleAspectFill
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Generate the new MeMe image from original image
    
    func generateMemedImage() -> UIImage
    {
        TopToolbar.hidden = true
        BottomToolbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        
        view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        
        memedImage  =
            UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return memedImage!
    }
    
    @IBAction func takePictureWithCamera(sender: AnyObject) {
        
        pickImageFromSource("Camera")
    }
    
    @IBAction func selectImageFromAlbum(sender: AnyObject) {
        
        // Select image from camera roll
        
        pickImageFromSource("Album")
    }
    
    
    func save() {
        
        //Save the meme image
        var meme = Meme(TopText: TopText.text!, BottomText: BottomText.text!, originalImage: showImage.image!, memedImage: memedImage)
    }
    
    @IBAction func shareBtnClicked(sender: AnyObject) {
        generateMemedImage()
        
        let shareMeme:UIImage = memedImage!
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [shareMeme], applicationActivities: nil)
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
            
            self.TopToolbar.hidden = false
            self.BottomToolbar.hidden = false
            
        }
    }
    
    
    @IBAction func cancelBtnClicked(sender: AnyObject) {
        showImage.image = nil
        setTextFieldAttributes(TopText)
        setTextFieldAttributes(BottomText)
    }
    
    
    //subscribe to Keyboard Notification
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        CameraBtn.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
    }
    
    
    //Unsubscribe to Keyboard Notification
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
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
        if BottomText.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    
    // Get the height of the keyboard
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
        
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
    
    func setTextFieldAttributes(textField: UITextField){
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName :UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName :-2.0
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.clearsOnBeginEditing = true
        textField.delegate = self
        textField.backgroundColor = UIColor.clearColor()
        
        if (textField == TopText) {
            textField.text = "TOP"
        }
        else {
            textField.text = "BOTTOM"
        }
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
        presentViewController( pickImageController, animated: true, completion: nil)

        
    }
    
    
}

