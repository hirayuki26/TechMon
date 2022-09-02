//
//  BattleViewController.swift
//  TechMon
//
//  Created by Yuki Hirayama on 2022/09/02.
//

import UIKit

//class Character {
//    var name: String = ""
//    var image: UIImage!
//    var attackPoint: Int = 30
//    
//    var currentHP: Int = 100
//    var currentTP: Int = 0
//    var currentMP: Int = 0
//    
//    var maxHP: Int = 100
//    var maxTP: Int = 20
//    var maxMP: Int = 20
//    
//    init(name: String, imagaName: String, attackPoint: Int, maxHP: Int, maxTP: Int, maxMP: Int) {
//        self.name = name
//        self.image = UIImage(named: imageName)
//        self.attackPoint = attackPoint
//        self.maxHP = maxHP
//        self.currentHP = maxHP
//        self.maxTP = maxTP
//        self.maxMP = maxMP
//    }
//    
//    func resetStatus() {
//        currentHP = maxHP
//        currentTP = 0
//        currentMP = 0
//    }
//}

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var player: Character!
    var enemy: Character!
    
//    var playerHP = 100
//    var playerMP = 0
//    var enemyHP = 200
//    var enemyMP = 0
    
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        player.currentHP = player.maxHP
        player.currentMP = 0
        player.currentTP = 0
        enemy.currentHP = enemy.maxHP
        enemy.currentMP = 0
        
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        

        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
        

//        playerNameLabel.text = "勇者"
//        playerImageView.image = UIImage(named: "yusya.png")
//        playerHPLabel.text = "\(playerHP) / 100"
//        playerMPLabel.text = "\(playerMP) / 20"
//
//        enemyNameLabel.text = "龍"
//        enemyImageView.image = UIImage(named: "monster.png")
//        enemyHPLabel.text = "\(enemyHP) / 200"
//        enemyMPLabel.text = "\(enemyMP) / 35"
//
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    @objc func updateGame() {
        player.currentMP += 1
        if player.currentMP >= player.maxMP {
            isPlayerAttackAvailable = true
            player.currentMP = player.maxMP
        } else {
            isPlayerAttackAvailable = false
        }
        
        enemy.currentMP += 1
        if enemy.currentMP >= enemy.maxMP {
            enemyAttack()
            enemy.currentMP = 0
        }
        
        updateUI()
//        playerMPLabel.text = "\(playerMP) / 20"
//        enemyMPLabel.text = "\(enemyMP) / 35"
    }
    
    func updateUI() {
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    
    func judgeBattle() {
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        } else if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    func enemyAttack() {
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= enemy.attackPoint
        
        updateUI()
//        playerHPLabel.text = "\(playerHP) / 100"
        
        judgeBattle()
//        if player.currentHP <= 0 {
//            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
//        }
    }
    
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！！"
        } else {
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北"
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func attackAction() {
        if isPlayerAttackAvailable {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            
            player.currentMP = 0
            
            updateUI()
//            enemyHPLabel.text = "\(enemyHP) / 200"
//            playerMPLabel.text = "\(playerHP) / 200"
            
            judgeBattle()
//            if enemy.currentHP <= 0 {
//                finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
//            }
        }
    }
    
    @IBAction func tameruAction() {
        if isPlayerAttackAvailable {
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }
    }
    
    @IBAction func fireAction() {
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                player.currentTP = 0
            }
            player.currentMP = 0
            
            judgeBattle()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
