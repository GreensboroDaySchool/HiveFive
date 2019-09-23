/**
 *
 *  This file is part of Hive Five.
 *
 *  Hive Five is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Hive Five is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Hive Five.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import Foundation
import UIKit
import AVFoundation

public class Utils {
    
    /**
     - Parameter id: The id of the event, must be unique and consistent
     - Parameter exec: The event to be executed once when the app is first launched.
     */
    public static func executeOnce(id: String, _ exec: () -> Void) {
        if let _ = UserDefaults.standard.object(forKey: id)  {
            return
        }
        exec()
    }
    
    public static func loadFile(name: String, extension ext: String) -> String? {
        let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: nil)
        let url = URL(fileURLWithPath: path!)
        let data = try? Data(contentsOf: url)
        return String(data: data!, encoding: .utf8)
    }
    
    public static func loadJSON(from fileName: String) -> Any? {
        let path = Bundle.main.path(forResource: fileName, ofType: "json", inDirectory: nil)
        let url = URL(fileURLWithPath: path!)
        let data = try? Data(contentsOf: url)
        let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        print(jsonObj ?? "not valid")
        return jsonObj
    }
    
    public static func loadFrom(url: String, completion: @escaping HtmlCompletionHandler) {
        if let url = URL(string: url) {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            }
            dataTask.resume()
        }
    }
    
    public typealias HtmlCompletionHandler = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
    
    public static func playSound(_ name: String) {
        var alarmAudioPlayer: AVAudioPlayer?
        if let sound = NSDataAsset(name: name) {
            do {
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .default)
                try! AVAudioSession.sharedInstance().setActive(true)
                try alarmAudioPlayer = AVAudioPlayer(data: sound.data, fileTypeHint: AVFileType.wav.rawValue)
                alarmAudioPlayer!.play()
            } catch {
                print("error initializing AVAudioPlayer")
            }
        }
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    private static func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
    }

}



