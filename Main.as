package{
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.media.SoundTransform;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import Infos.ImgInfo;
	import Utils.DisObjUtil;
	import gs.TweenLite;
	import gs.easing.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	public class Main extends MovieClip{
		private var imgContainer:Sprite = new Sprite();
		private var imgLoader:Loader = new Loader();
		private var loadingCircle:core_loading_circle;
		private var rulePanel:RulePanel;
		private var answerPanel:AnswerPanel;
		private var resultPanel:ResultPanel;
		private var choseDifficultyPanel:ChoseDifficultyPanel;
		private var keyPanel:KeyPanel;
		private var tempImgArray:Array;
		private var diffType:String;
		private var easyImgArray:Array;
		private var mediumImgArray:Array;
		private var hardImgArray:Array;
		private var userArray:Array;
		private var randomArray:Array;
		private var sbArray:Array;
		private var currentImgInfo:ImgInfo;
		private var timeOutId:uint;
		private var trueCount:int;
		private var errorCount:int;
		private var countDownTimer:Timer;
		private var countDownInt:int;
		private var gameTime:Number;
		private var playerScore:int;
		private var bgSoundChannel:SoundChannel;
		private var bgSound:BgSound;
		private var otherSoundChannel:SoundChannel;
		private var overSound:OverSound = new OverSound();
		private var fishSound:FishSound = new FishSound();
		private var trueSound:TrueSound = new TrueSound();
		private var errorSound:ErrorSound = new ErrorSound();
		private var bgSoundTransform:SoundTransform;
		private var pt:PageTurner;
		private var itemList:Array;
		private var disoArray:Array;
		private var keyCharArray:Array;
		
		public function Main():void {
			if (stage) {
				init();
			}else {
				addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);   
			}
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			XML.ignoreComments = true;
			XML.ignoreProcessingInstructions = true;
			loadingCircle = new core_loading_circle();
			rulePanel = new RulePanel();
			answerPanel = new AnswerPanel();
			resultPanel = new ResultPanel();
			choseDifficultyPanel = new ChoseDifficultyPanel();
			init2();
			bgSound = new BgSound();
			bgSoundTransform = new SoundTransform(0.6);
			bgSoundChannel = new SoundChannel();
			bgSoundChannel = bgSound.play();
			bgSoundChannel.soundTransform = bgSoundTransform;
			bgSoundChannel.addEventListener(Event.SOUND_COMPLETE, bgSoundComplete);
		}
		
		private function bgSoundComplete(e:Event):void {
			bgSound = new BgSound();
			bgSoundChannel = new SoundChannel();
			bgSoundChannel.soundTransform = bgSoundTransform;
			bgSoundChannel = bgSound.play();
		}
		
		private function init2():void {
			tip_mc.visible = false;
			DisObjUtil.removeAllChildren(imgContainer);
			addChild(imgContainer);
			rod.gotoAndStop(22);
			rod.fish.gotoAndStop(int(Math.random() * 8) + 1);
			score_mc.visible = false;
			replay_btn.visible = false;
			if(countDownTimer!=null){
				countDownTimer.addEventListener(TimerEvent.TIMER, onCoundDown);
				countDownTimer.stop();
			}
			if(this.contains(answerPanel)){
				answerPanel.answer_txt.text = "";
				answerPanel.ok_btn.removeEventListener(MouseEvent.CLICK, onAnswerBtn);
				answerPanel.jump_btn.removeEventListener(MouseEvent.CLICK,onJumpBtn);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDownHandler);
				removeChild(answerPanel);
			}
			clearTimeout(timeOutId);
			stage.removeEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrameHandler);
			userArray = [];
			randomArray = [];
			disoArray = [];
			sbArray = [];
			itemList = [];
			keyCharArray = [];
			loadingConfig();
			trueCount = 0;
			errorCount = 0;
			playerScore = 0;
			countDownInt = gameTime * 60;
			diffType = "";
		}
		
		
		private function loadingConfig():void{
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, onLoadingConfigComplete);
			l.load(new URLRequest("data/config.xml"));
		}
		
		private function onLoadingConfigComplete(e:Event):void{
			var s:String = e.target.data as String;
			var xml:XML = XML(s);
			tempImgArray = new Array();
			easyImgArray = new Array();
			mediumImgArray = new Array();
			hardImgArray = new Array();
			analyseXML(xml[0].images[0].easy[0], easyImgArray);
			analyseXML(xml[0].images[0].medium[0], mediumImgArray);
			analyseXML(xml[0].images[0].hard[0], hardImgArray);
			gameTime = xml[0].gameTime;
			countDownInt = gameTime * 60;
			initStart();
		}
		
		private function analyseXML(xw:XML, imgArray:Array):void {
			for each (var xx:XML in xw.descendants("img")) {
				var imgInfo:ImgInfo = new ImgInfo();
				imgInfo.key = xx.@key;
				imgInfo.path = xx;
				imgArray.push(imgInfo);
			}
		}
		
		private function initStart():void {
			startGame_btn.addEventListener(MouseEvent.CLICK, onStartGameBtn);
			gameRule_btn.addEventListener(MouseEvent.CLICK, onGameRuleBtn);
		}
		
		private function onGameRuleBtn(e:MouseEvent):void {
			startGame_btn.removeEventListener(MouseEvent.CLICK, onStartGameBtn);
			gameRule_btn.removeEventListener(MouseEvent.CLICK, onGameRuleBtn);
			addChild(rulePanel);
			rulePanel.scaleX = 1;
			rulePanel.scaleY = 1;
			rulePanel.x = 0;
			rulePanel.y = 0;
			TweenLite.from(rulePanel, 0.5, { scaleX:0, ease:Cubic.easeOut } );
			DisObjUtil.toStageCenter(rulePanel);
			rulePanel.close_btn.addEventListener(MouseEvent.CLICK, onCloseRulePanel);
		}
		
		private function onCloseRulePanel(e:MouseEvent):void {
			rulePanel.close_btn.removeEventListener(MouseEvent.CLICK, onCloseRulePanel);
			TweenLite.to(rulePanel, 0.5, { scaleX:0, ease:Cubic.easeOut, onComplete:onCloseRulePanelComplete } );
		}
		
		private function onCloseRulePanelComplete():void {
			removeChild(rulePanel);
			startGame_btn.addEventListener(MouseEvent.CLICK, onStartGameBtn);
			gameRule_btn.addEventListener(MouseEvent.CLICK, onGameRuleBtn);
		}
		
		private function onStartGameBtn(e:MouseEvent):void {
			TweenLite.to(startGame_btn, 0.8, { y:"-20", autoAlpha:0 } );
			TweenLite.to(gameRule_btn, 0.8, { y:"-20", autoAlpha:0 } );
			TweenLite.to(title_mc, 0.8, { y:"-20", autoAlpha:0, onComplete:onStartGameBtnComplete } );
		}
		
		private function onStartGameBtnComplete():void {
			if(this.contains(startGame_btn)){
				startGame_btn.removeEventListener(MouseEvent.CLICK, onStartGameBtn);
				gameRule_btn.removeEventListener(MouseEvent.CLICK, onGameRuleBtn);
				removeChild(startGame_btn);
				removeChild(gameRule_btn);
				removeChild(title_mc);
			}
			addChild(choseDifficultyPanel);
			choseDifficultyPanel.scaleX = 1;
			choseDifficultyPanel.scaleY = 1;
			choseDifficultyPanel.x = 0;
			choseDifficultyPanel.y = 0;
			TweenLite.from(choseDifficultyPanel, 0.7, { scaleX:0, ease:Cubic.easeOut, onComplete:onChoseDifficultyPanelComplete } );
			DisObjUtil.toStageCenter(choseDifficultyPanel);
		}
		
		private function onChoseDifficultyPanelComplete():void {
			choseDifficultyPanel.easy_btn.addEventListener(MouseEvent.CLICK, onEasyBtn);
			choseDifficultyPanel.medium_btn.addEventListener(MouseEvent.CLICK, onMediumBtn);
			choseDifficultyPanel.difficulty_btn.addEventListener(MouseEvent.CLICK, onDifficultyBtn);
		}
		
		private function onEasyBtn(e:MouseEvent):void {
			tempImgArray = easyImgArray;
			diffType = "简单";
			removeChoseDifficultyPanel();
		}
		
		private function onMediumBtn(e:MouseEvent):void {
			tempImgArray = mediumImgArray;
			diffType = "中等";
			removeChoseDifficultyPanel();
		}
		
		private function onDifficultyBtn(e:MouseEvent):void {
			tempImgArray = hardImgArray;
			diffType = "困难";
			removeChoseDifficultyPanel();
		}
		
		private function removeChoseDifficultyPanel():void {
			TweenLite.to(choseDifficultyPanel, 0.5, { scaleX:0, ease:Cubic.easeOut, onComplete:startLevel } );
		}
		
		private function startLevel():void {
			if (this.contains(choseDifficultyPanel)) {
				removeChild(choseDifficultyPanel);
			}
			replay_btn.visible = true;
			replay_btn.addEventListener(MouseEvent.CLICK, onReplayBtn);
			score_mc.score_txt.text = String(playerScore);
			score_mc.visible = true;
			tip_mc.visible = true;
			countDownTimer = new Timer(1000, 0);
			countDownTimer.addEventListener(TimerEvent.TIMER, onCoundDown);
			countDownTimer.start();
			onCoundDown();
			stage.addEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrameHandler);
		}
		
		private function onMouseMoveEnterFrameHandler(e:Event):void{
			rod.gotoAndStop(22-int(stage.mouseY/17));
			if(rod.currentFrame == 22){
				onStartRod();
				tip_mc.visible = false;
				stage.removeEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrameHandler);
			}
		}
		
		private function onCoundDown(e:TimerEvent = null):void {
			score_mc.time_txt.text = transToTime(countDownInt--);
			if (countDownInt <= 0) {
				score_mc.time_txt.text = "0";
				overGame();
			}
		}
		
		private function onReplayBtn(e:MouseEvent):void{
			stage.removeEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrameHandler);
			init2();
			onStartGameBtnComplete();
		}		
		
		private function overGame():void {
			countDownTimer.stop();
			countDownTimer.removeEventListener(TimerEvent.TIMER, onCoundDown);
			gameOver();
		}
		
		private function gameOver():void {
			stage.removeEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrameHandler);
			clearTimeout(timeOutId);
			DisObjUtil.removeAllChildren(imgContainer);
			if (this.contains(answerPanel)) {
				answerPanel.answer_txt.text = "";
				answerPanel.jump_btn.removeEventListener(MouseEvent.CLICK, onJumpBtn);
				answerPanel.ok_btn.removeEventListener(MouseEvent.CLICK, onAnswerBtn);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
				removeChild(answerPanel);
			}
			replay_btn.visible = false;
			imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImgComplete);
			imgLoader.unload();
			addChild(resultPanel);
			resultPanel.scaleX = 1;
			resultPanel.scaleY = 1;
			resultPanel.x = 0;
			resultPanel.y = 0;
			DisObjUtil.toStageCenter(resultPanel);
			resultPanel.difficulty_txt.text = "难度：" + diffType;
			resultPanel.true_txt.text = "你猜对了：" + trueCount + "个字";
			resultPanel.false_txt.text = "你猜错了：" + errorCount + "个字";
			resultPanel.totalScore_txt.text = "总分：" + playerScore + "分";
			resultPanel.key_btn.addEventListener(MouseEvent.CLICK,onKeyBtn);
			resultPanel.close_btn.addEventListener(MouseEvent.CLICK, onCloseResultPanel);
			otherSoundChannel = overSound.play();
		}
		
		private function onCloseResultPanel(e:MouseEvent):void{
			TweenLite.to(resultPanel, 0.5, { scaleY:0, ease:Cubic.easeOut, onComplete:onCloseResultPanelComplete } );
		}
		
		private function onCloseResultPanelComplete():void {
			resultPanel.key_btn.removeEventListener(MouseEvent.CLICK, onKeyBtn);
			resultPanel.close_btn.removeEventListener(MouseEvent.CLICK, onCloseResultPanel);
			removeChild(resultPanel);
			init2();
			onStartGameBtnComplete();
		}
		
		private function onKeyBtn(e:MouseEvent):void{
			tip_mc.visible = false;
			DisObjUtil.removeAllChildren(imgContainer);
			addChild(imgContainer);
			rod.gotoAndStop(22);
			rod.fish.gotoAndStop(int(Math.random() * 8) + 1);
			score_mc.visible = false;
			replay_btn.visible = false;
			if(countDownTimer!=null){
				countDownTimer.addEventListener(TimerEvent.TIMER, onCoundDown);
				countDownTimer.stop();
			}
			if(this.contains(answerPanel)){
				answerPanel.answer_txt.text = "";
				answerPanel.ok_btn.removeEventListener(MouseEvent.CLICK, onAnswerBtn);
				answerPanel.jump_btn.removeEventListener(MouseEvent.CLICK,onJumpBtn);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDownHandler);
				removeChild(answerPanel);
			}
			clearTimeout(timeOutId);
			stage.removeEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrameHandler);
			TweenLite.to(resultPanel, 0.5, { scaleY:0, ease:Cubic.easeOut, onComplete:onAddKeyPanel } );
		}
		
		private function onAddKeyPanel():void{
			removeChild(resultPanel);
			keyPanel = new KeyPanel();
			addChild(keyPanel);
			keyPanel.x = 320;
			keyPanel.y = 200;
			keyPanel.close_btn.addEventListener(MouseEvent.CLICK,onCloseKeyPanel);
			loadJpg();
			pt = new PageTurner(ptHandler,4,keyPanel.prev_btn,keyPanel.next_btn,keyPanel.page_txt);
			pt.update(sbArray);
		}
		
		private function loadJpg():void{
			for(var i:int=0;i<disoArray.length;i++){
				var k:Object = new Object();
				k.intt = i+1;
				k.pic = disoArray[i];
				k.dc = userArray[i];
				k.trueChar = keyCharArray[i];
				sbArray.push(k);
			}
		}
		
		private function ptHandler(arr:Array):void {
			clearItems();
			for (var j:int = 0; j < arr.length; j++) {
				var item:KeyItem = new KeyItem(arr[j].intt,arr[j].pic,arr[j].dc,arr[j].trueChar);
				item.x = 140;
				item.y = 60 + j * 80;
				addChild(item);
				itemList.push(item);
			}
		}
		
		private function clearItems():void {
			for (var i:int = 0; i < itemList.length; i++) {
				var i1:KeyItem=itemList[i];
				if(this.contains(i1)){
		   			removeChild(i1);
				}
			}
		}
		
		private function onCloseKeyPanel(e:MouseEvent):void{
			clearItems();
			TweenLite.to(keyPanel, 0.5, { scaleY:0, ease:Cubic.easeOut, onComplete:onCloseKeyPanelComplete } );
		}
		
		private function onCloseKeyPanelComplete():void{
			keyPanel.close_btn.removeEventListener(MouseEvent.CLICK,onCloseKeyPanel);
			removeChild(keyPanel);
			init2();
			onStartGameBtnComplete();
		}
		
		private function transToTime(waitTime:Number):String {
			var m:int = Math.floor(waitTime / 60);
			var s:int = waitTime - m * 60;
			var ms:String = (m + "").length > 1 ? m + "" : m + "";
			var ss:String = (s + "").length > 1 ? s + "" : "0" + s + "";
			return ms + "分" + ss + "秒";
		} 
		
		private function onStartRod():void {
			stage.removeEventListener(Event.ENTER_FRAME, onMouseMoveEnterFrameHandler);
			otherSoundChannel = fishSound.play();
			addChild(loadingCircle);
			DisObjUtil.toStageCenter(loadingCircle);
			loadImg();
		}
		
		private function loadImg():void {
			var i:int = int(Math.random() * tempImgArray.length);
			randomArray.push(i);
			currentImgInfo = tempImgArray[i];
			keyCharArray.push(currentImgInfo.key);
			tempImgArray.splice(i, 1);
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadImgComplete);
			var s:String = "images/" + currentImgInfo.path;
			imgLoader.load(new URLRequest(s));
		}
		
		private function onLoadImgComplete(e:Event):void {
			imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImgComplete);
			if(this.contains(loadingCircle)){
				removeChild(loadingCircle);
			}
			var diso:DisplayObject = e.target.content as DisplayObject;
			imgContainer.addChild(diso);
			imgContainer.x = 0;
			imgContainer.y = 0;
			disoArray.push(diso);
			diso.width = 280;
			diso.height = 280;
			diso.x = -diso.width / 2;
			diso.y = -diso.height / 2;
			var glow:GlowFilter = new GlowFilter();
			glow.color = 0x009922;
			glow.alpha = 1;
			glow.blurX = 25;
			glow.blurY = 25;
			glow.strength = 1.2;
			glow.quality = BitmapFilterQuality.LOW;
			diso.filters = [glow];
			DisObjUtil.toStageCenter(imgContainer);
			imgContainer.y -= 65;
			TweenLite.from(imgContainer, 1, { alpha:0, scaleX:0, scaleY:0, ease:Cubic.easeOut } );
			timeOutId = setTimeout(addAnswerPanel, 1000);
		}
		
		private function addAnswerPanel():void {
			clearTimeout(timeOutId);
			addChild(answerPanel);
			answerPanel.x = 317;
			answerPanel.y = 400;
			answerPanel.answer_txt.restrict = "\u4E00-\u9FA5";
			answerPanel.answer_txt.text = "";
			stage.focus = answerPanel.answer_txt;
			TweenLite.from(answerPanel, 0.5, { y:"30", ease:Cubic.easeOut } );
			answerPanel.ok_btn.addEventListener(MouseEvent.CLICK, onAnswerBtn);
			answerPanel.jump_btn.addEventListener(MouseEvent.CLICK, onJumpBtn);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
		}
		
		private function onKeyDownHandler(e:KeyboardEvent):void {
			if (e.keyCode == 13) {
				onAnswerBtn();
			}
		}
		
		private var tempErrorCount:int = 0;
		private function onAnswerBtn(e:MouseEvent = null):void{
			if(answerPanel.answer_txt.text == currentImgInfo.key){
				answerPanel.true_mc.gotoAndPlay(2);
				timeOutId = setTimeout(nextWord, 1000);
				playerScore += 10;
				userArray.push(true);
				trueCount++;
				addScore_mc.gotoAndPlay(2);
				score_mc.score_txt.text = String(playerScore);
				answerPanel.answer_txt.text = "";
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
				answerPanel.ok_btn.removeEventListener(MouseEvent.CLICK, onAnswerBtn);
				answerPanel.jump_btn.removeEventListener(MouseEvent.CLICK, onJumpBtn);
				otherSoundChannel = trueSound.play();
				tempErrorCount = 0;
			}else{
				tempErrorCount++;
				answerPanel.false_mc.gotoAndPlay(2);
				answerPanel.answer_txt.text = "";
				otherSoundChannel = errorSound.play();
				if (tempErrorCount >= 3) {
					userArray.push(false);
					tempErrorCount = 0;
					errorCount++;
					answerPanel.answer_txt.text = "";
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
					answerPanel.ok_btn.removeEventListener(MouseEvent.CLICK, onAnswerBtn);
					answerPanel.jump_btn.removeEventListener(MouseEvent.CLICK, onJumpBtn);
					answerPanel.false_mc.gotoAndPlay(2);
					answerPanel.false_mc.addEventListener(Event.ENTER_FRAME, onFalseMc);
				}
			}
		}
		
		private function onFalseMc(e:Event):void {
			if (e.target.currentFrame == 22) {
				answerPanel.false_mc.removeEventListener(Event.ENTER_FRAME, onFalseMc);
				nextWord();
			}
		}
		
		private function onJumpBtn(e:MouseEvent):void{
			errorCount++;
			userArray.push(false);;
			nextWord();
		}		
		
		private function nextWord():void {
			clearTimeout(timeOutId);
			DisObjUtil.removeAllChildren(imgContainer);
			if (this.contains(answerPanel)) {
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
				answerPanel.ok_btn.removeEventListener(MouseEvent.CLICK, onAnswerBtn);
				answerPanel.jump_btn.removeEventListener(MouseEvent.CLICK, onJumpBtn);
				removeChild(answerPanel);
			}
			if (tempImgArray.length == 0) {
				overGame();
				if(this.contains(loadingCircle)){
					removeChild(loadingCircle);
				}
				return;
			}
			rod.fish.gotoAndStop(int(Math.random() * 8) + 1);
			rod.gotoAndStop(22);
			stage.addEventListener(Event.ENTER_FRAME,onMouseMoveEnterFrameHandler);
		}
	}
}
