//
//  PinataService.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 08/04/2022.
//


// https://docs.pinata.cloud/api-pinning


import Alamofire
import Foundation

protocol PinataApi {
    var headers: HTTPHeaders { get }
    func pinDirectory()
    func pinFile(data: Data, fileName: String) async throws -> IPFSFilePinResponse?
}

struct PinataService: PinataApi {
    
    enum Endpoints: String {
        case pinFileToIPFS
        case pinJSONToIPFS
    }
    
    private(set) var pinataApiBase: String
    private(set) var headers: HTTPHeaders
    private(set) var configuration: URLSessionConfiguration
    
    private var session: Session
    
    init(headers: HTTPHeaders = ["Authorization": "Bearer \(ApiKeys.pinataProjectJWT)"],
         configuration: URLSessionConfiguration = URLSessionConfiguration.default,
         pinataApiBase: String = ApiKeys.pinataApiBase
    ) {
        self.headers = headers
        self.configuration = configuration
        self.session = Session(configuration: configuration)
        self.pinataApiBase = pinataApiBase
    }
    
    func pinDirectory() {}

    func pinFile(data: Data, fileName: String) async throws -> IPFSFilePinResponse? {
        let apiURLString = pinataApiBase + "/\(Endpoints.pinFileToIPFS)"
        let request = session.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file" , fileName: fileName)
        },
        to: apiURLString, headers: headers)
        .responseDecodable(of: IPFSFilePinResponse.self) { response in
            switch response.result {
            case .success(let result):
                debugPrint("result = \(result)")
            case .failure(let error):
                debugPrint("error = \(error)")
            }
            debugPrint("response = \(response.debugDescription)")
        }
        .uploadProgress(closure: { (progress) in
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        
        return try await request.serializingDecodable(IPFSFilePinResponse.self).value
    }
}

struct IPFSFilePinResponse: Codable, Equatable {
        
    var hash: String
    var size: Int
    var timestamp: String
    
    //    IpfsHash: This is the IPFS multi-hash provided back for your content,
    //    PinSize: This is how large (in bytes) the content you just pinned is,
    //    Timestamp: This is the timestamp for your content pinning (represented in ISO 8601 format)

    enum CodingKeys: String, CodingKey {
        case hash = "IpfsHash"
        case size = "PinSize"
        case timestamp = "Timestamp"
    }
}
