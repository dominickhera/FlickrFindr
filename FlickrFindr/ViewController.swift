//
//  ViewController.swift
//  FlickrFindr
//
//  Created by Dominick Hera on 12/15/21.
//

import UIKit

struct Photo: Decodable
{
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

struct Photos: Decodable
{
    let photo: [Photo]
    let page: Double
    let pages: Int
    let perpage: Int
    let total: Int
}

struct PhotoObject: Decodable
{
    let photos: Photos
}

class ViewController: UIViewController
{

    //MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    
    var searchUrl = URLComponents(string: "https://www.flickr.com/services/rest/")
    lazy var photoObjects = [Photo]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let searchNib = UINib(nibName: "SearchPhotoTableViewCell", bundle: nil)
        tableView.register(searchNib, forCellReuseIdentifier: "SearchPhotoTableViewCell")
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer)
    {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

    func searchForImages(searchValue: String, callback: @escaping(_ matchingPhotos: [Photo], _ error: Error?) -> Void)
    {
        searchUrl?.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "api_key", value: "1508443e49213ff84d566777dc211f2a"),
            URLQueryItem(name: "text", value: searchValue),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "per_page", value: "25"),
            URLQueryItem(name: "page", value: "1")
        ]
        
        let url = URL(string: searchUrl?.string ?? "")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        
        let task = URLSession.shared.dataTask(with: request)
        {
            data, response, error in
            
            guard error == nil, let serverResponse = response as? HTTPURLResponse, serverResponse.statusCode == 200, let receivedData = data
            else
            {
                callback([Photo](), error)
                
                return
            }
            
            do
            {
                let decoder = JSONDecoder()
                let photoObject = try decoder.decode(PhotoObject.self, from: receivedData)
                callback(photoObject.photos.photo, nil)
            }
            catch
            {
                print("Invalid Response")
                print(error)
                callback([Photo](), error)
            }
        }
        
        task.resume()
    }
    
    func retrievePhoto(photoData: Photo, callback: @escaping(_ photo: UIImage?, _ error: Error?) -> Void)
    {
        let url = URL(string: "https://live.staticflickr.com/\(photoData.server)/\(photoData.id)_\(photoData.secret).jpg")!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request)
        {
            data, response, error in
            
            guard error == nil, let serverResponse = response as? HTTPURLResponse, serverResponse.statusCode == 200, let receivedData = data
            else
            {
                callback(nil, error)
                
                return
            }
            
            let photo = UIImage(data: receivedData)
            callback(photo, nil)
        }
        
        task.resume()
    }
}

//MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPhotoTableViewCell", for: indexPath) as! SearchPhotoTableViewCell
    
        let photoObject = photoObjects[indexPath.row]
        
        cell.resultImageTitleLabel.text = photoObject.title
        
        retrievePhoto(photoData: photoObject)
        {
            photo, error in
            
            DispatchQueue.main.async
            {
                cell.resultImageView.image = photo
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return photoObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
}

//MARK: UITableViewDelegate

extension ViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath) as! SearchPhotoTableViewCell
        let newImageView = UIImageView(image: cell.resultImageView.image)
        
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
}

//MARK: UISearchBarDelegate

extension ViewController: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchForImages(searchValue: searchText)
        {
            matchingPhotos, error in
            
            self.photoObjects = matchingPhotos
            
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        }
    }
}
