//
//  Point.swift
//  KakaoMap
//
//  Created by YOUNG on 2020/08/06.
//  Copyright © 2020 YOUNG. All rights reserved.
//

import UIKit

class Result: NSObject, Codable {
    let frame_id: Int
    let filename: String
    let objects: [Object]
}

class Object: NSObject, Codable{
    let class_id: Int
    let confidence: Float
    let name: String
    let relative_coordinates: Coordinate
}

class Coordinate: NSObject, Codable{
    let height: Int
    let left_x: Int
    let top_y: Int
    let width: Int

//    let long: 127.026581+left_x
//    let lat: 37.584611+top_y
    
    //사진 픽셀 : 960 × 720
    //가로 960 세로 720
    //높이
}



//[
//{
// "frame_id":1,
// "filename":"sample_imgs/KakaoTalk_Photo_2020-08-02-12-59-19.jpeg",
// "objects": [
//  {"class_id":60, "name":"diningtable", "relative_coordinates":{"left_x": -24, "top_y": 429, "width":1021, "height": 311}, "confidence":0.298528},
//  {"class_id":48, "name":"sandwich", "relative_coordinates":{"left_x": 258, "top_y": 441, "width": 376, "height": 142}, "confidence":0.701933},
//  {"class_id":48, "name":"sandwich", "relative_coordinates":{"left_x": 398, "top_y": 451, "width": 255, "height": 203}, "confidence":0.627459},
//  {"class_id":42, "name":"fork", "relative_coordinates":{"left_x": 245, "top_y": 466, "width":  86, "height":  42}, "confidence":0.255697},
//  {"class_id":39, "name":"bottle", "relative_coordinates":{"left_x": 696, "top_y": 310, "width": 214, "height": 300}, "confidence":0.783990},
//  {"class_id":0, "name":"person", "relative_coordinates":{"left_x": 462, "top_y": 281, "width":  16, "height":  42}, "confidence":0.920241},
//  {"class_id":0, "name":"person", "relative_coordinates":{"left_x": 474, "top_y": 296, "width":  15, "height":  27}, "confidence":0.820938}
// ]
//}
//]

