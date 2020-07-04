//
//  ImagePickerManager.swift
//  Stripes
//
//  Created by Dylan Baker on 5/13/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import Foundation
import UIKit


class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var picker = UIImagePickerController();
  var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
  var viewController: UIViewController?
  var pickImageCallback : ((UIImage) -> ())?;
  
  func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
    pickImageCallback = callback
    self.viewController = viewController
    
    let cameraAction = UIAlertAction(title: "Camera", style: .default){ UIAlertAction in
      self.openCamera()
    }
    let galleryAction = UIAlertAction(title: "Gallery", style: .default){
      UIAlertAction in
      self.openGallery()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ UIAlertAction in
      
    }
    
    alert.addAction(cameraAction)
    alert.addAction(galleryAction)
    alert.addAction(cancelAction)
    alert.popoverPresentationController?.sourceView = self.viewController!.view
    picker.delegate = self
    viewController.present(alert, animated: true, completion: nil)
  }
  
  private func openCamera(){
    alert.dismiss(animated: true, completion: nil)
    if(UIImagePickerController.isSourceTypeAvailable(.camera)){
      picker.sourceType = .camera
      self.viewController!.present(picker, animated: true, completion: nil)
    } else {
      self.presentWarning("Could not access camera")
    }
  }
  
  private func openGallery(){
    alert.dismiss(animated: true, completion: nil)
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      picker.sourceType = .photoLibrary
      self.viewController!.present(picker, animated: true, completion: nil)
    } else {
      self.presentWarning("Could not access photo library")
    }
  }
  
  private func presentWarning(_ warningText : String) {
    let warning = UIAlertController(title: "Warning", message: warningText, preferredStyle: .alert)
    warning.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    self.viewController?.present(warning, animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let image = info[.originalImage] as? UIImage else {
      fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    }
    pickImageCallback?(image)
  }
  
  
  
  @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
  }
  
}
