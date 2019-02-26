//
//  ViewController.swift
//  TicTacToe
//
//  Created by Chang Sophia on 2/21/19.
//  Copyright © 2019 Chang Sophia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let grid: Grid = Grid()
    
    @IBOutlet var gestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var oLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var infoView: InfoView!
    @IBOutlet var squares: [UIView]!
    
    var occupyPieces = [UILabel]()
    
    
    //label動畫顯示輪流出牌
    func takeTurn(label: UILabel){
        let rotateAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeIn){
            label.transform = CGAffineTransform(rotationAngle:CGFloat.pi / 4)
            label.alpha = 0.5
        }
        let backAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut){
            label.transform = CGAffineTransform.identity
            label.alpha = 1
        }
        backAnimator.addCompletion { (_) in
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(self.gestureRecognizer)
            self.view.bringSubviewToFront(label)
        }
        rotateAnimator.addCompletion{ (_) in
            backAnimator.startAnimation()
        }
        rotateAnimator.startAnimation()
    }
    
    //遊戲從圈開始
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        takeTurn(label: oLabel)
    }
    
    
//label賦圖
    
    func labelLoadImage(){
        let content = NSMutableAttributedString(string: "")
        let oAttachment = NSTextAttachment()
        oAttachment.image = UIImage(named: "o")
        oAttachment.bounds = CGRect(x: 255, y: 550, width: 90, height: 100)
        content.append(NSAttributedString(attachment: oAttachment))
        let Label = UILabel(frame: CGRect(x: 255, y:550, width: 110, height:110))
        let contentX = NSMutableAttributedString(string: "")
        let xAttachment = NSTextAttachment()
        xAttachment.image = UIImage(named: "x")
        xAttachment.bounds = CGRect(x: 10, y: 550, width:90, height:100)
        contentX.append(NSAttributedString(attachment: xAttachment))
        oLabel.numberOfLines = 20
        xLabel.numberOfLines = 20
        oLabel.attributedText = content
        xLabel.attributedText = contentX
        view.addSubview(oLabel)
        view.addSubview(xLabel)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelLoadImage()
        
    }

//開始一回新遊戲
    func newGame() {
        grid.clear()
        labelLoadImage()
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 1, options: [], animations: {
            self.occupyPieces.forEach { (piece) in
                piece.alpha = 0
            }
        }) { (_) in
            self.occupyPieces.forEach { (piece) in
                piece.removeFromSuperview()
            }
            self.occupyPieces.removeAll()
            self.takeTurn(label: self.oLabel)
        }
    }
    
//產生新的label
    func createPieceLabel(label:UILabel) -> UILabel {
        let newLabel = UILabel(frame: label.frame)
        newLabel.text = label.text
        newLabel.font = label.font
        newLabel.backgroundColor = label.backgroundColor
        newLabel.textColor = label.textColor
        newLabel.textAlignment = label.textAlignment
        newLabel.alpha = 0.5
        newLabel.isUserInteractionEnabled = false
        return newLabel
        
        
    }
    
    
//判斷一回合遊戲結束
    func finishCurrentTurn(label: UILabel, index: Int, originalPieceCenter: CGPoint) {
        occupyPieces.append(label)
        let newLabel = createPieceLabel(label: label)
        newLabel.center = originalPieceCenter
        view.addSubview(newLabel)
        
        let nextLabel: UILabel
        if label == xLabel {
            self.grid.occupy(piece: .x, on: index)
            xLabel = newLabel
            nextLabel = oLabel
        } else {
            self.grid.occupy(piece: .o, on: index)
            oLabel = newLabel
            nextLabel = xLabel
        }
        if let winner = grid.winner {
            if winner == Grid.Piece.o {
                infoView.show(text: "Congratulations, O wins!")
            } else {
                infoView.show(text: "Congratulations, X wins!")
            }
        } else if grid.isTie {
            infoView.show(text: "Tie")
        } else {
            takeTurn(label: nextLabel)
            
        }
    }
    
//圈叉放至方格
    func placePiece(_label: UILabel, on square: UIView, index: Int) {
    
        var originalPieceCenter = CGPoint.zero
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [], animations: {
            _label.transform = .identity
            originalPieceCenter = _label.center
            _label.center = square.center
            
        }) {(_) in
            
            self.finishCurrentTurn(label: _label, index: index, originalPieceCenter: originalPieceCenter)
            
        }
    }

//方格回到原點動畫
    func pieceBackToStartLocation(label: UILabel){
        UIView.animate(withDuration: 0.5) {
            label.transform = .identity
        }
    }

    @IBAction func movePiece(_ sender: UIPanGestureRecognizer) {
        guard let label = sender.view as? UILabel else {
            return
        }
        if sender.state == .ended {
            var maxIntersctionArea: CGFloat = 0
            var targetSquare: UIView?
            var targetIndex: Int?
            for (i, square) in squares.enumerated() {
                let intersectionFrame =
                square.frame.intersection(label.frame)
                let area = intersectionFrame.width * intersectionFrame.height
                if area > maxIntersctionArea {
                    maxIntersctionArea = area
                    targetSquare = square
                    targetIndex = i
                }
            }
                if let targetSquare = targetSquare, let targetIndex = targetIndex, grid.isSquareEmpty(index: targetIndex) {
                    placePiece(_label: label, on: targetSquare, index: targetIndex)
                } else {
                   pieceBackToStartLocation(label: label)
            }
            } else {
              let translation = sender.translation(in: view)
              label.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        }
          labelLoadImage()
    }
    //info view遊戲說明
    @IBAction func infoButtonTapped(_ sender: Any){
        infoView.show(text: "Get 3 in a row to win!")
        
    }
    
    //關閉info View重新開始
    @IBAction func closeInfoView(_ sender: Any) {
        infoView.close()
        if grid.winner != nil || grid.isTie {
            newGame()
        }
    }
    
    
  
}

