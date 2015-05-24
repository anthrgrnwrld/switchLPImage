//
//  ViewController.swift
//  swichOasisLP
//
//  Created by Masaki Horimoto on 2015/05/21.
//  Copyright (c) 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit

//自分が表示している画像名を保存出来るクラス (UIImageViewを継承)
class lpImageView: UIImageView {
    var lpName: String! = ""
}

//二つのCGPointを持つクラス (イメージ移動の座標管理)
class TwoCGPoint {
    var imagePoint: CGPoint!    //イメージの座標保存用
    var touchPoint: CGPoint!    //タッチ位置の座標保存用
}

//タッチスタート時と移動後の座標情報を持つクラス (イメージ移動の座標管理)
class ControlImageClass {
    var start: TwoCGPoint = TwoCGPoint()            //スタート時の画像座標とタッチ座標
    var destination: TwoCGPoint = TwoCGPoint()      //移動後(または移動途中の)画像座標とタッチ座標
    var draggingView: UIView?                       //どの画像を移動しているかを保存
    
    //startとdestinationからタッチ中の移動量を計算
    var delta: CGPoint {
        get {
            let deltaX: CGFloat = destination.touchPoint.x - start.touchPoint.x
            let deltaY: CGFloat = destination.touchPoint.y - start.touchPoint.y
            return CGPointMake(deltaX, deltaY)
        }
    }
    
    //移動後(または移動中の)画像の座標取得用のメソッド
    func setMovedImagePoint() -> CGPoint {
        let imagePointX: CGFloat = start.imagePoint.x + delta.x
        let imagePointY: CGFloat = start.imagePoint.y + delta.y
        destination.imagePoint = CGPointMake(imagePointX, imagePointY)
        return destination.imagePoint
    }
}

class ViewController: UIViewController {
    
    @IBOutlet var imageLPArray: [lpImageView]!                  //LP画像配列
    @IBOutlet var imageTranceparentLPArray: [lpImageView]!      //移動中のLP画像配列
    @IBOutlet var outputFrame: [lpImageView]!                   //拡大表示用フレーム配列
    @IBOutlet var outputLabel: [UILabel]!                       //拡大表示したLP名表示用配列
    
    let initialLPArray: [String] = ["DefinitelyMaybe", "MorningGlory", "BeHereNow"]     //初期LP画像名
    var pointImage: ControlImageClass! = ControlImageClass()                            //移動画像管理用変数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("\(__FUNCTION__)")

        //表示したいLP画像名を設定する (実際の表示はviewDidLayoutSubviewsで行う)
        for (index, val) in enumerate(initialLPArray) {
            imageLPArray[index].lpName = initialLPArray[index]
            imageTranceparentLPArray[index].lpName = initialLPArray[index]
            imageTranceparentLPArray[index].userInteractionEnabled = true
            imageTranceparentLPArray[index].layer.opacity = 1.0
        }

        //Labelに表示画像名を表示
        for (index, val) in enumerate(outputLabel) {
            outputLabel[index].text = (outputFrame[index].lpName == "") ? "Display LP name" : "\(outputFrame[index].lpName)"
        }

        
    }
    
    override func viewWillAppear(animated: Bool) {
        println("\(__FUNCTION__)")
    }
    
    override func viewDidAppear(animated: Bool) {
        println("\(__FUNCTION__)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        println("\(__FUNCTION__)")
    }
    
    override func viewDidDisappear(animated: Bool) {
        println("\(__FUNCTION__)")
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("\(__FUNCTION__)")
        
        for (index, val) in enumerate(initialLPArray) {
            imageLPArray[index].image = UIImage(named: "\(imageLPArray[index].lpName).jpg")
            imageTranceparentLPArray[index].image = UIImage(named: "\(imageTranceparentLPArray[index].lpName).jpg")
            imageTranceparentLPArray[index].layer.opacity = 1.0
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        
        //タッチスタート時の座標情報を保存する
        if touch.view is lpImageView {
            pointImage.start.imagePoint = touch.view.center
            pointImage.start.touchPoint = touch.locationInView(self.view)
            pointImage.draggingView = touch.view
            touch.view.layer.opacity = 0.5
            touch.view.layer.shadowOpacity = 0.8

        } else {
            //Do nothing
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        
        //移動後(または移動中)の座標情報を保存し、それらの情報から画像の表示位置を変更する
        //タッチされたviewとpointに保存されたviewと等しい時のみ画像を動かす
        if touch.view == pointImage.draggingView {
            pointImage.destination.touchPoint = touch.locationInView(self.view)
            touch.view.center = pointImage.setMovedImagePoint()     //移動後の座標を取得するメソッドを使って画像の表示位置を変更
            
        } else {
            //Do nothing
        }
    }
    
    //各locationとの距離を管理するクラス
    class distanceClass {
        var distanceArray: [CGFloat] = []
        var minIndex: Int!
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
    
        if touch.view == pointImage.draggingView {
            let tmpLPImageView: lpImageView = touch.view as! lpImageView
            var distance: distanceClass = distanceClass()   //locationとの距離を管理する変数
            distance = getDistanceWithImage(touch.view)     //各locationの距離と最小値のindexを保存
            
            displayOnFrmaeWithDistance(distance, imageLP: tmpLPImageView)         //最も近いlocationへ or 元の位置へアニメーション
            
        } else {
            //Do nothing
        }
        
    }

    
    //各locationとの距離とその最小値のIndexを保存するメソッド
    func getDistanceWithImage(imageLP :UIView) -> distanceClass {
        let distance: distanceClass = distanceClass()
        
        distance.distanceArray = outputFrame.map({self.getDistanceWithPoint1(imageLP.center, point2: $0.center)})
        let (index, val) = reduce(enumerate(distance.distanceArray), (-1, CGFloat(FLT_MAX))) {
            $0.1 < $1.1 ? $0 : $1
        }
        distance.minIndex = index
        
        return distance
    }
    
    
    //2点の座標間の距離を取得するメソッド
    func getDistanceWithPoint1(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let distanceX = point1.x - point2.x
        let distanceY = point1.y - point2.y
        let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
        return distance
    }
    
    //最も近いoutputFrameにLPを表示 && 透明度を0%にして元の位置へ  or  何もせず透明度を0%にして元の位置へ
    func displayOnFrmaeWithDistance(distance: distanceClass, imageLP: lpImageView) {
        let point: CGPoint!
        
        if distance.distanceArray[distance.minIndex] < 50 * sqrt(2.000) {
            imageLP.center = pointImage.start.imagePoint
            imageLP.layer.opacity = 1.0
            imageLP.layer.shadowOpacity = 0.0
   
            outputLabel[distance.minIndex].text = "\(imageLP.lpName)"
            outputFrame[distance.minIndex].image = UIImage(named: "\(imageLP.lpName).jpg")
            self.outputFrame[distance.minIndex].layer.opacity = 0.3
 
            let tmpOutputFrame = outputFrame[distance.minIndex]
            animationWithImageView(tmpOutputFrame, point: tmpOutputFrame.center, duration: 0.7)

        } else {
            let point = pointImage.start.imagePoint
            animationWithImageView(imageLP, point: point, duration: 0.2)
            
        }
        
    }
    
    //引数1のUIImageViewを引数2の座標へアニメーションするメソッド
    func animationWithImageView(ImageView: UIImageView, point: CGPoint, duration : Double
        ) {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            ImageView.center = point
            ImageView.layer.opacity = 1.0

        })
        
    }

}

