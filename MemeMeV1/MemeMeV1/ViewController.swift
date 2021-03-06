//
//  ViewController.swift
//  MemeMeV1
//
//  Created by Jonathan Cochran on 7/6/18.
//  Copyright © 2018 Jonathan Cochran. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBOutlet weak var albumBtn: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navibar: UINavigationBar!
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.white,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.black,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: Float()]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToKeyboardNotifications()
        
        func stylizeTextField(textField: UITextField) {
            textField.defaultTextAttributes = memeTextAttributes
            
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            textField.textAlignment = .center
            textField.delegate = self
        }
        stylizeTextField(textField: topTextField)
        stylizeTextField(textField: bottomTextField)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.subscribeToKeyboardNotifications()
        
        cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
        func textFieldDidBeginEditing(textField: UITextField) {
            if textField.text == "TOP" || textField.text == "BOTTOM"{
                textField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            print("keyboardWillShow BT")
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            print("keyboardWillHide BT")
            view.frame.origin.y = 0
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }else {
            print("error with image conversion")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    func generateMemedImage() -> UIImage {
        //hide nav bar
        navibar.isHidden = true
        toolBar.isHidden = true
        
        // Render View To An Image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show Toolbar and Navigation Bar
        navibar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
    }
    
    func save() {
        
        let memedImage = generateMemedImage()
        _ = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imageView.image, memedImage:memedImage)
        
    }
    
    func openImagePicker(source: UIImagePickerControllerSourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        openImagePicker(source: .camera)
    }
    
    @IBAction func pickImage(_ sender: Any) {
        openImagePicker(source: .photoLibrary)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save()
                self.dismiss(animated: true, completion: nil)
                self.generateMemedImage()
            }
        }
        
        present(activityController, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        self.imageView.image = nil
    }
    
    
}

