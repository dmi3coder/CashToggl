//
//  TogglApi.swift
//  CashToggl
//
//  Created by Dmitry Chaban on 28.06.2020.
//  Copyright © 2020 Donau Tech. All rights reserved.
//

import Foundation
import TogglCore
import Foundation

class TogglApi {

    func setupApi() -> NetworkService {
        // Define your URLSession
        let urlSession = URLSession(configuration: .default)

        // JSON Serializer
        // Or XML, Thrift, ... by adopting the Serializable protocol
        let jsonSerializer = JSONSerializer()


        // Initialize
        let network = NetworkService(fetcher: urlSession, serializer: jsonSerializer)
        return network
    }
    
    static func getEntriesForToday(from: Date, to: Date, lastDate: @escaping (Date?, Bool) -> Void) {

        var semaphore = DispatchSemaphore (value: 0)

        var request = URLRequest(url: URL(string: "https://www.toggl.com/api/v8/time_entries?start_date=\(from.iso8601withFractionalSeconds)&end_date=\(to.iso8601withFractionalSeconds)")!,timeoutInterval: Double.infinity)
        request.addValue("Basic YOUR_TOKEN", forHTTPHeaderField: "Authorization")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
            
//            let json = String(data: data, encoding: .utf8)!
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [Any]
                
                var latestEndDate: Date? = nil
                var earinig: Bool = false
                
                json?.forEach {
                    let entry = $0 as! Dictionary<String, AnyObject>
                    
                    if let stop = entry["stop"] {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        latestEndDate = dateFormatter.date(from:stop as! String)!

                    } else if let start = entry["start"] {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        latestEndDate = dateFormatter.date(from: start as! String)!
                        earinig = true
                    }
                }
                lastDate(latestEndDate, earinig)
            }
            catch {
               print(error)
            }
//            if let data = json.data(using: String.Encoding.utf8) {
//                do {
//                    let decoder = JSONDecoder()
//                    let jsonDictionary = try decoder.decode(Dictionary<String, String>.self, from: data)
//                    print(jsonDictionary) // prints: ["user": "andreas", "password": "1234"]
//                } catch {
//                    // Handle error
//                    print(error)
//                }
//            }
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}
extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}
extension Date {
    var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
}
extension String {
    var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }
}

