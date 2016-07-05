//
//  SoundHelper.swift
//  MatchThree
//
//  Created by Theodore Abshire on 7/5/16.
//  Copyright © 2016 Theodore Abshire. All rights reserved.
//

import AVFoundation

enum SoundIDs:String
{
	case Match = "50557_broumbroum_sf3-sfx-menu-back"
	case Treasure = "201159__kiddpark__cash-register"
	case Junk = "232137_yottasounds_rock-falling-010"
	case Rotate = "176146_swagmuffinplus_sliding-doors"
	case Clap = "51746_erkanozan_clap"
	case Yay = "252808_xtrgamr_yay"
	case Boo = "333393_jayfrosting_boo-5-only-a-couple-people"
	case Select = "256116_kwahmah-02_click"
	case Shine = "169375_yoh_whoosh-crystal-reverse-yoh"
}

class SoundHelper
{
	static let sharedInstance = SoundHelper()
	
	private var musicPlayer:AVAudioPlayer?
	private var soundPlayers = [SoundIDs : AVAudioPlayer]()
	
	func playSound(id:SoundIDs)
	{
		do
		{
			if let player = soundPlayers[id]
			{
				if !player.playing
				{
					player.play()
				}
			}
			else
			{
				if let path = NSBundle.mainBundle().pathForResource(id.rawValue, ofType: "mp3")
				{
					let url = NSURL(fileURLWithPath: path)
					let player = try AVAudioPlayer(contentsOfURL: url)
					player.volume = 0.65
					player.numberOfLoops = 0
					player.play()
					soundPlayers[id] = player
				}
			}
		}
		catch let error
		{
			print("AVAudio error: \(error)")
		}
	}
	
	func playMusic()
	{
		do
		{
			if let path = NSBundle.mainBundle().pathForResource("Bushwick Tarantella Loop", ofType: "mp3")
			{
				let url = NSURL(fileURLWithPath: path)
				musicPlayer = try AVAudioPlayer(contentsOfURL: url)
				musicPlayer!.volume = 0.25
				musicPlayer!.numberOfLoops = -1
				musicPlayer!.play()
			}
		}
		catch let error
		{
			print("AVAudio error: \(error)")
		}
	}
}
