//
//  ReportsRepo.swift
//  Public Eyes
//
//  Created by Fitsyu  on 26/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import Promises
import Alamofire

class ReportsRepo {
    
    private var memory: [Report] = [] //Report.fakes()
    
    func fetchAll() -> [Report] {
        return memory
    }
    
    func add(_ one: Report) {
        
        memory.append(one)
    }
    
    func remove(_ one: Report) {
        
        memory.removeAll(where: { $0.id == one.id })
    }
    
    func clear() {
        
        memory.removeAll()
    }
    
    func update(report: Report) {
        
        if let index = memory.firstIndex(where: { $0.id == report.id }) {
            
            
            // should we use diffing algorithm here. hmm
//            var rep = memory[index]
//
//            rep.what = report.what
//            rep.who  = report.who
//            rep.submitted = report.submitted
//
//            memory[index] = rep
            
            memory[index] = report
            
            
        } else {
            //  reject(Error)
        }
    }
    
    
    struct NetworkError: Error {
        var localizedDescription: String = "Just error. Try again!"
    }
    
    func upload(report: Report, progressHandler: ((Double)->())? ) -> Promise<Bool> {
        
        let promise = Promise<Bool> { fulfill, reject in
  
            
            let imgData = try Data(contentsOf: report.how.photoUrl)
            let vidData = try Data(contentsOf: report.how.videoUrl!)
            
            
            Alamofire.upload(multipartFormData: { (mfd: MultipartFormData) in
                
                mfd.append(Data(report.what!.description.utf8), withName: "what")
                mfd.append(Data(report.who!.utf8), withName: "who")
                mfd.append(Data(report.when.description.utf8), withName: "when")
                
                mfd.append(Data(report.whre!.latitude.description.utf8), withName: "lat")
                mfd.append(Data(report.whre!.longitude.description.utf8), withName: "lng")
                
                
                mfd.append(imgData, withName: "img")
                mfd.append(vidData, withName: "vid")
            },
//                             to: "http://localhost:8080/uploads",
                to: "https://pub-eyes-develop.vapor.cloud/uploads",
                             encodingCompletion: { (result: SessionManager.MultipartFormDataEncodingResult) in
                                
                                switch result {
                                    
                                case .failure(let error):
                                    reject(error)
                                    
                                case .success(let request, _, _):
                                    
                                    request
                                        .uploadProgress { progress in
                                            
                                            progressHandler?(progress.fractionCompleted)
                                        }
                                        .response { response in
                                        
                                            fulfill(true)
                                        }
                                }
                                
            })
            
        }
        
        return promise
    }
    
    
    // MARK: Singleton Instance
    private init() {}
    public static let shared = ReportsRepo()

}




//            let item = UploadableReport(from: report)
//
//            guard let uploadData = try? JSONEncoder().encode(item) else {
//                reject(NetworkError(localizedDescription: "encoding failure"))
//                return
//            }
//
////            let url = URL(string: "https://pub-eyes-develop.vapor.cloud/reports")!
//            let url = URL(string: "http://localhost:8080/uploads")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//
//            request.setValue("multipart/form-data",
//                             forHTTPHeaderField: "Content-Type")
////            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
//                if let error = error {
//                    print ("error: \(error)")
//                    reject(error)
//                    return
//                }
//
//                guard let response = response as? HTTPURLResponse,
//                    (200...299).contains(response.statusCode) else {
//                        print ("server error")
//                        reject(NetworkError())
//                        return
//                }
//
//                if let mimeType = response.mimeType,
//                    mimeType == "application/json",
//                    let data = data,
//                    let dataString = String(data: data, encoding: .utf8) {
//                    print ("got data: \(dataString)")
//                }
//
//                fulfill(true)
//            }
//
//            task.resume()
