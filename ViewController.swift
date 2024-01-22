//
//  ViewController.swift
//  Project10
//
//  Created by Venkata on 1/21/24.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.ImageView.image = UIImage(contentsOfFile: path.path)
        
        cell.ImageView.layer.borderColor = UIColor(white: 0, alpha: 0.03).cgColor
        cell.ImageView.layer.borderWidth = 2
        cell.ImageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7 
        
        return cell
    }
    
    @objc func addPerson() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknow", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename or Delete", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            let ad = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            ad.addTextField()
            ad.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self, weak ad] _ in
                guard let newName = ad?.textFields?[0].text else { return }
                person.name = newName
                self?.collectionView.reloadData()
            })
            
            ad.addAction(UIAlertAction(title: "Cancle", style: .cancel))
            self?.present(ad, animated: true)
        })
        
        ac.addAction(UIAlertAction(title: "Delete", style: .default) { [weak self] _ in
            self?.people.remove(at: indexPath.item)
            let ae = UIAlertController(title: "Image Deleted", message: nil, preferredStyle: .alert)
            self?.present(ae, animated: true)
            ae.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self?.collectionView.reloadData()
        })
        present(ac, animated: true)
    }

}

