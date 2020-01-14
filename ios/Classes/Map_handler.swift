import Flutter
import UIKit
import MapKit
enum MapType: String {
    case apple
    case google
    case amap
    case baidu
    case waze
    case yandexNavi
    case yandexMaps
    
    func type() -> String {
        return self.rawValue
    }
}

class Map {
    let mapName: String
    let mapType: MapType
    let urlPrefix: String?
    
    init(mapName: String, mapType: MapType, urlPrefix: String?) {
        self.mapName = mapName
        self.mapType = mapType
        self.urlPrefix = urlPrefix
    }
    
    func toMap() -> [String:String] {
        return [
            "mapName": mapName,
            "mapType": mapType.type(),
        ]
    }
}

public class MapHandler: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "maps_channel", binaryMessenger: registrar.messenger())
        let instance = MapHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    let maps: [Map] = [
        Map(mapName: "Apple Maps", mapType: MapType.apple, urlPrefix: ""),
        Map(mapName: "Google Maps", mapType: MapType.google, urlPrefix: "comgooglemaps://"),
        Map(mapName: "Amap", mapType: MapType.amap, urlPrefix: "iosamap://"),
        Map(mapName: "Baidu Maps", mapType: MapType.baidu, urlPrefix: "baidumap://"),
        Map(mapName: "Waze", mapType: MapType.waze, urlPrefix: "waze://"),
        Map(mapName: "Yandex Navigator", mapType: MapType.yandexNavi, urlPrefix: "yandexnavi://"),
        Map(mapName: "Yandex Maps", mapType: MapType.yandexMaps, urlPrefix: "yandexmaps://")
    ]
    
    func getMapByRawMapType(type: String) -> Map {
        return maps.first(where: { $0.mapType.type() == type })!
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getInstalledMaps":
            result(maps.filter({ isMapAvailable(map: $0) }).map({ $0.toMap() }))
        case "launchMap":
            guard let args = call.arguments as? [String: String],
                let mapType = args["mapType"],
                let url = args["url"],
                let title = args["title"],
                let address = args["address"] else { return }
            
            let map = getMapByRawMapType(type: mapType ?? "")
            if (!isMapAvailable(map: map)) {
                result(FlutterError(code: "MAP_NOT_AVAILABLE", message: "Map is not installed on a device", details: nil))
                return;
            }
            
            launchMap(mapType: MapType(rawValue: mapType)!, url: url, title: title)
        case "isMapAvailable":
            guard let args = call.arguments as? [String: String],
                let mapType = args["mapType"] else { return }
            let map = getMapByRawMapType(type: mapType)
            result(isMapAvailable(map: map))
        default:
            print("method does not exist")
        }
    }

    func launchMap(mapType: MapType, url: String, title: String) {
        //For now open url for all the maps because we are using address instead of coordinates.
        UIApplication.shared.openURL(URL(string:url)!)
    }
    
    func isMapAvailable(map: Map) -> Bool {
        if map.mapType == MapType.apple {
            return true
        }
        return UIApplication.shared.canOpenURL(URL(string:map.urlPrefix!)!)
    }
}
